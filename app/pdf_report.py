import io
from datetime import datetime

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    PageBreak,
)

COR_ALERTA = colors.HexColor("#fca5a5")
COR_OK = colors.HexColor("#bbf7d0")
COR_INDEFINIDO = colors.HexColor("#e2e8f0")
COR_ACCENT = colors.HexColor("#0f766e")
COR_TEXTO_MUTED = colors.HexColor("#555555")


def _valor(v) -> str:
    return "" if v is None else str(v)


def _status_da_linha(row: dict) -> str:
    return str(row.get("STATUS", "")).lower()


def _tabela_generica(linhas: list[dict], styles) -> Table:
    colunas = [c for c in linhas[0].keys() if c != "STATUS"]

    largura_disponivel = 18.4 * cm
    largura_col = largura_disponivel / len(colunas)

    cabecalho = [Paragraph(f"<b>{c}</b>", styles["CelulaCabecalho"]) for c in colunas]
    dados = [cabecalho]
    cor_linhas = []
    for i, row in enumerate(linhas, start=1):
        dados.append([Paragraph(_valor(row.get(c))[:200], styles["Celula"]) for c in colunas])
        if _status_da_linha(row) == "alerta":
            cor_linhas.append(i)

    tabela = Table(dados, repeatRows=1, colWidths=[largura_col] * len(colunas))
    estilo = [
        ("BACKGROUND", (0, 0), (-1, 0), COR_ACCENT),
        ("FONTSIZE", (0, 0), (-1, -1), 7),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#dddddd")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f7f7f8")]),
    ]
    for i in cor_linhas:
        estilo.append(("BACKGROUND", (0, i), (-1, i), COR_ALERTA))
    tabela.setStyle(TableStyle(estilo))
    return tabela


def _tabela_cards(linhas: list[dict], styles) -> Table:
    dados = [["Parâmetro", "Esperado", "Atual", "Status"]]
    cores = []
    for i, row in enumerate(linhas, start=1):
        status = _status_da_linha(row) or "indefinido"
        dados.append([
            _valor(row.get("PARAMETRO")),
            _valor(row.get("ESPERADO")) or "—",
            _valor(row.get("ATUAL")),
            status.upper(),
        ])
        cores.append((i, status))

    tabela = Table(dados, repeatRows=1, colWidths=[5.5 * cm, 3.5 * cm, 4.5 * cm, 3 * cm])
    estilo = [
        ("BACKGROUND", (0, 0), (-1, 0), COR_ACCENT),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#dddddd")),
    ]
    for i, status in cores:
        cor = {"ok": COR_OK, "alerta": COR_ALERTA}.get(status, COR_INDEFINIDO)
        estilo.append(("BACKGROUND", (0, i), (-1, i), cor))
    tabela.setStyle(TableStyle(estilo))
    return tabela


def _tabela_contagem(linhas: list[dict], styles) -> Table:
    dados = [["Título", "Contagem", "Detalhe"]]
    cores = []
    for i, row in enumerate(linhas, start=1):
        status = _status_da_linha(row)
        dados.append([
            Paragraph(_valor(row.get("TITULO"))[:60], styles["Celula"]),
            _valor(row.get("CONTAGEM")),
            Paragraph(_valor(row.get("DETALHE"))[:150], styles["Celula"]),
        ])
        if status == "alerta":
            cores.append(i)

    tabela = Table(dados, repeatRows=1, colWidths=[5 * cm, 2 * cm, 9.5 * cm])
    estilo = [
        ("BACKGROUND", (0, 0), (-1, 0), COR_ACCENT),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("FONTSIZE", (0, 0), (-1, -1), 7.5),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#dddddd")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]
    for i in cores:
        estilo.append(("BACKGROUND", (0, i), (-1, i), COR_ALERTA))
    tabela.setStyle(TableStyle(estilo))
    return tabela


def gerar_relatorio_pdf(
    cliente_id: str,
    db_type: str,
    checks_meta: list[dict],
    resultados: dict,
) -> io.BytesIO:
    """
    checks_meta: [{"id": ..., "titulo": ..., "exibicao": "tabela"|"cards"|"contagem"}, ...]
    resultados: mesmo dict devolvido por /analise/{id}/executar
    """
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer, pagesize=A4,
        topMargin=1.8 * cm, bottomMargin=1.8 * cm,
        leftMargin=1.6 * cm, rightMargin=1.6 * cm,
    )

    base_styles = getSampleStyleSheet()
    styles = {
        "Titulo": ParagraphStyle("Titulo", parent=base_styles["Title"], textColor=COR_ACCENT, fontSize=18),
        "Meta": ParagraphStyle("Meta", parent=base_styles["Normal"], textColor=COR_TEXTO_MUTED, fontSize=9),
        "SecaoTitulo": ParagraphStyle("SecaoTitulo", parent=base_styles["Heading2"], fontSize=12, spaceBefore=14, spaceAfter=6),
        "Celula": ParagraphStyle("Celula", parent=base_styles["Normal"], fontSize=7.5, leading=9),
        "CelulaCabecalho": ParagraphStyle("CelulaCabecalho", parent=base_styles["Normal"], fontSize=7, leading=8.5, textColor=colors.white),
    }

    story = []
    story.append(Paragraph("Relatório de Análise de Ambiente", styles["Titulo"]))
    story.append(Spacer(1, 4))
    agora = datetime.now().strftime("%d/%m/%Y às %H:%M")
    story.append(Paragraph(f"Cliente: <b>{cliente_id}</b> &nbsp;·&nbsp; Banco: <b>{db_type}</b> &nbsp;·&nbsp; Gerado em {agora}", styles["Meta"]))
    story.append(Spacer(1, 10))

    # ------------------------------------------------------------ resumo
    total_ok = total_alerta = total_indef = 0
    for check in checks_meta:
        linhas = resultados.get(check["id"]) or []
        for row in linhas:
            s = _status_da_linha(row)
            if s == "ok":
                total_ok += 1
            elif s == "alerta":
                total_alerta += 1
            elif s == "indefinido":
                total_indef += 1

    resumo = Table(
        [["Em alerta", "Sem baseline", "OK"], [str(total_alerta), str(total_indef), str(total_ok)]],
        colWidths=[5 * cm, 5 * cm, 5 * cm],
    )
    resumo.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#f0f0f0")),
        ("FONTSIZE", (0, 0), (-1, 0), 9),
        ("FONTSIZE", (0, 1), (-1, 1), 16),
        ("FONTNAME", (0, 1), (-1, 1), "Helvetica-Bold"),
        ("TEXTCOLOR", (0, 1), (0, 1), colors.HexColor("#b91c1c")),
        ("TEXTCOLOR", (2, 1), (2, 1), colors.HexColor("#15803d")),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#dddddd")),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
    ]))
    story.append(resumo)
    story.append(Spacer(1, 6))

    # ------------------------------------------------------------ seções
    for check in checks_meta:
        erro = resultados.get(f"{check['id']}_erro")
        linhas = resultados.get(check["id"])

        story.append(Paragraph(check["titulo"], styles["SecaoTitulo"]))

        if erro:
            story.append(Paragraph(f"<font color='#b91c1c'>Erro: {erro}</font>", styles["Meta"]))
            continue

        if not linhas:
            story.append(Paragraph("Nenhum resultado.", styles["Meta"]))
            continue

        if check["exibicao"] == "cards":
            story.append(_tabela_cards(linhas, styles))
        elif check["exibicao"] == "contagem":
            story.append(_tabela_contagem(linhas, styles))
        else:
            story.append(_tabela_generica(linhas, styles))

    doc.build(story)
    buffer.seek(0)
    return buffer