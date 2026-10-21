# Tables and analytical grain

| Table | One row represents | Key | Rows in this snapshot |
| --- | --- | --- | ---: |
| customers | Customer identity attached to an order | customer_id | 99,441 |
| orders | Order | order_id | 99,441 |
| order_items | Item line within an order | order_id + order_item_id | 112,650 |
| sellers | Seller | seller_id | 3,095 |
| payments | Payment sequence within an order | order_id + payment_sequential | 103,886 |
| reviews | Source review row | source_row (generated on import) | 99,224 |

`customer_unique_id` identifies repeat customers across orders. `customer_id`
is the order-linked identifier, so counting it does not count distinct people.
Location strings and zip-code prefixes are retained as text.

## Dates

- `order_purchase_timestamp`: when the order was placed.
- `order_approved_at`: payment approval timestamp.
- `order_delivered_carrier_date`: carrier handover timestamp at order level.
- `order_delivered_customer_date`: recorded customer delivery timestamp.
- `order_estimated_delivery_date`: promised delivery date. Compare calendar
  dates to avoid marking a delivery later on the promised day as late.
- `shipping_limit_date`: item-level shipping deadline. Dispatch analysis only
  uses orders where every item has the same non-null deadline.
- `review_creation_date` and `review_answer_timestamp`: used to choose the
  latest source review per order; ties use review ID and source row number.

Timestamps are interpreted as supplied, without inventing timezone offsets.
Delivery duration is an elapsed-day measure, not a business-day measure.

## Amounts

- `price`: item price in BRL.
- `freight_value`: freight charge attached to an item, in BRL.
- `payment_value`: amount for a payment sequence, in BRL.
- `review_score`: integer from 1 to 5.

Amounts are stored as SQLite REAL values for analysis; reconciliation rounds
order totals to cents and uses a BRL 0.02 tolerance. This is not a financial
ledger designed for exact accounting calculations.

## Source fields not imported

Review title and free-text comments are omitted because these queries use
scores only. Product and geolocation tables are not needed for the current
questions. `product_id` is retained on items but is not joined to a product table.
