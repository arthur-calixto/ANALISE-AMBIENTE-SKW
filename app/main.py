import uvicorn
from fastapi import FastAPI

from app.config import settings
from app.routes import analise, monitor

app = FastAPI(title="Análise de Ambiente Sankhya")
app.include_router(analise.router)
app.include_router(monitor.router)


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
