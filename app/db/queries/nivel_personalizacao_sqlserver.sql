WITH CONTAGEM AS (
    SELECT 'TSIGDG - Card Usuário'              AS RECURSO, COUNT(1) AS QTD, 1.0 AS PESO
    FROM TSIGDG WHERE EVOCARD IS NOT NULL
    UNION ALL
    SELECT 'TSIEVP - Eventos Programáveis (RJ)', COUNT(1), 2.0
    FROM TSIEVP WHERE ATIVO = 'S' AND TIPO = 'RJ'
    UNION ALL
    SELECT 'TSIEVP - Eventos Programáveis (SP)', COUNT(1), 2.0
    FROM TSIEVP WHERE ATIVO = 'S' AND TIPO = 'SP'
    UNION ALL
    SELECT 'TSIAAG - Ações Agendadas',           COUNT(1), 1.0
    FROM TSIAAG WHERE ATIVO = 'S'
    UNION ALL
    SELECT 'TSICND - Consolidador de Dados',     COUNT(1), 1.0
    FROM TSICND WHERE ATIVO = 'S'
    UNION ALL
    SELECT 'TGFRNG - Regra de Negócios',         COUNT(1), 2.0
    FROM TGFRNG WHERE ATIVO = 'S'
    UNION ALL
    SELECT 'TSIJAR - Módulos Java',              COUNT(1), 1.0
    FROM TSIJAR
    UNION ALL
    SELECT 'TDDCAM - Campo Calculado (AD_)',     COUNT(1), 2.0
    FROM TDDCAM WHERE CALCULADO = 'S' AND EXPRESSAO IS NOT NULL AND NOMECAMPO LIKE 'AD_%'
    UNION ALL
    SELECT 'TSIBTA - Botões de Aplicação',       COUNT(1), 1.0
    FROM TSIBTA
),

PONTUACAO AS (
    SELECT
        RECURSO, QTD, PESO,
        CASE
            WHEN QTD = 0   THEN 0
            WHEN QTD <= 10 THEN 3
            WHEN QTD <= 40 THEN 6
            ELSE 10
        END AS NOTA_BASE,
        CASE
            WHEN QTD = 0   THEN 'NENHUM'
            WHEN QTD <= 10 THEN 'BAIXO'
            WHEN QTD <= 40 THEN 'MÉDIO'
            ELSE 'ALTO'
        END AS NIVEL
    FROM CONTAGEM
),

TRIGGERS_CONTAGEM AS (
    -- sys.triggers é o catálogo de DML triggers do SQL Server (equivalente
    -- ao ALL_TRIGGERS do Oracle). parent_class = 1 = trigger em tabela/view.
    SELECT
        OBJECT_NAME(tr.parent_id) AS TABELA,
        COUNT(1) AS QTD_TRIGGER
    FROM sys.triggers tr
    WHERE OBJECT_NAME(tr.parent_id) IN ('TGFCAB', 'TGFITE', 'TGFFIN', 'TGFVAR', 'TSILIB')
      AND tr.parent_class = 1
      AND OBJECT_SCHEMA_NAME(tr.parent_id) = SCHEMA_NAME()
    GROUP BY OBJECT_NAME(tr.parent_id)
),

TRIGGERS_BASE AS (
    SELECT F.TABELA, ISNULL(C.QTD_TRIGGER, 0) AS QTD_TRIGGER, F.PADRAO, F.MEDIO_LIMITE
    FROM (
        SELECT 'TGFCAB' AS TABELA, 35 AS PADRAO, 40 AS MEDIO_LIMITE UNION ALL
        SELECT 'TGFITE',           35,          40               UNION ALL
        SELECT 'TGFFIN',           35,          40               UNION ALL
        SELECT 'TGFVAR',            7,          10               UNION ALL
        SELECT 'TSILIB',            0,           1
    ) F
    LEFT JOIN TRIGGERS_CONTAGEM C ON C.TABELA = F.TABELA
),

TRIGGERS_PONTUACAO AS (
    SELECT
        TABELA, QTD_TRIGGER, 2.0 AS PESO,
        CASE
            WHEN QTD_TRIGGER <= PADRAO       THEN 0
            WHEN QTD_TRIGGER <= MEDIO_LIMITE THEN 6
            ELSE 10
        END AS NOTA_BASE,
        CASE
            WHEN QTD_TRIGGER <= PADRAO       THEN 'BAIXO'
            WHEN QTD_TRIGGER <= MEDIO_LIMITE THEN 'MÉDIO'
            ELSE 'ALTO'
        END AS NIVEL
    FROM TRIGGERS_BASE
),

