SELECT *
FROM (
    SELECT
        DESCRICAO,
        TIPO,
        ENTIDADE,
        SUM(QTDCOLETA)                       AS EXECUCOES,
        SUM(QTDERROS)                        AS ERROS,
        ROUND(AVG(TEMPOMEDIO), 0)            AS TEMPO_MEDIO_MS,
        SUM(TEMPOTOTAL)                      AS TEMPO_TOTAL_MS,
        MAX(DHEXECUCAO)                      AS ULTIMA_EXECUCAO,
        CASE WHEN SUM(QTDERROS) > 0 THEN 'alerta' ELSE 'ok' END AS STATUS
    FROM TSITCM
    WHERE DHEXECUCAO >= TRUNC(SYSDATE) - 7   -- últimos 7 dias, ajustável
    GROUP BY DESCRICAO, TIPO, ENTIDADE
    ORDER BY ERROS DESC, EXECUCOES DESC
)
WHERE ROWNUM <= 30