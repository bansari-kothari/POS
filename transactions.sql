/*TRANSACTION 1*/

START TRANSACTION;
SET autocommit = 0;

INSERT INTO Customer(id,firstName,lastName,email,address,birthDate,zip)
SELECT 99999,'Bansari','Kothari','bkothari@gmail.com','8 Tennessee Place','1995-12-07',77554;

INSERT INTO pos.`Order`(id,customerID)
SELECT 99999,99999;

INSERT INTO OrderLine(orderID,productID,quantity)
SELECT 99999,17,1 UNION ALL
SELECT 99999,27,1 UNION ALL
SELECT 99999,57,1;

COMMIT;

/*TRANSACTION 2*/

START TRANSACTION;
SET autocommit = 0;

INSERT INTO Customer(id,firstName,lastName,email,address,birthDate,zip)
SELECT 99998,'Wrong','Kothari','bwrongkothari@gmail.com','8 Tennessee Place','1995-12-07',77554;

INSERT INTO pos.`Order`(id,customerID)
SELECT 99998,99997;

INSERT INTO OrderLine(orderID,productID,quantity)
SELECT 99998,18,2 UNION ALL
SELECT 99998,28,2 UNION ALL
SELECT 99998,58,2;

COMMIT;
