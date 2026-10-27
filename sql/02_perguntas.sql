
-- ============================================================
-- PROJETO AVALIATIVO SCTEC - MODULO II
-- CONSULTAS DE NEGOCIO DA CONTROLADORIA
-- ============================================================

-- PERGUNTA 1: ECONOMIA GLOBAL DO PODER PUBLICO
-- Considera somente os itens comparaveis (Regra 6).

SELECT
    COUNT(*) FILTER (WHERE comparavel = 1)
        AS itens_comparaveis,

    SUM(valor_total_estimado) FILTER (WHERE comparavel = 1)
        AS valor_estimado_comparavel,

    SUM(economia_valor)
        AS economia_reais,

    ROUND(
        100.0 * SUM(economia_valor)
        / NULLIF(
            SUM(valor_total_estimado) FILTER (WHERE comparavel = 1),
            0
        ),
        2
    ) AS economia_percentual

FROM fato_item_contratado;


-- ============================================================
-- PERGUNTA 2: CONCENTRACAO E RISCO DE FORNECEDORES
-- Dez maiores fornecedores por volume homologado.
-- ============================================================

SELECT
    d.ni_fornecedor,
    d.nome_fornecedor,
    COUNT(*) AS quantidade_itens,
    SUM(f.valor_total_homologado) AS volume_homologado,

    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / NULLIF(
            (SELECT SUM(valor_total_homologado)
             FROM fato_item_contratado),
            0
        ),
        2
    ) AS participacao_percentual

FROM fato_item_contratado AS f

JOIN dim_fornecedor AS d
    ON f.sk_fornecedor = d.sk_fornecedor

GROUP BY
    d.ni_fornecedor,
    d.nome_fornecedor

ORDER BY volume_homologado DESC

LIMIT 10;

-- PERGUNTA 2: CONCENTRACAO CONSOLIDADA DO TOP 10

WITH volumes_fornecedores AS (
    SELECT
        sk_fornecedor,
        SUM(valor_total_homologado) AS volume
    FROM fato_item_contratado
    GROUP BY sk_fornecedor
),
top_10 AS (
    SELECT volume
    FROM volumes_fornecedores
    ORDER BY volume DESC
    LIMIT 10
)
SELECT
    SUM(volume) AS volume_top_10,

    ROUND(
        100.0 * SUM(volume)
        / NULLIF(
            (SELECT SUM(valor_total_homologado)
             FROM fato_item_contratado),
            0
        ),
        2
    ) AS concentracao_top_10_percentual

FROM top_10;


-- ============================================================
-- PERGUNTA 3: EFICACIA POR MODALIDADE DE CONTRATACAO
-- Economia apenas nos itens comparaveis (Regra 6).
-- Volume homologado considera todos os itens.
-- ============================================================

SELECT
    d.nome_modalidade,

    COUNT(*) AS quantidade_itens,

    SUM(f.valor_total_homologado)
        AS volume_homologado,

    COUNT(*) FILTER (WHERE f.comparavel = 1)
        AS itens_comparaveis,

    ROUND(
        100.0 * SUM(f.economia_valor)
        / NULLIF(
            SUM(f.valor_total_estimado)
                FILTER (WHERE f.comparavel = 1),
            0
        ),
        2
    ) AS economia_percentual

FROM fato_item_contratado AS f

JOIN dim_modalidade AS d
    ON f.sk_modalidade = d.sk_modalidade

GROUP BY d.nome_modalidade

ORDER BY volume_homologado DESC;



-- ============================================================
-- PERGUNTA 4: TEMPO DO CICLO DE COMPRAS POR ORGAO
-- Agrupa pelo nome padronizado do orgao.
-- Mostra somente orgaos com 5 ou mais itens com ciclo.
-- ============================================================

SELECT
    d.nome_orgao,

    COUNT(f.dias_ciclo) AS itens_com_ciclo,

    ROUND(AVG(f.dias_ciclo), 1)
        AS ciclo_medio_dias,

    MAX(f.dias_ciclo)
        AS ciclo_maximo_dias

FROM fato_item_contratado AS f

JOIN dim_orgao AS d
    ON f.sk_orgao = d.sk_orgao

GROUP BY d.nome_orgao

HAVING COUNT(f.dias_ciclo) >= 5

ORDER BY ciclo_medio_dias DESC;


-- ============================================================
-- PERGUNTA 5: DISTRIBUICAO REGIONAL DOS GASTOS
-- Volume homologado e participacao por regiao do Brasil.
-- ============================================================

SELECT
    d.regiao,

    COUNT(*) AS quantidade_itens,

    SUM(f.valor_total_homologado)
        AS volume_homologado,

    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / NULLIF(
            (SELECT SUM(valor_total_homologado)
             FROM fato_item_contratado),
            0
        ),
        2
    ) AS participacao_percentual

FROM fato_item_contratado AS f

JOIN dim_localidade AS d
    ON f.sk_localidade = d.sk_localidade

GROUP BY d.regiao

ORDER BY volume_homologado DESC;

-- ============================================================
-- PERGUNTA 6: PERFIL DOS GASTOS PUBLICOS
-- Distribuicao do volume homologado por perfil (Regra 8).
-- ============================================================

SELECT
    perfil_gasto,

    COUNT(*) AS quantidade_itens,

    SUM(valor_total_homologado)
        AS volume_homologado,

    ROUND(
        100.0 * SUM(valor_total_homologado)
        / NULLIF(
            (SELECT SUM(valor_total_homologado)
             FROM fato_item_contratado),
            0
        ),
        2
    ) AS participacao_percentual

FROM fato_item_contratado

GROUP BY perfil_gasto

ORDER BY volume_homologado DESC;
