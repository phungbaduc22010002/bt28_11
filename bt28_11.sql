
CREATE DATABASE InventoryManagement;

USE InventoryManagement;

-- Tạo bảng ProductSummary
CREATE TABLE ProductSummary (
    SummaryID INT PRIMARY KEY,
    TotalQuantity INT
);

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100),
    Quantity INT
);

CREATE TABLE InventoryChanges (
    ChangeID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    OldQuantity INT,
    NewQuantity INT,
    ChangeDate DATETIME,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
DELIMITER $$
CREATE TRIGGER AfterProductUpdate
AFTER INSERT 
ON Products
FOR EACH ROW
BEGIN
	 
     INSERT INTO InventoryChanges(ProductID ,OldQuantity, NewQuantity,ChangeDate)
     VALUES (ProductID ,OldQuantity, NewQuantity,NOW());
END $$
DELIMITER ;
 INSERT INTO  Products(ProductName,Quantity)
VALUES('ny1',500),('ny2',800),('ny3',900);

UPDATE Products
SET Quantity = 10
WHERE ProductID = 1;
-- Tạo Trigger BeforeProductDelete để kiểm tra số lượng sản phẩm trước khi xóa:
-- Kiểm tra xóa một sản phẩm có số lượng lớn hơn 10 và kiểm tra thông báo lỗi.

DELIMITER $$
CREATE TRIGGER BeforeProductDelete
BEFORE DELETE
ON Products
FOR EACH ROW
BEGIN
	IF OldQuantity >= 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'lỗi ';
    END IF;
END $$
DELIMITER ;
-- Thay đổi cấu trúc bảng Products để bao gồm một trường LastUpdated
-- Tạo Trigger AfterProductUpdateSetDate để cập nhật trường LastUpdated khi có thay đổi
ALTER TABLE Products
ADD COLUMN LastUpdated DATETIME;
DELIMITER $$
CREATE TRIGGER AfterProductUpdateSetDate
AFTER INSERT 
ON Products
FOR EACH ROW
BEGIN
	UPDATE Products
    SET LastUpdated = NOW()
    WHERE ProductID = NEW.ProductID;
END $$
DELIMITER ;
-- Tạo bảng ProductSummary: SummaryID(INT, Primary Key), TotalQuantity(INT)
-- Thêm một bản ghi khởi tạo vào bảng ProductSummary
-- Tạo Trigger AfterProductUpdateSummary để cập nhật tổng số lượng hàng trong ProductSummary mỗi khi có thay đổi số lượng hàng trong Products:
INSERT INTO ProductSummary (SummaryID, TotalQuantity)
SELECT 1, SUM(Quantity) FROM Products;
DELIMITER $$
CREATE TRIGGER AfterProductUpdateSummary
AFTER INSERT 
ON Products
FOR EACH ROW
BEGIN
	UPDATE ProductSummary
    SET  TotalQuantity = (SELECT SUM(Quantity) FROM Products);
END $$
DELIMITER ;
UPDATE Products
SET Quantity = 50
WHERE ProductID = 3;

-- ex5 Tạo Trigger AfterProductUpdateHistory để ghi lại lịch sử thay đổi số lượng và phân loại thay đổi
CREATE TABLE InventoryChangeHistory (
 historyID INT,
 oldQuantity INT,
 newQuantity INT,
 changeDate DATE,
  ProductID INT,
  ChangeType enum('Increase', 'Decrease'),
 FOREIGN KEY (ProductID) REFERENCES Products(ProductID)

);
DELIMITER $$
CREATE TRIGGER AfterProductUpdateHistory
AFTER INSERT 
ON Products
FOR EACH ROW
BEGIN

	DECLARE changeType enum('Increase', 'Decrease');
    IF Quantity < Quantity THEN
        SET changeType = 'Increase';
    ELSE
        SET changeType = 'Decrease';
    END IF;
    INSERT INTO InventoryChangeHistory(oldQuantity, newQuantity,  changeDate)
    VALUES(ProductID, Quantity, Quantity, NOW());

END $$
DELIMITER ;






