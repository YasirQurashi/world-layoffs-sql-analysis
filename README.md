# 🌍 World Tech Layoffs 2020–2023 | SQL Data Cleaning & EDA

![SQL](https://img.shields.io/badge/SQL-MySQL-blue) ![Status](https://img.shields.io/badge/Status-Completed-green) ![Dataset](https://img.shields.io/badge/Dataset-Layoffs.fyi-orange)

## 📌 Project Overview
This project performs end-to-end **Data Cleaning and Exploratory Data Analysis (EDA)** on the World Layoffs dataset (2020–2023) using **MySQL**. The dataset contains 1,995 records of global tech layoffs across 1,628 companies, 51 countries, and 30 industries.

---

## 🎯 Objectives
- Remove duplicates and inconsistent data
- Standardize formats across company, industry, country, and date columns
- Handle NULL and blank values professionally
- Extract meaningful business insights using SQL queries
- Identify trends across time, industry, and geography

---

## 📂 Project Structure
```
world-layoffs-sql-analysis/
│
├── layoffs.csv                      # Raw dataset
├── world_layoffs_data_cleaning.sql  # Full SQL script (cleaning + EDA)
└── README.md                        # Project documentation
```

---

## 🗃️ Dataset
- **Source:** [Alex The Analyst - MySQL World Layoffs](https://github.com/AlexTheAnalyst/MySQL-World-Layoffs)
- **Period:** March 2020 – March 2023
- **Records:** 1,995 rows (after cleaning)
- **Columns:** Company, Location, Industry, Total Laid Off, Percentage Laid Off, Date, Stage, Country, Funds Raised

---

## 🔄 Workflow

### 🧹 Phase 1: Data Cleaning

| Step | Task | Technique Used |
|---|---|---|
| 1 | Remove Duplicates | ROW_NUMBER() Window Function |
| 2 | Standardize Company Names | TRIM() |
| 3 | Fix Industry Names | LIKE + UPDATE |
| 4 | Fix Country Names | TRIM(TRAILING) |
| 5 | Convert Date Format | STR_TO_DATE() + ALTER TABLE |
| 6 | Handle NULL Values | Self-Join Imputation |
| 7 | Remove Irrelevant Rows | DELETE WHERE both NULLs |

### 📊 Phase 2: Exploratory Data Analysis

| Analysis | Key Finding |
|---|---|
| Max Single Day Layoffs | Explored scale of individual events |
| Companies Shutdown (100%) | Identified companies fully closed |
| Top Companies | Amazon, Google, Meta led layoffs |
| Funding vs Layoffs | Netflix most funded; Meta most laid off |
| Industry Analysis | Consumer (225K) & Retail (218K) hit hardest |
| Country Analysis | USA dominated with 1.28M layoffs |
| Yearly Trend | 2022 was worst year (803K layoffs) |
| Monthly Trend | January consistently worst month |
| Rolling Monthly Total | Cumulative reached 1.9M by March 2023 |

---

## 💡 Key Insights

- 📍 **United States** accounted for **67%** of all global layoffs
- 📅 **2022** was the worst year with **803,305** layoffs — post-COVID market correction
- 🏭 **Consumer and Retail** industries were hit hardest combined
- 📈 **November 2022** single month saw **267,255** layoffs — driven by Meta, Twitter & Amazon
- 💀 Several companies laid off **100% of workforce** — complete shutdowns
- 💰 High funding doesn't protect from layoffs — Netflix raised most but Meta laid off most

---

## 🛠️ Tools & Techniques Used
- **Database:** MySQL
- **Tool:** MySQL Workbench
- **SQL Concepts:**
  - CTEs (Common Table Expressions)
  - Window Functions (ROW_NUMBER, SUM OVER)
  - Self Joins
  - String Functions (TRIM, LIKE, STR_TO_DATE)
  - Aggregate Functions (SUM, COUNT, MAX, MIN)
  - ALTER TABLE, UPDATE, DELETE

---

## ▶️ How to Reproduce

1. Clone this repository
```bash
git clone https://github.com/YasirQurashi/world-layoffs-sql-analysis.git
```

2. Open **MySQL Workbench** and create database
```sql
CREATE DATABASE layoffs_project;
USE layoffs_project;
```

3. Import `layoffs.csv` into table `layoffs_raw` using Table Data Import Wizard

4. Open and run `world_layoffs_data_cleaning.sql` **step by step**

---

## 📈 Results
- ✅ Clean dataset: **1,995 rows** ready for analysis
- ✅ **5 duplicate rows** removed
- ✅ **Date column** converted from TEXT to DATE
- ✅ **NULL industries** filled using Self-Join technique
- ✅ **9 EDA queries** extracting business insights

---

## 🔗 Author
**Muhammad Yasir Qurashi**
- 🐙 GitHub: [YasirQurashi](https://github.com/YasirQurashi)
- 💼 LinkedIn: [www.linkedin.com/in/muhammad-yasir-qurashi]

---

## ⭐ If you found this project helpful, please star the repository!
