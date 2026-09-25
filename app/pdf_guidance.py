"""Textos curtos do relatório, alinhados às consultas do projeto."""

GUIAS = {
    "locks": (
        "Bloqueios no banco de dados",
        "Identifica sessões que aguardam outra sessão liberar um recurso do banco, no momento da coleta.",
        "Verificar se a espera persiste e identificar o processamento que bloqueia antes de interromper qualquer sessão.",
    ),
    "nivel_personalizacao": (
        "Nível de personalização",
        "Apresenta os recursos personalizados e os indicadores calculados pela análise. Mais personalizações não significam, por si só, falha ou lentidão.",
        "Revisar os recursos de maior relevância e sua necessidade com a equipe responsável.",
    ),
    "parametros": (
        "Parâmetros do ambiente",
        "Compara configurações com as referências desta ferramenta. Uma divergência pede revisão, não alteração automática.",
        "Validar as necessidades do ambiente e os impactos antes de alterar os parâmetros fora da referência.",
    ),
    "api_logins": (
        "Logins de integrações",
        "Apresenta contagens de login das integrações selecionadas pela consulta com atividade recente. Não mede o número de chamadas de API.",
        "Revisar integrações com muitos logins e verificar se a autenticação pode ser reutilizada.",
    ),
    "acoes_agendadas": (
        "Ações agendadas",
        "Mostra ações automáticas encontradas na coleta, seus tempos de execução e erros registrados.",
        "Revisar ações demoradas ou com erros e avaliar seus horários de execução.",
    ),
    "eventos_erro": (
        "Eventos monitorados e erros",
        "Apresenta eventos selecionados pela consulta na janela dos últimos 7 dias, com tempos e erros registrados.",
        "Investigar os eventos com erros e verificar se o problema ainda ocorre.",
    ),
    "jobs_falhando": (
        "Rotinas automáticas e falhas",
        "Lista rotinas ativas selecionadas pela consulta e seus contadores de falha. A lista também pode conter rotinas sem falhas.",
        "Consultar a mensagem das rotinas com falhas e confirmar a situação atual antes de reexecutá-las.",
    ),
    "triggers_log": (
        "Rotinas do banco que registram logs",
        "Localiza triggers, rotinas automáticas do banco, cujo código referencia GRAVATABLOG. A presença não comprova execução nem impacto no desempenho.",
        "Verificar se a trigger está habilitada e avaliar o volume de registros e a necessidade do log.",
    ),
}
