import json
import re
from pathlib import Path

from app.config import settings

# session_id deve ser um UUID (ou similar) — validação evita path traversal
# vindo da URL (ex: "../../etc/passwd").
_SESSION_ID_RE = re.compile(r"^[a-zA-Z0-9_-]{8,64}$")


class SessionNotFound(Exception):
    pass


class InvalidSessionId(Exception):
    pass


def _validate_session_id(session_id: str) -> None:
    if not _SESSION_ID_RE.match(session_id):
        raise InvalidSessionId(f"session_id inválido: {session_id!r}")


def get_session_dir(session_id: str) -> Path:
    _validate_session_id(session_id)
    session_dir = Path(settings.shared_dir) / session_id

    # Garante que o path resolvido continua dentro do shared_dir
    # (defesa extra, além da regex acima).
    shared_root = Path(settings.shared_dir).resolve()
    resolved = session_dir.resolve()
    if shared_root not in resolved.parents and resolved != shared_root:
        raise InvalidSessionId(f"session_id fora do diretório esperado: {session_id!r}")

    return session_dir


def load_credentials(session_id: str) -> dict:
    session_dir = get_session_dir(session_id)
    credentials_path = session_dir / "credentials.json"

    if not credentials_path.exists():
        raise SessionNotFound(f"Sessão não encontrada: {session_id!r}")

    with open(credentials_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    required_fields = {"cliente_id", "db_type"}
    missing = required_fields - data.keys()
    if missing:
        raise ValueError(f"credentials.json incompleto, faltando: {missing}")

    return data
