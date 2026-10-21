-- Are delivery times and late rates changing across purchase cohorts?
-- Exclude the latest purchase month because the source ends mid-cohort.
WITH cutoff AS (
    SELECT date(MAX(order_purchase_timestamp), 'start of month') AS month_start
    FROM orders
)
SELECT
    strftime('%Y-%m', order_purchase_timestamp) AS purchase_month,
    COUNT(*) AS eligible_orders,
    SUM(is_late) AS late_orders,
    ROUND(100.0 * AVG(is_late), 2) AS late_pct,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM order_delivery
WHERE is_eligible = 1
  AND date(order_purchase_timestamp) < (SELECT month_start FROM cutoff)
GROUP BY purchase_month
ORDER BY purchase_month;
