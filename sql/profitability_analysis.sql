USE Superstore_analysis;

-- =====================================================
-- 1. OVERALL PROFITABILITY ANALYSIS
-- Purpose:
-- Identify which categories and sub-categories contribute
-- to the lower Consumer profit margin.
-- =====================================================

SELECT
	category,
    segment,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
GROUP BY category,segment
ORDER BY category,segment;

SELECT
	sub_category,
    segment,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE category = 'Furniture'
GROUP BY sub_category,segment
ORDER BY sub_category,segment;

-- =====================================================
-- 2. BOOKCASES - DISCOUNT ANALYSIS
-- Question:
-- Is the low Consumer Bookcases margin related to discount?
-- =====================================================

SELECT
    discount,
    segment,
    COUNT(*) AS record_count,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
GROUP BY discount, segment
ORDER BY discount, segment;

-- =====================================================
-- 3. TABLES - DISCOUNT PROFITABILITY
-- Question:
-- How does profitability change across discount levels?
-- Finding:
-- Profit margin becomes increasingly negative at higher
-- discount levels, especially around 40%-50%.
-- =====================================================
  
  SELECT
    discount,
    COUNT(*) AS record_count,
    SUM(quantity) AS total_quantity,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Tables'
GROUP BY discount
ORDER BY discount;

-- =====================================================
-- 4. TABLES - DISCOUNT BY SEGMENT
-- Question:
-- Is the high-discount profitability problem specific
-- to Consumer?
-- Finding:
-- Similar losses appear across segments at the same
-- high discount levels.
-- =====================================================

SELECT
    discount,
    segment,
    COUNT(*) AS record_count,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Tables'
GROUP BY discount,segment
ORDER BY discount,segment;

-- =====================================================
-- 5. TABLES - HIGH DISCOUNT EXPOSURE
-- Question:
-- Is Consumer more exposed to high-discount Tables sales?
-- High discount is defined as >= 30%.
-- =====================================================

SELECT
    segment,
    SUM(sales) AS total_sales,
     SUM(
		CASE
			WHEN discount>=0.3 THEN sales
            ELSE 0
		END
    ) AS high_discount_sales,
      SUM(
		CASE
			WHEN discount>=0.3 THEN sales
            ELSE 0
		END
    )/SUM(sales) AS high_discount_sales_share
FROM superstore_orders
WHERE sub_category = 'Tables'
GROUP BY segment
ORDER BY segment;

-- =====================================================
-- 6. TABLES - LOSS-MAKING PRODUCTS BY DISCOUNT
-- Question:
-- Are high-discount losses concentrated in only
-- one product?
-- =====================================================

SELECT
    product_name,
    discount,
	COUNT(*) AS record_count,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Tables'
GROUP BY product_name,discount
HAVING SUM(profit)<0
ORDER BY SUM(profit) ASC;

-- =====================================================
-- 7. BOOKCASES - HIGH DISCOUNT PROFITABILITY
-- Question:
-- How profitable are high-discount Bookcases sales?
-- High discount = >= 30%.
-- =====================================================


SELECT
	segment,
	SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases' 
	AND (segment = 'Consumer' OR segment = 'Corporate') 
    AND discount >= 0.3
GROUP BY segment
ORDER BY segment;



-- Question:
-- Is Consumer more exposed to high-discount sales?

SELECT
    segment,
	SUM(sales) AS total_sales,
    SUM(CASE WHEN discount >= 0.3 THEN sales ELSE 0 END) AS High_discount_sale,
    SUM(CASE WHEN discount >= 0.3 THEN sales ELSE 0 END)/SUM(sales) AS High_discount_sale_percentage
FROM superstore_orders
WHERE sub_category = 'Bookcases' 
	AND (segment = 'Consumer' OR segment = 'Corporate')
GROUP BY segment
ORDER BY segment;




-- =====================================================
-- 8. BOOKCASES - LOW DISCOUNT PROFITABILITY
-- Question:
-- Does the Consumer-Corporate margin gap remain after
-- excluding high-discount transactions?
-- =====================================================


SELECT
    segment,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
	AND segment IN ('Consumer', 'Corporate')
	AND discount < 0.3
GROUP BY segment
ORDER BY segment;



-- =====================================================
-- 9. BOOKCASES - WITHIN-PRODUCT COMPARISON
-- Question:
-- Is Consumer less profitable even when comparing
-- the same products?
-- =====================================================

