USE testdb;

-- Creación de la tabla 
CREATE TABLE IF NOT EXISTS items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Consultas
-- Seleccionar todos los elementos
SELECT *
FROM items;

-- Insertar un elemento
INSERT INTO items (nombre, descripcion)
VALUES ('Tarea x', 'Descripción');

-- Actualizar un elemento
UPDATE items 
SET nombre='Nuevo nombre', descripcion='Nueva descripción'
WHERE id=1;

-- Eliminar un elemento
DELETE FROM items
WHERE id=1;
