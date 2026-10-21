-- Which destinations have high late rates? Require at least 100 eligible orders.
SELECT
    customer_state,
    COUNT(*) AS eligible_orders,
    SUM(is_late) AS late_orders,
    ROUND(100.0 * AVG(is_late), 2) AS late_pct,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    RANK() OVER (ORDER BY AVG(is_late) DESC) AS late_rate_rank
FROM order_delivery
WHERE is_eligible = 1
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY late_rate_rank, customer_state;
