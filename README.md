# 🚗 Auto Analytics & Retail DB — Modelagem e Análise de Dados em SQL

Este projeto consiste na modelagem e implementação de um banco de dados relacional para controle de vendas, clientes, catálogo de produtos e movimentação de estoque em um cenário do setor de varejo/automotivo.

O objetivo é demonstrar a aplicação prática de **SQL Avançado** (Window Functions, CTEs, Joins complexos), **Integridade Referencial**, **Automação via Triggers/Functions** e **Geração de Métricas Financeiras/Analytics**.

---

## 📌 Diagrama de Entidade-Relacionamento (DER)

Abaixo está o modelo conceitual de dados estruturado para suportar o fluxo completo desde a estocagem até o faturamento.

```mermaid
erDiagram
    CATEGORIAS ||--o{ PRODUTOS : "possuem"
    CLIENTES ||--o{ VENDAS : "realizam"
    VENDAS ||--|{ ITENS_VENDA : "contêm"
    PRODUTOS ||--o{ ITENS_VENDA : "compõem"

    CATEGORIAS {
        int id PK
        string nome_categoria
    }

    PRODUTOS {
        int id PK
        int categoria_id FK
        string nome
        decimal preco_custo
        decimal preco_venda
        int estoque_atual
        int estoque_minimo
    }

    CLIENTES {
        int id PK
        string nome
        string cidade
        string estado
        date data_cadastro
    }

    VENDAS {
        int id PK
        int cliente_id FK
        timestamp data_venda
        string status
        decimal valor_total
    }

    ITENS_VENDA {
        int id PK
        int venda_id FK
        int produto_id FK
        int quantidade
        decimal preco_unitario
    }