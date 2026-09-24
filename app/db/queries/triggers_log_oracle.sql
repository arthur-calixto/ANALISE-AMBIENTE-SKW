-- Localiza triggers cujo código-fonte referencia a função de log
-- (GRAVATABLOG) e sinaliza alerta quando estão em tabelas de movimento
-- (alto volume de DML = overhead de log em cada operação).
WITH TRIGGERS_COM_LOG AS (
    SELECT DISTINCT NAME AS TRIGGER_NAME
    FROM USER_SOURCE
    WHERE UPPER(TEXT) LIKE '%GRAVATABLOG%'
      AND TYPE = 'TRIGGER'
)
SELECT
    TCL.TRIGGER_NAME,
    TR.TABLE_NAME,
    TR.TRIGGERING_EVENT,
    TR.STATUS AS TRIGGER_STATUS,
    CASE
        WHEN TR.TABLE_NAME IN ('TGFCAB', 'TGFITE', 'TGFFIN', 'TGFVAR') THEN 'alerta'
        ELSE 'ok'
    END AS STATUS
FROM TRIGGERS_COM_LOG TCL
JOIN USER_TRIGGERS TR ON TR.TRIGGER_NAME = TCL.TRIGGER_NAME
ORDER BY STATUS DESC, TR.TABLE_NAME