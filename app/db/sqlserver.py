import pyodbc

# Requer o driver ODBC instalado no host/imagem, ex:
# "ODBC Driver 18 for SQL Server" (ver Dockerfile)
DRIVER = "{ODBC Driver 18 for SQL Server}"


def get_connection(credentials: dict):
    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={credentials['host']},{credentials.get('port', 1433)};"
        f"DATABASE={credentials.get('database', '')};"
        f"UID={credentials['user']};"
        f"PWD={credentials['password']};"
        f"TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)


def run_query(credentials: dict, sql: str, params: tuple = ()) -> list[dict]:
    with get_connection(credentials) as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params)
            columns = [col[0] for col in cur.description]
            return [dict(zip(columns, row)) for row in cur.fetchall()]
