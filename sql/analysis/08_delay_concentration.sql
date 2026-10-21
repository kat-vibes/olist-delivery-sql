-- How many destination states account for most delayed orders?
WITH state_totals AS (
    SELECT customer_state, COUNT(*) AS late_orders
    FROM order_delivery WHERE is_eligible = 1 AND is_late = 1
    GROUP BY customer_state
)
SELECT customer_state, late_orders,
    ROUND(100.0 * late_orders / SUM(late_orders) OVER (), 2) AS late_order_share_pct,
    ROUND(100.0 * SUM(late_orders) OVER (
        ORDER BY late_orders DESC, customer_state
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / SUM(late_orders) OVER (), 2) AS cumulative_late_order_share_pct
FROM state_totals ORDER BY late_orders DESC, customer_state;
