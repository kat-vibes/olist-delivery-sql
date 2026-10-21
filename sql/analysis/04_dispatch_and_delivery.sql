-- Is a missed shipping deadline associated with a late delivery?
-- Only orders with consistent item deadlines and a carrier timestamp.
WITH deadlines AS (
    SELECT order_id, MIN(shipping_limit_date) AS deadline
    FROM order_items GROUP BY order_id
    HAVING COUNT(shipping_limit_date) = COUNT(*)
       AND MIN(shipping_limit_date) = MAX(shipping_limit_date)
), dispatch AS (
    SELECT d.*,
        CASE WHEN julianday(d.order_delivered_carrier_date) > julianday(i.deadline)
             THEN 'after_shipping_deadline' ELSE 'within_shipping_deadline' END AS dispatch_group
    FROM order_delivery d JOIN deadlines i USING (order_id)
    WHERE d.is_eligible = 1
      AND julianday(d.order_delivered_carrier_date)
          BETWEEN julianday(d.order_purchase_timestamp)
              AND julianday(d.order_delivered_customer_date)
)
SELECT dispatch_group, COUNT(*) AS eligible_orders,
    SUM(is_late) AS late_orders, ROUND(100.0 * AVG(is_late), 2) AS late_pct,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM dispatch GROUP BY dispatch_group ORDER BY dispatch_group;
