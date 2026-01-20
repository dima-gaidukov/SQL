------------ РАЗДЕЛ 1: SELECT с сортировкой и фильтрацией


-- 1.1. Сортировка пользователей по имени (возрастание)
SELECT id,full_name,email,created_at
FROM users
ORDER BY full_name ASC ;

-- 1.2. Сортировка товаров по цене (убывание)

SELECT id,name,price,stock_quantity
FROM products
ORDER BY price DESC ;


-- 1.3. Фильтрация: товары дороже 60,000
SELECT id,name,price
FROM products
WHERE price > 60000
ORDER BY price ASC ;

-- 1.4. Фильтрация: заказы в статусе 'paid' или 'shipped'
SELECT id,user_id,status,total_amount
FROM orders
WHERE status IN ('paid','shopped')
ORDER BY create_at ASC;


-- 1.5. Фильтрация: пользователи с email на gmail.com (LIKE)
SELECT id,full_name,email
FROM users
WHERE email LIKE'%gmail.com%'
ORDER BY full_name;

-- 1.6. Фильтрация: товары с ценой между 30,000 и 80,000 (BETWEEN)
SELECT id,name,price
FROM products
WHERE price BETWEEN 30000 AND 80000
ORDER BY price;

-- 1.7. Комбинированная фильтрация: активные заказы за последнюю неделю
SELECT id,status,total_amount,create_at
FROM orders
WHERE status NOT IN ('cancelled') AND create_at >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY create_at DESC ;




------------ РАЗДЕЛ 2: GROUP BY с агрегатными функциями

-- 2.1. Количество заказов у каждого пользователя
SELECT user_id,
       u.full_name,
       count(*) as order_count,
       sum(total_amount) as total_sum,
       avg(total_amount) as total_avg
FROM orders o
JOIN users u ON o.user_id = u.id
GROUP BY user_id,u.full_name
ORDER BY order_count DESC ;

-- 2.2. Статистика по товарам: мин/макс/средняя цена в категории
SELECT c.name as category_name,
       count(p.id) as product_count,
       min(p.price) as min_price,
       max(p.price) as max_price,
       round(avg(p.price),2) as avg_price,
       sum(p.stock_quantity) as total_stock
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.name,c.id
ORDER BY product_count DESC;

-- 2.3. Рейтинги товаров
SELECT p.name as product_name,
       count(r.id) as total_rate,
       min(r.rating) as min_rate,
       max(r.rating) as max_rate,
       round(avg(r.rating),2) as avg_rate

FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.name,p.id
HAVING count(r.id) > 0
ORDER BY avg_rate DESC;

-- 2.4. Суммарная выручка по статусам заказов
SELECT status,
       count(*) as count_status,
       sum(total_amount) as sum_amount,
       round(avg(total_amount),2) as avg_anount
FROM orders
GROUP BY status
ORDER BY sum_amount DESC;

------------ РАЗДЕЛ 3: JOIN (связывание таблиц)

-- 3.1. Заказы с информацией о клиенте и адресе
SELECT o.id as order_id,
       o.status as order_status,
       o.total_amount as order_amount,
       o.create_at as order_date,
       u.full_name as user_name,
       u.email,
       concat(a.city,', ул. ', a.street, ', кв. ',a.apartment)
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN addresses a ON o.address_id = a.id
ORDER BY o.create_at DESC;

-- 3.2. Состав заказов с названиями товаров
SELECT
    oi.order_id,
    oi.quantity,
    oi.price_at_time,
    p.name as prod_name,
    p.price as current_price,
    (oi.quantity * oi.price_at_time) as item_total
FROM order_items oi
JOIN products p ON oi.product_id = p.id
ORDER BY oi.order_id,oi.id;

-- 3.3. Полная детализация заказа (клиент + товары)
SELECT o.id as ored_id,
       u.full_name as custamer,
       o.status ,
       o.total_amount,
       STRING_AGG(CONCAT(p.name, ' (', oi.quantity, ' шт.)'), ', ') as products_list
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
GROUP BY o.id,u.full_name,o.total_amount,o.status
ORDER BY o.id;

-- 3.4. Отзывы с полной информацией
SELECT r.rating,
       r.comment,
       r.created_at as rait_date,
       u.full_name as reviewer,
       p.name as product_name,
       c.name as category_name
FROM reviews r
JOIN users u ON r.user_id = u.id
JOIN products p ON r.product_id = p.id
JOIN categories c ON p.category_id = c.id
ORDER BY r.rating DESC;

-- 3.5. Товары с категориями (включая родительские)
SELECT
    p.name as product_name,
    p.price,
    p.stock_quantity,
    child.name as subcategory,
    COALESCE(parent.name, 'Без родительской') as maincategory

FROM products p
JOIN categories child ON p.category_id = child.id
LEFT JOIN categories parent ON child.parent_id = child.parent_id
ORDER BY maincategory,subcategory,p.name;






------------ РАЗДЕЛ 4: UPDATE (обновление данных)

-- 4.1. Обновление цены товара

SELECT 'ДО обновления:' as checkpoint;
SELECT id, name, price FROM products WHERE id = 1;

UPDATE products
SET price = 84990.00
WHERE id = 1;

SELECT 'ПОСЛЕ обновления:' as checkpoint;
SELECT id, name, price FROM products WHERE id = 1;


-- 4.2. Обновление статуса заказа

