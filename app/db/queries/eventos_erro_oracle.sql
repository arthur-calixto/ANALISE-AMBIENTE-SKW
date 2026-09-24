SELECT
    DESCRICAO,
    TIPO,
    ENTIDADE,
    SUM(QTDCOLETA)                                                        AS EXECUCOES,
    SUM(QTDERROS)                                                         AS ERROS,
    ROUND(SUM(TEMPOTOTAL) / NULLIF(SUM(QTDCOLETA), 0) / 1000, 2)          AS TEMPO_MEDIO_SEGUNDOS,
    ROUND(SUM(TEMPOTOTAL) / 1000, 2)                                      AS TEMPO_TOTAL_SEGUNDOS,
    MAX(DHEXECUCAO)                                                       AS ULTIMA_EXECUCAO,
    CASE WHEN SUM(QTDERROS) > 0 THEN 'alerta' ELSE 'ok' END               AS STATUS
FROM TSITCM
WHERE DHEXECUCAO >= TRUNC(SYSDATE) - 7   -- últimos 7 dias, ajustável
GROUP BY DESCRICAO, TIPO, ENTIDADE
ORDER BY TEMPO_MEDIO_SEGUNDOS DESC
FETCH FIRST 30 ROWS ONLY