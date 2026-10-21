-- Keep one seller per order so the same delivery is not counted for several sellers.
WITH single_seller AS (
    SELECT
        order_id,
        MIN(seller_id) AS seller_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(DISTINCT seller_id) = 1
), seller_metrics AS (
    SELECT
        s.seller_id,
        COUNT(*) AS eligible_orders,
        SUM(d.is_late) AS late_orders,
        AVG(d.is_late) AS late_rate
    FROM single_seller s
    JOIN order_delivery d USING (order_id)
    WHERE d.is_eligible = 1
    GROUP BY s.seller_id
    HAVING COUNT(*) >= 100
)
SELECT
    m.seller_id,
    s.seller_state,
    m.eligible_orders,
    m.late_orders,
    ROUND(100.0 * m.late_rate, 2) AS late_pct,
    DENSE_RANK() OVER (ORDER BY m.late_rate DESC) AS late_rate_rank
FROM seller_metrics m
JOIN sellers s USING (seller_id)
ORDER BY late_rate_rank, m.seller_id;
