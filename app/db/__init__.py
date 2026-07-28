from app.db import oracle, sqlserver

_DRIVERS = {
    "oracle": oracle,
    "sqlserver": sqlserver,
}


def run_query(credentials: dict, sql: str, params=None) -> list[dict]:
    db_type = credentials.get("db_type")
    driver = _DRIVERS.get(db_type)
    if driver is None:
        raise ValueError(f"db_type não suportado: {db_type!r}")
    return driver.run_query(credentials, sql, params or {})
