-- CREATE DATABASE tecmarket;
USE tecmarket;

-- Tabela CARGO
CREATE TABLE IF NOT EXISTS cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    dc_cargo VARCHAR(70) NOT NULL
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

-- Tabela TELEFONE
CREATE TABLE IF NOT EXISTS telefone (
    id_telefone INT PRIMARY KEY AUTO_INCREMENT,
    telefone VARCHAR(20) NOT NULL,
    id_user INT,
    FOREIGN KEY (id_user) REFERENCES usuarios(id_user)
);

-- Tabela CATEGORIA
CREATE TABLE IF NOT EXISTS categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    dc_categoria VARCHAR(100) NOT NULL
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

-- Tabela FORNECEDOR
CREATE TABLE IF NOT EXISTS fornecedor (
    id_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    dc_fornecedor VARCHAR(100) NOT NULL,
    id_produto INT,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);


-- Procedures
-- ==============================================
-- 1 - Crie um Stored Procedure para cadastrar produtos;
DELIMITER $$
CREATE PROCEDURE CadastrarProduto (
    IN p_dc_produto VARCHAR(100),
    IN p_descricao TEXT,
    IN p_vl_produto DECIMAL(10, 2),
    IN p_qntd_estoque INT
)
BEGIN
    INSERT INTO produto (dc_produto, descricao, vl_produto, qntd_estoque)
    VALUES (p_dc_produto, p_descricao, p_vl_produto, p_qntd_estoque);
END $$
DELIMITER ;

-- 2 - Crie um Stored Procedure para gerar relatório de vendas por data de início e fim;
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

-- 3 - Crie um função para calcular o valor total de cada venda;
DELIMITER $$
CREATE FUNCTION CalcularValorTotalVenda (
    p_id_pedido INT
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);

    -- Correção: Usar INTO para atribuir o valor à variável
    SELECT SUM(vl_item_produto) INTO total
    FROM itens_pedido
    WHERE id_pedido = p_id_pedido;
    
    -- Retorna 0 se for nulo (caso não tenha itens)
    RETURN COALESCE(total, 0.00);
END $$
DELIMITER ;

-- 5 - Crie um trigger para atualizar o estoque quando um item de venda for inserido;

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

-- 6 - Crie um evento (EVENT SCHEDULER) que gere diariamente uma tabela de log de estoque;

-- CREATE TABLE IF NOT EXISTS tabela_log
--     id_produto_log INT PRIMARY KEY AUTO_INCREMENT,
--     dc_produto_log VARCHAR(100) NOT NULL,
--     descricao_log TEXT,
--     vl_produto_log DECIMAL(10, 2) NOT NULL,
--     qntd_estoque_log INT NOT NULL,
--     id_categoria_log INT,
--     data_log DATE,
--     FOREIGN KEY (id_categoria_log) REFERENCES categoria(id_categoria)


-- CREATE EVENT IF NOT EXISTS log_estoque
--     ON SCHEDULE EVERY 1 DAY
--     DO
        



-- -- add cargo com null primeiro para evitar erro de fk
START TRANSACTION;
INSERT INTO cargo (dc_cargo) VALUES
('Atendente'), -- id 1
('Gerente'),   -- id 2
('Caixa');     -- id 3

