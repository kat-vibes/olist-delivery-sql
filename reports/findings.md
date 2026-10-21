# What the queries show

The starting point is 99,441 orders. Of these, 96,478 are marked delivered,
but eight have no delivery timestamp. That leaves **96,470 orders** for the
delivery analysis. **6,534 arrived late: 6.77%.** Delivery on the promised
calendar date counts as on time, regardless of the hour.

The audit also found 547 orders with multiple reviews and 1,278 with multiple
sellers. Those details matter for the joins: one order should not become two
observations just because it has two reviews.

[Data audit](results/00_data_quality.csv)

## High late rates and high volumes are different problems

Alagoas (AL) has the highest late rate among states with at least 100 eligible
orders: **85 of 397 orders, or 21.41%**. Maranhão (MA) follows at 17.43%.

By volume, São Paulo and Rio de Janeiro stand out instead. SP has 1,820 late
orders and RJ has 1,495. Together, they account for **50.73% of all late
orders**. AL would be worth investigating for reliability; SP and RJ would
be the starting point for reducing the number of customers affected.

[State rates](results/02_customer_states.csv) ·
[Share of late orders](results/08_delay_concentration.csv)

## Late dispatch is a useful warning sign

| Carrier handover | Orders | Late deliveries | Late rate |
| --- | ---: | ---: | ---: |
| After the shipping deadline | 8,695 | 1,814 | 20.86% |
| Within the shipping deadline | 87,257 | 4,717 | 5.41% |

The difference is large enough to justify tracking missed shipping deadlines.
It would also be useful to split these groups by route and promised delivery
window before deciding where to intervene. This comparison only uses orders
with a usable carrier timestamp and the same deadline on every item.

[Dispatch results](results/04_dispatch_and_delivery.csv)

## Reviews are much worse for late orders

The average review score is **4.29 for on-time orders** and **2.27 for late
orders**. Scores of 1 or 2 make up 9.27% of the on-time group and 62.40% of
the late group. Each order contributes its latest review only.

Review text would help distinguish delivery complaints from product issues.
The current query uses scores, including reviews submitted before delivery,
so it cannot isolate the effect of a delay on customer satisfaction.

[Review results](results/05_delivery_and_reviews.csv)

## Interstate orders carry higher freight charges

For single-seller orders, average freight is **BRL 26.55 between states** and
**BRL 15.19 within a state**. Freight as a share of total goods value is 18.18%
and 12.84%, respectively. These are customer charges recorded in the dataset;
carrier costs and margins are not available.

[Freight results](results/06_freight_by_route.csv)

## Most payment totals reconcile

Item value plus freight matches the payment total within BRL 0.02 for
**98,385 orders**. The remaining groups are 280 orders outside the tolerance,
775 without item rows and one without a payment row.

The query sums items and payments separately before joining them. Joining
both raw tables directly would multiply rows and inflate the totals.
The 280 differences need a closer look; the data alone do not explain them.

[Payment reconciliation](results/07_payment_reconciliation.csv)

## Monthly and seller comparisons

March 2018 has a late rate of **18.96% across 7,003 eligible orders**. The
monthly table groups orders by purchase date. The latest source month is
excluded, although other recent months can still be missing unresolved orders.

The seller table covers 201 sellers with at least 100 eligible single-seller
orders. It gives a list to investigate, but seller rankings also reflect
where orders went, what was sold and how much delivery time was promised.

[Monthly results](results/01_monthly_delivery.csv) ·
[Seller results](results/03_seller_exposure.csv)

## What would help next

Parcel-level handover events, carrier names and route distances would make
the delivery analysis more specific. Product weight and dimensions would
help explain freight charges. The current data show differences between
groups, without establishing what caused them.
