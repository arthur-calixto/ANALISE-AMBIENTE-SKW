import oracledb


def get_connection(credentials: dict):
    """
    Abre conexão Oracle usando o driver thin do python-oracledb
    (não depende de Oracle Instant Client instalado no host/container).
    """
    dsn = oracledb.makedsn(
        credentials["host"],
        credentials.get("port", 1521),
        service_name=credentials.get("service_name"),
        sid=credentials.get("sid"),
    )
    return oracledb.connect(
        user=credentials["user"],
        password=credentials["password"],
        dsn=dsn,
    )


def run_query(credentials: dict, sql: str, params: dict | None = None) -> list[dict]:
    with get_connection(credentials) as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params or {})
            columns = [col[0] for col in cur.description]
            return [dict(zip(columns, row)) for row in cur.fetchall()]
