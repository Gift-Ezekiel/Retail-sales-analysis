## Excel Dashboard

The Excel dashboard provides an interactive visual summary of the sales data, allowing users to explore revenue, profitability, product performance, store performance, and discount impact across different years and regions.

### Data Source

The dashboard was built using a flat table exported from MySQL after joining the required tables. The dataset includes the cleaned and corrected dates, discount bands, and relevant sales, product, and store information.

The exported data was loaded into Excel as a named table and used as the source for the PivotTables and dashboard visualizations.

### Dashboard Components

| Component | Description |
|---|---|
| **KPI Cards** | Displays total revenue, total profit, profit margin, and units sold. The KPI values are linked to a supporting PivotTable using `GETPIVOTDATA`, allowing them to respond dynamically to slicer selections. |
| **Seasonality Chart** | Compares monthly revenue trends for 2024 and 2025 to highlight changes in sales performance over time. |
| **Category Performance** | Uses a combination chart with sales displayed as columns and profit margin as a line on a secondary axis to compare category revenue and profitability. |
| **Top 10 Products** | A sorted horizontal bar chart highlighting the ten highest-performing products by sales. |
| **Sales by Store** | A sorted bar chart comparing sales performance across stores. |
| **Discount Impact** | Displays profit margin across discount bands, filtered specifically to the Furniture category to examine the relationship between discount levels and profitability within that category. |
| **Interactive Slicers** | Year and region slicers connected to all relevant PivotTables through Report Connections, allowing users to filter the dashboard interactively. |
| **Key Insights** | A summary box containing four plain-language findings derived from the analysis. |

### Design Decisions

- **Dynamic KPI calculations:** KPI cards are linked to a supporting PivotTable using `GETPIVOTDATA` so that the displayed figures update when users interact with the slicers.
- **Calculated profit margin:** Profit margin is calculated within each PivotTable as profit divided by sales rather than being averaged or summed from individual row-level margin values. This ensures the margin reflects the overall figures being analyzed.
- **Focused discount analysis:** The discount chart is filtered to Furniture only. Combining all categories produced misleading results because high-volume, low-discount products (such as Groceries) and lower-volume, higher-discount products (such as Furniture) have different sales patterns.
- **Insight-driven chart titles:** Chart titles communicate the main finding or analytical focus rather than simply describing the chart.
- **Consistent visual design:** The dashboard uses one primary color and a single highlight color to draw attention to important findings without overcrowding the visuals.
- **Interactive filtering:** Year and region slicers are connected across the dashboard to maintain consistency when exploring different segments of the data. Users can filter the dashboard by year and region using the slicers. All connected PivotTables, KPI cards, and charts update based on the selected filters, making it easier to compare performance across different periods and regions.
