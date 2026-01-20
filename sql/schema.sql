CREATE SCHEMA IF NOT EXISTS public;

---------Таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY ,
    email VARCHAR(100) UNIQUE NOT NULL ,
    password_hash VARCHAR(250) NOT NULL ,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);


---------Таблица адресов
CREATE TABLE addresses(
    id SERIAL PRIMARY KEY ,
    user_id INT NOT NULL ,
    city VARCHAR(50) NOT NULL ,
    street VARCHAR(100) NOT NULL ,
    apartment VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE


);


----------Таблица категорий
CREATE TABLE categories(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(100) NOT NULL ,
    parent_id INT NULL ,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL

);


----------Таблица товаров
CREATE TABLE products(
    id SERIAL PRIMARY KEY ,
    name VARCHAR(200) NOT NULL ,
    description TEXT,
    price DECIMAL(10,2) NOT NULL ,
    stock_quantity INT DEFAULT 0,
    category_id INT NOT NULL ,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT

);


-----------Таблица заказов
CREATE TABLE orders(
    id SERIAL PRIMARY KEY ,
    user_id INT NOT NULL ,
    address_id INT NOT NULL ,
    status VARCHAR(20) CHECK ( status IN('pending','paid','shipped','delivered','cancelled')) ,
    total_amount DECIMAL(10,2) NOT NULL ,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ,
    FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE RESTRICT


);


---------Состав заказа
CREATE TABLE order_items(
    id SERIAL PRIMARY KEY ,
    order_id INT NOT NULL ,
    product_id INT NOT NULL ,
    quantity INT NOT NULL CHECK ( quantity > 0 ),
    price_at_time DECIMAL(10,2) NOT NULL ,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT

);

----------Таблица отзывов
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY ,
    user_id INT NOT NULL ,
    product_id INT NOT NULL ,
    rating INT NOT NULL CHECK ( rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ,
    UNIQUE (user_id,product_id)

);


