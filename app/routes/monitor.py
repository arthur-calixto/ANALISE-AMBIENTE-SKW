import io
import zipfile
from pathlib import Path

from fastapi import APIRouter, File, Request, UploadFile
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates

from app.monitor.parser import parse_consulta_log, top_processos, top_queries

router = APIRouter(prefix="/monitor", tags=["monitor"])

templates_dir = Path(__file__).resolve().parent.parent / "templates"
templates = Jinja2Templates(directory=str(templates_dir))

NOME_ARQUIVO_CONSULTA = "Monitor_Consulta.log"


@router.get("", response_class=HTMLResponse)
def tela_upload(request: Request):
    return templates.TemplateResponse("monitor.html", {"request": request})


@router.post("/analisar")
async def analisar_monitor(arquivo: UploadFile = File(...)):
    conteudo_zip = await arquivo.read()

    try:
        with zipfile.ZipFile(io.BytesIO(conteudo_zip)) as zf:
            nomes = zf.namelist()
            candidato = next(
                (n for n in nomes if n.endswith(NOME_ARQUIVO_CONSULTA)), None
            )
            if candidato is None:
                return JSONResponse(
                    {"erro": f"'{NOME_ARQUIVO_CONSULTA}' não encontrado no zip. Arquivos: {nomes}"},
                    status_code=400,
                )
            conteudo_log = zf.read(candidato).decode("utf-8", errors="replace")
    except zipfile.BadZipFile:
        return JSONResponse({"erro": "Arquivo enviado não é um zip válido."}, status_code=400)

    registros = parse_consulta_log(conteudo_log)
    if not registros:
        return JSONResponse(
            {"erro": "Nenhum registro reconhecido no Monitor_Consulta.log — formato inesperado?"},
            status_code=422,
        )

    return JSONResponse(
        {
            "total_registros": len(registros),
            "tempo_total_ms": sum(r.tempo_ms for r in registros),
            "top_queries": top_queries(registros),
            "top_processos": top_processos(registros),
        }
    )
