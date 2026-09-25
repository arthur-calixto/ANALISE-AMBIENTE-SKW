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

    def test_muitas_colunas_e_erros_com_markup(self):
        meta = [{"id": "locks", "titulo": "Locks", "exibicao": "tabela"},
                {"id": "jobs_falhando", "titulo": "Jobs", "exibicao": "tabela"}]
        rows = {"locks": [{f"CAMPO_{i}": "<&>" for i in range(12)}],
                "jobs_falhando_erro": "erro <objeto> & detalhe"}
        self.assertTrue(gerar_relatorio_pdf("Exemplo", "SQL Server", meta, rows).getvalue().startswith(b"%PDF"))


if __name__ == "__main__":
    unittest.main()
