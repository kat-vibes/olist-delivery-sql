PRAGMA foreign_keys = ON;

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT NOT NULL,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL REFERENCES customers(customer_id),
    order_status TEXT NOT NULL,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

CREATE TABLE order_items (
    order_id TEXT REFERENCES orders(order_id),
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT REFERENCES sellers(seller_id),
    shipping_limit_date TEXT,
    price REAL,
    freight_value REAL,
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE payments (
    order_id TEXT REFERENCES orders(order_id),
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value REAL,
    PRIMARY KEY (order_id, payment_sequential)
);

-- Review IDs are not unique in the source. Keep every source row.
CREATE TABLE reviews (
    source_row INTEGER PRIMARY KEY,
    review_id TEXT,
    order_id TEXT REFERENCES orders(order_id),
    review_score INTEGER CHECK (review_score BETWEEN 1 AND 5),
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_items_seller ON order_items(seller_id);
CREATE INDEX idx_reviews_order ON reviews(order_id);

CREATE VIEW order_delivery AS
SELECT
    o.*,
    c.customer_state,
    CASE WHEN o.order_status = 'delivered'
        AND date(o.order_purchase_timestamp) IS NOT NULL
        AND date(o.order_estimated_delivery_date) IS NOT NULL
        AND julianday(o.order_delivered_customer_date)
            >= julianday(o.order_purchase_timestamp)
        THEN 1 ELSE 0 END AS is_eligible,
    -- Promises are date-based: delivery later on the promised day is on time.
    CASE WHEN date(o.order_delivered_customer_date)
        > date(o.order_estimated_delivery_date) THEN 1 ELSE 0 END AS is_late,
    julianday(o.order_delivered_customer_date)
        - julianday(o.order_purchase_timestamp) AS delivery_days
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

CREATE VIEW latest_reviews AS
SELECT order_id, review_score
FROM (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY review_creation_date DESC, review_answer_timestamp DESC,
                 review_id DESC, source_row DESC
    ) AS review_rank
    FROM reviews
)
WHERE review_rank = 1;
