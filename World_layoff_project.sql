-- World Tech Layoffs 2020-2023
-- Data Cleaning & Exploratory Data Analysis
-- Author: Muhammad Yasir Qurashi
-- Tool: MySQL Workbench


-- first create the database and select it
CREATE DATABASE layoffs_project;
USE layoffs_project;

-- check if data imported correctly
SELECT * FROM layoffs_raw LIMIT 10;


-- -----------------------------------------------
-- PART 1: DATA CLEANING
-- -----------------------------------------------

-- always work on a copy, never touch the raw data
CREATE TABLE layoffs_staging AS 
SELECT * FROM layoffs_raw;

SELECT * FROM layoffs_staging LIMIT 10;


-- step 1: find duplicates
-- using ROW_NUMBER to assign a number to each group of identical rows
-- if row_num = 2 or more, that row is a duplicate

SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry,
                     total_laid_off, percentage_laid_off,
                     `date`, stage, country, funds_raised_millions
        ORDER BY (SELECT NULL)
    ) AS row_num
FROM layoffs_staging;

-- filter and see only the duplicate rows
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry,
                         total_laid_off, percentage_laid_off,
                         `date`, stage, country, funds_raised_millions
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM layoffs_staging
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

-- mysql doesn't allow deleting from a CTE directly
-- so we create a new table with row_num column included
CREATE TABLE layoffs_staging2 (
    company               VARCHAR(100),
    location              VARCHAR(100),
    industry              VARCHAR(100),
    total_laid_off        INT,
    percentage_laid_off   TEXT,
    `date`                TEXT,
    stage                 VARCHAR(50),
    country               VARCHAR(100),
    funds_raised_millions INT,
    row_num               INT
);

INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry,
                     total_laid_off, percentage_laid_off,
                     `date`, stage, country, funds_raised_millions
        ORDER BY (SELECT NULL)
    ) AS row_num
FROM layoffs_staging;

-- now delete the duplicates safely
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging2 WHERE row_num > 1;
SET SQL_SAFE_UPDATES = 1;

-- should return empty result now
SELECT * FROM layoffs_staging2 WHERE row_num > 1;


-- step 2: standardize the data

-- trim whitespace from company names
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET company = TRIM(company);
SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT company FROM layoffs_staging2 ORDER BY company;

-- check industry column -- noticed some inconsistencies
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY industry;

-- 'Crypto', 'Crypto Currency', 'CryptoCurrency' all mean the same thing
-- standardizing all to just 'Crypto'
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY industry;

-- check country column
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY country;

-- found 'United States' and 'United States.' -- removing the trailing dot
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT country FROM layoffs_staging2 ORDER BY country;

-- date column was imported as text, need to convert it to proper date
SELECT `date` FROM layoffs_staging2 LIMIT 10;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
SET SQL_SAFE_UPDATES = 1;

-- change the column type from text to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT `date` FROM layoffs_staging2 LIMIT 10;


-- step 3: handle nulls and blank values

-- rows where both layoff columns are null are useless
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- check industry nulls
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- convert blanks to null first for consistency
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
SET SQL_SAFE_UPDATES = 1;

-- if the same company has industry filled in another row, use that value
-- this is a self join technique
SELECT t1.company, t1.industry, t2.industry AS fill_from
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

-- check remaining nulls
SELECT * FROM layoffs_staging2
WHERE industry IS NULL;

-- Bally's Interactive appears only once in the dataset
-- manually filling based on company research
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET industry = 'Consumer'
WHERE company = "Bally's Interactive";
SET SQL_SAFE_UPDATES = 1;

SELECT company, industry
FROM layoffs_staging2
WHERE company = "Bally's Interactive";

-- final null check on industry
SELECT * FROM layoffs_staging2
WHERE industry IS NULL;


-- step 4: remove irrelevant rows and cleanup

-- rows with no layoff numbers at all -- not useful for analysis
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
SET SQL_SAFE_UPDATES = 1;

-- drop the row_num column, no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- final look at clean dataset
SELECT * FROM layoffs_staging2;

-- quick summary of the clean data
SELECT
    COUNT(*) AS total_rows,
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date,
    COUNT(DISTINCT company) AS total_companies,
    COUNT(DISTINCT country) AS total_countries,
    COUNT(DISTINCT industry) AS total_industries
FROM layoffs_staging2;


-- -----------------------------------------------
-- PART 2: EXPLORATORY DATA ANALYSIS (EDA)
-- -----------------------------------------------

-- what are the maximum layoffs in a single event?
SELECT MAX(total_laid_off) AS max_laid_off,
       MAX(percentage_laid_off) AS max_percentage
FROM layoffs_staging2;

-- companies that shut down completely (100% laid off)
SELECT company, total_laid_off, percentage_laid_off, `date`
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- top 10 companies by total layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- checking if higher funding leads to fewer layoffs
SELECT company, industry,
       SUM(total_laid_off) AS total_laid_off,
       MAX(funds_raised_millions) AS funds_raised
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL
AND total_laid_off IS NOT NULL
GROUP BY company, industry
ORDER BY funds_raised DESC
LIMIT 10;

-- which industry was hit the hardest?
SELECT industry,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE industry IS NOT NULL
AND total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_laid_off DESC;

-- which country had the most layoffs?
SELECT country,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE country IS NOT NULL
AND total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_laid_off DESC;

-- layoffs by year
SELECT YEAR(`date`) AS year,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
AND total_laid_off IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY total_laid_off DESC;

-- which month was consistently the worst?
SELECT MONTH(`date`) AS month,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
AND total_laid_off IS NOT NULL
GROUP BY MONTH(`date`)
ORDER BY total_laid_off DESC;

-- rolling monthly total to see cumulative growth over time
WITH monthly_totals AS (
    SELECT
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        SUM(total_laid_off) AS monthly_total
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    AND total_laid_off IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)
SELECT
    month,
    monthly_total,
    SUM(monthly_total) OVER (ORDER BY month) AS rolling_total
FROM monthly_totals
ORDER BY month;
