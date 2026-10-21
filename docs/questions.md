# Analysis notes

The queries follow the order of the analysis: check the records, compare
delivery outcomes, then look at reviews, freight and payments. Each saved
CSV has the same name as its SQL file.

## Counting orders

The main delivery view has one row per order. An order needs a delivered
status, valid purchase and delivery dates, and an estimated date. Delivery
cannot precede purchase. Late means the delivery date is after the estimated
date; comparing full timestamps would incorrectly flag deliveries later on
the promised day.

The monthly query groups by purchase month and drops the latest month in
the source. This does not fully solve incomplete observation near the end
of the dataset: some orders placed earlier may still be unresolved.

## Comparing destinations and sellers

State and seller rankings require at least 100 eligible orders so that a
handful of deliveries cannot dominate the ranking. The threshold is a
practical filter, not a test of statistical significance.

The seller query first reduces item rows to one seller per order. Multi-seller
orders are left out because the delivery timestamp belongs to the whole
order. Even for single-seller orders, a delay can happen after carrier handover.

Query 08 answers a different question from the state ranking: which states
contribute the largest number of late orders? Its cumulative percentage
helps separate service reliability from the volume of customers affected.

## Joining the other tables

- **Dispatch:** all items must have the same non-null shipping deadline. The
  carrier timestamp must fall between purchase and customer delivery.
- **Reviews:** keep one per order, ordered by creation date and answer time.
  Review ID and source row break any remaining ties. Reviews before delivery
  are kept, so the groups should not be read as a post-delivery survey.
- **Freight:** use single-seller orders to identify the origin state. The
  freight percentage is `SUM(freight) / SUM(goods)`, not the average of each
  order's percentage. Prices and freight charges are in BRL.
- **Payments:** total the items and payments independently, then join by
  order. Two items and two payment rows would otherwise create four rows.
  Reconciliation allows a BRL 0.02 difference between rounded totals.

The [data dictionary](data_dictionary.md) lists the source fields and keys.
