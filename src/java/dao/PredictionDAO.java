package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import util.DBConnection;

public class PredictionDAO {

    public List<Map<String, Object>> getStockPredictions(String branchID) {
        return getStockPredictions(branchID, false);
    }

    public List<Map<String, Object>> getStockPredictions(String branchID, boolean showHistory) {
        List<Map<String, Object>> predictions = new ArrayList<>();
        
        // 1. Run dynamic calculation query
        String sql = "SELECT p.productID, p.productName, p.sku, pb.quantity AS stockCurrent, pb.low_stock_threshold AS minStock, " +
                     "COALESCE(SUM(sd.quantity), 0) AS qtySold30Days " +
                     "FROM product p " +
                     "JOIN product_branch pb ON p.productID = pb.productID " +
                     "LEFT JOIN sales_detail sd ON p.productID = sd.productID " +
                     "LEFT JOIN sales s ON sd.saleID = s.saleID AND s.branchID = pb.branchID AND s.saleDate >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                     "WHERE pb.branchID = ? AND p.status = 'Active' " +
                     "GROUP BY p.productID";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, branchID);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String productID = rs.getString("productID");
                    String sku = rs.getString("sku");
                    int stockCurrent = rs.getInt("stockCurrent");
                    int qtySold30Days = rs.getInt("qtySold30Days");
                    int minStock = rs.getInt("minStock");
                    
                    // Kira Velocity (Purata jualan sehari)
                    double dailyVelocity = (double) qtySold30Days / 30.0;
                    int daysVelocityLeft = 999;
                    String statusAction = "Selamat (Stok Stabil)";
                    String badgeColor = "#10b981"; // Hijau
                    int recommendedRestockQty = 0;

                    if (dailyVelocity > 0) {
                        daysVelocityLeft = (int) Math.ceil(stockCurrent / dailyVelocity);
                        if (stockCurrent <= minStock) {
                            statusAction = "RESTOCK SEGERA (Kritikal)";
                            badgeColor = "#ef4444"; // Merah
                            recommendedRestockQty = (int) Math.ceil((dailyVelocity * 30) * 1.5); 
                        } else if (daysVelocityLeft <= 7) {
                            statusAction = "Sedia Restock (< 7 hari)";
                            badgeColor = "#f59e0b"; // Jingga
                            recommendedRestockQty = (int) Math.ceil((dailyVelocity * 15)); 
                        } else if (daysVelocityLeft <= 14) {
                            statusAction = "Perhatian (< 14 hari)";
                            badgeColor = "#3b82f6"; // Biru
                        }
                    } else if (stockCurrent <= minStock) {
                        statusAction = "Restock (Bawah Min Stock)";
                        badgeColor = "#f59e0b";
                        recommendedRestockQty = minStock * 2;
                    }

                    if (dailyVelocity > 0 || stockCurrent <= minStock) {
                        // Check if forecast row already recorded for this product in last 12 hours
                        boolean exists = false;
                        String checkSql = "SELECT predictionID FROM ai_predictions WHERE branchID = ? AND productID = ? AND computedDate >= DATE_SUB(NOW(), INTERVAL 12 HOUR)";
                        try (PreparedStatement psCheck = con.prepareStatement(checkSql)) {
                            psCheck.setString(1, branchID);
                            psCheck.setString(2, productID);
                            try (ResultSet rsCheck = psCheck.executeQuery()) {
                                if (rsCheck.next()) {
                                    exists = true;
                                }
                            }
                        }

                        if (!exists) {
                            String insertSql = "INSERT INTO ai_predictions (branchID, productID, sku, stockCurrent, dailyVelocity, daysLeft, recommendedQty, statusAction, badgeColor, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending')";
                            try (PreparedStatement psIns = con.prepareStatement(insertSql)) {
                                psIns.setString(1, branchID);
                                psIns.setString(2, productID);
                                psIns.setString(3, sku);
                                psIns.setInt(4, stockCurrent);
                                psIns.setDouble(5, dailyVelocity);
                                psIns.setInt(6, daysVelocityLeft);
                                psIns.setInt(7, recommendedRestockQty);
                                psIns.setString(8, statusAction);
                                psIns.setString(9, badgeColor);
                                psIns.executeUpdate();
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. Fetch logged predictions from DB matching the filter
        String query;
        if (showHistory) {
            query = "SELECT ap.*, p.productName FROM ai_predictions ap JOIN product p ON ap.productID = p.productID WHERE ap.branchID = ? ORDER BY ap.computedDate DESC";
        } else {
            query = "SELECT ap.*, p.productName FROM ai_predictions ap JOIN product p ON ap.productID = p.productID WHERE ap.branchID = ? AND ap.computedDate >= DATE_SUB(NOW(), INTERVAL 12 HOUR) ORDER BY ap.computedDate DESC";
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, branchID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("predictionID", rs.getInt("predictionID"));
                    map.put("productID", rs.getString("productID"));
                    map.put("productName", rs.getString("productName"));
                    map.put("sku", rs.getString("sku"));
                    map.put("stockCurrent", rs.getInt("stockCurrent"));
                    map.put("dailyVelocity", rs.getDouble("dailyVelocity"));
                    map.put("daysLeft", rs.getInt("daysLeft"));
                    map.put("statusAction", rs.getString("statusAction"));
                    map.put("badgeColor", rs.getString("badgeColor"));
                    map.put("recommendedQty", rs.getInt("recommendedQty"));
                    map.put("status", rs.getString("status"));
                    map.put("computedDate", rs.getTimestamp("computedDate"));
                    predictions.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return predictions;
    }

    public boolean approveReplenishment(int predictionID) {
        String sql = "UPDATE ai_predictions SET status = 'Processed' WHERE predictionID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, predictionID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String getSkuByPredictionID(int predictionID) {
        String sql = "SELECT sku FROM ai_predictions WHERE predictionID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, predictionID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("sku");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "Unknown SKU";
    }
}