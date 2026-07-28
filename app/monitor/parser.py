import re
from dataclasses import dataclass


@dataclass
class RegistroConsulta:
    id: str
    tempo_ms: int
    application: str | None
    resource_id: str | None
    uri: str | None
    sql: str


def parse_consulta_log(content: str) -> list[RegistroConsulta]:
    """
    Parseia o Monitor_Consulta.log do monitor de consulta do Sankhya.
    Formato: blocos separados por "##ID_<n>##", cada um com o tempo de
    execução (ms), opcionalmente um comentário Runtime-info
    (Application/ResourceID/uri) e o SQL + Params.
    """
    parts = re.split(r"##ID_(\d+)##", content)
    registros: list[RegistroConsulta] = []

    # parts[0] é lixo antes do primeiro ID; depois alterna [id, bloco, id, bloco, ...]
    for i in range(1, len(parts), 2):
        id_ = parts[i]
        bloco = parts[i + 1]

        m_tempo = re.search(r"tempo:\s*(\d+)\s*\(ms\)", bloco)
        if not m_tempo:
            continue
        tempo_ms = int(m_tempo.group(1))

        m_app = re.search(r"Application:\s*(.+)", bloco)
        m_resource = re.search(r"ResourceID:\s*(.+)", bloco)
        m_uri = re.search(r"uri:\s*(.+)", bloco)

        sql_parte = bloco.split("Params:")[0]
        sql_parte = re.sub(r"/\*\s*Runtime-info.*?\*/", "", sql_parte, flags=re.S)
        sql_parte = re.sub(r"^\s*tempo:\s*\d+\s*\(ms\)", "", sql_parte)
        sql_parte = sql_parte.strip("-\r\n \t")

        registros.append(
            RegistroConsulta(
                id=id_,
                tempo_ms=tempo_ms,
                application=m_app.group(1).strip() if m_app else None,
                resource_id=m_resource.group(1).strip() if m_resource else None,
                uri=m_uri.group(1).strip() if m_uri else None,
                sql=sql_parte,
            )
        )

    return registros


def top_queries(registros: list[RegistroConsulta], limite: int = 30) -> list[dict]:
    ordenados = sorted(registros, key=lambda r: r.tempo_ms, reverse=True)[:limite]
    return [
        {
            "ID": r.id,
            "TEMPO_MS": r.tempo_ms,
            "APPLICATION": r.application or "-",
            "RESOURCE_ID": r.resource_id or "-",
            "SQL": (r.sql[:200] + "...") if len(r.sql) > 200 else r.sql,
        }
        for r in ordenados
    ]


def top_processos(registros: list[RegistroConsulta], limite: int = 30) -> list[dict]:
    """
    Agrega por Application + ResourceID (o "processo" de negócio que
    disparou as queries), somando tempo total e contando execuções.
    """
    agregados: dict[tuple[str, str], dict] = {}

    for r in registros:
        chave = (r.application or "-", r.resource_id or "-")
        if chave not in agregados:
            agregados[chave] = {"qtd": 0, "tempo_total": 0, "tempo_max": 0}
        ag = agregados[chave]
        ag["qtd"] += 1
        ag["tempo_total"] += r.tempo_ms
        ag["tempo_max"] = max(ag["tempo_max"], r.tempo_ms)

    linhas = []
    for (application, resource_id), ag in agregados.items():
        linhas.append(
            {
                "TITULO": f"{application} — {resource_id}",
                "CONTAGEM": ag["qtd"],
                "DETALHE": (
                    f"tempo total: {ag['tempo_total']} ms · "
                    f"média: {round(ag['tempo_total'] / ag['qtd'], 1)} ms · "
                    f"máx: {ag['tempo_max']} ms"
                ),
                "_tempo_total": ag["tempo_total"],
            }
        )

    linhas.sort(key=lambda l: l["_tempo_total"], reverse=True)
    for l in linhas:
        del l["_tempo_total"]
    return linhas[:limite]
