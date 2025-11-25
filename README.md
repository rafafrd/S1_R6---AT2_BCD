# 🛒 TecMarket Database Project

Este projeto consiste na modelagem e implementação de um banco de dados relacional para a **TecMarket**, um cenário de varejo focado em gestão de vendas, estoque e colaboradores. O desenvolvimento abrange desde a normalização de dados até a criação de rotinas avançadas de banco de dados (Stored Procedures, Functions e Triggers).

## 🎯 Objetivos da Atividade

O projeto visa demonstrar competências em SQL e modelagem de dados, cumprindo os seguintes requisitos:

  - [x] Modelagem de dados (DER) e Normalização.
  - [x] Criação de Dicionário de Dados.
  - [x] Implementação de DDL (Estrutura do Banco).
  - [x] Manipulação de DML (Inserção de dados e Testes).
  - [x] Desenvolvimento de Scripts Avançados (Procedures, Functions, Triggers, Events e Views).

## 🗂️ Estrutura do Banco de Dados

O banco de dados `tecmarket` foi normalizado para garantir integridade e eficiência. Abaixo, o diagrama conceitual das entidades principais:

### Principais Tabelas

  * **`usuarios`**: Armazena dados de Clientes e Funcionários.
  * **`cargo`**: Define as funções dos colaboradores (Gerente, Caixa, Atendente).
  * **`produto`**: Catálogo de itens vendidos e controle de estoque.
  * **`pedido`**: Cabeçalho das vendas realizadas.
  * **`itens_pedido`**: Tabela associativa detalhando os produtos de cada venda.
  * **`categoria` / `fornecedor`**: Classificação e origem dos produtos.
  * **`telefone`**: Contatos dos usuários.

## ⚙️ Funcionalidades Implementadas

O sistema conta com automações e funções nativas do MySQL Server:

### 📦 Stored Procedures

1.  **`CadastrarProduto`**: Facilita a inserção segura de novos itens no inventário.
2.  **`RelatorioVendasPorData`**: Gera um relatório de vendas filtrado por um período (Data Início/Fim).

### 🧮 Functions

1.  **`CalcularValorTotalVenda`**: Calcula automaticamente o valor total de um pedido somando seus itens.
2.  **`CalcularDesconto`**: Aplica percentuais de desconto sobre o valor do produto.
3.  **`VerificarEstoqueBaixo`**: Alerta sobre produtos com quantidade crítica.

### ⚡ Triggers e Eventos

  * **Trigger de Estoque**: Atualiza automaticamente a coluna `qntd_estoque` na tabela `produto` após a inserção de um item no pedido.
  * **Event Scheduler**: Gera diariamente um log do estado atual do estoque para auditoria.

### 📊 Relatórios e Views

Uma **VIEW** gerencial foi criada para consolidar dados de Vendas, Clientes e Funcionários responsáveis, facilitando a análise de desempenho sem necessidade de *joins* complexos repetitivos.

## 🛠️ Tecnologias Utilizadas

  * **SGBD:** MySQL Server
  * **Linguagem:** SQL (Structured Query Language)
  * **Ferramentas:** MySQL Workbench / VS Code

-----
