-- ============================================
-- EXEMPLO 08: Window Functions - LAG, Rankings e Percentuais
-- ============================================
-- Conceito: Funções que operam sobre uma "janela" de linhas (não agrupam como GROUP BY)
-- Pergunta de negócio: Estamos crescendo mês a mês? Qual o ranking dos produtos?
-- Conexão com dbt: LAG é a base de KPIs temporais (MoM, YoY) na camada gold
--                  ROW_NUMBER usado em gold_kpi_produtos_top_receita
--                  SUM() OVER() usado em gold_kpi_receita_por_canal (percentual)

-- ============================================
-- O que é uma Window Function?
-- ============================================
-- GROUP BY: reduz várias linhas em UMA linha por grupo (você "perde" o detalhe)
-- Window Function: mantém TODAS as linhas e adiciona um cálculo "olhando" para outras
--
-- Sintaxe geral:
--     FUNCAO(coluna) OVER (
--         PARTITION BY <agrupamento opcional>
--         ORDER BY <ordenação opcional>
--     )
--
-- A "janela" é o conjunto de linhas que a função "enxerga" para fazer o cálculo.


-- ============================================
-- 1. LAG() - Olhando para o período anterior
-- ============================================
-- LAG() pega o valor da LINHA ANTERIOR segundo a ordenação definida
--
-- LAG(coluna, N) OVER (ORDER BY ...)
--   coluna = qual valor queremos buscar
--   N      = quantas linhas para trás (1 = linha imediatamente anterior)
--
-- Aqui agregamos a receita por mês e, ao lado de cada mês, mostramos o mês anterior
-- O cast ::timestamp garante que data_venda seja tratada como data/hora

SELECT
    EXTRACT(YEAR FROM data_venda::timestamp) AS ano,
    EXTRACT(MONTH FROM data_venda::timestamp) AS mes,
    SUM(quantidade * preco_unitario) AS receita_total,
    LAG(SUM(quantidade * preco_unitario), 1) OVER (
        ORDER BY
            EXTRACT(YEAR FROM data_venda::timestamp),
            EXTRACT(MONTH FROM data_venda::timestamp)
    ) AS receita_mes_anterior
FROM vendas
GROUP BY
    EXTRACT(YEAR FROM data_venda::timestamp),
    EXTRACT(MONTH FROM data_venda::timestamp)
ORDER BY ano, mes;

-- 👀 Observe: a primeira linha tem receita_mes_anterior = NULL
--    Isso é esperado: não existe um mês "antes" do primeiro mês da base.


-- ============================================
-- 2. LAG() + variação MoM (Month-over-Month)
-- ============================================
-- Agora calculamos:
--   - Variação absoluta (R$): receita_atual - receita_anterior
--   - Variação percentual (%): (atual - anterior) / anterior * 100
--
-- Esse é o KPI clássico de crescimento mês a mês usado em dashboards executivos

SELECT
    EXTRACT(YEAR FROM data_venda::timestamp) AS ano,
    EXTRACT(MONTH FROM data_venda::timestamp) AS mes,
    SUM(quantidade * preco_unitario) AS receita_total,
    LAG(SUM(quantidade * preco_unitario), 1) OVER (
        ORDER BY
            EXTRACT(YEAR FROM data_venda::timestamp),
            EXTRACT(MONTH FROM data_venda::timestamp)
    ) AS receita_mes_anterior,
    SUM(quantidade * preco_unitario) - LAG(SUM(quantidade * preco_unitario), 1) OVER (
        ORDER BY
            EXTRACT(YEAR FROM data_venda::timestamp),
            EXTRACT(MONTH FROM data_venda::timestamp)
    ) AS variacao_absoluta,
    ROUND(
        (SUM(quantidade * preco_unitario) - LAG(SUM(quantidade * preco_unitario), 1) OVER (
            ORDER BY
                EXTRACT(YEAR FROM data_venda::timestamp),
                EXTRACT(MONTH FROM data_venda::timestamp)
        )) * 100.0
        / LAG(SUM(quantidade * preco_unitario), 1) OVER (
            ORDER BY
                EXTRACT(YEAR FROM data_venda::timestamp),
                EXTRACT(MONTH FROM data_venda::timestamp)
        ),
        2
    ) AS variacao_percentual
FROM vendas
GROUP BY
    EXTRACT(YEAR FROM data_venda::timestamp),
    EXTRACT(MONTH FROM data_venda::timestamp)
ORDER BY ano, mes;


-- ============================================
-- 3. Ranking de produtos por receita - ROW_NUMBER()
-- ============================================
-- ROW_NUMBER() OVER (ORDER BY ...) numera as linhas 1, 2, 3... segundo a ordenação
-- Essa lógica é usada no gold_kpi_produtos_top_receita

SELECT
    p.nome_produto,
    p.categoria,
    p.marca,
    SUM(v.quantidade * v.preco_unitario) AS receita_total,
    ROW_NUMBER() OVER (ORDER BY SUM(v.quantidade * v.preco_unitario) DESC) AS ranking_receita
FROM vendas v
INNER JOIN produtos p
    ON v.id_produto = p.id_produto
GROUP BY p.nome_produto, p.categoria, p.marca
ORDER BY ranking_receita
LIMIT 10;


-- ============================================
-- 4. Ranking POR categoria - PARTITION BY
-- ============================================
-- PARTITION BY divide as linhas em grupos e o ranking "reinicia" em cada grupo
-- No gold_kpi_produtos_top_receita: ranking_receita_categoria

SELECT
    p.nome_produto,
    p.categoria,
    SUM(v.quantidade * v.preco_unitario) AS receita_total,
    ROW_NUMBER() OVER (
        PARTITION BY p.categoria
        ORDER BY SUM(v.quantidade * v.preco_unitario) DESC
    ) AS ranking_na_categoria
FROM vendas v
INNER JOIN produtos p
    ON v.id_produto = p.id_produto
GROUP BY p.nome_produto, p.categoria
ORDER BY p.categoria, ranking_na_categoria;


-- ============================================
-- 5. Percentual de receita por canal - SUM() OVER()
-- ============================================
-- SUM() OVER () (sem PARTITION/ORDER) calcula o total GERAL da janela
-- Usamos esse total como denominador para obter o % de cada linha sobre o total
-- Essa lógica é EXATAMENTE a do gold_kpi_receita_por_canal

SELECT
    canal_venda,
    SUM(quantidade * preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas,
    AVG(quantidade * preco_unitario) AS ticket_medio,
    SUM(quantidade * preco_unitario) * 100.0 / SUM(SUM(quantidade * preco_unitario)) OVER () AS percentual_receita
FROM vendas
GROUP BY canal_venda
ORDER BY receita_total DESC;


-- ============================================
-- 6. Percentual de receita por categoria
-- ============================================

SELECT
    p.categoria,
    SUM(v.quantidade * v.preco_unitario) AS receita_total,
    COUNT(*) AS total_vendas,
    SUM(v.quantidade * v.preco_unitario) * 100.0 / SUM(SUM(v.quantidade * v.preco_unitario)) OVER () AS percentual_receita
FROM vendas v
INNER JOIN produtos p
    ON v.id_produto = p.id_produto
GROUP BY p.categoria
ORDER BY receita_total DESC;
