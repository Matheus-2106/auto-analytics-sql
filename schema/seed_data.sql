-- =============================================================================
-- AUTO ANALYTICS & RETAIL DB — SCRIPT DML DE POVOAMENTO (SEED DATA)
-- =============================================================================

TRUNCATE TABLE itens_venda, vendas, produtos, categorias, clientes RESTART IDENTITY CASCADE;

-- -----------------------------------------------------------------------------
-- 1. POVOAMENTO: categorias
-- -----------------------------------------------------------------------------
INSERT INTO categorias (nome_categoria) VALUES 
('Pneus'),
('Óleos e Lubrificantes'),
('Baterias'),
('Acessórios e Ferramentas'),
('Serviços Mecânicos');

-- -----------------------------------------------------------------------------
-- 2. POVOAMENTO: clientes
-- -----------------------------------------------------------------------------
INSERT INTO clientes (nome, cidade, estado, data_cadastro) VALUES 
('Carlos Eduardo Silva', 'Santarém', 'PA', '2025-10-15'),
('Mariana Oliveira', 'Santarém', 'PA', '2025-11-02'),
('Roberto Santos', 'Belém', 'PA', '2025-12-10'),
('Ana Paula Costa', 'Santarém', 'PA', '2026-01-05'),
('Fernando Gomes', 'Manaus', 'AM', '2026-01-20'),
('Juliana Lima', 'Santarém', 'PA', '2026-02-12'),
('Lucas Mendes', 'Belém', 'PA', '2026-03-01');

-- -----------------------------------------------------------------------------
-- 3. POVOAMENTO: produtos
-- Nota: Inclui produtos com estoque abaixo do estoque_minimo para alertas futuros
-- -----------------------------------------------------------------------------
INSERT INTO produtos (categoria_id, nome, preco_custo, preco_venda, estoque_atual, estoque_minimo) VALUES 
(1, 'Pneu ARO 15 195/65 R15', 280.00, 420.00, 24, 10),
(1, 'Pneu ARO 14 175/65 R14', 210.00, 330.00, 4, 8), -- Estoque baixo
(2, 'Óleo Sintético 5W30 1L', 32.00, 58.00, 45, 15),
(2, 'Óleo Semissintético 10W40 1L', 24.00, 42.00, 3, 10), -- Estoque baixo
(3, 'Bateria 60Ah 12V', 290.00, 480.00, 12, 5),
(3, 'Bateria 45Ah 12V', 220.00, 370.00, 2, 5), -- Estoque baixo
(4, 'Jogo de Chaves Soquete 40 Peças', 85.00, 150.00, 18, 5),
(4, 'Calibrador Digital de Pneus', 35.00, 75.00, 10, 5),
(5, 'Alinhamento e Balanceamento', 30.00, 120.00, 999, 0), -- Serviço
(5, 'Troca de Óleo e Filtro (Mão de Obra)', 20.00, 60.00, 999, 0); -- Serviço

-- -----------------------------------------------------------------------------
-- 4. POVOAMENTO: vendas
-- Registro distribuído ao longo dos últimos meses para simulação de MoM
-- -----------------------------------------------------------------------------
INSERT INTO vendas (cliente_id, data_venda, status, valor_total) VALUES 
(1, '2026-01-10 10:30:00', 'CONCLUIDA', 960.00),
(2, '2026-01-18 14:15:00', 'CONCLUIDA', 178.00),
(3, '2026-02-05 09:00:00', 'CONCLUIDA', 1320.00),
(4, '2026-02-14 16:45:00', 'CONCLUIDA', 480.00),
(1, '2026-02-22 11:20:00', 'CANCELADA', 330.00),
(5, '2026-03-02 10:00:00', 'CONCLUIDA', 740.00),
(6, '2026-03-11 15:10:00', 'CONCLUIDA', 180.00),
(7, '2026-03-18 13:30:00', 'CONCLUIDA', 1500.00);

-- -----------------------------------------------------------------------------
-- 5. POVOAMENTO: itens_venda
-- Associação entre vendas e produtos com preservação do preço praticado
-- -----------------------------------------------------------------------------
INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario) VALUES 
-- Venda 1 (Total: 960.00)
(1, 1, 2, 420.00), -- 2x Pneu Aro 15 (840.00)
(1, 9, 1, 120.00), -- 1x Alinhamento (120.00)

-- Venda 2 (Total: 178.00)
(2, 3, 2, 58.00),  -- 2x Óleo Sintético (116.00)
(2, 10, 1, 62.00), -- 1x Mão de obra (62.00 - valor praticado no momento)

-- Venda 3 (Total: 1320.00)
(3, 1, 2, 420.00), -- 2x Pneu Aro 15 (840.00)
(3, 5, 1, 480.00), -- 1x Bateria 60Ah (480.00)

-- Venda 4 (Total: 480.00)
(4, 5, 1, 480.00), -- 1x Bateria 60Ah (480.00)

-- Venda 5 - CANCELADA (Total: 330.00)
(5, 2, 1, 330.00), -- 1x Pneu Aro 14 (330.00)

-- Venda 6 (Total: 740.00)
(6, 6, 2, 370.00), -- 2x Bateria 45Ah (740.00)

-- Venda 7 (Total: 180.00)
(7, 3, 1, 58.00),  -- 1x Óleo Sintético (58.00)
(7, 9, 1, 122.00), -- 1x Alinhamento (122.00)

-- Venda 8 (Total: 1500.00)
(8, 1, 3, 420.00), -- 3x Pneu Aro 15 (1260.00)
(8, 7, 1, 150.00), -- 1x Jogo de Chaves (150.00)
(8, 10, 1, 90.00); -- 1x Mão de obra (90.00)