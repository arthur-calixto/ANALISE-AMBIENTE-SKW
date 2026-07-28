SELECT *
FROM (
    SELECT
        s.sql_id,
        ROUND(s.elapsed_time / 1000000, 2)        AS TEMPO_TOTAL_SEG,
        s.executions                                AS EXECUCOES,
        ROUND(s.elapsed_time / NULLIF(s.executions, 0) / 1000, 2) AS TEMPO_MEDIO_MS,
        ROUND(s.buffer_gets / NULLIF(s.executions, 0), 0)         AS BUFFER_GETS_MEDIO,
        SUBSTR(s.sql_text, 1, 200)                  AS SQL_TEXTO,
        CASE WHEN s.elapsed_time / NULLIF(s.executions, 0) / 1000 > 1000 THEN 'alerta' ELSE 'ok' END AS STATUS
    FROM v$sql s
    WHERE s.executions > 0
    ORDER BY s.elapsed_time DESC
)
WHERE ROWNUM <= 20