SELECT 'ДО обновления заказов:' as checkpoint;
SELECT id, status FROM orders WHERE id = 4;

UPDATE orders
SET status = 'shipped'
WHERE id = 4 AND status = 'pending';

SELECT 'ПОСЛЕ обновления заказов:' as checkpoint;
SELECT id, status FROM orders WHERE id = 4;


-- 4.3. Обновление остатка на складе

SELECT 'ДО обновления остатков:' as checkpoint;
SELECT id, name, stock_quantity FROM products WHERE id = 2;

UPDATE products
SET stock_quantity = stock_quantity - 3
WHERE id = 2;

SELECT 'ПОСЛЕ обновления остатков:' as checkpoint;
SELECT id, name, stock_quantity FROM products WHERE id = 2;







------------ РАЗДЕЛ 5: DELETE (удаление данных)

-- 5.1. Проверка данных перед удалением

SELECT 'Перед удалением отзыва:' as checkpoint;
SELECT * FROM reviews WHERE id = 7;

-- Удаление отзыва (проверка ON DELETE CASCADE не требуется, т.к. нет зависимостей)
DELETE FROM reviews WHERE id = 7;

SELECT 'После удаления отзыва:' as checkpoint;
SELECT  FROM reviews WHERE id = 7;

-- 5.2. Попытка удалить пользователя с заказами (проверка ON DELETE CASCADE)

SELECT 'Перед удалением пользователя:' as check_point;
SELECT * FROM users WHERE id = 4;
SELECT * FROM orders WHERE user_id = 4;
SELECT * FROM addresses WHERE user_id = 4;

-- Удаление пользователя (должно каскадно удалить его адреса и заказы)
DELETE FROM users WHERE id = 4;

SELECT 'После удаления пользователя:' as checkpoint;
SELECT * FROM users WHERE id = 4;
SELECT * FROM orders WHERE user_id = 4;
SELECT * FROM addresses WHERE user_id = 4;

-- 5.3. Попытка удалить категорию с товарами (должна быть ошибка RESTRICT)

SELECT 'Попытка удалить категорию с товарами:' as checkpoint;
SELECT * FROM categories WHERE id = 3;
SELECT COUNT(*) as productsincategory FROM products WHERE category_id = 3;

-- Эта команда вызовет ошибку (можно закомментировать после проверки)
DELETE FROM categories WHERE id = 3;

--[23503] ERROR: update or delete on table "categories" violates foreign key constraint "products_category_id_fkey" on table "products"
--Подробности: Key (id)=(3) is still referenced from table "products".







------------ РАЗДЕЛ 6: Проверка целостности данных

-- 6.1. Попытка вставить запись с несуществующим FOREIGN KEY

SELECT 'Попытка вставить заказ с несуществующим userid:' as checkpoint;

-- Эта команда вызовет ошибку
INSERT INTO orders (user_id, address_id, status, total_amount)
VALUES (999, 1, 'pending', 10000);

--[23503] ERROR: insert or update on table "orders" violates foreign key constraint "orders_user_id_fkey"
--Подробности: Key (user_id)=(999) is not present in table "users".






-- 6.2. Попытка вставить отзыв с несуществующим productid

SELECT 'Попытка вставить отзыв с несуществующим product_id:' as check_point;

-- Эта команда вызовет ошибку
INSERT INTO reviews (user_id, product_id, rating, comment)
VALUES (1, 999, 5, 'Тестовый отзыв');

--[23503] ERROR: insert or update on table "reviews" violates foreign key constraint "reviews_product_id_fkey"
--Подробности: Key (product_id)=(999) is not present in table "products".






-- 6.3. Проверка UNIQUE ограничения (email пользователей)

SELECT 'Попытка вставить дубликат email:' as check_point;

-- Эта команда вызовет ошибку
INSERT INTO users (email, password_hash, full_name)
VALUES ('ivanov@mail.ru', 'hash123', 'Тестовый Пользователь');

--[23505] ERROR: duplicate key value violates unique constraint "users_email_key"
--Подробности: Key (email)=(ivanov@mail.ru) already exists.





-- 6.4. Проверка CHECK ограничения (рейтинг от 1 до 5)

SELECT 'Попытка вставить некорректный рейтинг:' as check_point;

-- Эта команда вызовет ошибку
INSERT INTO reviews (user_id, product_id, rating, comment)
VALUES (1, 1, 6, 'Некорректный рейтинг');

--[23514] ERROR: new row for relation "reviews" violates check constraint "reviews_rating_check"
--Подробности: Failing row contains (9, 1, 1, 6, Некорректный рейтинг, 2026-01-20 12:03:35.76804).





-- 6.5. Итоговая проверка целостности данных
-- Проверка, что нет "осиротевших" записей

-- Проверка, что нет "осиротевших" записей
SELECT 'order_items без заказа:' as issue, COUNT(*) as count
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.id
WHERE o.id IS NULL

UNION ALL

SELECT 'order_items без товара:' as issue, COUNT(*) as count
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.id
WHERE p.id IS NULL

UNION ALL

SELECT 'заказы без пользователя:' as issue, COUNT(*) as count
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL

UNION ALL

SELECT 'адреса без пользователя:' as issue, COUNT(*) as count
FROM addresses a
LEFT JOIN users u ON a.user_id = u.id
WHERE u.id IS NULL;

