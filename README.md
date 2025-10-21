Café Sales Data Analysis

Author: Miguel Mora

Tools: MySQL, Power BI

Dataset: Adapted from Kaggle



📖 Introduction

This project focuses on analyzing café sales data to uncover trends, customer behavior, and key business insights. The goal is to transform raw, inconsistent data into a reliable and structured dataset ready for analysis and visualization. The process combines SQL for data cleaning and transformation with Power BI for reporting and insight generation.

📈 Data Exploration

- The first step was to explore the raw dataset, which included columns such as transaction ID, item, quantity, price per unit, payment method, location, and transaction date.

- During the exploration, several data quality issues were identified, including duplicated records, missing or invalid values, inconsistent naming conventions, and incorrect data types.

- This step helped define the cleaning strategy and the transformations required to prepare the dataset for analysis.

🧹 Data Cleaning Process

- Duplicate records were removed by keeping only unique transaction IDs.
- Column names were standardized to lowercase with underscores for consistency.
- The total_spent field was recalculated as quantity multiplied by price_per_unit to ensure accuracy.
- Invalid or missing entries such as UNKNOWN, ERROR, or empty fields were replaced with NULL or standardized placeholders.
- Numeric validation was applied to remove rows with zero or negative values in quantity or price fields.
- Transaction dates were converted into proper date formats, allowing for time-based grouping and analysis.
- After cleaning, the dataset was fully consistent, with no duplicates or invalid records remaining.

🔧 Feature Engineering

- Several new analytical columns were created to enhance insights.
- The item_category column was used to classify products into Drink, Food, Dessert, or Unknown.
- The payment_type column was introduced to group payment methods into Electronic, Cash, or Unknown.
- The spending_category column was designed to classify transactions based on total spending as Low, Medium, or High.
- Additional columns such as transaction_month, transaction_day, and day_type (Weekday or Weekend) were added to support temporal analysis.

📊 Data Visualization and Analysis

- The cleaned dataset was imported into Power BI to develop an interactive dashboard.
- The dashboard included visual representations of total revenue, sales trends by month, item performance, payment distribution, and spending patterns by weekday and weekend.
- These visualizations helped identify relationships and patterns that were not visible in the raw data.
- Through this analysis, it became possible to observe the café’s operational dynamics and customer behavior more clearly.

💡 Insights and Results

- Drinks represented the most frequently purchased category, while food items generated higher average revenue per transaction.
- Electronic payments, such as credit card and digital wallet, were dominant, reflecting a shift toward cashless transactions.
- Weekends showed higher-value transactions, although weekdays had more consistent daily sales volume.
- Some months displayed strong seasonal peaks, which suggests opportunities for targeted promotional campaigns.
- These insights can guide pricing strategies, promotional timing, and customer experience improvements.

🧭 Conclusions

The cleaning and analysis process demonstrated the importance of structured data preparation. SQL ensured accuracy and consistency, while Power BI provided an intuitive platform to visualize complex relationships. The combination of both tools resulted in clear, actionable insights that can help the café make better business decisions, optimize operations, and increase profitability.


Thanks for reading!
Feel free to connect with me on LinkedIn or explore more projects on my GitHub profile.
