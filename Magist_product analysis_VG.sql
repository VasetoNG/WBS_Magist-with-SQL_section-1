USE magist;

# exploring the data:

SELECT * FROM order_items;

SELECT * FROM order_payments

WHERE order_id LIKE "%dc731a";

SELECT * FROM order_payments;

SELECT * FROM order_items
WHERE order_item_id >= 10;


# 1 What categories of tech products does Magist have?

SELECT *
FROM product_category_name_translation;

SELECT 
COUNT(DISTINCT product_category_name)
FROM product_category_name_translation;

SELECT *
FROM product_category_name_translation
WHERE product_category_name_english LIKE "%computer%" OR 
      product_category_name_english LIKE "%tablet%" OR
      product_category_name_english LIKE "%electronics%" OR
      product_category_name_english LIKE "telephony%" OR 
      product_category_name_english = "audio" OR
      product_category_name_english = "pc_gamer";
      
      
# 2 How many items of tech categories have been sold?

SELECT * 
FROM order_items;

SELECT p.product_category_name,
       SUM(os.order_item_id) AS "sold_items"
FROM order_items as os
INNER JOIN products as p
ON os.product_id = p.product_id
WHERE product_category_name LIKE "pcs" OR 
      product_category_name LIKE "%tablet%" OR
      product_category_name LIKE "%informatica%" OR
      product_category_name LIKE "%eletroni%" OR
      product_category_name LIKE "%telefonia" OR
      product_category_name = "audio" OR
      product_category_name = "pc_gamer"
GROUP BY p.product_category_name
ORDER BY sold_items DESC;

# 2.1 How many items (all categories, not only tech) have been sold?

SELECT
       SUM(os.order_item_id) AS "sold_items"
FROM order_items as os;

# 3 What’s the average price of the products being sold?

CREATE TABLE Tech_Products AS
SELECT *
FROM products
WHERE product_category_name LIKE "pcs" OR 
      product_category_name LIKE "%tablet%" OR
      product_category_name LIKE "%informatica%" OR
      product_category_name LIKE "%eletroni%" OR
      product_category_name LIKE "%telefonia" OR
      product_category_name = "audio" OR
      product_category_name = "pc_gamer"
ORDER BY product_category_name;

#check up
SELECT * FROM Tech_products;

SELECT tp.product_category_name,
       e.product_category_name_english,
       ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items AS oi
INNER JOIN Tech_Products AS tp
ON oi.product_id = tp.product_id
INNER JOIN product_category_name_translation AS e
ON tp.product_category_name = e.product_category_name
GROUP BY tp.product_category_name
ORDER BY avg_price DESC;

# 3.1 Getting the Revenue and the earnings

# Revenue per tech category:
SELECT tp.product_category_name,
       ROUND(SUM(op.payment_value * op.payment_installments), 0) AS revenue
FROM Tech_Products AS tp       
INNER JOIN order_items AS oi
ON tp.product_id = oi.product_id
INNER JOIN order_payments AS op
ON oi.order_id = op.order_id
GROUP BY tp.product_category_name
ORDER BY revenue DESC;


# Total revenue (from all categories, not the tech only):
SELECT ROUND(SUM(op.payment_value * op.payment_installments), 0) AS revenue
FROM order_items AS oi      
INNER JOIN order_payments AS op
ON oi.order_id = op.order_id
ORDER BY revenue DESC;



# 4 Are expensive tech products popular? 

CREATE TABLE average_price AS
SELECT tp.product_category_name,
       ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items AS oi
INNER JOIN Tech_Products AS tp
ON oi.product_id = tp.product_id
GROUP BY tp.product_category_name
ORDER BY avg_price DESC;

# check up
SELECT *
FROM average_price;

SELECT tp.product_category_name,
	   eng.product_category_name_english,
       COUNT(oi.order_item_id) AS number_of_orders,
       ap.avg_price,
       COUNT(
             CASE WHEN oi.price > ap.avg_price THEN 1 ELSE NULL END
             ) AS orders_above_avg_price
FROM order_items AS oi
INNER JOIN Tech_Products AS tp
ON oi.product_id = tp.product_id
INNER JOIN average_price as ap
ON tp.product_category_name = ap.product_category_name
INNER JOIN product_category_name_translation AS eng
ON ap.product_category_name = eng.product_category_name
GROUP BY tp.product_category_name, ap.avg_price;


