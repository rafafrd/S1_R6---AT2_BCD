CREATE DATABASE IF NOT EXISTS tecmarket;
USE tecmarket;

-- Tabela CARGO
CREATE TABLE IF NOT EXISTS cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    dc_cargo VARCHAR(70) NOT NULL,
    id_user INT
);

-- Tabela USUARIOS
CREATE TABLE IF NOT EXISTS usuarios (
    id_user INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    rua VARCHAR(150),
    numero VARCHAR(10),
    bairro VARCHAR(100),
    CEP VARCHAR(8),
    id_cargo INT,
    FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo)
);

-- Adiciona a FK pq tava criando dependencia
ALTER TABLE cargo
ADD CONSTRAINT fk_cargo_usuario
FOREIGN KEY (id_user) REFERENCES usuarios(id_user);

-- Tabela TELEFONE
CREATE TABLE IF NOT EXISTS telefone (
    id_telefone INT PRIMARY KEY AUTO_INCREMENT,
    telefone VARCHAR(20) NOT NULL,
    id_user INT,
    FOREIGN KEY (id_user) REFERENCES usuarios(id_user)
);

-- Tabela PEDIDO
CREATE TABLE IF NOT EXISTS pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    dt_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_user INT,
    vl_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_user) REFERENCES usuarios(id_user)
);

-- Tabela PRODUTO
CREATE TABLE IF NOT EXISTS produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    dc_produto VARCHAR(100) NOT NULL,
    descricao TEXT,
    vl_produto DECIMAL(10, 2) NOT NULL,
    qntd_estoque INT NOT NULL,
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- Tabela ITENS_PEDIDO (Tabela Associativa)
CREATE TABLE IF NOT EXISTS itens_pedido (
    id_pedido INT,
    id_produto INT,
    qntd_produto INT NOT NULL,
    vl_item_produto DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_pedido, id_produto),
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- Tabela CATEGORIA
CREATE TABLE IF NOT EXISTS categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    dc_categoria VARCHAR(100) NOT NULL
);

-- Tabela FORNECEDOR
CREATE TABLE IF NOT EXISTS fornecedor (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    dc_fornecedor VARCHAR(100) NOT NULL,
    id_produto INT,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);


-- popular tabelas

-- add cargo com null primeiro para evitar erro de fk
INSERT INTO cargo (dc_cargo, id_user) VALUES
('Atendente', NULL), -- id 1
('Gerente', NULL),   -- id 2
('Caixa', NULL);     -- id 3

-- add users (referenciando os cargos criados)
INSERT INTO usuarios (nome, rua, numero, bairro, CEP, id_cargo) VALUES
('Ana Silva', 'Rua A', '123', 'Bairro X', '12345678', NULL), -- Cliente
('Bruno Souza', 'Rua B', '456', 'Bairro Y', '23456789', NULL), -- Cliente
('Carla Mendes', 'Rua C', '789', 'Bairro Z', '34567890', 1), -- Atendente
('Daniel Oliveira', 'Rua D', '101', 'Bairro W', '45678901', 2), -- Gerente
('Eva Costa', 'Rua E', '202', 'Bairro V', '56789012', NULL), -- Cliente
('Fábio Lima', 'Rua F', '303', 'Bairro U', '67890123', 3); -- Caixa

-- att a tabela CARGO para dizer quem ocupa aquele cargo
UPDATE cargo SET id_user = 3 WHERE id_cargo = 1; -- Atendente
UPDATE cargo SET id_user = 4 WHERE id_cargo = 2; -- Gerente
UPDATE cargo SET id_user = 6 WHERE id_cargo = 3; -- Caixa

-- Telefones
INSERT INTO telefone (telefone, id_user) VALUES
('11987654321', 1),
('21976543210', 2),
('31965432109', 3),
('41954321098', 4),
('51943210987', 5);

