/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import util.DBConnection; // Sila sesuaikan dengan nama class utiliti DB anda (cth: DBConnect dll)

public class SalesDAO {

    public Map<String, String> getCategoryMap() {
        Map<String, String> categoryMap = new HashMap<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            // Sesuaikan nama table 'category' dan nama kolum jika berbeza di DB anda
            String query = "SELECT categoryID, categoryName FROM category"; 
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                categoryMap.put(rs.getString("categoryID"), rs.getString("categoryName"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return categoryMap;
    }
    /**
     * Memproses keseluruhan transaksi jualan (Internal POS & External API)
     * Menggunakan konsep Database Transaction (Atomic / All-or-Nothing)
     */
    public boolean processSale(String saleID, String branchID, double totalAmount, double amountPaid, double change, String userID, String[] productIDs, int[] quantities, double[] prices) {
    Connection conn = null;
    PreparedStatement psSale = null;
    PreparedStatement psDetail = null;
    PreparedStatement psUpdateStock = null;
    PreparedStatement psStockHistory = null;
    PreparedStatement psCost = null;

    // Menetapkan laluan folder dan nama fail resit secara automatik
    // Contoh hasil: receipts/REC-10001.txt
    // Tukar pelanjutan fail kepada .pdf
    String relativeReceiptPath = "receipts/" + saleID + ".pdf";

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); 

        // A. MASUKKAN DATA KE JADUAL SALES
        String querySale = "INSERT INTO sales (saleID, branchID, totalAmount, amountPaid, `change`, soldBy) VALUES (?, ?, ?, ?, ?, ?)";
        psSale = conn.prepareStatement(querySale);
        psSale.setString(1, saleID);
        psSale.setString(2, branchID);
        psSale.setDouble(3, totalAmount);
        psSale.setDouble(4, amountPaid);
        psSale.setDouble(5, change);
        psSale.setString(6, userID); 
        psSale.executeUpdate();

        // B. SEDIAKAN QUERY DETAIL, UPDATE STOCK & HISTORY
        String queryDetail = "INSERT INTO sales_detail (saleID, productID, quantity, pricePerUnit, costPrice, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
        String queryUpdateStock = "UPDATE product_branch SET quantity = quantity - ? WHERE productID = ? AND branchID = ?";
        String queryCost = "SELECT costPrice FROM product WHERE productID = ?";
        
        // SINI: Kolum evidencePath diisi dengan relativeReceiptPath
        String queryStockHistory = "INSERT INTO stock_transaction (productID, branchID, transactionType, quantity, reason, remarks, userID, evidencePath) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        psDetail = conn.prepareStatement(queryDetail);
        psUpdateStock = conn.prepareStatement(queryUpdateStock);
        psStockHistory = conn.prepareStatement(queryStockHistory);
        psCost = conn.prepareStatement(queryCost);

        for (int i = 0; i < productIDs.length; i++) {
            if (productIDs[i] == null || productIDs[i].trim().isEmpty()) {
                continue; 
            }

            double currentPrice = prices[i];
            int currentQty = quantities[i];
            double subtotal = (double) currentQty * currentPrice;

            // Fetch product cost price
            double costPrice = 0.0;
            psCost.setString(1, productIDs[i]);
            try (ResultSet rsCost = psCost.executeQuery()) {
                if (rsCost.next()) {
                    costPrice = rsCost.getDouble("costPrice");
                }
            }

            psDetail.setString(1, saleID);
            psDetail.setString(2, productIDs[i]);
            psDetail.setInt(3, currentQty);
            psDetail.setDouble(4, currentPrice);
            psDetail.setDouble(5, costPrice);
            psDetail.setDouble(6, subtotal);
            psDetail.addBatch(); 

            psUpdateStock.setInt(1, currentQty);
            psUpdateStock.setString(2, productIDs[i]);
            psUpdateStock.setString(3, branchID);
            psUpdateStock.addBatch(); 

            // C. SET DATA HISTORY (Sertakan fail resit untuk setiap barangan dalam transaksi ini)
            psStockHistory.setString(1, productIDs[i]);
            psStockHistory.setString(2, branchID);
            psStockHistory.setString(3, "OUT");             
            psStockHistory.setInt(4, currentQty);           
            psStockHistory.setString(5, "Sales (POS)");      
            psStockHistory.setString(6, "Receipt No: " + saleID); 
            psStockHistory.setString(7, userID);            
            psStockHistory.setString(8, relativeReceiptPath); // <--- Laluan fail resit disimpan di sini
            psStockHistory.addBatch();
        }

        psDetail.executeBatch();
        psUpdateStock.executeBatch();
        psStockHistory.executeBatch(); 

        conn.commit(); 
        return true;

    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
        }
        e.printStackTrace();
        return false;
    } finally {
        try {
            if (psSale != null) psSale.close();
            if (psDetail != null) psDetail.close();
            if (psUpdateStock != null) psUpdateStock.close();
            if (psStockHistory != null) psStockHistory.close();
            if (psCost != null) psCost.close();
            if (conn != null) conn.close();
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
    }
}
}