-- add users (referenciando os cargos criados)
INSERT INTO usuarios (nome, rua, numero, bairro, CEP, id_cargo) VALUES
('Ana Silva', 'Rua A', '123', 'Bairro X', '12345678', NULL), -- Cliente
('Bruno Souza', 'Rua B', '456', 'Bairro Y', '23456789', NULL), -- Cliente
('Carla Mendes', 'Rua C', '789', 'Bairro Z', '34567890', 1), -- Atendente
('Daniel Oliveira', 'Rua D', '101', 'Bairro W', '45678901', 2), -- Gerente
('Eva Costa', 'Rua E', '202', 'Bairro V', '56789012', NULL), -- Cliente
('Fábio Lima', 'Rua F', '303', 'Bairro U', '67890123', 3); -- Caixa
('Ana Silva', 'Rua A', '123', 'Bairro X', '12345678', NULL), -- Cliente
('Bruno Souza', 'Rua B', '456', 'Bairro Y', '23456789', NULL), -- Cliente
('Carla Mendes', 'Rua C', '789', 'Bairro Z', '34567890', 1), -- Atendente
('Daniel Oliveira', 'Rua D', '101', 'Bairro W', '45678901', 2), -- Gerente
('Eva Costa', 'Rua E', '202', 'Bairro V', '56789012', NULL); -- Cliente

SELECT nome,
    COALESCE(dc_cargo,"Cliente") AS cargo
FROM usuarios
LEFT JOIN cargo 
ON usuarios.id_cargo = cargo.id_cargo;

-- Telefones
INSERT INTO telefone (telefone, id_user) VALUES
('11987654321', 1),
('21976543210', 2),
('31965432109', 3),
('41954321098', 4),
('51943210987', 5);
('11987654321', 6),
('21976543210', 7),
('31965432109', 8),
('41954321098', 9),
('51943210987', 10),
('61932109876', 11);


-- Produtos - tem que vir antes para nao bugar
INSERT INTO produto (dc_produto, descricao, vl_produto, qntd_estoque) VALUES
('Notebook Gamer', 'Notebook potente', 5500.00, 10),
('Smartphone Azul', 'Câmera alta resolução', 1500.00, 25),
('Tablet DEF', 'Tablet leve', 1200.00, 15),
('Monitor GHI', 'Monitor 4K', 2000.00, 8)
('Computador Desktop', 'Computador para uso diário', 4500.00, 12),
('Smartphone Preto', 'Câmera de alta qualidade', 1800.00, 30),
('Tablet XYZ', 'Tablet com boa performance', 1300.00, 20),        
('Monitor Full HD', 'Monitor com resolução Full HD', 2200.00, 10),
('Headset Gamer', 'Headset com som surround', 800.00, 15),
('Teclado Mecânico', 'Teclado com switches mecânicos', 600.00, 20);

-- Categorias e Fornecedores
INSERT INTO categoria (dc_categoria) VALUES
('Eletrônicos'), ('Celulares'), ('Tablets'), ('Monitores'),
('Computadores'), ('Acessórios'), ('Periféricos'), ('Gadgets'),
('Hardware'), ('Software');

INSERT INTO fornecedor (dc_fornecedor, id_produto) VALUES
('Tech Distributors Inc.', 1), ('Gadget World', 2), ('Tablet Suppliers Co.', 3), ('Display Masters Ltd.', 4),
('Computer Hub', 5), ('Mobile Solutions', 6), ('Tablet Experts', 7), ('Monitor Pros', 8),
('Audio Gear Inc.', 9), ('Keyboard Kings', 10);

-- Pedidos 
INSERT INTO pedido (id_user, vl_total) VALUES
(1, 12500.00),
(2, 1500.00), 
(1, 10000.00),
(3, 3000.00); 
(3, 12500.00),
(4, 1500.00), 
(1, 10000.00),
(2, 3000.00),
(5, 5000.00),
(6, 7500.00),
(7, 2000.00),
(2, 4500.00); 

-- associativa
INSERT INTO itens_pedido (id_pedido, id_produto, qntd_produto, vl_item_produto) VALUES
(1, 1, 2, 11000.00),
(2, 2, 1, 1500.00),
(3, 1, 1, 5500.00),
(3, 4, 1, 2000.00),
(5, 5, 2, 9000.00),
(6, 6, 1, 1800.00),
(7, 7, 3, 3900.00),
(8, 8, 1, 2200.00),
(9, 9, 5, 4000.00),
(10, 10, 5, 3000.00),
(11, 2, 3, 4500.00);
COMMIT;

