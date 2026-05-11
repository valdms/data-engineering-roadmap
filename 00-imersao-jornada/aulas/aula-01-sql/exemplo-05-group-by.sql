-- ============================================
-- EXEMPLO 05: GROUP BY - Agrupando resultados
-- ============================================
-- Conceito: GROUP BY para agrupar e agregar por dimensão
-- Pergunta de negócio: Qual a receita por canal de venda? E por mês?
-- Conexão com dbt: gold_kpi_receita_por_canal agrupa receita por canal_venda
--                  gold_kpi_vendas_temporais agrupa por data

-- ============================================
-- 1. Receita por canal de venda
-- ============================================
-- Esse é EXATAMENTE o gold_kpi_receita_por_canal (sem window function ainda)

SELECT
    canal_venda,
    SUM(quantidade * preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas
FROM vendas
GROUP BY canal_venda
ORDER BY receita_total DESC;


-- ============================================
-- 2. Contagem de vendas por canal
-- ============================================

SELECT
    canal_venda,
    COUNT(*) AS total_vendas,
    COUNT(DISTINCT id_cliente) AS clientes_unicos,
    SUM(quantidade) AS quantidade_total
FROM vendas
GROUP BY canal_venda
ORDER BY total_vendas DESC;


-- ============================================
-- 3. Ticket médio por canal
-- ============================================

SELECT
    canal_venda,
    SUM(quantidade * preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas,
    AVG(quantidade * preco_unitario) AS ticket_medio
FROM vendas
GROUP BY canal_venda
ORDER BY ticket_medio DESC;


-- ============================================
-- 4. Vendas por mês (análise temporal)
-- ============================================
-- No dbt, gold_kpi_vendas_temporais faz essa análise com mais dimensões

SELECT
    EXTRACT(YEAR FROM data_venda::timestamp) AS ano,
    EXTRACT(MONTH FROM data_venda::timestamp) AS mes,
    SUM(quantidade * preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas,
    COUNT(DISTINCT id_cliente) AS clientes_unicos
FROM vendas
GROUP BY
    EXTRACT(YEAR FROM data_venda::timestamp),
    EXTRACT(MONTH FROM data_venda::timestamp)
ORDER BY ano, mes;


-- ============================================
-- 5. Produtos por categoria (contagem)
-- ============================================

SELECT
    categoria,
    COUNT(*) AS total_produtos,
    AVG(preco_atual) AS preco_medio,
    MIN(preco_atual) AS preco_minimo,
    MAX(preco_atual) AS preco_maximo
FROM produtos
GROUP BY categoria
ORDER BY total_produtos DESC;


-- ============================================
-- 6. HAVING - Filtrando grupos
-- ============================================
-- Pergunta de negócio: Em quais meses a receita ultrapassou R$ 50.000?
-- WHERE filtra linhas ANTES do agrupamento
-- HAVING filtra grupos DEPOIS do agrupamento (você só pode usar agregações no HAVING)

SELECT
    EXTRACT(YEAR FROM data_venda::timestamp) AS ano,
    EXTRACT(MONTH FROM data_venda::timestamp) AS mes,
    SUM(quantidade * preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas
FROM vendas
GROUP BY
    EXTRACT(YEAR FROM data_venda::timestamp),
    EXTRACT(MONTH FROM data_venda::timestamp)
HAVING SUM(quantidade * preco_unitario) > 50000
ORDER BY receita_total DESC;
