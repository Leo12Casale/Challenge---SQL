-- 1. Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. 
SELECT u.user_id
    ,u.first_name
    , u.last_name
    ,COUNT(po.order_id) AS total_sales
FROM User u
JOIN Item i ON u.user_id = i.seller_id
JOIN PurchaseOrder po ON po.item_id = i.item_id
AND u.birth_date = CAST(CURDATE() AS DATE)
AND po.order_date BETWEEN '2020-01-01' AND '2020-01-31'
GROUP BY u.user_id, u.first_name, u.last_name
HAVING total_sales > 1500;

-- 2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. 
--    Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, 
--    cantidad de productos vendidos y el monto total transaccionado. 

SELECT * FROM (
  SELECT YEAR(po.order_date) AS anio,
    MONTH(po.order_date) AS mes,
    u.first_name AS nombre_vendedor,
    u.last_name AS apellido_vendedor,
    COUNT(po.order_id) AS cantidad_ventas,
    SUM(po.quantity) AS cantidad_productos_vendidos,
    SUM(po.quantity * po.unit_price) AS monto_total_transaccionado,
    ROW_NUMBER() OVER (PARTITION BY YEAR(po.order_date), MONTH(po.order_date) ORDER BY SUM(po.quantity * po.unit_price) DESC) AS posicion
  FROM PurchaseOrder po
  JOIN User u ON po.seller_id = u.user_id
  JOIN Item i ON po.item_id = i.item_id
  JOIN Category c ON i.category_id = c.category_id
  WHERE c.description = 'Celulares'
  AND po.order_date BETWEEN '2020-01-01' AND '2020-12-31'
  GROUP BY anio, mes, po.seller_id
) AS ranking
WHERE posicion <= 5
ORDER BY anio, mes, posicion;

-- 3. Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. 
--    Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item, 
--    vamos a tener únicamente el último estado informado por la PK definida. (Se puede resolver a través de StoredProcedure) 
DELIMITER $$

CREATE PROCEDURE populate_item_historical()
BEGIN
    -- Inserta o actualiza (Upsert) los items, dejando al finalizar cada día, una combinación item+fecha única,
    -- con el último precio y estado que haya tenido cada ítem para esa fecha
    INSERT INTO ItemHistorical (item_id, snapshot_date, price, item_status_id)
    SELECT
        i.item_id,
        CURRENT_DATE(),
        i.price,
        i.item_status_id
    FROM Item i
    ON DUPLICATE KEY UPDATE -- Si la PK ya existe, actualiza precio y status del item
        price = VALUES(price),
        item_status_id = VALUES(item_status_id);
END $$

DELIMITER ;

-- Si se quisiera cronear al finalizar cada día:
SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT IF NOT EXISTS daily_populate_item_historical
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE() + INTERVAL 1 DAY - INTERVAL 1 MINUTE)
DO
BEGIN
    CALL populate_item_historical();
END $$

DELIMITER ;

