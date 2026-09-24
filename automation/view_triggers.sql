-- =============================================================================
-- AUTO ANALYTICS & RETAIL DB — VIEWS, FUNCTIONS E TRIGGERS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. VIEW: vw_resumo_vendas_detalhado
-- Abstração para simplificar o consumo por ferramentas de BI (Power BI, Metabase)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_resumo_vendas_detalhado AS
SELECT 
    v.id AS venda_id,
    v.data_venda,
    v.status,
    c.nome AS cliente_nome,
    c.cidade AS cliente_cidade,
    p.nome AS produto_nome,
    cat.nome_categoria,
    iv.quantidade,
    iv.preco_unitario,
    (iv.quantidade * iv.preco_unitario) AS subtotal
FROM vendas v
JOIN clientes c ON v.cliente_id = c.id
JOIN itens_venda iv ON v.id = iv.venda_id
JOIN produtos p ON iv.produto_id = p.id
JOIN categorias cat ON p.categoria_id = cat.id;


-- -----------------------------------------------------------------------------
-- 2. FUNCTION & TRIGGER: trg_atualizar_estoque_venda
-- Regra de Negócio: Baixa automática do estoque ao inserir um novo item na venda
-- -----------------------------------------------------------------------------

-- Função que executa a lógica de redução de estoque
CREATE OR REPLACE FUNCTION fn_atualizar_estoque_venda()
RETURNS TRIGGER AS $$
DECLARE
    v_estoque_atual INT;
BEGIN
    -- Busca o estoque atual do produto
    SELECT estoque_atual INTO v_estoque_atual
    FROM produtos
    WHERE id = NEW.produto_id;

    -- Validação: impede venda de itens físicos sem estoque suficiente
    IF v_estoque_atual < NEW.quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto ID %. Estoque atual: %, Solicitado: %', 
            NEW.produto_id, v_estoque_atual, NEW.quantidade;
    END IF;

    -- Atualiza o estoque decrementando a quantidade vendida
    UPDATE produtos
    SET estoque_atual = estoque_atual - NEW.quantidade
    WHERE id = NEW.produto_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado à tabela itens_venda
DROP TRIGGER IF EXISTS trg_baixa_estoque ON itens_venda;

CREATE TRIGGER trg_baixa_estoque
BEFORE INSERT ON itens_venda
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_estoque_venda();


-- -----------------------------------------------------------------------------
-- 3. FUNCTION & TRIGGER: trg_recalcular_total_venda
-- Regra de Negócio: Recalcula o valor_total na tabela vendas automaticamente
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_recalcular_total_venda()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE vendas
    SET valor_total = (
        SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
        FROM itens_venda
        WHERE venda_id = NEW.venda_id
    )
    WHERE id = NEW.venda_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_atualiza_valor_total ON itens_venda;

CREATE TRIGGER trg_atualiza_valor_total
AFTER INSERT OR UPDATE OR DELETE ON itens_venda
FOR EACH ROW
EXECUTE FUNCTION fn_recalcular_total_venda();