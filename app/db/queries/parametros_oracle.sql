SELECT 'CALCCUSTOASSINC' AS PARAMETRO, '= 2' AS ESPERADO,
       COALESCE(TO_CHAR(t.INTEIRO), 'não definido (sem padrão conhecido)') AS ATUAL,
       CASE WHEN t.INTEIRO IS NULL THEN 'indefinido'
            WHEN t.INTEIRO = 2 THEN 'ok' ELSE 'alerta' END AS STATUS
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'CALCCUSTOASSINC'
UNION ALL
SELECT 'MAXRSLTSIZE', '<= 2000',
       COALESCE(TO_CHAR(t.INTEIRO), 'não definido (sem padrão conhecido)'),
       CASE WHEN t.INTEIRO IS NULL THEN 'indefinido'
            WHEN t.INTEIRO <= 2000 THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'MAXRSLTSIZE'
UNION ALL
-- padrão conhecido = 15 (comentário original), que diverge do esperado (60)
SELECT 'REFRESHCARDS', '= 60',
       COALESCE(TO_CHAR(t.TEXTO), '15 (padrão)'),
       CASE WHEN t.TEXTO IS NULL THEN 'alerta'  -- padrão (15) != esperado (60)
            WHEN t.TEXTO = '60' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'REFRESHCARDS'
UNION ALL
SELECT 'INATSESSTIMEOUT', '= 5',
       COALESCE(TO_CHAR(t.TEXTO), 'não definido (sem padrão conhecido)'),
       CASE WHEN t.TEXTO IS NULL THEN 'indefinido'
            WHEN t.TEXTO = '5' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'INATSESSTIMEOUT'
UNION ALL
SELECT 'DEBUG_ENVMSGJOB', '= N',
       COALESCE(TO_CHAR(t.LOGICO), 'N(padrão)'),
       CASE WHEN t.LOGICO IS NULL THEN 'ok'
            WHEN t.LOGICO = 'N' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'DEBUG_ENVMSGJOB'
UNION ALL
SELECT 'DEBUGXMLSANNFE', '= N',
       COALESCE(TO_CHAR(t.LOGICO), 'N (padrão)'),
       CASE WHEN t.LOGICO IS NULL THEN 'ok'
            WHEN t.LOGICO = 'N' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'DEBUGXMLSANNFE'
UNION ALL
SELECT 'QTDWARNPARLOAD', '<= 6000',
       COALESCE(TO_CHAR(t.INTEIRO), 'não definido (sem padrão conhecido)'),
       CASE WHEN t.INTEIRO IS NULL THEN 'indefinido'
            WHEN t.INTEIRO <= 6000 THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'QTDWARNPARLOAD'
UNION ALL
SELECT 'DIASVENCTFILE', '<= 5',
       COALESCE(TO_CHAR(t.INTEIRO), 'não definido (sem padrão conhecido)'),
       CASE WHEN t.INTEIRO IS NULL THEN 'indefinido'
            WHEN t.INTEIRO <= 5 THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'DIASVENCTFILE'
UNION ALL
SELECT 'MAXPAGRELATORIO', '<= 200',
       COALESCE(TO_CHAR(t.INTEIRO), 'não definido (sem padrão conhecido)'),
       CASE WHEN t.INTEIRO IS NULL THEN 'indefinido'
            WHEN t.INTEIRO <= 200 THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'MAXPAGRELATORIO'
UNION ALL
-- padrão conhecido = 'N' (comentário original), que diverge do esperado ('S')
SELECT 'GERECDCACHE', '= S',
       COALESCE(TO_CHAR(t.LOGICO), 'N (padrão)'),
       CASE WHEN t.LOGICO IS NULL THEN 'alerta'  -- padrão (N) != esperado (S)
            WHEN t.LOGICO = 'S' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'GERECDCACHE'
UNION ALL
SELECT 'GEREMAILMDDEBUG', '= N',
       COALESCE(TO_CHAR(t.LOGICO), 'N (padrão)'),
       CASE WHEN t.LOGICO IS NULL THEN 'ok'  -- padrão (N) == esperado (N)
            WHEN t.LOGICO = 'N' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'GEREMAILMDDEBUG'
UNION ALL
SELECT 'HABCOLTELPRO', '= N',
       COALESCE(TO_CHAR(t.LOGICO), 'não definido (sem padrão conhecido)'),
       CASE WHEN t.LOGICO IS NULL THEN 'indefinido'
            WHEN t.LOGICO = 'N' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'HABCOLTELPRO'
UNION ALL
SELECT 'HABILITATEAPP', '= N',
       COALESCE(TO_CHAR(t.LOGICO), 'N (padrão)'),
       CASE WHEN t.LOGICO IS NULL THEN 'ok'  -- padrão (N) == esperado (N)
            WHEN t.LOGICO = 'N' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'HABILITATEAPP'
UNION ALL
SELECT 'HABILITATELPRO', '= N',
       COALESCE(TO_CHAR(t.LOGICO), 'N (padrão)'),
       CASE WHEN t.LOGICO IS NULL THEN 'ok'  -- padrão (N) == esperado (N)
            WHEN t.LOGICO = 'N' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'HABILITATELPRO'
UNION ALL
SELECT 'ENBLMONBD', '= N',
       COALESCE(TO_CHAR(t.LOGICO), 'N (padrão)'),
       CASE WHEN t.LOGICO IS NULL THEN 'ok'  -- padrão (N) == esperado (N)
            WHEN t.LOGICO = 'N' THEN 'ok' ELSE 'alerta' END
FROM DUAL LEFT JOIN TSIPAR t ON t.CHAVE = 'ENBLMONBD'
ORDER BY 1
