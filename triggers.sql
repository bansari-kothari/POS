USE pos;

/************* Create History Table for tracking change in prices ********************************************/
CREATE OR REPLACE TABLE HistoricalPricing(
	 id INT NOT NULL AUTO_INCREMENT
	,productID INT NOT NULL
	,changeTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
	,oldPrice DOUBLE(5,2)
	,newPrice DOUBLE(5,2)
        ,PRIMARY KEY(id)
	,CONSTRAINT `Fk_Product_HistoricalPricing_productID` FOREIGN KEY(productID) REFERENCES pos.`Product`(id) ON DELETE RESTRICT
        )ENGINE=InnoDB;

/************* Call spCalculateTotals proc to calculate unitPrice & totalPrice for all records ***************/
CALL spCalculateTotals();

DELIMITER //

CREATE OR REPLACE TRIGGER insert_OrderLine
BEFORE INSERT ON pos.`OrderLine`
FOR EACH ROW
BEGIN
   
      SET new.unitPrice    = ( 
				SELECT price 
				FROM pos.`Product` 
				WHERE id = new.productID
						)
	,new.totalPrice  = (
				SELECT price * CAST(new.quantity  AS DECIMAL(5,2))
				FROM pos.`Product` 
				WHERE id = new.productID
                           );

      UPDATE pos.`Order`
      SET totalPrice = (
				SELECT SUM(totalPrice)+ new.totalPrice
				FROM pos.`OrderLine` 
			        WHERE orderID = new.orderID
				GROUP BY new.orderID
		           )
     WHERE id = new.orderID ;
	
END; //


CREATE OR REPLACE TRIGGER update_OrderLine
BEFORE UPDATE ON pos.`OrderLine`
FOR EACH ROW
BEGIN
   
	SET new.unitPrice = ( 
				SELECT price 
				FROM pos.`Product` 
				WHERE id = new.productID
		           )
	,new.totalPrice  = (
				SELECT price * CAST(new.quantity  AS DECIMAL(5,2))
				FROM pos.`Product` 
	                	WHERE id = new.productID
			    );		
      /* UPDATE pos.`Order`
       SET totalPrice = (
                              SELECT SUM(totalPrice) + new.totalPrice - old.totalPrice
                              FROM pos.`OrderLine`
                              WHERE orderID = new.orderID
                              GROUP BY new.orderID
                            )
       WHERE id = new.orderID; 
       */

END; //

CREATE OR REPLACE TRIGGER delete_OrderLine
AFTER DELETE ON pos.`OrderLine`
FOR EACH ROW
BEGIN
   
        UPDATE pos.`Order`
	SET totalPrice = (
				SELECT SUM(totalPrice)
				FROM pos.`OrderLine` 
				WHERE orderID = old.orderID
                                GROUP BY old.orderID				
                        )
       WHERE id = old.OrderID;
	
END; //


CREATE OR REPLACE TRIGGER insertol_mv_ProductCustomers
AFTER INSERT ON pos.`OrderLine`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
        
        UPDATE pos.`Order`
        SET totalPrice = (
                           SELECT SUM(totalPrice)
                           FROM pos.`OrderLine`
                           WHERE orderID = new.orderID
                           GROUP BY new.orderID
                         )
        WHERE id = new.orderID;
	
END; //


CREATE OR REPLACE TRIGGER updateol_mv_ProductCustomers
AFTER UPDATE ON pos.`OrderLine`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();

        UPDATE pos.`Order`
        SET totalPrice = (
                           SELECT SUM(totalPrice)
                           FROM pos.`OrderLine`
                           WHERE orderID = old.orderID
                           GROUP BY old.orderID
                         )
        WHERE id = old.orderID;
	
END; //


CREATE OR REPLACE TRIGGER deleteol_mv_ProductCustomers
AFTER DELETE ON pos.`OrderLine`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //

CREATE OR REPLACE TRIGGER insertprod_mv_ProductCustomers
AFTER INSERT ON pos.`Product`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //

CREATE OR REPLACE TRIGGER updateprod_mv_ProductCustomers
AFTER UPDATE ON pos.`Product`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //


CREATE OR REPLACE TRIGGER deleteprod_mv_ProductCustomers
AFTER DELETE ON pos.`Product`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //

CREATE OR REPLACE TRIGGER insertcust_mv_ProductCustomers
AFTER INSERT ON pos.`Customer`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //


CREATE OR REPLACE TRIGGER updatecust_mv_ProductCustomers
AFTER UPDATE ON pos.`Customer`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //

CREATE OR REPLACE TRIGGER deletecust_mv_ProductCustomers
AFTER DELETE ON pos.`Customer`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //

CREATE OR REPLACE TRIGGER insertorder_mv_ProductCustomers
AFTER INSERT ON pos.`Order`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //

CREATE OR REPLACE TRIGGER updateorder_mv_ProductCustomers
AFTER UPDATE ON pos.`Order`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //


CREATE OR REPLACE TRIGGER deleteorder_mv_ProductCustomers
AFTER DELETE ON pos.`Order`
FOR EACH ROW
BEGIN

	CALL spFillMVProductCustomers();
	
END; //


CREATE OR REPLACE TRIGGER update_ProductPricing
BEFORE UPDATE ON Product
FOR EACH ROW
BEGIN

	IF old.price<>new.price
        THEN 
            INSERT INTO HistoricalPricing(productID,oldPrice,newPrice)
	    SELECT old.id,old.price,new.price;
        END IF;

END; //

DELIMITER ;
