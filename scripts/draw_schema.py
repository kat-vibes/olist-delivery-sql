"""Draw the six tables used in the notebook."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

fig, ax = plt.subplots(figsize=(13, 8))
fig.patch.set_facecolor("#fafaf7")
ax.set_facecolor("#fafaf7")
ax.set_xlim(0, 13)
ax.set_ylim(0, 8)
ax.axis("off")


def table(x, y, title, fields, color="#e7eeed"):
    box = FancyBboxPatch(
        (x, y), 3.3, 1.7, boxstyle="round,pad=0.06",
        facecolor=color, edgecolor="#516967", linewidth=1.2,
    )
    ax.add_patch(box)
    ax.text(x + 0.16, y + 1.4, title, fontsize=13, weight="bold", color="#1d3735")
    ax.text(x + 0.16, y + 1.08, fields, fontsize=10, va="top", linespacing=1.55)


def link(start, end, label, label_position):
    ax.annotate("", xy=end, xytext=start,
                arrowprops={"arrowstyle": "->", "color": "#516967", "lw": 1.5})
    ax.text(*label_position, label, fontsize=9, color="#516967", ha="center",
            bbox={"facecolor": "#fafaf7", "edgecolor": "none", "pad": 2})


table(0.2, 3.7, "customers", "customer_id · PK\ncustomer_unique_id\ncustomer_state")
table(4.8, 3.7, "orders", "order_id · PK\ncustomer_id · FK\nstatus and delivery dates", "#dce8ba")
table(9.4, 3.7, "order_items", "order_id + order_item_id · PK\nseller_id · FK; order_id · FK\nprice, freight_value")
table(9.4, 6.0, "sellers", "seller_id · PK\nseller_state")
table(0.2, 0.3, "payments", "order_id + payment_sequential · PK\norder_id · FK\npayment_value")
table(4.8, 0.3, "reviews", "source_row · PK\norder_id · FK\nreview_score")

link((3.56, 4.55), (4.74, 4.55), "1 → many", (4.15, 4.8))
link((8.16, 4.55), (9.34, 4.55), "1 → many", (8.75, 4.8))
link((11.05, 5.94), (11.05, 5.46), "1 → many", (11.85, 5.65))
link((6.45, 3.64), (6.45, 2.06), "1 → many", (7.0, 2.8))
link((5.0, 3.64), (2.2, 2.06), "1 → many", (3.2, 2.9))

ax.text(0.2, 7.7, "How the tables connect", fontsize=20, weight="bold", color="#1d3735")
ax.text(9.4, 0.9, "PK = primary key\nFK = foreign key\nArrows point to child rows.",
        fontsize=11, color="#516967", linespacing=1.7)
fig.tight_layout()
output = Path(__file__).resolve().parents[1] / "docs/schema.png"
fig.savefig(output, dpi=180, facecolor=fig.get_facecolor())
plt.close(fig)
