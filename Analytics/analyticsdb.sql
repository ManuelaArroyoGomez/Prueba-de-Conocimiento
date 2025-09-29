CREATE DATABASE IF NOT EXISTS analyticsdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE analyticsdb;

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS Clientes (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(100) NOT NULL,
  email     VARCHAR(150) NOT NULL UNIQUE,
  telefono  VARCHAR(30)
) ENGINE=InnoDB;

-- Tabla de pedidos
CREATE TABLE IF NOT EXISTS Pedidos (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id   INT NOT NULL,
  fecha_pedido DATE NOT NULL,
  CONSTRAINT fk_pedidos_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_pedidos_cliente (cliente_id),
  INDEX idx_pedidos_fecha (fecha_pedido)
) ENGINE=InnoDB;

-- Tabla de productos
CREATE TABLE IF NOT EXISTS Productos (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  nombre  VARCHAR(120) NOT NULL,
  precio  DECIMAL(10,2) NOT NULL CHECK (precio >= 0)
) ENGINE=InnoDB;

-- Tabla de detalles de pedidos
CREATE TABLE IF NOT EXISTS DetallesPedidos (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id   INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad    INT NOT NULL CHECK (cantidad > 0),
  CONSTRAINT fk_det_pedido
    FOREIGN KEY (pedido_id)  REFERENCES pedidos(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_det_producto
    FOREIGN KEY (producto_id) REFERENCES productos(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_det_pedido (pedido_id),
  INDEX idx_det_producto (producto_id)
) ENGINE=InnoDB;

-- Insertar valores a las tablas
INSERT INTO Clientes (nombre, email, telefono) 
VALUES ('Manuela Arroyo',  'manu@ejemplo.com',     '30014777128'),
	   ('Juan Pérez',      'juanperez@mail.com',   '3001234567'),
	   ('María Gómez',     'mariagomez@mail.com',  '3109876543'),
       ('Carlos Ramírez',  'carlosramirez@mail.com','3112223344'),
       ('Ana Torres',      'anatorres@mail.com',   '3156789012'),
       ('Pedro Sánchez',   'pedrosanchez@mail.com','3124445566'),
       ('Laura Herrera',   'lauraherrera@mail.com','3201112233'),
       ('Jorge Castillo',  'jorgecastillo@mail.com','3019871234'),
       ('Sofía López',     'sofialopez@mail.com',  '3176667788'),
       ('Rafael Valencia', 'rafa@ejemplo.com',     '3001234567');
       
INSERT INTO Productos (nombre, precio) 
VALUES ('AirPods Pro 3',                   199.90),
	   ('Laptop Lenovo ThinkPad',         3500.00),
       ('Smartphone Samsung Galaxy S21',  2800.00),
       ('Monitor LG 24”',                  900.00),
       ('Teclado Mecánico Redragon',       250.00),
       ('Mouse Logitech MX Master 3',      400.00),
       ('Audífonos Sony WH-1000XM4',      1200.00),
       ('Tablet Apple iPad Air',          2300.00),
       ('Disco Duro Externo 1TB',          500.00),
       ('Impresora HP DeskJet',            850.00),
       ('Smartwatch Xiaomi',               650.00),
       ('Iphone 17 Pro',                   999.90);
       
INSERT INTO Pedidos (cliente_id, fecha_pedido)
SELECT id, CURDATE() FROM Clientes WHERE email='manu@ejemplo.com';
SET @p_manu := LAST_INSERT_ID();
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_manu, id, 1 FROM Productos WHERE nombre='AirPods Pro 3';

INSERT INTO Pedidos (cliente_id, fecha_pedido)
SELECT id, CURDATE() FROM clientes WHERE email='mariagomez@mail.com';
SET @p_maria := LAST_INSERT_ID();
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_maria, id, 1 FROM Productos WHERE nombre='Laptop Lenovo ThinkPad';
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_maria, id, 1 FROM Productos WHERE nombre='Teclado Mecánico Redragon';
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_maria, id, 1 FROM Productos WHERE nombre='Smartwatch Xiaomi';

INSERT INTO Pedidos (cliente_id, fecha_pedido)
SELECT id, CURDATE() FROM Clientes WHERE email='carlosramirez@mail.com';
SET @p_carlos := LAST_INSERT_ID();
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_carlos, id, 2 FROM Productos WHERE nombre='Monitor LG 24”';
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_carlos, id, 1 FROM Productos WHERE nombre='Disco Duro Externo 1TB';

INSERT INTO Pedidos (cliente_id, fecha_pedido)
SELECT id, CURDATE() FROM Clientes WHERE email='lauraherrera@mail.com';
SET @p_laura := LAST_INSERT_ID();
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_laura, id, 1 FROM Productos WHERE nombre='Audífonos Sony WH-1000XM4';
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_laura, id, 1 FROM Productos WHERE nombre='Impresora HP DeskJet';

INSERT INTO Pedidos (cliente_id, fecha_pedido)
SELECT id, CURDATE() FROM Clientes WHERE email='jorgecastillo@mail.com';
SET @p_jorge := LAST_INSERT_ID();
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_jorge, id, 1 FROM Productos WHERE nombre='Tablet Apple iPad Air';
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_jorge, id, 1 FROM Productos WHERE nombre='Mouse Logitech MX Master 3';
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_jorge, id, 1 FROM Productos WHERE nombre='Teclado Mecánico Redragon';

-- Consulta del reporte
SELECT 
  c.nombre  AS `Nombre Cliente`,
  c.email   AS `Email Cliente`,
  COALESCE(ROUND(SUM(dp.cantidad * p.precio), 2), 0) AS `Valor Total del Pedido`
FROM clientes c
LEFT JOIN Pedidos pe          ON pe.cliente_id = c.id
LEFT JOIN DetallesPedidos dp ON dp.pedido_id = pe.id
LEFT JOIN Productos p         ON p.id = dp.producto_id
GROUP BY c.id, c.nombre, c.email
ORDER BY `Valor Total del Pedido` DESC;

-- Vista del reporte
CREATE OR REPLACE VIEW vw_reporte_clientes AS
SELECT 
  c.id      AS cliente_id,
  c.nombre,
  c.email,
  COALESCE(ROUND(SUM(dp.cantidad * p.precio), 2), 0) AS total
FROM Clientes c
LEFT JOIN Pedidos pe          ON pe.cliente_id = c.id
LEFT JOIN DetallesPedidos dp ON dp.pedido_id = pe.id
LEFT JOIN Productos p         ON p.id = dp.producto_id
GROUP BY c.id, c.nombre, c.email;

SELECT * FROM analyticsdb.vw_reporte_clientes;
