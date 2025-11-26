DROP DATABASE IF EXISTS tecmarket; -- Adicionado para garantir limpeza ao re-rodar
CREATE DATABASE tecmarket;
USE tecmarket;

-- Tabela CARGO
CREATE TABLE IF NOT EXISTS cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    dc_cargo VARCHAR(70) NOT NULL
);

-- Tabela FUNCIONARIOS
CREATE TABLE IF NOT EXISTS funcionarios (
    id_func INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    id_cargo INT,
    FOREIGN KEY(id_cargo) REFERENCES cargo(id_cargo)
);

-- Tabela USUARIOS
CREATE TABLE IF NOT EXISTS usuarios (
    id_user INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    rua VARCHAR(150),
    numero VARCHAR(10),
    bairro VARCHAR(100),
    CEP VARCHAR(8)
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
    id_func INT,
    vl_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_user) REFERENCES usuarios(id_user),
    FOREIGN KEY (id_func) REFERENCES funcionarios(id_func)
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

-- Tabela ITENS_PEDIDO 
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



-- 1 - Stored Procedure para cadastrar produtos
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
    SELECT SUM(vl_item_produto) INTO total
    FROM itens_pedido
    WHERE id_pedido = p_id_pedido;
    RETURN COALESCE(total, 0.00);
END $$
DELIMITER ;

-- 4 - Crie um função para calcular o valor de desconto de um determinado produto (preço, percentual);
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

-- 5 - Trigger para atualizar o estoque
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

