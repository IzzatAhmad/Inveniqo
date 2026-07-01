package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.ProductVariant;
import util.DBConnection;

public class ProductVariantDAO {

    /**
     * 1. Mengambil senarai variasi produk spesifik berdasarkan cawangan aktif.
     * Digunakan untuk paparan baris-demi-baris pada tabel utama di inventory.jsp.
     */
    public List<ProductVariant> getVariantsByProductID(String productID, String branchID) throws Exception {
        List<ProductVariant> list = new ArrayList<>();
        // Query dikunci menggunakan productID DAN branchID cawangan masing-masing
        String sql = "SELECT * FROM product_variants WHERE productID = ? AND branchID = ? ORDER BY size ASC, color ASC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, productID);
            ps.setString(2, branchID);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantID(rs.getInt("variantID"));
                    v.setProductID(rs.getString("productID"));
                    v.setSize(rs.getString("size"));
                    v.setColor(rs.getString("color"));
                    v.setVariantSku(rs.getString("variant_sku")); // sepadan nama lajur DB
                    v.setStockQty(rs.getInt("stock_qty"));       // sepadan nama lajur DB
                    v.setImagePath(rs.getString("imagePath"));
                    v.setBranchID(rs.getString("branchID"));
                    list.add(v);
                }
            }
        }
        return list;
    }

    /**
     * 2. Menambah variasi produk baharu (Stok bermula dengan 0 seperti keperluan Phase 2).
     * Digunakan apabila pendaftaran produk baharu atau penambahan variasi di modal dikonfirmasikan.
     */
    public boolean addProductVariant(ProductVariant v) throws Exception {
        // Kuantiti stock_qty diwajibkan bermula dengan 0 (Initial stock tiada, perlu melalui proses Stock In)
        String sql = "INSERT INTO product_variants (productID, size, color, variant_sku, stock_qty, imagePath, branchID) "
                   + "VALUES (?, ?, ?, ?, 0, ?, ?)";
                   
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, v.getProductID());
            ps.setString(2, v.getSize());
            ps.setString(3, v.getColor());
            ps.setString(4, v.getVariantSku());
            ps.setString(5, v.getImagePath());
            ps.setString(6, v.getBranchID()); // Mengunci hak milik cawangan semasa pendaftaran
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 3. Kaedah Pemotongan / Penambahan Stok Variasi Pintar (Sinkronisasi Seiring Jualan & Transaksi)
     * Dipanggil oleh StockInServlet, StockOutServlet, dan enjin DirectInvoice kelak.
     */
    public boolean updateVariantStock(String variantSku, String branchID, int quantityChange, String transactionType) throws Exception {
        // Query diselaraskan mengikut lajur baharu dan dikunci mengikut cawangan bagi menjaga multi-branch
        String operator = "IN".equalsIgnoreCase(transactionType) ? "+" : "-";
        String sql = "UPDATE product_variants SET stock_qty = stock_qty " + operator + " ? WHERE variant_sku = ? AND branchID = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantityChange);
            ps.setString(2, variantSku);
            ps.setString(3, branchID); // Kunci cawangan yang memproses transaksi
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * 4. Membersihkan variasi produk lama semasa proses kemas kini modal (Edit Modal).
     * Membolehkan fungsi penukaran, penambahan, dan pemadaman baris variasi (Delete Row) berjalan bersih.
     */
    public void deleteVariantsByProduct(String productID, String branchID) throws Exception {
        String sql = "DELETE FROM product_variants WHERE productID = ? AND branchID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, productID);
            ps.setString(2, branchID);
            ps.executeUpdate();
        }
    }
}