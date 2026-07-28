from dataclasses import dataclass
from enum import Enum


class Exibicao(str, Enum):
    CARDS = "cards"        # linhas com PARAMETRO / ESPERADO / ATUAL / STATUS -> card verde/vermelho/cinza
    TABELA = "tabela"      # exibição genérica em tabela
    CONTAGEM = "contagem"  # linhas com TITULO / CONTAGEM / DETALHE -> card com número grande + detalhe


@dataclass
class Check:
    id: str                # usado na URL/JSON e no nome do arquivo .sql
    titulo: str             # título exibido na seção do dashboard
    exibicao: Exibicao
    obrigatorio: bool = True  # se False, erro nesse check não quebra a análise


# Registro central: pra adicionar uma nova query, basta:
#   1) colocar o .sql em app/db/queries/<id>_<db_type>.sql
#   2) adicionar uma entrada aqui
CHECKS: list[Check] = [
    Check(id="locks", titulo="Locks", exibicao=Exibicao.TABELA),
    Check(id="nivel_personalizacao", titulo="Nível de Personalização", exibicao=Exibicao.TABELA),
    Check(id="parametros", titulo="Parâmetros do Ambiente", exibicao=Exibicao.CARDS),
    Check(id="api_logins", titulo="Logins de API (últimos 30 dias)", exibicao=Exibicao.CONTAGEM),
    Check(id="acoes_agendadas", titulo="Ações Agendadas", exibicao=Exibicao.TABELA),
    Check(id="eventos_erro", titulo="Eventos com Mais Erro (últimos 7 dias)", exibicao=Exibicao.TABELA),
    Check(id="jobs_falhando", titulo="Jobs/Rotinas com Falha", exibicao=Exibicao.TABELA),
]
