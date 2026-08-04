import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from app.config import settings
from app.routes import analise, monitor
from app.session import listar_clientes

app = FastAPI(title="Análise de Ambiente Sankhya")
app.mount("/static", StaticFiles(directory="app/static"), name="static")
app.include_router(analise.router)
app.include_router(monitor.router)

templates = Jinja2Templates(directory="app/templates")


@app.get("/", response_class=HTMLResponse)
def tela_inicial(request: Request):
    return templates.TemplateResponse(
        "index.html", {"request": request, "clientes": listar_clientes()}
    )


@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.app_host,
        port=settings.app_port,
        reload=True,
    )
