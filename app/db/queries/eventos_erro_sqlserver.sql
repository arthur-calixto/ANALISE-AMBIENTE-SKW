SELECT TOP 30
    DESCRICAO,
    TIPO,
    ENTIDADE,
    SUM(QTDCOLETA)                                                        AS EXECUCOES,
    SUM(QTDERROS)                                                         AS ERROS,
    ROUND(SUM(TEMPOTOTAL) * 1.0 / NULLIF(SUM(QTDCOLETA), 0) / 1000.0, 2) AS TEMPO_MEDIO_SEGUNDOS,
    ROUND(SUM(TEMPOTOTAL) / 1000.0, 2)                                    AS TEMPO_TOTAL_SEGUNDOS,
    MAX(DHEXECUCAO)                                                       AS ULTIMA_EXECUCAO,
    CASE WHEN SUM(QTDERROS) > 0 THEN 'alerta' ELSE 'ok' END               AS STATUS
FROM TSITCM
WHERE DHEXECUCAO >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))   -- últimos 7 dias, ajustável
GROUP BY DESCRICAO, TIPO, ENTIDADE
ORDER BY TEMPO_MEDIO_SEGUNDOS DESC