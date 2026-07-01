package model;

public class Product {
    private String productID;
    private String productName;
    private String sku;
    private int categoryID;
    private String categoryName;
    private String description;
    private double costPrice;
    private double sellingPrice;
    private int currentStock; // Memetakan nilai 'quantity' dari product_branch (Total Stock)
    private int lowStockThreshold;
    private String productImage;
    private String companyID;
    private String status; // 'Active' atau 'Pending' atau 'Inactive'

    public Product() {}

    // Getter dan Setter Asas
    public String getProductID() { return productID; }
    public void setProductID(String productID) { this.productID = productID; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public int getCategoryID() { return categoryID; }
    public void setCategoryID(int categoryID) { this.categoryID = categoryID; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getCostPrice() { return costPrice; }
    public void setCostPrice(double costPrice) { this.costPrice = costPrice; }

    public double getSellingPrice() { return sellingPrice; }
    public void setSellingPrice(double sellingPrice) { this.sellingPrice = sellingPrice; }

    public int getCurrentStock() { return currentStock; }
    public void setCurrentStock(int currentStock) { this.currentStock = currentStock; }

    public int getLowStockThreshold() { return lowStockThreshold; }
    public void setLowStockThreshold(int lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public String getCompanyID() { return companyID; }
    public void setCompanyID(String companyID) { this.companyID = companyID; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // Fungsi Pembantu Status Stok Pintar Berpusat
    public String getStockStatus() {
        if (this.currentStock <= 0) {
            return "Out of Stock";
        } else if (this.currentStock <= this.lowStockThreshold) {
            return "Low Stock";
        } else {
            return "In Stock";
        }
    }
}