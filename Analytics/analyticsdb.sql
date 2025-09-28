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
INSERT INTO clientes (nombre, email, telefono) 
VALUES ('Andrea Ramirez',  'andre@ejemplo.com','3104556782');
INSERT INTO productos (nombre, precio) 
VALUES('TV SAMSUNG 50" Pulgadas', 250.00);
INSERT INTO pedidos (cliente_id, fecha_pedido)
SELECT id, CURDATE() FROM clientes WHERE email='andre@ejemplo.com';
SET @p_andre := LAST_INSERT_ID();
INSERT INTO DetallesPedidos (pedido_id, producto_id, cantidad)
SELECT @p_andre, id, 1 FROM productos WHERE nombre='TV SAMSUNG 50" Pulgadas';

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
