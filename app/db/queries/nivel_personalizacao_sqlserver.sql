/* =====================================================================================
       INDICADOR DE NÍVEL DE PERSONALIZAÇÃO DO AMBIENTE SANKHYA — VERSÃO SQL SERVER
       ===================================================================================== */

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
            END AS NOTA_BASE
        FROM CONTAGEM
    ),

    TRIGGERS_CONTAGEM AS (
        SELECT
            t.name AS TABELA,
            COUNT(tr.object_id) AS QTD_TRIGGER
        FROM sys.tables t
        LEFT JOIN sys.triggers tr ON tr.parent_id = t.object_id
        WHERE t.name IN ('TGFCAB', 'TGFITE', 'TGFFIN', 'TGFVAR', 'TSILIB')
        GROUP BY t.name
    ),

    TRIGGERS_FAIXA AS (
        SELECT C.TABELA, C.QTD_TRIGGER, F.PADRAO, F.MEDIO_LIMITE
        FROM TRIGGERS_CONTAGEM C
        JOIN (
            SELECT 'TGFCAB' AS TABELA, 35 AS PADRAO, 40 AS MEDIO_LIMITE UNION ALL
            SELECT 'TGFITE',           35,          40              UNION ALL
            SELECT 'TGFFIN',           35,          40              UNION ALL
            SELECT 'TGFVAR',            7,          10              UNION ALL
            SELECT 'TSILIB',            0,           1
        ) F ON F.TABELA = C.TABELA
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
                WHEN QTD_TRIGGER <= PADRAO       THEN 'PADRÃO'
                WHEN QTD_TRIGGER <= MEDIO_LIMITE THEN 'MÉDIO'
                ELSE 'ALTO'
            END AS NIVEL_TABELA
        FROM TRIGGERS_FAIXA
    ),

    TOTAIS AS (
        SELECT
            (SELECT SUM(NOTA_BASE * PESO) FROM PONTUACAO)      AS SCORE_RECURSOS,
            (SELECT SUM(PESO) * 10 FROM PONTUACAO)              AS SCORE_RECURSOS_MAX,
            (SELECT MAX(CASE NIVEL_TABELA WHEN 'ALTO' THEN 3 WHEN 'MÉDIO' THEN 2 ELSE 1 END)
                FROM TRIGGERS_PONTUACAO)                        AS PIOR_CASO_TRIGGER
    ),

    RESULTADO AS (
        SELECT
            SCORE_RECURSOS,
            SCORE_RECURSOS_MAX,
            PIOR_CASO_TRIGGER,
            CAST(ROUND(SCORE_RECURSOS * 100.0 / SCORE_RECURSOS_MAX, 2) AS DECIMAL(5,2)) AS PERC_RECURSOS,
            CASE
                WHEN SCORE_RECURSOS * 100.0 / SCORE_RECURSOS_MAX < 30 THEN 'BAIXO'
                WHEN SCORE_RECURSOS * 100.0 / SCORE_RECURSOS_MAX < 55 THEN 'MÉDIO'
                ELSE 'ALTO'
            END AS NIVEL_BASE
        FROM TOTAIS
    )

    /* ---------------------- DETALHE POR RECURSO ---------------------- */
    SELECT
        1 AS ORDEM, 'DETALHE' AS TIPO_LINHA, RECURSO,
        CAST(QTD AS VARCHAR(20)) AS QTD,
        CAST(PESO AS VARCHAR(20)) AS PESO,
        CAST(NOTA_BASE AS VARCHAR(20)) AS NOTA_BASE,
        CAST(NOTA_BASE * PESO AS VARCHAR(20)) AS NIVEL_PERSONALIZACAO
    FROM PONTUACAO

    UNION ALL

    /* ---------------------- DETALHE DE TRIGGERS ---------------------- */
    SELECT
        2 AS ORDEM, 'TRIGGER' AS TIPO_LINHA,
        'Triggers - ' + TABELA AS RECURSO,
        CAST(QTD_TRIGGER AS VARCHAR(20)) AS QTD,
        CAST(PESO AS VARCHAR(20)) AS PESO,
        NIVEL_TABELA AS NOTA_BASE,
        CAST(NOTA_BASE * PESO AS VARCHAR(20)) AS NIVEL_PERSONALIZACAO
    FROM TRIGGERS_PONTUACAO

    UNION ALL

    /* ---------------------- LINHA CONSOLIDADA FINAL ---------------------- */
    SELECT
        3 AS ORDEM, 'CONSOLIDADO' AS TIPO_LINHA,
        'NÍVEL DE PERSONALIZAÇÃO DO AMBIENTE' AS RECURSO,
        CAST(SCORE_RECURSOS AS VARCHAR(20)) AS QTD,
        CAST(SCORE_RECURSOS_MAX AS VARCHAR(20)) AS PESO,
        CAST(PERC_RECURSOS AS VARCHAR(20)) AS NOTA_BASE,
        CASE
            WHEN PIOR_CASO_TRIGGER = 3 THEN 'ALTO'
            WHEN PIOR_CASO_TRIGGER = 2 AND NIVEL_BASE = 'BAIXO' THEN 'MÉDIO'
            ELSE NIVEL_BASE
        END AS NIVEL_PERSONALIZACAO
    FROM RESULTADO

    ORDER BY ORDEM, NIVEL_PERSONALIZACAO DESC
