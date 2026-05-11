-- ============================================
-- EXEMPLO 04: Campos Calculados + Funções de Agregação
-- ============================================
-- Conceito: Criar colunas derivadas com aritmética + agregar com SUM, COUNT, AVG, MIN, MAX
-- Pergunta de negócio: Qual a receita de cada venda? Qual o total? E o ticket médio?
-- Conexão com dbt: silver_vendas calcula receita_total = quantidade * preco_unitario
--                  Métricas base de TODOS os KPIs gold (receita_total, total_vendas, ticket_medio)

-- ============================================
-- 1. Campo calculado: criando uma nova coluna
-- ============================================
-- SQL permite fazer aritmética entre colunas e dar um nome (alias) ao resultado com AS
-- Aqui criamos a coluna receita_total = quantidade × preço unitário
-- Esse cálculo é EXATAMENTE o que o silver_vendas faz no dbt

SELECT
    id_venda,
    quantidade,
    preco_unitario,
    quantidade * preco_unitario AS receita_total
FROM vendas
ORDER BY receita_total DESC
LIMIT 20;


-- ============================================
-- 2. Contando registros - COUNT
-- ============================================
-- COUNT(*) conta TODAS as linhas (uma métrica por consulta)

SELECT COUNT(*) AS total_vendas FROM vendas;

SELECT COUNT(*) AS total_produtos FROM produtos;

SELECT COUNT(*) AS total_clientes FROM clientes;


-- ============================================
-- 3. Somando valores - SUM
-- ============================================
-- SUM aplica a soma sobre a coluna (pode usar um campo calculado dentro!)

SELECT
    SUM(quantidade * preco_unitario) AS receita_total
FROM vendas;


-- ============================================
-- 4. Estatísticas - AVG, MIN, MAX
-- ============================================
-- AVG = média, MIN = menor valor, MAX = maior valor

SELECT
    AVG(preco_atual) AS preco_medio,
    MIN(preco_atual) AS preco_minimo,
    MAX(preco_atual) AS preco_maximo
FROM produtos;


-- ============================================
-- 5. COUNT DISTINCT - Valores únicos
-- ============================================
-- COUNT(*) conta todas as linhas; COUNT(DISTINCT coluna) conta valores únicos
-- No dbt gold, clientes_unicos usa COUNT(DISTINCT id_cliente)

SELECT
    COUNT(DISTINCT id_cliente) AS clientes_unicos,
    COUNT(DISTINCT id_produto) AS produtos_vendidos,
    COUNT(DISTINCT canal_venda) AS canais_venda
FROM vendas;


-- ============================================
-- 6. Painel completo de métricas - estilo KPI gold
-- ============================================
-- Todas as métricas que os modelos gold calculam, numa única query

SELECT
    COUNT(*) AS total_vendas,
    COUNT(DISTINCT id_cliente) AS clientes_unicos,
    COUNT(DISTINCT id_produto) AS produtos_vendidos,
    SUM(quantidade) AS quantidade_total,
    SUM(quantidade * preco_unitario) AS receita_total,
    AVG(quantidade * preco_unitario) AS ticket_medio,
    MIN(quantidade * preco_unitario) AS menor_venda,
    MAX(quantidade * preco_unitario) AS maior_venda
FROM vendas;
