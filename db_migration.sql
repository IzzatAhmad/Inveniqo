-- 1. Overhaul roles names in database
-- R1 is Manager -> change to Admin
UPDATE role SET roleName = 'Admin' WHERE roleID = 'R1';
-- R3 is Finance Officer -> change to Manager
UPDATE role SET roleName = 'Manager' WHERE roleID = 'R3';

-- 2. Add Company profile Address and Logo columns
ALTER TABLE company ADD COLUMN companyAddress TEXT NULL;
ALTER TABLE company ADD COLUMN companyLogo VARCHAR(255) NULL;

-- 3. Add Multi-Location placement columns in product_branch
ALTER TABLE product_branch ADD COLUMN qty_on_display INT DEFAULT 0;
ALTER TABLE product_branch ADD COLUMN qty_storeroom INT DEFAULT 0;

-- Sync existing quantities to the storeroom
UPDATE product_branch SET qty_storeroom = quantity;

-- 4. Create Product Variant table for apparel/shoes parent-child relationship
CREATE TABLE IF NOT EXISTS product_variants (
    variantID INT AUTO_INCREMENT PRIMARY KEY,
    productID VARCHAR(255) NOT NULL,
    size VARCHAR(50) NULL,
    color VARCHAR(50) NULL,
    variant_sku VARCHAR(255) UNIQUE NOT NULL,
    stock_qty INT DEFAULT 0,
    FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Add costPrice to sales_detail for direct invoice / transaction profits
ALTER TABLE sales_detail ADD COLUMN costPrice DOUBLE DEFAULT 0.0;

-- 6. Add customerName to sales table for direct invoice tracking
ALTER TABLE sales ADD COLUMN customerName VARCHAR(255) NULL;

-- 7. Add imagePath to product_variants for variant-specific image handling
ALTER TABLE product_variants ADD COLUMN imagePath VARCHAR(255) NULL;

