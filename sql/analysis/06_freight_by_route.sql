-- Order-level freight burden for single-seller orders. Freight is an amount
-- charged in the dataset, not the carrier's operating cost or profit.
WITH item_totals AS (
    SELECT order_id, MIN(seller_id) AS seller_id,
        SUM(price) AS goods_value, SUM(freight_value) AS freight_value
    FROM order_items GROUP BY order_id HAVING COUNT(DISTINCT seller_id) = 1
), routes AS (
    SELECT d.order_id, d.is_late, i.goods_value, i.freight_value,
        CASE WHEN s.seller_state = d.customer_state
             THEN 'same_state' ELSE 'interstate' END AS route_type
    FROM item_totals i
    JOIN order_delivery d USING (order_id)
    JOIN sellers s USING (seller_id)
    WHERE d.is_eligible = 1 AND i.goods_value > 0
      AND s.seller_state IS NOT NULL AND d.customer_state IS NOT NULL
)
SELECT route_type, COUNT(*) AS eligible_orders,
    ROUND(AVG(freight_value), 2) AS avg_freight_brl,
    ROUND(100.0 * SUM(freight_value) / SUM(goods_value), 2) AS freight_to_goods_pct,
    ROUND(100.0 * AVG(is_late), 2) AS late_pct
FROM routes GROUP BY route_type ORDER BY route_type;
