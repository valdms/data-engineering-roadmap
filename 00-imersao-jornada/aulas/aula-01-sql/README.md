# 📚 Dia 1: SQL & Analytics | Jornada de Dados

Bem-vindo ao **primeiro dia da imersão Jornada de Dados**! Hoje você vai aprender SQL do zero, pensando como um analista de dados que precisa responder perguntas de negócio.

> **Domínio:** Sistema de vendas (e-commerce + loja física)
> **Conexão:** Cada exemplo SQL prepara você para conceitos que vai reencontrar na **aula-03-dbt** (arquitetura medalhão: bronze, silver, gold).

---

## 🧠 Antes de tudo: o que é SQL na prática?

Imagine que o banco de dados é um **arquivo gigante** com várias planilhas (tabelas) ligadas entre si. SQL é a **forma de "fazer perguntas"** a esse arquivo.

A diferença para Excel/Python é que em SQL você **descreve o resultado que quer**, não o passo a passo:

```sql
-- "Me dá os 10 produtos mais caros"
SELECT nome_produto, preco_atual
FROM produtos
ORDER BY preco_atual DESC
LIMIT 10;
```

Quem decide *como* buscar isso (qual índice usar, em que ordem ler os dados) é o próprio banco. Você só diz **o que quer**.

### 📐 Anatomia de uma query

Toda query SQL segue mais ou menos esta estrutura:

```sql
SELECT   colunas_que_quero
FROM     qual_tabela
WHERE    filtro_de_linhas        -- opcional
GROUP BY agrupamento             -- opcional
HAVING   filtro_de_grupos        -- opcional
ORDER BY ordenação               -- opcional
LIMIT    quantas_linhas          -- opcional
```

Você não precisa decorar — vamos construir isso peça por peça nos 8 exemplos.

---

## 🛠️ Plataforma: Supabase

