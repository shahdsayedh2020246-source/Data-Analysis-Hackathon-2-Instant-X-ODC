# 📊 Marketing Analytics Project — SQL Server + Power BI + Python

## 📝 Overview
This project analyzes ShopEasy’s marketing performance to address:
* 📉 Declining customer engagement
* 🛒 Low conversion rates
* 💰 High marketing spend with weak ROI
* ⭐ Decreasing customer satisfaction based on reviews

The workflow covers data profiling (EDA), data cleaning, and building a reporting-ready layer (SQL views) that feeds a Power BI dashboard. A Python notebook is included for optional/bonus analysis.

## 🛠️ Tech Stack
* 🗄️ SQL Server (database restore, EDA, cleaning, reporting views)
* 💻 SSMS (query execution)
* 📊 Power BI Desktop (dashboard & KPIs)
* 🐍 Python (Jupyter Notebook) (optional exploratory analysis)

## 📁 Repository Structure

<pre>
PortfolioProject_MarketingAnalytics/
│
├── Query.sql                # EDA + cleaning + view creation scripts
├── Dashboard.pbix           # Power BI dashboard
├── Notebook.ipynb           # Optional Python analysis (bonus)
└── Row_Data/                     # Materials provided by Orange (inputs/templates)
</pre>
## 📂 Row_Data Folder (Provided by Orange)

Place the project inputs sent by Orange inside `Ref/`, for example:
* 📄 `DA_Marketing_Project.pdf` (project brief / requirements)
* 💾 `MarketingAnalyticsProject.bak` (SQL Server database backup)
* 📝 Any additional notes, templates, or supporting assets shared with the assignment

> 💡 **Tip:** Keeping “provided materials” in `Ref/` makes the project clean and easy to review.

---

## 🗄️ Database & Tables

* 🗄️ **Database:** PortfolioProject_MarketingAnalytics
* 📋 **Core tables:**
  * `customer_journey` — customer funnel activity (homepage/product page/checkout)
  * `engagement_data` — content engagement by campaign/product
  * `customer_reviews` — ratings + free-text reviews
  * `customers` — customer demographics + geography key
  * `products` — product catalog and pricing
  * `geography` — country/city dimension

---

## 🔍 Data Profiling (EDA) — Key Findings

### 📊 Table Sizes
| Table | Rows | Columns |
| :--- | :--- | :--- |
| customer_journey | 40117 | 7 |
| engagement_data | 4623 | 8 |
| customer_reviews | 1363 | 6 |
| customers | 100 | 7 |
| products | 20 | 4 |
| geography | 10 | 3 |

### ❌ Nulls
* ⚠️ `customer_journey.Duration`: 613 NULL values

### 🔄 Duplicates (full-row duplicates)
* 👥 `customer_journey`: 79 duplicate rows
* ✨ All other tables: 0 duplicates

### 🔤 Standardization Issues (case/spacing)
* 🔄 **Stage values (examples):**
  * Homepage vs homepage
  * ProductPage vs productpage
  * Checkout vs checkout
* 🔄 **ContentType values (examples):**
  * Blog vs blog
  * Socialmedia vs socialmedia
  * Newsletter vs newsletter
  * Video vs video

### 🔎 Price sanity check (products)
Within the checked range (10–300):
* 📈 **Avg:** 138.18
* 📉 **Min:** 26.21
* 📈 **Max:** 275.43

---

## ⚙️ Data Cleaning & Reporting Layer (SQL Views)

The cleaning pipeline is implemented as SQL views so Power BI can consume clean, consistent data.

### 1️⃣ vw_clean_journey
Cleans `customer_journey` by:
* 🔤 Standardizing Stage ➡️ CleanStage using `TRIM + UPPER`
* 🛠️ Filling NULL Duration values with the average duration (imputation)
* 📊 Exposes CleanDuration for reporting
* 📤 **Output columns:** JourneyID, CustomerID, ProductID, VisitDate, CleanStage, Action, CleanDuration

