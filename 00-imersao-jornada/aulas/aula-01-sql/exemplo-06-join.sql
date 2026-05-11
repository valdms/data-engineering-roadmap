-- ============================================
-- EXEMPLO 06: JOIN - Combinando tabelas
-- ============================================
-- Conceito: INNER JOIN para conectar vendas com produtos e clientes
-- Pergunta de negócio: Quais produtos foram vendidos? Para quem? Qual a receita por categoria?
-- Conexão com dbt: silver_vendas_enriquecidas faz JOIN vendas + produtos + clientes
--                  gold_kpi_receita_por_categoria/marca/estado = JOIN + GROUP BY

-- ============================================
-- 1. JOIN vendas + produtos (duas tabelas)
-- ============================================
-- Enriquece cada venda com o nome e categoria do produto
-- ON v.id_produto = p.id_produto: a "ponte" entre as tabelas

SELECT
    v.id_venda,
    v.data_venda,
    v.canal_venda,
    v.quantidade,
    v.preco_unitario,
    p.nome_produto,
    p.categoria,
    p.marca
FROM vendas v
INNER JOIN produtos p
    ON v.id_produto = p.id_produto
ORDER BY v.data_venda DESC
LIMIT 20;


-- ============================================
-- 2. JOIN vendas + clientes
-- ============================================
-- Enriquece cada venda com dados do cliente

SELECT
    v.id_venda,
    v.data_venda,
    v.canal_venda,
    v.quantidade,
    v.preco_unitario,
    c.nome_cliente,
    c.estado
FROM vendas v
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
ORDER BY v.data_venda DESC
LIMIT 20;


-- ============================================
-- 3. Triple JOIN: vendas + produtos + clientes
-- ============================================
-- Essa é a base do silver_vendas_enriquecidas no dbt
-- Combina TUDO numa visão completa para análise

SELECT
    v.id_venda,
    v.data_venda,
    v.canal_venda,
    v.quantidade,
    v.preco_unitario,
    v.quantidade * v.preco_unitario AS receita_total,
    p.nome_produto,
    p.categoria,
    p.marca,
    c.nome_cliente,
    c.estado
FROM vendas v
INNER JOIN produtos p
    ON v.id_produto = p.id_produto
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
ORDER BY receita_total DESC
LIMIT 20;


-- ============================================
-- 4. JOIN + GROUP BY: receita por categoria
-- ============================================
-- Agora juntamos as duas coisas: combinar tabelas e agrupar
-- Esse é EXATAMENTE o gold_kpi_receita_por_categoria

SELECT
    p.categoria,
    SUM(v.quantidade * v.preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas,
    AVG(v.quantidade * v.preco_unitario) AS ticket_medio
FROM vendas v
INNER JOIN produtos p
    ON v.id_produto = p.id_produto
GROUP BY p.categoria
ORDER BY receita_total DESC;


-- ============================================
-- 5. JOIN + GROUP BY: receita por estado do cliente
-- ============================================
-- Mesmo padrão, agora cruzando com a tabela clientes

SELECT
    c.estado,
    SUM(v.quantidade * v.preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas,
    COUNT(DISTINCT v.id_cliente) AS total_clientes
FROM vendas v
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
GROUP BY c.estado
ORDER BY receita_total DESC;


-- ============================================
-- 6. Análise cruzada: categoria × canal
-- ============================================
-- Agrupando por DUAS dimensões: como cada categoria performa em cada canal

SELECT
    p.categoria,
    v.canal_venda,
    SUM(v.quantidade * v.preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas
FROM vendas v
INNER JOIN produtos p
    ON v.id_produto = p.id_produto
GROUP BY p.categoria, v.canal_venda
ORDER BY p.categoria, receita_total DESC;
