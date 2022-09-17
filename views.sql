USE pos;

CREATE OR REPLACE VIEW v_Customers
AS
SELECT a.lastName,a.firstName,a.email,a.address,b.city,b.`state`,a.zip
FROM pos.Customer a 
INNER JOIN pos.Zip b
ON a.zip = b.zip
ORDER BY a.lastName,a.firstName,a.birthDate;

CREATE OR REPLACE VIEW v_CustomerProducts
AS
SELECT a.lastName,a.firstName,GROUP_CONCAT(DISTINCT d.app ORDER BY d.app SEPARATOR ',')apps
FROM pos.`Customer` a
LEFT JOIN pos.`Order` b 
ON a.id = b.customerID
INNER JOIN pos.`OrderLine` c
ON b.id = c.orderID
INNER JOIN pos.`Product` d
ON c.productID = d.id
GROUP BY a.lastName,a.firstName
ORDER BY a.lastName,a.firstName;

CREATE OR REPLACE VIEW v_ProductCustomers
AS
SELECT a.app,a.id AS productID,GROUP_CONCAT(DISTINCT CONCAT(d.firstName,' ',d.lastName) ORDER BY d.lastName,d.firstName SEPARATOR ',')customers
FROM pos.`Product` a
LEFT JOIN pos.`OrderLine` b 
ON a.id = b.productID
LEFT JOIN pos.`Order` c
ON b.orderID = c.id
LEFT JOIN pos.`Customer` d
ON c.customerID = d.id
GROUP BY a.app,a.id;

DROP TABLE IF EXISTS mv_ProductCustomers;

CREATE TABLE pos.`mv_ProductCustomers`
(
	app TEXT
	,productID INT NOT NULL
	,customers TEXT
	,PRIMARY KEY(productID)
)ENGINE = InnoDB;

INSERT INTO pos.`mv_ProductCustomers`(app,productID,customers)
SELECT a.app,a.id AS productID,GROUP_CONCAT(DISTINCT CONCAT(d.firstName,' ',d.lastName) ORDER BY d.lastName,d.firstName SEPARATOR ',')customers
FROM pos.`Product` a
LEFT JOIN pos.`OrderLine` b 
ON a.id = b.productID
LEFT JOIN pos.`Order` c
ON b.orderID = c.id
LEFT JOIN pos.`Customer` d
ON c.customerID = d.id
GROUP BY a.app,a.id;