### 2️⃣ vw_clean_engagement_data
Cleans `engagement_data` by:
* 🔤 Standardizing ContentType ➡️ CleanContentType using `TRIM + UPPER`
* 📤 **Output columns:** EngagementID, ContentID, CleanContentType, Likes, EngagementDate, CampaignID, ProductID, ViewsClicksCombined

### 3️⃣ vw_stage_engagement
Creates an initial combined view by joining journey + engagement:
* 🔗 `LEFT JOIN` on ProductID
* ⚠️ **Why this matters:** a product may have multiple engagement rows (different content/campaign/date), so this join can multiply rows.

### 4️⃣ vw_final_clean_journey
Final reporting-ready view that removes duplicates after the join using:
* 🔢 `ROW_NUMBER() OVER (PARTITION BY CustomerID, ProductID, VisitDate ORDER BY JourneyID)`
* 🎯 Keeps `rn = 1` to return one representative row per (CustomerID, ProductID, VisitDate)
* 📤 **Output columns include:** Journey fields + Engagement fields (IDs, content type, likes, campaign, etc.)

> 📌 **Note:** If you want detailed engagement analysis (multiple engagement rows per product), use `vw_clean_engagement_data` as a separate fact table in Power BI instead of relying on the joined view.

### 5️⃣ Dimension Views
Simple pass-through views for consistent naming and modeling:
* 👥 `vw_customers`
* 📦 `vw_products`
* ⭐ `vw_customer_reviews`
* 🗺️ `vw_geography`

---

## 🚀 How to Run (End-to-End)

### 1) Restore the database backup
* 📂 Copy `MarketingAnalyticsProject.bak` into your SQL Server backup directory
* 🗄️ Restore via SSMS: Right-click **Databases** ➡️ **Restore Database…**
* 🎯 Select **Device** ➡️ choose the `.bak` file
* 🔄 Confirm the restored DB name matches your setup (e.g., `PortfolioProject_MarketingAnalytics`)

### 2) Execute the SQL script
* 📂 Open and run: `Query.sql`
* ⚙️ This script: Performs EDA (row counts, null checks, duplicates, standardization checks) and creates/updates the cleaning views (`CREATE OR ALTER VIEW ...`)

### 3) Open the Power BI report
* 📊 Open: `Dashboard.pbix`
* ⚙️ Then: Update the SQL Server connection (if needed) and **Refresh** the dataset

### 4) (Optional) Run the notebook
* 🐍 Open: `Notebook.ipynb`
* 📈 Run EDA/visualizations and any bonus analysis.

---

## 📐 Power BI Modeling Notes (Recommended)

For a clean star schema, consider:

### 📑 Fact tables:
* 🔄 `vw_clean_journey` (journey events)
* 📈 `vw_clean_engagement_data` (engagement events)
* ⭐ `vw_customer_reviews` (review events)

### 📑 Dimensions:
* 👥 `vw_customers` + 🗺️ `vw_geography`
* 📦 `vw_products`

### 🔗 Relationships (typical):
* 👥 Customers ➡️ Journey (`CustomerID`)
* 📦 Products ➡️ Journey (`ProductID`)
* 📦 Products ➡️ Engagement (`ProductID`)
* 👥 Customers ➡️ Reviews (`CustomerID`)
* 📦 Products ➡️ Reviews (`ProductID`)
* 🗺️ Geography ➡️ Customers (`GeographyID`)

---

## 📈 KPI Ideas (Aligned to the Brief)

Depending on how “conversion” is defined in your analysis:
* 🎯 **Conversion Rate:** reach checkout / product page visits (or homepage)
* 📈 **Engagement Rate:** likes per view/click (after parsing `ViewsClicksCombined`)
* ⭐ **Customer Feedback Score:** average rating + rating distribution + review themes
* 📉 **Drop-off Rate:** drop-offs by stage and over time
* 📊 **Content Performance:** engagement by content type and campaign
