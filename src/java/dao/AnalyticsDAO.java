package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import util.DBConnection;

public class AnalyticsDAO {

    // 1. Dapatkan Jumlah Jualan Hari Ini (Today's Sales)
    public double getTodaysSales(String branchID) {
        double total = 0.0;
        String sql = "SELECT COALESCE(SUM(totalAmount), 0.0) FROM sales WHERE DATE(saleDate) = CURDATE() ";
        
        // Tambah filter cawangan jika bukan HQ/Admin yang melihat keseluruhan
        if (branchID != null && !branchID.equals("all")) {
            sql += "AND branchID = ?";
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            if (branchID != null && !branchID.equals("all")) {
                ps.setString(1, branchID);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

    // 2. Dapatkan 5 Produk Paling Laris (Top Selling Products)
    public List<Map<String, Object>> getTopSellingProducts(String branchID) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.productName, p.sku, SUM(sd.quantity) as totalQtySold, SUM(sd.subtotal) as totalRevenue " +
                     "FROM sales_detail sd " +
                     "JOIN sales s ON sd.saleID = s.saleID " +
                     "JOIN product p ON sd.productID = p.productID " +
                     "WHERE 1=1 ";
        
        if (branchID != null && !branchID.equals("all")) {
            sql += "AND s.branchID = ? ";
        }
        
        sql += "GROUP BY p.productID ORDER BY totalQtySold DESC LIMIT 5";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            if (branchID != null && !branchID.equals("all")) {
                ps.setString(1, branchID);
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("productName", rs.getString("productName"));
                map.put("sku", rs.getString("sku"));
                map.put("totalQtySold", rs.getInt("totalQtySold"));
                map.put("totalRevenue", rs.getDouble("totalRevenue"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Dapatkan Aktiviti Terkini (Gabungan Transaksi POS & Pergerakan Stok)
    public List<Map<String, Object>> getRecentActivities(String branchID) {
        List<Map<String, Object>> list = new ArrayList<>();
        
        // Kita guna teknik UNION untuk gabungkan log jualan (sales) dan log inventori (stock_transaction)
        String sql = "(SELECT 'Jualan (POS)' as type, saleID as reference, totalAmount as amount, soldBy as user, saleDate as actDate " +
                     "FROM sales WHERE branchID = ?) " +
                     "UNION " +
                     "(SELECT CONCAT('Stok ', transactionType) as type, reason as reference, quantity as amount, userID as user, createdAt as actDate " +
                     "FROM stock_transaction WHERE branchID = ?) " +
                     "ORDER BY actDate DESC LIMIT 8";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, branchID);
            ps.setString(2, branchID);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("type", rs.getString("type"));
                map.put("reference", rs.getString("reference")); // Boleh jadi saleID atau 'Supply Restock'
                map.put("amount", rs.getDouble("amount"));       // Boleh jadi nilai RM atau Kuantiti Stok
                map.put("user", rs.getString("user"));
                map.put("actDate", rs.getTimestamp("actDate"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public static void logSecurityAction(String userID, String action, String ipAddress) {
        String sql = "INSERT INTO security_logs (userID, action, ipAddress) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.setString(2, action);
            ps.setString(3, ipAddress);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Map<String, Object>> getSecurityLogs() {
        List<Map<String, Object>> list = new ArrayList<>();
        
        // Auto-populate mock logs if empty
        try (Connection con = DBConnection.getConnection()) {
            checkAndInsertMockLogs(con);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        String sql = "SELECT sl.logID, sl.action, sl.ipAddress, sl.logDate, u.userName AS staffName " +
                     "FROM security_logs sl " +
                     "LEFT JOIN user u ON sl.userID = u.userID " +
                     "ORDER BY sl.logDate DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("logID", rs.getInt("logID"));
                map.put("action", rs.getString("action"));
                map.put("ipAddress", rs.getString("ipAddress"));
                map.put("logDate", rs.getTimestamp("logDate"));
                map.put("staffName", rs.getString("staffName")); // Normalized Cashier Name!
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void checkAndInsertMockLogs(Connection con) {
        try {
            String checkSql = "SELECT COUNT(*) FROM security_logs";
            try (PreparedStatement psCheck = con.prepareStatement(checkSql);
                 ResultSet rs = psCheck.executeQuery()) {
                if (rs.next() && rs.getInt(1) == 0) {
                    String ins = "INSERT INTO security_logs (userID, action, ipAddress) VALUES (?, ?, ?)";
                    try (PreparedStatement ps = con.prepareStatement(ins)) {
                        ps.setString(1, "U000000001");
                        ps.setString(2, "System Initialized AI Forecasting Engine");
                        ps.setString(3, "127.0.0.1");
                        ps.addBatch();

                        ps.setString(1, "U000000002");
                        ps.setString(2, "Replenishment Threshold updated for Category: Apparel");
                        ps.setString(3, "192.168.1.100");
                        ps.addBatch();

                        ps.setString(1, "U000000001");
                        ps.setString(2, "Database Security Audit Trail activated");
                        ps.setString(3, "127.0.0.1");
                        ps.addBatch();

                        ps.executeBatch();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}