/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.AuditLog;
import util.DBConnection;

public class AuditLogDAO {

    /**
     * Menambah log aktiviti baharu ke dalam pangkalan data.
     * Kaedah ini boleh dipanggil secara statik atau dinamik di mana-mana Servlets.
     */
    public static void logActivity(String userID, String action, String details, String ipAddress) {
        String sql = "INSERT INTO audit_log (userID, action, details, ip_address, timestamp) VALUES (?, ?, ?, ?, NOW())";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.setString(2, action);
            ps.setString(3, details);
            ps.setString(4, ipAddress);
            ps.executeUpdate();
        } catch (Exception e) {
            System.err.println("Gagal merekodkan log audit keselamatan: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Menarik senarai log audit terbaharu untuk paparan dashboard System Admin (Limit 50 rekod).
     */
    public List<model.AuditLog> getRecentAuditLogs() throws Exception {
        List<model.AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.*, u.username FROM audit_log al " +
                     "JOIN user u ON al.userID = u.userID " +
                     "ORDER BY al.timestamp DESC LIMIT 50";
                     
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                model.AuditLog log = new model.AuditLog();
                log.setLogID(rs.getInt("logID"));
                log.setUserID(rs.getString("userID"));
                log.setUsername(rs.getString("username"));
                log.setAction(rs.getString("action"));
                log.setDetails(rs.getString("details"));
                log.setTimestamp(rs.getTimestamp("timestamp"));
                list.add(log);
            }
        }
        return list;
    }
}