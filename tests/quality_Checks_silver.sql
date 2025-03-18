/* 
##################################################################################
Scripts Usage: 
     Use this SQL scripts to run the quality checks for silver layer
Condition to use:
    - First Load the silver layer by running stored procedure ( silver.load_silver)
    - After the use this scripts for silver level tables 
*/

-- FOR crm_sales_details

-- Check Invalid Dates

SELECT * 
FROM silver.crm_sales_details
where sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency: Between sales, Quantity, and price
-- Sales = Quantity * Price
-- Values must not be Null, zero, or negative.

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0
     THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price
END AS sls_price

FROM silver.crm_sales_details
WHERE sls_sales = sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,
sls_quantity,
sls_price

-- FOR silver.erp_px_cat_g1v

-- Check for unwanted Spaces

SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE TRIM(cat) != cat OR TRIM(subcat) != subcat OR TRIM(maintenance) != maintenance;

-- Data Standardization & consistency 

SELECT DISTINCT subcat 
FROM silver.erp_px_cat_g1v2;


-- silver.erp_cust_az12
-- Identify Out-of-Range Dates
SELECT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency
SELECT DISTINCT
gen
FROM silver.erp_cust_az12;