SELECT
    product_name,
    SUM(
    CASE
        WHEN segment = 'Consumer' THEN sales
        ELSE 0
    END
	) AS consumer_sales,
    SUM(
    CASE
        WHEN segment = 'Corporate' THEN sales
        ELSE 0
    END
	) AS corporate_sales,
	SUM(
    CASE
        WHEN segment = 'Consumer' THEN profit
        ELSE 0
    END
	) AS consumer_profit,
    SUM(
    CASE
        WHEN segment = 'Corporate' THEN profit
        ELSE 0
    END
	) AS corporate_profit,
	SUM(CASE WHEN segment = 'Consumer' THEN profit ELSE 0 END)
	/
	NULLIF(SUM(CASE WHEN segment = 'Consumer' THEN sales ELSE 0 END),0) AS consumer_margin,
	SUM(CASE WHEN segment = 'Corporate' THEN profit ELSE 0 END)
	/
	NULLIF(SUM(CASE WHEN segment = 'Corporate' THEN sales ELSE 0 END),0) AS corporate_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
	AND segment IN ('Consumer', 'Corporate')
	AND discount < 0.3
GROUP BY product_name
HAVING SUM(CASE WHEN segment = 'Consumer' THEN sales ELSE 0 END) > 0
	AND
	SUM(CASE WHEN segment = 'Corporate' THEN sales ELSE 0 END) > 0
ORDER BY product_name;



-- =====================================================
-- 10. BOOKCASES - PRODUCT MIX ANALYSIS
-- Question:
-- Does product mix contribute to the lower Consumer
-- margin when the same product margin is applied to
-- both segments?
-- =====================================================

SELECT
	SUM(consumer_expected_profit)/NULLIF(SUM(consumer_sales),0) AS consumer_mix_margin,
    SUM(corporate_expected_profit)/NULLIF(SUM(corporate_sales),0) AS corporate_mix_margin
FROM(
		SELECT
		product_name,
		SUM(CASE WHEN segment = 'Consumer' THEN sales ELSE 0 END) AS consumer_sales,
		SUM(CASE WHEN segment = 'Corporate' THEN sales ELSE 0 END) AS corporate_sales,
		SUM(CASE WHEN segment = 'Consumer' THEN sales ELSE 0 END) * NULLIF(SUM(profit) / SUM(sales),0) AS consumer_expected_profit,
		SUM(CASE WHEN segment = 'Corporate' THEN sales ELSE 0 END) * NULLIF(SUM(profit) / SUM(sales),0) AS corporate_expected_profit,
		SUM(sales) AS total_sales,
		SUM(profit) AS total_profit,
		SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
	FROM superstore_orders
	WHERE sub_category = 'Bookcases'
		AND segment IN ('Consumer', 'Corporate')
		AND discount < 0.3
	GROUP BY product_name
) AS product_mix;

-- Finding:
-- Under shared product-level margins, Consumer's
-- expected margin is 6.22%, compared with 14.29%
-- for Corporate.
--
-- This indicates that differences in product sales
-- mix contribute to the profitability gap.
--
-- Scope:
-- Bookcases, Consumer and Corporate, discount < 30%.
--
-- Limitation:
-- Product mix is not necessarily the only factor.
-- Within-product profitability differences may also
-- contribute to the observed margin gap.



-- =====================================================
-- APPENDIX - EXPLORATORY ANALYSIS
-- These queries were used during investigation but were
-- not part of the final findings.
-- =====================================================

SELECT
	ship_mode,
    segment,
    COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
GROUP BY ship_mode,segment
ORDER BY ship_mode,segment;

SELECT
	country_region,
    region,
    state_province,
    city,
    segment,
    COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
GROUP BY country_region,
    region,
    state_province,
    city,segment
ORDER BY country_region,
    region,
    state_province,
    city,segment;
    
SELECT
    region,
    segment,
    COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
GROUP BY region,segment
ORDER BY region,segment;

SELECT
	state_province,
    segment,
    COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
	AND region = 'East'
GROUP BY state_province,segment
ORDER BY state_province,segment;

SELECT
    segment,
    discount,
    COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
	AND state_province = 'Pennsylvania'
GROUP BY segment,discount
ORDER BY segment,discount;

SELECT
    product_name,
    segment,
    COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
GROUP BY product_name,segment
ORDER BY product_name,segment;

SELECT
    product_name,
    segment,
    COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
GROUP BY product_name, segment
HAVING SUM(profit) < 0
ORDER BY SUM(profit);

SELECT
    product_name,
    segment,
	COUNT(*) AS record_count,
    SUM(profit) AS total_profit,
	SUM(profit)/NULLIF(SUM(sales),0) AS profit_margin
FROM superstore_orders
WHERE sub_category = 'Bookcases'
	AND product_name LIKE '%Riverside%'
GROUP BY product_name, segment
ORDER BY SUM(profit);

SELECT
    segment,
    sales,
    quantity,
    discount,
    profit,
    region,
    state_province,
    city,
    ship_mode
FROM superstore_orders
WHERE sub_category = 'Bookcases'
	AND product_name LIKE '%Riverside%';
