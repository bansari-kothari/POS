USE pos;

CREATE OR REPLACE INDEX Idx_Product_app 
ON Product(app);

CREATE OR REPLACE FULLTEXT INDEX FtIdx_mv_ProductCustomers
ON mv_ProductCustomers(customers);
