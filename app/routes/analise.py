from pathlib import Path

from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates

from app import db
from app.checks import CHECKS
from app.session import InvalidSessionId, SessionNotFound, load_credentials

router = APIRouter(prefix="/analise", tags=["analise"])

templates_dir = Path(__file__).resolve().parent.parent / "templates"
templates = Jinja2Templates(directory=str(templates_dir))

QUERIES_DIR = Path(__file__).resolve().parent.parent / "db" / "queries"


def _load_sql(check_id: str, db_type: str) -> str:
    path = QUERIES_DIR / f"{check_id}_{db_type}.sql"
    if not path.exists():
        raise FileNotFoundError(f"Query não encontrada para '{check_id}' ({db_type})")
    return path.read_text(encoding="utf-8")


@router.get("/{session_id}", response_class=HTMLResponse)
def tela_analise(request: Request, session_id: str):
    try:
        credentials = load_credentials(session_id)
    except (SessionNotFound, InvalidSessionId) as exc:
        return templates.TemplateResponse(
            "erro.html",
            {"request": request, "mensagem": str(exc)},
            status_code=404,
        )

    checks_json = [
        {"id": c.id, "titulo": c.titulo, "exibicao": c.exibicao.value} for c in CHECKS
    ]

    return templates.TemplateResponse(
        "dashboard.html",
        {
            "request": request,
            "session_id": session_id,
            "cliente_id": credentials.get("cliente_id"),
            "db_type": credentials.get("db_type"),
            "checks": checks_json,
        },
    )


@router.post("/{session_id}/executar")
def executar_analise(session_id: str):
    try:
        credentials = load_credentials(session_id)
    except (SessionNotFound, InvalidSessionId) as exc:
        return JSONResponse({"erro": str(exc)}, status_code=404)

    db_type = credentials["db_type"]
    resultados = {}

    for check in CHECKS:
        try:
            sql = _load_sql(check.id, db_type)
            resultados[check.id] = db.run_query(credentials, sql)
        except Exception as exc:
            resultados[f"{check.id}_erro"] = str(exc)

    return JSONResponse(resultados)
