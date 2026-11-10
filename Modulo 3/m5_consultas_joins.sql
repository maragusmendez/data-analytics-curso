-- === M5: Consultas con JOINs sobre Ventas_Tech_DB ===
USE Ventas_Tech_DB;
GO
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: ver cada venta con nombre de cliente, producto y categoría en una sola fila.
SELECT
    v.fecha_venta,
    v.id_cliente,
    c.nombre                         AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario   AS total_venta
FROM ventas AS v
INNER JOIN clientes   AS c   ON v.id_cliente  = c.id_cliente
INNER JOIN productos  AS p   ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;

-- Hallazgo: las 10 ventas se cruzaron con cliente, producto y categoría sin perder ninguna fila.
-- Las 4 ventas de mayor valor corresponden a la categoría Computación.

-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento, para que el área de producto los revise.
SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazgo: 0 de los 6 productos del catálogo quedaron sin ventas; todos tuvieron movimiento en marzo de 2024.
-- Para el área de producto no hay artículos sin rotación que revisar con estos datos.

-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: comparar la facturación de dos períodos de marzo apilando dos SELECT con una etiqueta de origen.
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Primera mitad de marzo' AS canal
    FROM ventas
    WHERE fecha_venta <= '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Segunda mitad de marzo' AS canal
    FROM ventas
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal;

-- Hallazgo: la primera mitad de marzo facturó 3620 (56,2% del total) contra 2824 (43,8%) de la segunda mitad.
-- Las ventas se concentraron en los primeros días del mes, impulsadas por la venta de 2 laptops el día 5.

