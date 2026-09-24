SELECT
    tr.name                                                        AS TRIGGER_NAME,
    OBJECT_NAME(tr.parent_id)                                      AS TABLE_NAME,
    STUFF((
        SELECT ' OR ' + te.type_desc
        FROM sys.trigger_events te
        WHERE te.object_id = tr.object_id
        FOR XML PATH('')
    ), 1, 4, '')                                                   AS TRIGGERING_EVENT,
    CASE WHEN tr.is_disabled = 1 THEN 'DISABLED' ELSE 'ENABLED' END AS TRIGGER_STATUS,
    CASE
        WHEN OBJECT_NAME(tr.parent_id) IN ('TGFCAB', 'TGFITE', 'TGFFIN', 'TGFVAR') THEN 'alerta'
        ELSE 'ok'
    END AS STATUS
FROM sys.triggers tr
JOIN sys.sql_modules m ON m.object_id = tr.object_id
WHERE UPPER(m.definition) LIKE '%GRAVATABLOG%'
  AND tr.parent_class = 1
ORDER BY STATUS DESC, TABLE_NAME;