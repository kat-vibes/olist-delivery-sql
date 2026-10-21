-- Sum items and payments separately: joining the raw tables would multiply rows.
WITH item_totals AS (
    SELECT order_id, ROUND(SUM(price + freight_value), 2) AS order_value
    FROM order_items
    GROUP BY order_id
), payment_totals AS (
    SELECT order_id, ROUND(SUM(payment_value), 2) AS paid_value
    FROM payments
    GROUP BY order_id
), reconciled AS (
    SELECT o.order_id, o.order_status, i.order_value, p.paid_value,
        CASE WHEN i.order_id IS NULL THEN 'missing_items'
             WHEN p.order_id IS NULL THEN 'missing_payment'
             WHEN ABS(i.order_value - p.paid_value) > 0.02 THEN 'difference_over_0_02_brl'
             ELSE 'matched_within_0_02_brl' END AS reconciliation_status
    FROM orders o LEFT JOIN item_totals i USING (order_id)
    LEFT JOIN payment_totals p USING (order_id)
)
SELECT reconciliation_status, COUNT(*) AS orders,
    ROUND(SUM(order_value), 2) AS item_total_brl,
    ROUND(SUM(paid_value), 2) AS paid_total_brl
FROM reconciled
GROUP BY reconciliation_status
ORDER BY orders DESC;