TOTAIS AS (
    SELECT
        (SELECT SUM(NOTA_BASE * PESO) FROM PONTUACAO) +
        (SELECT SUM(NOTA_BASE * PESO) FROM TRIGGERS_PONTUACAO)            AS SCORE_TOTAL,
        (SELECT SUM(PESO) * 10 FROM PONTUACAO) +
        (SELECT SUM(PESO) * 10 FROM TRIGGERS_PONTUACAO)                   AS SCORE_MAXIMO,
        (SELECT MAX(CASE NIVEL WHEN 'ALTO' THEN 3 WHEN 'MÉDIO' THEN 2 ELSE 1 END)
            FROM TRIGGERS_PONTUACAO)                                      AS PIOR_CASO_TRIGGER
)

/* ---------------------- DETALHE POR RECURSO ---------------------- */
SELECT
    1 AS ORDEM, 'DETALHE' AS TIPO_LINHA, RECURSO,
    CAST(QTD AS VARCHAR(20)) AS QUANTIDADE,
    NIVEL,
    NULL AS STATUS
FROM PONTUACAO

UNION ALL

/* ---------------------- DETALHE DE TRIGGERS ---------------------- */
SELECT
    2 AS ORDEM, 'TRIGGER' AS TIPO_LINHA,
    'Triggers - ' + TABELA AS RECURSO,
    CAST(QTD_TRIGGER AS VARCHAR(20)) AS QUANTIDADE,
    NIVEL,
    NULL AS STATUS
FROM TRIGGERS_PONTUACAO

UNION ALL

/* ---------------------- ALERTAS (só aparecem se houver algo a reportar) ---------------------- */
SELECT
    3 AS ORDEM, 'ALERTA' AS TIPO_LINHA,
    'Volume de triggers acima do esperado na tabela ' + TP.TABELA +
        ' (' + CAST(TP.QTD_TRIGGER AS VARCHAR(20)) + ' triggers encontradas, padrão é até ' +
        CAST(TB.PADRAO AS VARCHAR(20)) + ')' AS RECURSO,
    CAST(TP.QTD_TRIGGER AS VARCHAR(20)) AS QUANTIDADE,
    TP.NIVEL,
    'alerta' AS STATUS
FROM TRIGGERS_PONTUACAO TP
JOIN TRIGGERS_BASE TB ON TB.TABELA = TP.TABELA
WHERE TP.NIVEL IN ('MÉDIO', 'ALTO')

UNION ALL

SELECT
    3 AS ORDEM, 'ALERTA' AS TIPO_LINHA,
    'Alto volume de personalização em ' + RECURSO + ' (' + CAST(QTD AS VARCHAR(20)) + ' itens)' AS RECURSO,
    CAST(QTD AS VARCHAR(20)) AS QUANTIDADE,
    NIVEL,
    'alerta' AS STATUS
FROM PONTUACAO
WHERE NIVEL = 'ALTO'

UNION ALL

/* ---------------------- LINHA CONSOLIDADA FINAL ---------------------- */
SELECT
    4 AS ORDEM, 'CONSOLIDADO' AS TIPO_LINHA,
    'NÍVEL DE PERSONALIZAÇÃO DO AMBIENTE' AS RECURSO,
  --  CAST(ROUND(SCORE_TOTAL * 100.0 / SCORE_MAXIMO, 0) AS VARCHAR(20)) + '%' AS QUANTIDADE,
        CAST(CAST(ROUND(SCORE_TOTAL * 100.0 / SCORE_MAXIMO, 0) AS INT) AS VARCHAR(20)) + '%' AS QUANTIDADE,
	CASE
        WHEN PIOR_CASO_TRIGGER = 3 THEN 'ALTO'
        WHEN PIOR_CASO_TRIGGER = 2 AND (SCORE_TOTAL * 100.0 / SCORE_MAXIMO) < 65 THEN 'MÉDIO'
        WHEN (SCORE_TOTAL * 100.0 / SCORE_MAXIMO) < 30 THEN 'BAIXO'
        WHEN (SCORE_TOTAL * 100.0 / SCORE_MAXIMO) < 65 THEN 'MÉDIO'
        ELSE 'ALTO'
    END AS NIVEL,
    NULL AS STATUS
FROM TOTAIS

ORDER BY ORDEM, NIVEL DESC