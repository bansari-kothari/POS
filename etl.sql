DROP DATABASE IF EXISTS pos;

CREATE DATABASE pos;

USE pos;

/* Since state is a reserved keyword, enclose column name with back ticks */
CREATE TABLE pos.Customer(
    id 			INT NOT NULL
    ,firstName 	TEXT
    ,lastName 	TEXT
    ,email 		TEXT
    ,address 	TEXT
	,city 		TEXT
	,`state` 	TEXT		
    ,birthDate 	DATE
	,zip 		INT NOT NULL
	,PRIMARY KEY(id)   
)ENGINE=INNODB;

/* Since state is a reserved keyword, enclose column name with back ticks */
CREATE TABLE pos.Zip(
 	 zip 		INT NOT NULL 
    ,city 		TEXT
    ,`state` 	TEXT
	,PRIMARY KEY(zip)
) ENGINE=INNODB;

/* Since Order is a reserved keyword, enclose  table_name with back ticks */	
CREATE TABLE pos.`Order`(
	id INT NOT NULL 
	,customerID INT NOT NULL
	,PRIMARY KEY(id)
	,CONSTRAINT `Fk_Order_Customer` FOREIGN KEY(customerID) REFERENCES pos.Customer(id)
	) ENGINE=InnoDB;
	
CREATE TABLE pos.Product(
     id 	INT NOT NULL 
	,app 	TEXT
	,price 	DECIMAL(4,2)
	,PRIMARY KEY(id)
	) ENGINE=InnoDB;

CREATE TABLE orderLineDummy(
	orderID INT NOT NULL
	,productID INT NOT NULL
	)ENGINE=INNODB;
	
/* Since Order is a reserved keyword, enclose parent table_name with back ticks */	
CREATE TABLE OrderLine(
    orderID INT NOT NULL
	,productID INT NOT NULL
	,quantity INT NOT NULL
	,PRIMARY KEY(orderId,productID)
	,CONSTRAINT `Fk_OrderLine_Order` FOREIGN KEY(orderID) REFERENCES `Order`(id)
	,CONSTRAINT `Fk_OrderLine_Product` FOREIGN KEY(productID) REFERENCES Product(id)
	)ENGINE=InnoDB;

LOAD DATA LOCAL INFILE '/home/dgomillion/Customer.csv'
INTO TABLE pos.Customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id,firstName,lastName,email,address,city,state,@zip,@birthDate)
SET birthDate = STR_TO_DATE(@birthDate,'%m/%d/%Y')
,zip = @zip;
	
INSERT INTO pos.Zip(zip,city,`state`)
SELECT DISTINCT zip,city,`state`
FROM pos.Customer;

ALTER TABLE pos.Customer DROP city,DROP `state`;
ALTER TABLE pos.Customer ADD CONSTRAINT `Fk_Customer_Zip` FOREIGN KEY(zip) REFERENCES pos.Zip(zip);
	
LOAD DATA LOCAL INFILE '/home/dgomillion/Order.csv'
INTO TABLE pos.`Order`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';


LOAD DATA LOCAL INFILE '/home/dgomillion/Product.csv'
INTO TABLE pos.`Product`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id,app,@price)
SET price = REPLACE(@price,'$','');	
	
LOAD DATA LOCAL INFILE '/home/dgomillion/OrderLine.csv'
INTO TABLE orderLineDummy
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';
	
INSERT INTO OrderLine(orderID,productID,quantity)
SELECT orderID,productID,COUNT(1) AS quantity
FROM pos.orderLineDummy
GROUP BY orderID,productID;

DROP TABLE orderLineDummy;
