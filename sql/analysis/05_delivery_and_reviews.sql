-- Use the latest review so each order is counted once.
SELECT CASE d.is_late WHEN 1 THEN 'late' ELSE 'on_time' END AS delivery_group,
    COUNT(*) AS reviewed_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(100.0 * AVG(r.review_score <= 2), 2) AS low_score_pct,
    SUM(date(d.order_delivered_customer_date) > date(d.order_estimated_delivery_date))
        AS late_orders
FROM order_delivery d
JOIN latest_reviews r USING (order_id)
WHERE d.is_eligible = 1
  AND r.review_score IS NOT NULL
GROUP BY d.is_late
ORDER BY d.is_late;
