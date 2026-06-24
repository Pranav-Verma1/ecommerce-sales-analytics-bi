# E-Commerce Sales Analytics BI Solution

## Project Overview

This project demonstrates an end-to-end Business Intelligence solution built using Python, SQL Server, and Power BI.

The solution automates data ingestion from CSV files, loads data into a SQL Server data warehouse, tracks file changes, logs ETL execution, and exposes reporting views for Power BI dashboards.

---

## Architecture

CSV Files
→ Python ETL
→ File Change Detection
→ SQL Server Staging
→ Warehouse Refresh Procedures
→ Fact & Dimension Tables
→ Reporting Views
→ Power BI Dashboard

---

## Tech Stack

- Python
- Pandas
- SQL Server 2022 Express
- pyodbc
- Power BI
- Apache Airflow (planned)

---

## Data Sources

- fact_orders.csv
- dim_customers.csv
- dim_products.csv
- dim_carriers.csv

---

## Warehouse Model

### Fact Table

- fact_sales

### Dimension Tables

- dim_customers
- dim_products
- dim_carriers
- dim_date

---

## Reporting Views

- vw_sales_detail
- vw_daily_sales
- vw_monthly_sales
- vw_top_products

---

## ETL Features

- Automated CSV ingestion
- Data validation
- File change detection
- ETL logging
- Warehouse refresh procedures
- Star schema modeling

---

## Monitoring

### etl_log

Tracks:

- Process Name
- Rows Loaded
- Load Time
- Status

### etl_file_tracking

Tracks:

- File Name
- Last Modified
- Last Loaded
- Status

---

## Future Enhancements

- Apache Airflow Scheduling
- Email Notifications
- Incremental Loading
- Data Quality Dashboard

---

## Author

Pranav Verma