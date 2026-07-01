package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import util.DBConnection;

public class ExternalIntegrationDAO {

    /**
     * Memproses pemotongan stok daripada pesanan luar secara selamat (Transaction-safe)
     * Menyokong produk induk dan juga kemas kini stok variasi (variantSku).
     */
    public synchronized boolean deductStockFromExternal(String productID, String branchID, String variantSku, int quantityToDeduct) {
        // Query dipermudahkan tanpa lajur display/storeroom lama
        String checkSql = "SELECT quantity FROM product_branch WHERE productID = ? AND branchID = ?";
        String updateSql = "UPDATE product_branch SET quantity = quantity - ? WHERE productID = ? AND branchID = ?";
        String updateVariantSql = "UPDATE product_variants SET stock_qty = stock_qty - ? WHERE variant_sku = ? AND branchID = ?";
        String logSql = "INSERT INTO stock_transaction (productID, branchID, transactionType, quantity, reason, remarks, userID) "
                      + "VALUES (?, ?, 'OUT', ?, 'E-Commerce Sync', ?, 'SYSTEM_API')";
        
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Mulakan transaksi SQL tegar

            int currentTotal = 0;

            // 1. Semak baki stok semasa cawangan induk dahulu
            try (PreparedStatement psCheck = con.prepareStatement(checkSql)) {
                psCheck.setString(1, productID);
                psCheck.setString(2, branchID);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        currentTotal = rs.getInt("quantity");
                        
                        if (currentTotal < quantityToDeduct) {
                            con.rollback(); // Batalkan transaksi jika stok tidak mencukupi
                            return false; 
                        }
                    } else {
                        con.rollback(); // Produk tiada di cawangan ini
                        return false;
                    }
                }
            }

            // 2. Laksanakan kemaskini stok pada jadual induk cawangan
            try (PreparedStatement psUpdate = con.prepareStatement(updateSql)) {
                psUpdate.setInt(1, quantityToDeduct);
                psUpdate.setString(2, productID);
                psUpdate.setString(3, branchID);

                int rowsAffected = psUpdate.executeUpdate();
                if (rowsAffected <= 0) {
                    con.rollback();
                    return false;
                }
            }

            // 3. Kemaskini stok variasi sekiranya variantSku dihantar oleh Webhook pasaran luar
            if (variantSku != null && !variantSku.trim().isEmpty()) {
                try (PreparedStatement psVar = con.prepareStatement(updateVariantSql)) {
                    psVar.setInt(1, quantityToDeduct);
                    psVar.setString(2, variantSku);
                    psVar.setString(3, branchID);
                    
                    int varRows = psVar.executeUpdate();
                    if (varRows <= 0) {
                        // Jika fail kemaskini variasi gagal (contoh: Sku tidak wujud di cawangan ini)
                        con.rollback();
                        return false;
                    }
                }
            }

            // 4. Log transaksi ke Stock Transaction Control untuk jejak audit keselamatan
            try (PreparedStatement psLog = con.prepareStatement(logSql)) {
                psLog.setString(1, productID);
                psLog.setString(2, branchID);
                psLog.setInt(3, quantityToDeduct);
                
                String itemLabel = (variantSku != null && !variantSku.trim().isEmpty()) ? variantSku : productID;
                psLog.setString(4, "Auto sync dari External API Weborder. Item/SKU: " + itemLabel + " dipotong sebanyak " + quantityToDeduct + " unit.");
                psLog.executeUpdate();
            }

            con.commit(); // Berjaya semua, simpan perubahan kekal ke database
            return true;

        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try { con.close(); } catch (Exception ex) { ex.printStackTrace(); }
            }
        }
    }
}