-- Categorias e Fornecedores
INSERT INTO categoria (dc_categoria) VALUES
('Eletrônicos'), ('Celulares'), ('Tablets'), ('Monitores');
-- Produtos - tem que vir antes para nao bugar
INSERT INTO produto (dc_produto, descricao, vl_produto, qntd_estoque, id_categoria) VALUES
('Notebook Gamer XYZ', 'Notebook potente para jogos e tarefas pesadas.', 5500.00, 10, 1), -- id 1
('Smartphone ABC', 'Smartphone com câmera de alta resolução e desempenho rápido.', 1500.00, 25, 2), -- id 2
('Tablet DEF', 'Tablet leve e versátil para trabalho e entretenimento.', 1200.00, 15, 3), -- id 3
('Monitor 4K GHI', 'Monitor com resolução 4K para imagens nítidas e detalhadas.', 2000.00, 8, 4); -- id 4


INSERT INTO fornecedor (dc_fornecedor, id_produto) VALUES
('Tech Distributors Inc.', 1), ('Gadget World', 2), ('Tablet Suppliers Co.', 3), ('Display Masters Ltd.', 4);

-- Pedidos 
INSERT INTO pedido (id_user, vl_total) VALUES
(1, 12500.00), -- id 1
(2, 1500.00),  -- id 2
(1, 10000.00), -- id 3
(3, 3000.00);  -- id 4

-- associativa
INSERT INTO itens_pedido (id_pedido, id_produto, qntd_produto, vl_item_produto) VALUES
(1, 1, 2, 11000.00),
(2, 2, 1, 1500.00),
(3, 1, 1, 5500.00),
(3, 4, 1, 2000.00),
(4, 3, 2, 2400.00);


-- Procedures
-- ==============================================
DELIMITER $$
CREATE PROCEDURE CadastrarProduto (
    IN p_dc_produto VARCHAR(100),
    IN p_descricao TEXT,
    IN p_vl_produto DECIMAL(10, 2),
    IN p_qntd_estoque INT,
    IN p_id_categoria INT
)
BEGIN
    INSERT INTO produto (dc_produto, descricao, vl_produto, qntd_estoque, id_categoria)
    VALUES (p_dc_produto, p_descricao, p_vl_produto, p_qntd_estoque, p_id_categoria);
END $$
DELIMITER ;

CALL `CadastrarProduto`('Fone de Ouvido XYZ', 'Fone de ouvido com cancelamento de ruído.', 300.00, 50, 1);
SELECT * FROM produto;

-- Procedure: Relatório Vendas
DELIMITER $$
CREATE PROCEDURE RelatorioVendasPorData (
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT p.id_pedido, p.dt_pedido, u.nome AS cliente, p.vl_total
    FROM pedido p
    JOIN usuarios u ON p.id_user = u.id_user
    WHERE DATE(p.dt_pedido) BETWEEN p_data_inicio AND p_data_fim;
END $$
DELIMITER ;
CALL RelatorioVendasPorData('2025-11-01', '2025-11-30');

-- Function: Calcular Valor Total
DELIMITER $$
CREATE FUNCTION CalcularValorTotalVenda (
    p_id_pedido INT -- id do pedido
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);

    -- Correção: Usar INTO para atribuir o valor à variável
    SELECT SUM(vl_item_produto) INTO total -- soma os produtos
    FROM itens_pedido
    WHERE id_pedido = p_id_pedido;
    
    -- Retorna 0 se for nulo (caso não tenha itens)
    RETURN COALESCE(total, 0.00); -- retorna valor total
END $$
DELIMITER ;

select CalcularValorTotalVenda(3);

-- Crie um função para calcular o valor de desconto de um determinado produto (preço, percentual);
DELIMITER $$
CREATE FUNCTION CalcularDescontoProduto (
    p_vl_produto DECIMAL(10, 2),
    p_percentual_desconto INT
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE valor_desconto INT;
    SET valor_desconto = (p_vl_produto * p_percentual_desconto) / 100;
    RETURN valor_desconto;
END $$
DELIMITER ;

SELECT CalcularDescontoProduto(2000.00, 10) AS desconto;

-- Crie um trigger para atualizar o esqoque quando um item de venda for inserido;
DELIMITER $$
CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE produto
    SET qntd_estoque = qntd_estoque - NEW.qntd_produto
    WHERE id_produto = NEW.id_produto;
END $$
DELIMITER ;
