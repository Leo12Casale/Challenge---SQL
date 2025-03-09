drop database if exists challenge;
create database if not exists challenge;
use challenge;
-- Users
CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    address VARCHAR(255),
    birth_date DATE,
    phone VARCHAR(30)
);

-- Item Categories
CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(100) NOT NULL,
    path VARCHAR(255)
);

-- Item Status (active, inactive, etc.)
CREATE TABLE ItemStatus (
    item_status_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- Items
CREATE TABLE Item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    seller_id INT NOT NULL,
    title VARCHAR(150),
    price DECIMAL(15,2),
    item_status_id INT NOT NULL,
    date_created DATE DEFAULT (CURRENT_DATE()),
    date_removed DATE DEFAULT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (seller_id) REFERENCES User(user_id),
    FOREIGN KEY (item_status_id) REFERENCES ItemStatus(item_status_id)
);

-- Orders
CREATE TABLE PurchaseOrder (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT NOT NULL,
	seller_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2),
    order_date DATE DEFAULT (CURRENT_DATE()),
    FOREIGN KEY (buyer_id) REFERENCES User(user_id),
    FOREIGN KEY (seller_id) REFERENCES User(user_id),
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);

-- Historica snapshots de Items
CREATE TABLE ItemHistorical (
    item_id INT NOT NULL,
    snapshot_date DATE NOT NULL,
    price DECIMAL(15,2),
    item_status_id INT NOT NULL,
    PRIMARY KEY (item_id, snapshot_date),
    FOREIGN KEY (item_id) REFERENCES Item(item_id),
    FOREIGN KEY (item_status_id) REFERENCES ItemStatus(item_status_id)
);