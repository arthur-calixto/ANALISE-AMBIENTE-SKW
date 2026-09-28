import re
import subprocess
import tempfile
import unittest
from pathlib import Path

from app.pdf_report import gerar_relatorio_pdf, _resultado
from app.pdf_guidance import GUIAS
from app.checks import CHECKS


class RelatorioTests(unittest.TestCase):
    def test_todas_as_evidencias_tem_descricao(self):
        self.assertTrue({c.id for c in CHECKS}.issubset(GUIAS))

    def test_distingue_ausencia_erro_e_resultado_vazio(self):
        self.assertIn("resultado não recebido", _resultado("locks", {}))
        self.assertIn("erro na coleta", _resultado("locks", {"locks_erro": "falhou"}))
        self.assertIn("Sem ocorrências", _resultado("locks", {"locks": []}))
        self.assertIn("sem classificação", _resultado("locks", {"locks": [{"SID": 1}]}))

    def test_sumario_paginado_links_e_escape(self):
        meta = [{"id": "locks", "titulo": "Locks", "exibicao": "tabela"},
                {"id": "parametros", "titulo": "Parâmetros", "exibicao": "cards"}]
        rows = {"locks": [{"SID": i, "SQL": "select '<b>x</b>' & valor", "LONGO": "x" * 500}
                          for i in range(60)],
                "parametros": [{"PARAMETRO": "MAXRSLTSIZE", "ATUAL": "<2000 & >100", "STATUS": "alerta"}]}
        pdf = gerar_relatorio_pdf("Cliente <exemplo> & teste", "Oracle", meta, rows).getvalue()
        self.assertGreaterEqual(pdf.count(b"/Subtype /Link"), 4)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "test.pdf"
            path.write_bytes(pdf)
            text = subprocess.check_output(["pdftotext", "-layout", str(path), "-"]).decode()
        pages = text.split("\f")
        self.assertIn("Cliente <exemplo> & teste", pages[0])
        self.assertIn("Sumário", pages[1])
        self.assertIn("[abreviado]", text)
        self.assertIn("<b>x</b>", text)
        for title in ["1. Bloqueios no banco de dados", "2. Parâmetros do ambiente"]:
            match = re.search(re.escape(title) + r"[^\n]*?(\d+)\s*$", pages[1], re.M)
            self.assertIsNotNone(match)
            self.assertIn(title, pages[int(match.group(1)) - 1])

    def test_acoes_agendadas_tabela_continua(self):
        from unittest.mock import patch
        from app import pdf_report
        rows = [{"NUAAG": i, "STATUS_ACAO": "S", "EXPGATILHO": "0 0/5 * * * ?",
                 "ACAO": "RotinaJava", "DESCRICAO": f"ACAOEXEMPLO{i:03d}",
                 "TEMPO_MEDIO_SEGUNDOS": 8.4, "ULTIMA_EXECUCAO": "28/09/2026 10:00",
                 "TOTAL_ERROS": 2, "STATUS": "alerta"} for i in range(60)]
        meta = [{"id": "acoes_agendadas", "titulo": "Ações agendadas", "exibicao": "tabela"}]
        with patch.object(pdf_report, "_tabela", wraps=pdf_report._tabela) as tables:
            pdf = gerar_relatorio_pdf("Exemplo", "Oracle", meta, {"acoes_agendadas": rows}).getvalue()
        # Resumo e uma única tabela de evidências, em vez de uma tabela por ação.
        self.assertEqual(tables.call_count, 2)
        evidence = tables.call_args
        self.assertEqual(len(evidence.args[0]), 9)
        self.assertEqual(len(evidence.args[1]), 60)
        self.assertAlmostEqual(sum(evidence.kwargs["widths"]), pdf_report.LARGURA)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "acoes.pdf"
            path.write_bytes(pdf)
            text = subprocess.check_output(["pdftotext", "-layout", str(path), "-"]).decode()
        self.assertNotIn("Registro 1", text)
        for i in range(60):
            self.assertIn(f"ACAOEXEMPLO{i:03d}", text)
        evidence_pages = [page for page in text.split("\f") if "ACAOEXEMPLO" in page]
        self.assertGreater(len(evidence_pages), 1)
        for page in evidence_pages:
            self.assertIn("Código", page)
            self.assertIn("Descrição", page)

    def test_muitas_colunas_e_erros_com_markup(self):
        meta = [{"id": "locks", "titulo": "Locks", "exibicao": "tabela"},
                {"id": "jobs_falhando", "titulo": "Jobs", "exibicao": "tabela"}]
        rows = {"locks": [{f"CAMPO_{i}": "<&>" for i in range(12)}],
                "jobs_falhando_erro": "erro <objeto> & detalhe"}
        self.assertTrue(gerar_relatorio_pdf("Exemplo", "SQL Server", meta, rows).getvalue().startswith(b"%PDF"))


if __name__ == "__main__":
    unittest.main()
