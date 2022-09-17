USE pos;

ALTER TABLE pos.`OrderLine` DROP COLUMN IF EXISTS unitPrice,DROP COLUMN IF EXISTS totalPrice;
ALTER TABLE pos.`Order` DROP COLUMN IF EXISTS totalPrice;

ALTER TABLE pos.`OrderLine` ADD COLUMN IF NOT EXISTS( 
		unitPrice DECIMAL(5,2)
		,totalPrice DECIMAL(5,2)
		);
		
ALTER TABLE pos.`Order` ADD COLUMN IF NOT EXISTS totalPrice DECIMAL(5,2);

DELIMITER //
CREATE OR REPLACE PROCEDURE spCalculateTotals()
BEGIN

	UPDATE pos.`OrderLine` AS a
	INNER JOIN pos.`Product` AS b 
	ON a.productID    = b.id
	SET a.unitPrice   = b.price
	,a.totalPrice  = (b.price * CAST(a.quantity AS DECIMAL(5,2)))
	WHERE a.unitPrice IS NULL;
		
	
	CREATE OR REPLACE VIEW vw_OrderDetails
	AS
	SELECT a.id,SUM(CAST(b.totalPrice AS DECIMAL(5,2))) AS orderTotalPrice
	FROM pos.`Order` a
	INNER JOIN pos.`OrderLine` b
	ON a.id = b.orderID
	GROUP BY a.id;

	UPDATE pos.`Order` AS a
	INNER JOIN vw_OrderDetails AS b
	ON a.id = b.id
	SET a.totalPrice = b.orderTotalPrice;

END //

DELIMITER ;


DELIMITER //

CREATE OR REPLACE PROCEDURE spCalculateTotalsLoop()
BEGIN

	DECLARE done BOOLEAN DEFAULT false;
	DECLARE oid INT;
	DECLARE pid INT;
	DECLARE pri DECIMAL(5,2);
	DECLARE quantity INT;

	DECLARE olcur CURSOR FOR 
	SELECT a.orderID,a.productID,b.price
	FROM pos.`OrderLine` AS a
	INNER JOIN pos.`Product` AS b
	ON a.productID = b.id;
	
	DECLARE ocur CURSOR FOR SELECT id FROM pos.`Order`;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        
        OPEN olcur;
        
        ol_loop: LOOP
		FETCH olcur INTO oid,pid,pri;
		IF done THEN 
			LEAVE ol_loop;
		END IF;
    
                UPDATE pos.`OrderLine` AS a 
		SET a.unitPrice = pri 
	           ,a.totalPrice = pri * CAST(a.quantity AS DECIMAL(5,2))
		WHERE a.orderID = oid 
		AND a.productID = pid;
	
	END LOOP ol_loop;
	CLOSE olcur;
    
	SET done = FALSE;
	
	OPEN ocur;

        o_loop: LOOP
		FETCH ocur INTO oid;
		IF done THEN
			LEAVE o_loop;
		END IF;
		
		UPDATE pos.`Order` AS a
		INNER JOIN (
				SELECT orderID,SUM(CAST(totalPrice AS DECIMAL(6,2))) AS orderTotalPrice
				FROM pos.`OrderLine`
				WHERE orderID = oid
				GROUP BY orderID
		           )AS b
		ON a.id = b.orderID				
		SET a.totalPrice = b.orderTotalPrice
		WHERE a.id = oid;
	
	END LOOP o_loop;
	CLOSE ocur;

END //

DELIMITER ;

DELIMITER //

CREATE OR REPLACE PROCEDURE spFillMVProductCustomers()
BEGIN

	DELETE FROM mv_ProductCustomers;
	INSERT INTO pos.`mv_ProductCustomers`(app,productID,customers)
	SELECT app,productID,customers
	FROM v_ProductCustomers;


END //
DELIMITER ;
