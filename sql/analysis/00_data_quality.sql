-- Order-level audit. A row can fail more than one check.
SELECT
    COUNT(*) AS total_orders,
    SUM(order_status = 'delivered') AS delivered_orders,
    SUM(is_eligible) AS eligible_orders,
    SUM(is_eligible = 1 AND is_late = 1) AS eligible_late_orders,
    ROUND(100.0 * SUM(is_eligible = 1 AND is_late = 1) / NULLIF(SUM(is_eligible), 0), 2)
        AS overall_late_pct,
    MIN(order_purchase_timestamp) AS first_purchase,
    MAX(order_purchase_timestamp) AS last_purchase,
    SUM(order_status = 'delivered' AND order_delivered_customer_date IS NULL)
        AS delivered_without_delivery_timestamp,
    SUM(order_status = 'delivered' AND order_estimated_delivery_date IS NULL)
        AS delivered_without_estimate,
    SUM(julianday(order_delivered_customer_date) < julianday(order_purchase_timestamp))
        AS delivery_before_purchase,
    (SELECT COUNT(*) FROM (
        SELECT order_id FROM reviews GROUP BY order_id HAVING COUNT(*) > 1
    )) AS orders_with_multiple_reviews,
    (SELECT COUNT(*) FROM (
        SELECT order_id FROM order_items GROUP BY order_id
        HAVING COUNT(DISTINCT seller_id) > 1
    )) AS multi_seller_orders
FROM order_delivery;
