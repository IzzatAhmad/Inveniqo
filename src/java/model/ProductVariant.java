package model;

public class ProductVariant {
    private int variantID;
    private String productID;
    private String size;
    private String color;
    private String variantSku; // Pemetaan dari variant_sku
    private int stockQty;      // Pemetaan dari stock_qty
    private String imagePath;  // Pemetaan dari imagePath
    private String branchID;   // Pemetaan dari branchID

    // Constructor Kosong
    public ProductVariant() {}

    // Constructor Penuh
    public ProductVariant(int variantID, String productID, String size, String color, String variantSku, int stockQty, String imagePath, String branchID) {
        this.variantID = variantID;
        this.productID = productID;
        this.size = size;
        this.color = color;
        this.variantSku = variantSku;
        this.stockQty = stockQty;
        this.imagePath = imagePath;
        this.branchID = branchID;
    }

    // Getter dan Setter
    public int getVariantID() { return variantID; }
    public void setVariantID(int variantID) { this.variantID = variantID; }

    public String getProductID() { return productID; }
    public void setProductID(String productID) { this.productID = productID; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getVariantSku() { return variantSku; }
    public void setVariantSku(String variantSku) { this.variantSku = variantSku; }

    public int getStockQty() { return stockQty; }
    public void setStockQty(int stockQty) { this.stockQty = stockQty; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getBranchID() { return branchID; }
    public void setBranchID(String branchID) { this.branchID = branchID; }
}