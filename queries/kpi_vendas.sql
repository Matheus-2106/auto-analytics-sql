-- =============================================================================
-- AUTO ANALYTICS & RETAIL DB — CONSULTAS ANALÍTICAS E KPIS DE NEGÓCIO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- QUERY 1: Análise de Faturamento Mensal e Crescimento MoM (Month-over-Month)
-- -----------------------------------------------------------------------------
WITH faturamento_mensal AS (
    SELECT 
        DATE_TRUNC('month', data_venda)::DATE AS mes,
        COUNT(id) AS total_vendas,
        SUM(valor_total) AS receita_total
    FROM vendas
    WHERE status = 'CONCLUIDA'
    GROUP BY DATE_TRUNC('month', data_venda)
)
SELECT 
    mes,
    total_vendas,
    receita_total,
    COALESCE(LAG(receita_total) OVER (ORDER BY mes), 0) AS receita_mes_anterior,
    ROUND(
        COALESCE(
            ((receita_total - LAG(receita_total) OVER (ORDER BY mes)) / 
            NULLIF(LAG(receita_total) OVER (ORDER BY mes), 0)) * 100, 
        0), 2
    ) AS crescimento_mom_percentual
FROM faturamento_mensal
ORDER BY mes;


-- -----------------------------------------------------------------------------
-- QUERY 2: Ranking dos Top 2 Produtos Mais Vendidos por Categoria
-- -----------------------------------------------------------------------------
WITH ranking_produtos AS (
    SELECT 
        c.nome_categoria,
        p.nome AS produto,
        SUM(iv.quantidade) AS unidades_vendidas,
        SUM(iv.quantidade * iv.preco_unitario) AS receita_gerada,
        DENSE_RANK() OVER (
            PARTITION BY c.nome_categoria 
            ORDER BY SUM(iv.quantidade) DESC
        ) AS posicao_ranking
    FROM itens_venda iv
    JOIN produtos p ON iv.produto_id = p.id
    JOIN categorias c ON p.categoria_id = c.id
    JOIN vendas v ON iv.venda_id = v.id
    WHERE v.status = 'CONCLUIDA'
    GROUP BY c.nome_categoria, p.nome
)
SELECT 
    nome_categoria,
    produto,
    unidades_vendidas,
    receita_gerada,
    posicao_ranking
FROM ranking_produtos
WHERE posicao_ranking <= 2
ORDER BY nome_categoria, posicao_ranking;


-- -----------------------------------------------------------------------------
-- QUERY 3: Alerta de Reposição de Estoque e Valor Imobilizado
-- -----------------------------------------------------------------------------
SELECT 
    p.id AS produto_id,
    p.nome AS produto,
    c.nome_categoria,
    p.estoque_atual,
    p.estoque_minimo,
    (p.estoque_minimo - p.estoque_atual) AS quantidade_para_comprar,
    ROUND((p.estoque_minimo - p.estoque_atual) * p.preco_custo, 2) AS custo_estimado_reposicao,
    CASE 
        WHEN p.estoque_atual = 0 THEN 'CRÍTICO: SEM ESTOQUE'
        WHEN p.estoque_atual < p.estoque_minimo THEN 'ALERTA: ABAIXO DO MÍNIMO'
        ELSE 'ESTOQUE REGULAR'
    END AS status_estoque
FROM produtos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.estoque_atual < p.estoque_minimo 
  AND c.nome_categoria NOT IN ('Serviços Mecânicos') -- Exclui serviços virtuais
ORDER BY p.estoque_atual ASC;


-- -----------------------------------------------------------------------------
-- QUERY 4: Perfil de Clientes VIP (Análise de LTV e Frequência)
-- -----------------------------------------------------------------------------
SELECT 
    c.id AS cliente_id,
    c.nome AS cliente,
    c.cidade,
    COUNT(v.id) AS total_pedidos,
    SUM(v.valor_total) AS valor_total_gasto,
    ROUND(AVG(v.valor_total), 2) AS ticket_medio
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
WHERE v.status = 'CONCLUIDA'
GROUP BY c.id, c.nome, c.cidade
HAVING COUNT(v.id) >= 1
ORDER BY valor_total_gasto DESC;