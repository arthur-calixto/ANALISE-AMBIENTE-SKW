SELECT 'CALCCUSTOASSINC' AS PARAMETRO,
       '= 2 (Por item)' AS ESPERADO,
       COALESCE(CAST(t.INTEIRO AS VARCHAR(50)), 'Desligado (Padrão)') AS ATUAL,
       CASE
           WHEN t.INTEIRO IS NULL THEN 'alerta'
           WHEN t.INTEIRO = 2 THEN 'ok'
           ELSE 'alerta'
       END AS STATUS
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'CALCCUSTOASSINC'

UNION ALL

SELECT 'MAXRSLTSIZE',
       '<= 2000',
       COALESCE(CAST(t.INTEIRO AS VARCHAR(50)), '5000 (Padrão)'),
       CASE
           WHEN t.INTEIRO IS NULL THEN 'alerta'
           WHEN t.INTEIRO <= 2000 THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'MAXRSLTSIZE'

UNION ALL

SELECT 'REFRESHCARDS',
       '= 60',
       COALESCE(CAST(t.TEXTO AS VARCHAR(MAX)), '15 (padrão)'),
       CASE
           WHEN t.TEXTO IS NULL THEN 'alerta'
           WHEN CAST(t.TEXTO AS VARCHAR(MAX)) = '60' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'REFRESHCARDS'

UNION ALL

SELECT 'INATSESSTIMEOUT',
       '< 5',
       COALESCE(CAST(t.INTEIRO AS VARCHAR(MAX)), '0 (Padrão)'),
       CASE
           WHEN t.INTEIRO IS NULL THEN 'alerta'
           WHEN CAST(t.INTEIRO AS VARCHAR(MAX)) <= 5 THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'INATSESSTIMEOUT'

UNION ALL

SELECT 'DEBUG_ENVMSGJOB',
       '= N',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), 'Desligado (Padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'ok'
           WHEN t.LOGICO = 'N' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'DEBUG_ENVMSGJOB'

UNION ALL

SELECT 'DEBUGXMLSANNFE',
       '= N',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), 'Desligado (Padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'ok'
           WHEN t.LOGICO = 'N' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'DEBUGXMLSANNFE'

UNION ALL

SELECT 'QTDWARNPARLOAD',
       '<= 6000',
       COALESCE(CAST(t.INTEIRO AS VARCHAR(50)), 'não definido (sem padrão conhecido)'),
       CASE
           WHEN t.INTEIRO IS NULL THEN 'indefinido'
           WHEN t.INTEIRO <= 6000 THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'QTDWARNPARLOAD'

UNION ALL

SELECT 'DIASVENCTFILE',
       '<= 5',
       COALESCE(CAST(t.INTEIRO AS VARCHAR(50)), 'não definido (sem padrão conhecido)'),
       CASE
           WHEN t.INTEIRO IS NULL THEN 'indefinido'
           WHEN t.INTEIRO <= 5 THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'DIASVENCTFILE'

UNION ALL

SELECT 'MAXPAGRELATORIO',
       '<= 1000',
       COALESCE(CAST(t.INTEIRO AS VARCHAR(50)), 'não definido (sem padrão conhecido)'),
       CASE
           WHEN t.INTEIRO IS NULL THEN 'indefinido'
           WHEN t.INTEIRO <= 1000 THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'MAXPAGRELATORIO'

UNION ALL
/*
SELECT 'GERECDCACHE',
       '= S',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), 'N (padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'alerta'
           WHEN t.LOGICO = 'S' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'GERECDCACHE'

UNION ALL*/

SELECT 'GEREMAILMDDEBUG',
       '= N',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), 'N (padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'ok'
           WHEN t.LOGICO = 'N' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'GEREMAILMDDEBUG'

UNION ALL

SELECT 'HABCOLTELPRO',
       '= N',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), '= S (Padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'alerta'
           WHEN t.LOGICO = 'N' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'HABCOLTELPRO'

UNION ALL

SELECT 'HABILITATEAPP',
       '= N',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), 'N (padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'ok'
           WHEN t.LOGICO = 'N' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'HABILITATEAPP'

UNION ALL

SELECT 'HABILITATELPRO',
       '= N',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), 'N (padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'ok'
           WHEN t.LOGICO = 'N' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'HABILITATELPRO'

UNION ALL

SELECT 'ENBLMONBD',
       '= N',
       COALESCE(CAST(t.LOGICO AS VARCHAR(50)), 'N (padrão)'),
       CASE
           WHEN t.LOGICO IS NULL THEN 'ok'
           WHEN t.LOGICO = 'N' THEN 'ok'
           ELSE 'alerta'
       END
FROM (VALUES (1)) AS DUAL(N)
LEFT JOIN TSIPAR t
    ON t.CHAVE = 'ENBLMONBD'

ORDER BY 1