## SQL Analysis

### Techniques Used

| Technique | Used for |
|---|---|
| SELECT, WHERE, GROUP BY, ORDER BY | Retrieving, filtering, grouping and ranking records |
| Aggregate functions (SUM, AVG, COUNT, COUNT DISTINCT) | Calculating revenue, profit, units sold and order counts |
| JOIN | Adding product, customer, store and region details |
| CASE WHEN | Grouping discounts into discount bands |
| Date functions (YEAR, MONTH, QUARTER, DATEDIFF) | Analysing time trends and calculating shipping days |
| LIMIT | Producing Top 10 lists |

### Queries by Business Question

| Business question | Approach |
|---|---|
| Overall KPIs | Calculated total orders, units, revenue, profit and profit margin |
| Sales and profit over time | Grouped results by year, quarter and month |
| Top products and customers | Joined dimension tables, ranked by revenue and compared with profit |
| Category performance | Compared revenue and profit margin across categories |
| Store and region performance | Joined the stores table and performed year-over-year comparisons |
| Seasonality | Compared average monthly revenue across both years, alongside average sale value and transaction counts |
| Shipping | Calculated average shipping days by store, region and month |
| Discount impact | Analysed profit margin and average units by discount band, then repeated the analysis within each category |

### Important Metric Definitions

- **Average sale value:** Total sales divided by the number of sale lines. This measures the average revenue generated per sale line.
- **Average monthly revenue:** Monthly revenue totals averaged across the periods being compared. This helps identify typical revenue levels and seasonal patterns.
- **Profit margin:** Total profit divided by total sales, expressed as a percentage.

**Important:** Total orders were counted using distinct order IDs because an order may contain multiple order lines.
