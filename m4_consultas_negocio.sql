-- === M4: Consultas de negocio sobre Ventas_Tech_DB ===
USE Ventas_Tech_DB;
GO

-- Consulta 1: Resumen ejecutivo mensual
SELECT
    MONTH(fecha_venta)                  AS mes,
    SUM(cantidad * precio_unitario)     AS total_facturado,
    COUNT(*)                            AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)     AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);

-- Consulta 2: Ranking de productos (Top 5 por facturación)
SELECT TOP 5
    id_producto,
    SUM(cantidad)                       AS unidades_vendidas,
    SUM(cantidad * precio_unitario)     AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- Consulta 3: Clientes recurrentes (más de un pedido)
SELECT
    id_cliente,
    COUNT(*)                            AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)     AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- Consulta 4: Productos por encima/por debajo del promedio de facturación
WITH total_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM total_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM total_por_producto
ORDER BY total_facturado DESC;

-- === HALLAZGOS ===
-- 1. El producto 1 concentra aproximadamente el 55,9% de la facturación (3600 de 6444),
--    con solo 3 unidades vendidas: es un producto de alto valor.
-- 2. Solo los productos 1 y 3 superan el promedio de facturación por producto (1074,00)
--    y juntos suman cerca del 76,8% del total; los otros cuatro quedaron por debajo.
-- 3. El producto 2 es el más vendido en unidades (13), pero aporta apenas el 5,6% de la
--    facturación porque su precio unitario es bajo (28,00).