Vamos usar **[Supabase](https://supabase.com/)**, que é basicamente **PostgreSQL com uma interface web bonita**. Plano gratuito, setup em minutos, e tudo que você aprender funciona em qualquer Postgres.

---

## 🗄️ Nossas tabelas

📎 Dados originais: [Google Sheets](https://docs.google.com/spreadsheets/d/1V_ICue9zOznu-8WlCUpb0ZmHEE5NZcqgV1_Gw4RIJp4/edit?usp=sharing)

```
Banco: E-commerce
├── vendas               (~3.000 registros)  — Transações
├── produtos             (200 registros)     — Catálogo
├── clientes             (50 registros)      — Cadastro
└── preco_competidores   (~680 registros)    — Preços concorrentes (visto na aula 3)
```

### 📋 vendas — a tabela "fato"

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id_venda` | TEXT | ID único da venda |
| `data_venda` | TIMESTAMP | Quando aconteceu |
| `id_cliente` | TEXT | FK → clientes |
| `id_produto` | TEXT | FK → produtos |
| `canal_venda` | TEXT | `ecommerce` ou `loja_fisica` |
| `quantidade` | INTEGER | Unidades vendidas |
| `preco_unitario` | NUMERIC | Preço unitário (R$) |

### 📋 produtos

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id_produto` | TEXT | ID único |
| `nome_produto` | TEXT | Nome do produto |
| `categoria` | TEXT | Eletrônicos, Cozinha, Tênis... |
| `marca` | TEXT | Marca |
| `preco_atual` | NUMERIC | Preço atual (R$) |
| `data_criacao` | TIMESTAMP | Quando entrou no catálogo |

### 📋 clientes

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id_cliente` | TEXT | ID único |
| `nome_cliente` | TEXT | Nome |
| `estado` | TEXT | UF |
| `pais` | TEXT | País |
| `data_cadastro` | TIMESTAMP | Data de cadastro |

### 🔗 Como elas se conectam

```
vendas.id_produto   ──→  produtos.id_produto
vendas.id_cliente   ──→  clientes.id_cliente
```

> **Por que isso importa?** Cada venda guarda só o *ID* do produto e do cliente. Pra ver o nome do produto ou o estado do cliente, vamos precisar **juntar** as tabelas com `JOIN` (exemplo 06).

---

## 🎯 Roteiro de aprendizado

Os **8 exemplos** seguem uma progressão onde cada um usa conceitos dos anteriores:

```
  Fundamentos             Agregação                Análise
  (01 → 02 → 03)          (04 → 05)                (06 → 07 → 08)

  Ver, ordenar,           Calcular métricas,       Juntar tabelas,
  filtrar dados           agrupar por dimensão     classificar, ranking
```

### 🔄 Conexão SQL → dbt (Arquitetura Medalhão)

Você vai reencontrar tudo isso na **aula-03-dbt**, só que organizado em camadas:

| Camada dbt | O que faz | Exemplos SQL relacionados |
|:----------:|-----------|:-------------------------:|
| 🥉 **Bronze** | Views das tabelas raw | 01 |
| 🥈 **Silver** | Limpeza, campos calculados, JOINs, classificações | 03, 04, 06, 07 |
| 🥇 **Gold** | KPIs, agregações, rankings, percentuais | 05, 06, 08 |

---

## 📝 Os 8 exemplos

---

### 01 — SELECT básico: "o que tem aqui?"

📄 `exemplo-01-select-basico.sql`

**Intuição:** antes de analisar qualquer coisa, você precisa **ver os dados**. `SELECT` é o "abrir a planilha" do SQL.

| | |
|---|---|
| **O que você aprende** | Sintaxe básica de `SELECT`, escolher colunas, usar `LIMIT` para espiar |
| **Pergunta de negócio** | Que dados temos nas tabelas `vendas`, `produtos`, `clientes`? |
| **Conexão dbt** | 🥉 bronze — views que expõem as tabelas raw |

---

### 02 — ORDER BY + LIMIT: "qual o top N?"

📄 `exemplo-02-order-by-limit.sql`

**Intuição:** `ORDER BY` é o "ordenar pela coluna X" do Excel. Junto com `LIMIT`, dá o **top N** — o padrão mais usado em dashboards.

| | |
|---|---|
| **O que você aprende** | `ORDER BY ASC`/`DESC`, combinar com `LIMIT` para rankings |
| **Pergunta de negócio** | Quais os produtos mais caros? Quais as maiores vendas? |
| **Conexão dbt** | 🥇 padrão top N usado em `gold_kpi_produtos_top_receita` |

---

### 03 — WHERE: "só me mostra o que importa"

📄 `exemplo-03-where.sql`

**Intuição:** `WHERE` é o **filtro** do SQL — equivalente ao "filtrar coluna" do Excel, mas muito mais poderoso.

| | |
|---|---|
| **O que você aprende** | Operadores `=`, `>`, `<`, `IN`, `BETWEEN`, combinar com `AND`/`OR`, validar dados inválidos |
| **Pergunta de negócio** | Quais vendas são do e-commerce? Produtos entre R$ 100 e R$ 500? Existem vendas inválidas? |
| **Conexão dbt** | 🥈 filtros de validação do `silver_vendas` (`quantidade > 0`, `preco > 0`) |

---

### 04 — Campos calculados + Funções de agregação: "qual o total?"

📄 `exemplo-04-funcoes-agregacao.sql`

**Intuição:** até agora você só **viu** dados. Aqui começamos a **calcular**. Duas ideias juntas:
- **Campo calculado** = criar nova coluna a partir de outras (`quantidade * preco_unitario AS receita_total`)
- **Agregação** = resumir várias linhas em UM número (`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`)

| | |
|---|---|
| **O que você aprende** | Aritmética + alias com `AS` · `COUNT(*)` vs `COUNT(DISTINCT)` · `SUM`, `AVG`, `MIN`, `MAX` · painel completo de KPIs |
| **Pergunta de negócio** | Qual a receita de cada venda? Qual o total? Quantos clientes únicos? Ticket médio? |
| **Conexão dbt** | 🥈 `silver_vendas` (receita_total) · 🥇 métricas base de TODOS os KPIs gold |

---

### 05 — GROUP BY: "e por categoria?"

📄 `exemplo-05-group-by.sql`

**Intuição:** o exemplo 04 calculou UM número para a base toda. `GROUP BY` faz o mesmo cálculo **separadamente por grupo** — receita por canal, por mês, por categoria. É o "dividir em subtotais".

**Regra de ouro:** toda coluna no `SELECT` precisa estar no `GROUP BY` **ou** dentro de uma agregação.

| | |
|---|---|
| **O que você aprende** | `GROUP BY` para agrupar · combinar com agregações · `HAVING` (filtro DEPOIS do agrupamento) |
| **Pergunta de negócio** | Qual a receita por canal? Por mês? Em quais meses passamos de R$ 50 mil? |
| **Conexão dbt** | 🥇 `gold_kpi_receita_por_canal` é exatamente isso |

---

### 06 — JOIN: "juntando as tabelas"

📄 `exemplo-06-join.sql`

**Intuição:** a tabela `vendas` só tem `id_produto` — não tem o nome nem a categoria. Para responder "qual a receita por **categoria**?", você precisa **conectar** vendas + produtos. É isso que `JOIN` faz: usa um campo em comum (a "ponte") pra trazer colunas de outra tabela.

```
vendas (id_produto: P001)  ─JOIN─  produtos (id_produto: P001, categoria: Eletrônicos)
                                        ↓
                              agora cada linha de venda tem categoria!
```

| | |
|---|---|
| **O que você aprende** | `INNER JOIN` entre 2 tabelas · triple JOIN · `JOIN` + `GROUP BY` para receita por categoria/estado · análise cruzada (categoria × canal) |
| **Pergunta de negócio** | Quais produtos foram vendidos? Para quem? Qual a receita por categoria? Por estado? |
| **Conexão dbt** | 🥈 `silver_vendas_enriquecidas` · 🥇 `gold_kpi_receita_por_categoria` |

---

### 07 — CASE WHEN: "classificando as coisas"

📄 `exemplo-07-case-when.sql`

**Intuição:** `CASE WHEN` é o **"se/então/senão"** do SQL. Útil pra criar **classificações** — transformar valores contínuos (preço) em categorias (PREMIUM/MEDIO/BASICO).

```sql
CASE
    WHEN preco > 1000 THEN 'PREMIUM'
    WHEN preco > 500  THEN 'MEDIO'
    ELSE 'BASICO'
END AS faixa_preco
```

| | |
|---|---|
| **O que você aprende** | Sintaxe `CASE WHEN ... THEN ... ELSE ... END` · classificar produtos por faixa de preço · flags de validação |
| **Pergunta de negócio** | Qual a faixa de preço de cada produto? Como segmentar? |
| **Conexão dbt** | 🥈 `silver_produtos` classifica `faixa_preco` |

---

### 08 — Window Functions: "comparando com o vizinho"

📄 `exemplo-08-window-functions.sql`

**Intuição:** `GROUP BY` **junta** linhas (você perde o detalhe). Window function **mantém** todas as linhas e adiciona um cálculo que "olha" para outras — a linha anterior, o ranking dentro do grupo, o total geral.

Os 3 superpoderes:
- **`LAG()`** — pega o valor da linha anterior (ex: receita do mês passado)
- **`ROW_NUMBER()`** — numera as linhas em ordem (ex: ranking de produtos)
- **`SUM() OVER()`** — calcula o total geral pra usar como denominador (ex: % do total)

| | |
|---|---|
| **O que você aprende** | `LAG()` + variação MoM (mês a mês) · `ROW_NUMBER()` para rankings · `PARTITION BY` para ranking por grupo · `SUM() OVER ()` para percentuais |
| **Pergunta de negócio** | Estamos crescendo mês a mês? Qual o top produtos? % de cada canal? |
| **Conexão dbt** | 🥇 KPIs temporais · `gold_kpi_produtos_top_receita` · `gold_kpi_receita_por_canal` |

---

## 🎁 Bônus: e quando a query fica grande?

Você vai chegar num ponto em que a query tem `JOIN`, `GROUP BY`, `CASE`, window... tudo junto. Como organizar isso?

Existem **3 caminhos** para quebrar queries grandes em pedaços:
- **Subquery** — uma query dentro de outra (parênteses)
- **CTE (`WITH`)** — etapas nomeadas, leitura de cima para baixo
- **Criar tabela/view** — materializar o resultado intermediário

> 📅 **Na aula de quarta-feira** vamos ver as diferenças entre os três (quando usar cada um, performance, legibilidade) e como o **dbt** automatiza esse padrão de "queries em camadas". **Apareça!** É a ponte direta para a aula de dbt.

---

## 📊 Resumo

| # | Conceito | Para que serve | Camada dbt |
|:-:|----------|----------------|:----------:|
| 01 | `SELECT` | Ver os dados | 🥉 |
| 02 | `ORDER BY` + `LIMIT` | Top N / rankings simples | 🥇 |
| 03 | `WHERE` | Filtrar linhas | 🥈 |
| 04 | Campos calculados + Agregações | Calcular métricas (receita, total, média) | 🥈🥇 |
| 05 | `GROUP BY` | Métrica por dimensão (canal, mês) | 🥇 |
| 06 | `JOIN` | Juntar tabelas + análises por categoria/estado | 🥈🥇 |
| 07 | `CASE WHEN` | Classificar em faixas/segmentos | 🥈 |
| 08 | Window Functions | Comparar com período anterior, ranking, % | 🥇 |

---

## ❓ Perguntas de negócio respondidas

1. Que dados temos? *(01)*
2. Quais produtos são os mais caros? *(02)*
3. Quais as maiores vendas? *(02)*
4. Quais vendas são do e-commerce? *(03)*
5. Produtos custam entre R$ 100 e R$ 500? *(03)*
6. Existem vendas inválidas? *(03)*
7. Qual a receita de cada venda? *(04)*
8. Qual a receita total? Ticket médio? Clientes únicos? *(04)*
9. Qual a receita por canal? Por mês? *(05)*
10. Em quais meses passamos de R$ 50 mil? *(05)*
11. Quais produtos foram vendidos e para quem? *(06)*
12. Qual a receita por categoria? Por marca? Por estado? *(06)*
13. Qual a faixa de preço de cada produto? *(07)*
14. Estamos crescendo mês a mês? *(08)*
15. Qual o ranking de produtos por receita? *(08)*
16. Qual o percentual de receita por canal? *(08)*

---

## ✅ Checklist de aprendizado

Depois dos 8 exemplos, você deve conseguir:

- [ ] Ler dados com `SELECT` / `LIMIT`
- [ ] Ordenar com `ORDER BY`
- [ ] Filtrar com `WHERE` (`IN`, `BETWEEN`, `AND`/`OR`)
- [ ] Criar campos calculados e calcular agregações (`SUM`, `COUNT`, `AVG`...)
- [ ] Agrupar por dimensão com `GROUP BY` + `HAVING`
- [ ] Juntar tabelas com `INNER JOIN` (incluindo triple JOIN)
- [ ] Classificar com `CASE WHEN`
- [ ] Usar window functions (`LAG`, `ROW_NUMBER`, `SUM OVER`)
- [ ] Reconhecer o paralelo SQL → dbt (bronze, silver, gold)
- [ ] *(quarta-feira)* Saber escolher entre Subquery, CTE e tabela/view

---

## 💡 Como aproveitar melhor

- **Execute em ordem** — cada exemplo usa o anterior
- **Leia os comentários** dentro dos arquivos `.sql` — eles explicam o *porquê*
- **Quebre a query** — quando algo parecer complicado, rode só a parte de dentro do `FROM` ou da CTE para ver o que ela retorna
- **Modifique** — troque filtros, dimensões, ordenação. Aprender SQL é experimentar
- **Pense no dbt** — quando chegar na aula 03, você vai reconhecer cada peça

---

**Total: 8 exemplos progressivos · 16 perguntas de negócio · tudo conectado com dbt** 🚀
