-- ============================================
-- EXEMPLO 07: CASE WHEN - Classificações e categorizações
-- ============================================
-- Conceito: CASE WHEN para criar colunas de classificação condicional
-- Pergunta de negócio: Como classificar produtos por faixa de preço? E vendas por tamanho?
-- Conexão com dbt: silver_produtos classifica faixa_preco (PREMIUM/MEDIO/BASICO)
--                  gold_kpi_clientes_segmentacao classifica segmento (VIP/TOP_TIER/REGULAR)

-- ============================================
-- 1. Classificar produtos por faixa de preço
-- ============================================
-- Essa lógica é EXATAMENTE a do silver_produtos no dbt

SELECT
    nome_produto,
    categoria,
    marca,
    preco_atual,
    CASE
        WHEN preco_atual > 1000 THEN 'PREMIUM'
        WHEN preco_atual > 500 THEN 'MEDIO'
        ELSE 'BASICO'
    END AS faixa_preco
FROM produtos
ORDER BY preco_atual DESC;


-- ============================================
-- 2. Contagem de produtos por faixa de preço
-- ============================================

SELECT
    CASE
        WHEN preco_atual > 1000 THEN 'PREMIUM'
        WHEN preco_atual > 500 THEN 'MEDIO'
        ELSE 'BASICO'
    END AS faixa_preco,
    COUNT(*) AS total_produtos,
    AVG(preco_atual) AS preco_medio
FROM produtos
GROUP BY faixa_preco
ORDER BY preco_medio DESC;


-- ============================================
-- 3. Classificar vendas por tamanho da receita
-- ============================================

SELECT
    id_venda,
    quantidade,
    preco_unitario,
    quantidade * preco_unitario AS receita_total,
    CASE
        WHEN quantidade * preco_unitario > 5000 THEN 'GRANDE'
        WHEN quantidade * preco_unitario > 1000 THEN 'MEDIA'
        ELSE 'PEQUENA'
    END AS tamanho_venda
FROM vendas
ORDER BY receita_total DESC
LIMIT 30;


-- ============================================
-- 4. Flags de validação com CASE WHEN
-- ============================================
-- No dbt, silver_vendas cria flags booleanas para dados inválidos

SELECT
    id_venda,
    quantidade,
    preco_unitario,
    CASE
        WHEN quantidade <= 0 THEN TRUE
        ELSE FALSE
    END AS flag_quantidade_invalida,
    CASE
        WHEN preco_unitario <= 0 THEN TRUE
        ELSE FALSE
    END AS flag_preco_invalido
FROM vendas
LIMIT 20;