-- 6 - Evento (EVENT SCHEDULER) para log de estoque
CREATE TABLE IF NOT EXISTS tabela_log (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_produto_log INT,
    dc_produto_log VARCHAR(100) NOT NULL,
    descricao_log TEXT,
    vl_produto_log DECIMAL(10, 2) NOT NULL,
    qntd_estoque_log INT NOT NULL,
    id_categoria_log INT,
    data_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

DELIMITER $$
CREATE EVENT IF NOT EXISTS log_estoque
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    INSERT INTO tabela_log(id_produto_log, dc_produto_log, descricao_log, vl_produto_log, qntd_estoque_log, id_categoria_log)
    SELECT id_produto, dc_produto, descricao, vl_produto, qntd_estoque, id_categoria FROM produto;
END $$
DELIMITER ;



-- 7 Crie um script SQL para popular o banco de dados, insira ao menos 10 registros em cada tabela (DML);
START TRANSACTION;

-- Cargos
INSERT INTO cargo (dc_cargo) VALUES
('Gerente Geral'),
('Supervisor de Estoque'),  
('Estoquista'),
('Comprador'),
('Vendedor'),
('Caixa'),
('Aendente de Pos Venda'),
('Suporte Tecnico'),
('Analista Financeiro'),
('Auxiliar Administrativo');
SELECT * FROM cargo;

-- Funcionarios
INSERT INTO funcionarios (nome, id_cargo) VALUES
('Carla Mendes', 1), 
('Daniel Oliveira', 2), 
('Fábio Lima', 3),
('Gabriela Santos', 4), 
('Hugo Ferreira', 5), -- vendedor
('Isabela Rocha', 6),
('Ferreira Silva', 5), -- vendedor
('Mariana Pinto', 8), 
('Natália Gomes', 5), -- vendedor
('Otávio Cardoso', 10);

-- Usuarios
INSERT INTO usuarios (nome, rua, numero, bairro, CEP) VALUES
('Ana Silva', 'Rua A', '123', 'Bairro X', '12345678'),     
('Bruno Souza', 'Rua B', '456', 'Bairro Y', '23456789'),     
('Carla Mendes', 'Rua C', '789', 'Bairro Z', '34567890'),      
('Daniel Oliveira', 'Rua D', '101', 'Bairro W', '45678901'),    
('Eva Costa', 'Rua E', '202', 'Bairro V', '56789012'),   
('Fábio Lima', 'Rua F', '303', 'Bairro U', '67890123'),       
('Geraldo Alck', 'Rua G', '404', 'Bairro T', '78901234'),   
('Helena Trop', 'Rua H', '505', 'Bairro S', '89012345'),     
('Igor Karkar', 'Rua I', '606', 'Bairro R', '90123456'),     
('Joana Dark', 'Rua J', '707', 'Bairro Q', '01234567'),       
('Kleber Bam', 'Rua K', '808', 'Bairro P', '12345098');   

-- Telefones
INSERT INTO telefone (telefone, id_user) VALUES
('11987654321', 1), ('21976543210', 2), ('31965432109', 3),
('41954321098', 4), ('51943210987', 5), ('11987654321', 6),
('21976543210', 7), ('31965432109', 8), ('41954321098', 9),
('51943210987', 10), ('61932109876', 11);

-- Categorias
INSERT INTO categoria (dc_categoria) VALUES
('Eletrônicos'), ('Celulares'), ('Tablets'), ('Monitores'),
('Computadores'), ('Acessórios'), ('Periféricos'), ('Gadgets'),
('Hardware'), ('Software');

-- Produtos

INSERT INTO produto (dc_produto, descricao, vl_produto, qntd_estoque, id_categoria) VALUES
('Smartphone X1', 'Smartphone de última geração', 5500.00, 50, 2),  -- ID 1
('Tablet Pro 10', 'Tablet profissional', 1500.00, 30, 3),           -- ID 2
('Monitor UltraWide', 'Monitor ultrawide', 2000.00, 20, 4),         -- ID 3
('Laptop Gamer Z', 'Laptop potente', 9000.00, 15, 5),               -- ID 4
('Smartphone Y2', 'Custo-benefício', 1800.00, 40, 2),               -- ID 5
('Tablet Mini', 'Tablet compacto', 1300.00, 25, 3),                 -- ID 6
('Monitor 4K', 'Monitor 4K', 2200.00, 10, 4),                       -- ID 7
('Fone Bluetooth', 'Sem fio', 800.00, 60, 6),                       -- ID 8
('Teclado Mecânico', 'RGB', 600.00, 70, 7),                         -- ID 9
('Mouse Gamer', 'Alta precisão', 300.00, 80, 7);                    -- ID 10

-- Fornecedores
INSERT INTO fornecedor (dc_fornecedor, id_produto) VALUES
('Tech Distributors Inc.', 1), ('Gadget World', 2), ('Tablet Suppliers Co.', 3), 
('Display Masters Ltd.', 4), ('Computer Hub', 5), ('Mobile Solutions', 6), 
('Tablet Experts', 7), ('Monitor Pros', 8), ('Audio Gear Inc.', 9), ('Keyboard Kings', 10);

-- Pedidos 
INSERT INTO pedido (id_user, vl_total, id_func) VALUES
(1, 11000.00, 5),
(2, 1500.00, 5),
(3, 7500.00, 7),
(4, 2000.00, 7),
(5, 9000.00, 9),
(6, 1800.00, 9),
(7, 3900.00, 7),
(8, 2200.00, 7),
(9, 4000.00, 5),
(10, 3000.00, 5),
(11, 4500.00, 9);


-- Itens Pedido
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
(11, 9, 3, 4500.00);

COMMIT;

-- 8 - Crie simulações de vendas pra validar se todos os itens criados acima são funcionais;
SELECT id_pedido, dt_pedido, u.nome FROM pedido p JOIN usuarios u ON p.id_user = u.id_user;

-- Inserir pedido e item para ver se baixa o estoque do produto 10 (Mouse Gamer, estoque atual 80)
INSERT INTO pedido (id_user, vl_total, id_func) VALUES (1, 600.00, 5);
INSERT INTO itens_pedido (id_pedido, id_produto, qntd_produto, vl_item_produto) VALUES (13, 10, 2, 600.00);
-- Checar se estoque do produto 10 caiu para 78
SELECT * FROM produto


-- 9 - Crie uma consulta para exibir uma lista de produtos com a descrição de suas categorias;
SELECT p.dc_produto, p.descricao, c.dc_categoria
FROM produto p
JOIN categoria c ON p.id_categoria = c.id_categoria;

-- 10 - Crie uma consulta para exibir as vendas com nome de cliente e funcionário;
SELECT p.id_pedido, u.nome AS Cliente, f.nome AS Funcionario, p.vl_total 
FROM pedido p
LEFT JOIN usuarios u ON p.id_user = u.id_user
LEFT JOIN funcionarios f ON p.id_func = f.id_func;

-- 11 - Crie uma consulta para exibir o total de vendas por dia;
SELECT DATE(dt_pedido) AS data_venda, SUM(vl_total) AS total_vendas
FROM pedido
GROUP BY DATE(dt_pedido);

-- 12 - Crie uma consulta para exibir os produtos mais vendidos;
SELECT p.dc_produto, SUM(ip.qntd_produto) AS total_vendido
FROM itens_pedido ip
JOIN produto p ON ip.id_produto = p.id_produto
GROUP BY p.dc_produto
ORDER BY total_vendido DESC;

-- 13 - Crie uma consulta para exibir a quantidade de produtos por categoria;
SELECT
    c.dc_categoria,
    COUNT(p.id_produto) AS quantidade_produtos
FROM produto p
JOIN categoria c ON p.id_categoria = c.id_categoria
GROUP BY c.dc_categoria;

-- 14 - Crie uma consulta para exibir produtos acima do preço médio geral;
SELECT p.dc_produto, p.descricao, p.vl_produto, p.qntd_estoque
FROM produto AS p
WHERE p.vl_produto > (
    SELECT AVG(vl_produto) FROM produto
)

-- preciso q vc coloque ;
-- 15 - Crie uma consulta para exibir funcionários com maior número de vendas;
SELECT
    f.nome AS funcionario,
    COUNT(p.id_pedido) AS total_vendas
FROM pedido p
JOIN funcionarios f ON p.id_func = f.id_func
WHERE p.id_func IS NOT NULL
GROUP BY f.nome;

-- 16 - Crie uma função para exibir para exibir estoque baixo;
DELIMITER $$
CREATE PROCEDURE ExibirEstoqueBaixo (
    IN p_limite INT -- O parâmetro de entrada deve ser declarado como IN
)
BEGIN
    -- O SELECT é executado diretamente na procedure
    SELECT 
        dc_produto, 
        qntd_estoque
    FROM 
        produto
    WHERE 
        qntd_estoque < p_limite;
END $$

DELIMITER ;
CALL ExibirEstoqueBaixo(20); -- Chame a procedure com o limite de 20


-- 17 - Crie uma função para exibir o valor total de cada venda;   
