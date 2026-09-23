-- =============================================================================
-- AUTO ANALYTICS & RETAIL DB — SCRIPT DDL DE CRIAÇÃO DAS TABELAS
-- =============================================================================

DROP TABLE IF EXISTS itens_venda CASCADE;
DROP TABLE IF EXISTS vendas CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- -----------------------------------------------------------------------------
-- 1. TABELA: categorias
-- Classificação dos produtos para relatórios e agrupamentos
-- -----------------------------------------------------------------------------
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL UNIQUE
);

-- -----------------------------------------------------------------------------
-- 2. TABELA: clientes
-- Registro de clientes da rede de lojas
-- -----------------------------------------------------------------------------
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL,
    data_cadastro DATE NOT NULL DEFAULT CURRENT_DATE
);

-- -----------------------------------------------------------------------------
-- 3. TABELA: produtos
-- Catálogo de produtos com preços e regra de controle de estoque
-- -----------------------------------------------------------------------------
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    categoria_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    preco_custo NUMERIC(10, 2) NOT NULL CHECK (preco_custo >= 0),
    preco_venda NUMERIC(10, 2) NOT NULL CHECK (preco_venda >= 0),
    estoque_atual INT NOT NULL DEFAULT 0 CHECK (estoque_atual >= 0),
    estoque_minimo INT NOT NULL DEFAULT 5 CHECK (estoque_minimo >= 0),
    
    CONSTRAINT fk_produtos_categorias 
        FOREIGN KEY (categoria_id) 
        REFERENCES categorias(id) 
        ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- 4. TABELA: vendas
-- Registro principal de transações
-- -----------------------------------------------------------------------------
CREATE TABLE vendas (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    data_venda TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'CONCLUIDA' 
        CHECK (status IN ('CONCLUIDA', 'CANCELADA', 'PENDENTE')),
    valor_total NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (valor_total >= 0),

    CONSTRAINT fk_vendas_clientes 
        FOREIGN KEY (cliente_id) 
        REFERENCES clientes(id) 
        ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- 5. TABELA: itens_venda
-- Detalhamento N:N entre vendas e produtos (preserva o preço histórico praticado)
-- -----------------------------------------------------------------------------
CREATE TABLE itens_venda (
    id SERIAL PRIMARY KEY,
    venda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(10, 2) NOT NULL CHECK (preco_unitario >= 0),

    CONSTRAINT fk_itens_vendas 
        FOREIGN KEY (venda_id) 
        REFERENCES vendas(id) 
        ON DELETE CASCADE,

    CONSTRAINT fk_itens_produtos 
        FOREIGN KEY (produto_id) 
        REFERENCES produtos(id) 
        ON DELETE RESTRICT
);