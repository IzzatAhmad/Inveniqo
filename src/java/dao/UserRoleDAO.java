package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DBConnection;

public class UserRoleDAO {

    /**
     * Assign satu role sahaja.
     */
    public void assignRole(String userID, String roleID, Connection con) throws Exception {
        String sql = "INSERT INTO user_role (userID, roleID) VALUES (?,?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.setString(2, roleID);
            ps.executeUpdate();
        }
    }

    /**
     * 🔥 BARU: Assign banyak role serentak (Sesuai untuk Inheritance Manager).
     * Contoh: Manager nak ada role R1 (Manager) dan R2 (Staff).
     */
    public void assignMultipleRoles(String userID, String[] roleIDs, Connection con) throws Exception {
        if (roleIDs == null || roleIDs.length == 0) return;
        
        String sql = "INSERT INTO user_role (userID, roleID) VALUES (?,?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (String roleID : roleIDs) {
                ps.setString(1, userID);
                ps.setString(2, roleID);
                ps.addBatch(); // Gunakan batch untuk lebih laju
            }
            ps.executeBatch();
        }
    }

    /**
     * Mendapatkan List Nama Role (e.g., "Manager", "Staff").
     */
    public List<String> getUserRoles(String userID) throws Exception {
        List<String> roles = new ArrayList<>();
        String sql = "SELECT r.roleName FROM role r "
                   + "JOIN user_role ur ON r.roleID = ur.roleID "
                   + "WHERE ur.userID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roles.add(rs.getString("roleName"));
                }
            }
        }
        return roles;
    }

    /**
     * Memadam semua peranan user tersebut. 
     * Sangat berguna semasa fungsi 'Edit User' di mana kita padam role lama 
     * dan masukkan role baru (Clear then Assign).
     */
    public void clearRoles(String userID, Connection con) throws Exception {
        String sql = "DELETE FROM user_role WHERE userID=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.executeUpdate();
        }
    }
    
    /**
     * Method Tambahan: Untuk semak ID Role (R1, R2, R3) jika perlu.
     * Kadang-kadang kita perlukan ID untuk logic programming.
     */
    public List<String> getUserRoleIDs(String userID) throws Exception {
        List<String> roleIDs = new ArrayList<>();
        String sql = "SELECT roleID FROM user_role WHERE userID = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roleIDs.add(rs.getString("roleID"));
                }
            }
        }
        return roleIDs;
    }
}