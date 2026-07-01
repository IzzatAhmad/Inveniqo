package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.User;
import util.DBConnection;
import util.PasswordUtil;

public class UserDAO {

    // --- 1. LOGIN METHOD (With Double JOIN & Multi-Role) ---
    public User login(String email, String password) throws Exception {
        String sql = "SELECT u.userID, u.userName, u.userEmail, u.userStatus, u.branchID, u.profileImage, "
                + "r.roleName, b.branchName, b.companyID, c.companyName, c.companyLogo "
                + "FROM user u "
                + "LEFT JOIN branch b ON u.branchID = b.branchID "
                + "LEFT JOIN company c ON b.companyID = c.companyID "
                + "LEFT JOIN user_role ur ON u.userID = ur.userID "
                + "LEFT JOIN role r ON ur.roleID = r.roleID "
                + "WHERE u.userEmail=? AND u.password=? AND u.userStatus='Active'";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, PasswordUtil.hashPassword(password));

            ResultSet rs = ps.executeQuery();
            User u = null;

            while (rs.next()) {
                if (u == null) {
                    u = new User();
                    u.setUserID(rs.getString("userID"));
                    u.setUserName(rs.getString("userName"));
                    u.setUserEmail(rs.getString("userEmail"));
                    u.setUserStatus(rs.getString("userStatus"));
                    u.setBranchID(rs.getString("branchID"));
                    u.setProfileImage(rs.getString("profileImage"));
                    u.setBranchName(rs.getString("branchName"));
                    u.setCompanyName(rs.getString("companyName"));
                    u.setCompanyID(rs.getString("companyID"));
                    u.setCompanyLogo(rs.getString("companyLogo"));
                }
                String roleName = rs.getString("roleName");
                if (roleName != null) {
                    u.addRole(roleName);
                }
            }
            return u;
        }
    }

    // --- 2. GET USER BY ID (Consistent with Login Logic) ---
    public User getUserByID(String id) throws Exception {
        User u = null;
        String sql = "SELECT u.*, b.branchName, c.companyName, c.companyID, c.companyLogo "
                + "FROM user u "
                + "JOIN branch b ON u.branchID = b.branchID "
                + "JOIN company c ON b.companyID = c.companyID "
                + "WHERE u.userID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                u = new User();
                u.setUserID(rs.getString("userID"));
                u.setUserName(rs.getString("userName"));
                u.setUserEmail(rs.getString("userEmail"));
                u.setUserStatus(rs.getString("userStatus"));
                u.setBranchID(rs.getString("branchID"));
                u.setBranchName(rs.getString("branchName"));
                u.setCompanyName(rs.getString("companyName"));
                u.setCompanyID(rs.getString("companyID"));
                u.setCompanyLogo(rs.getString("companyLogo"));
            }
        }
        return u;
    }

    // --- 3. GET HQ BRANCH ID (Kunci untuk Manager HQ) ---
    public String getHQBranchID(String companyID) throws Exception {
        String sql = "SELECT branchID FROM branch WHERE companyID = ? ORDER BY branchID ASC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("branchID");
            }
        }
        return null;
    }

    // --- 4. SOFT DELETE ---
    public boolean deleteUser(String userID) throws Exception {
        String sql = "UPDATE user SET userStatus='Inactive' WHERE userID=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            return ps.executeUpdate() > 0;
        }
    }

    // --- 5. INSERT USER ---
    public void insertUser(User u, Connection con) throws Exception {
        String sql = "INSERT INTO user (userID, userName, userEmail, password, userStatus, branchID) VALUES (?,?,?,?,?,?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getUserID());
            ps.setString(2, u.getUserName());
            ps.setString(3, u.getUserEmail());
            ps.setString(4, PasswordUtil.hashPassword(u.getPassword()));
            ps.setString(5, u.getUserStatus() != null ? u.getUserStatus() : "Active");
            ps.setString(6, u.getBranchID());
            ps.executeUpdate();
        }
    }

    // --- 7. GET USERS BY BRANCH (Audit Trail Friendly) ---
    public List<User> getUsersByBranchWithRole(String branchID, String status) throws Exception {
        List<User> userList = new ArrayList<>();
        String sql = "SELECT u.userID, u.userName, u.userEmail, u.profileImage, u.userStatus, r.roleName "
                + "FROM user u "
                + "LEFT JOIN user_role ur ON u.userID = ur.userID "
                + "LEFT JOIN role r ON ur.roleID = r.roleID "
                + "WHERE u.branchID = ? AND u.userStatus = ? "
                + "ORDER BY u.userName ASC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, branchID);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();

            User lastUser = null;
            while (rs.next()) {
                String currentID = rs.getString("userID");
                if (lastUser == null || !lastUser.getUserID().equals(currentID)) {
                    lastUser = new User();
                    lastUser.setUserID(currentID);
                    lastUser.setUserName(rs.getString("userName"));
                    lastUser.setUserEmail(rs.getString("userEmail"));
                    lastUser.setUserStatus(rs.getString("userStatus"));
                    lastUser.setProfileImage(rs.getString("profileImage"));
                    userList.add(lastUser);
                }
                String roleName = rs.getString("roleName");
                if (roleName != null) {
                    lastUser.addRole(roleName);
                }
            }
        }
        return userList;
    }

    // --- 8. REACTIVATE USER ---
    public boolean reactivateUser(String userID) throws Exception {
        // Tukar status balik ke Active
        String sql = "UPDATE user SET userStatus='Active' WHERE userID=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userID);
            return ps.executeUpdate() > 0;
        }
    }

    // --- 9. UTILITY METHODS (Generators & Checks) ---
    public boolean isUserEmailExists(String email, Connection con) throws Exception {
        String sql = "SELECT 1 FROM user WHERE userEmail=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        }
    }

    public String generateNextUserID(Connection con) throws Exception {
        String sql = "SELECT userID FROM user ORDER BY userID DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String lastID = rs.getString("userID");
                long number = Long.parseLong(lastID.substring(1));
                return String.format("U%09d", number + 1);
            } else {
                return "U000000001";
            }
        }
    }

    // Generator untuk Company ID (C000000001 -> C999999999)
    public String generateNextCompanyID(Connection con) throws Exception {
        String sql = "SELECT companyID FROM company ORDER BY companyID DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String lastID = rs.getString("companyID");
                // Ambil semua karakter selepas 'C'
                long number = Long.parseLong(lastID.substring(1));
                return String.format("C%09d", number + 1);
            } else {
                return "C000000001";
            }
        }
    }

// Generator untuk Branch ID (B000000001 -> B999999999)
    public String generateNextBranchID(Connection con) throws Exception {
        String sql = "SELECT branchID FROM branch ORDER BY branchID DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String lastID = rs.getString("branchID");
                long number = Long.parseLong(lastID.substring(1));
                return String.format("B%09d", number + 1);
            } else {
                return "B000000001";
            }
        }
    }

    public List<User> getAllUsersByCompany(String companyID) throws Exception {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.userID, u.userName, u.branchID, b.branchName, r.roleName "
                + "FROM user u "
                + "JOIN branch b ON u.branchID = b.branchID "
                + "JOIN user_role ur ON u.userID = ur.userID "
                + "JOIN role r ON ur.roleID = r.roleID "
                + "WHERE b.companyID = ? ORDER BY u.userName ASC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserID(rs.getString("userID"));
                u.setUserName(rs.getString("userName"));
                u.setBranchID(rs.getString("branchID"));
                u.setBranchName(rs.getString("branchName"));
                u.addRole(rs.getString("roleName"));
                list.add(u);
            }
        }
        return list;
    }

    // Tambah method ini dalam UserDAO.java
    public void insertUserWithRole(User u, String roleName) throws Exception {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Mula Transaction

            // 1. Simpan ke table 'user'
            String sqlUser = "INSERT INTO user (userID, userName, userEmail, password, userStatus, branchID) VALUES (?,?,?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sqlUser)) {
                ps.setString(1, u.getUserID());
                ps.setString(2, u.getUserName());
                ps.setString(3, u.getUserEmail());
                ps.setString(4, PasswordUtil.hashPassword(u.getPassword()));
                ps.setString(5, "Active");
                ps.setString(6, u.getBranchID());
                ps.executeUpdate();
            }

            // 2. Cari roleID berdasarkan roleName
            int roleID = 0;
            String sqlRole = "SELECT roleID FROM role WHERE roleName = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlRole)) {
                ps.setString(1, roleName);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    roleID = rs.getInt("roleID");
                }
            }

            // 3. Simpan ke table 'user_role'
            String sqlUserRole = "INSERT INTO user_role (userID, roleID) VALUES (?,?)";
            try (PreparedStatement ps = con.prepareStatement(sqlUserRole)) {
                ps.setString(1, u.getUserID());
                ps.setInt(2, roleID);
                ps.executeUpdate();
            }

            con.commit(); // Berjaya semua, simpan!
        } catch (Exception e) {
            if (con != null) {
                con.rollback(); // Gagal, tarik balik semua
            }
            throw e;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

// --- Ambil Staff Berdasarkan Branch (Termasuk Active & Inactive) ---
    public List<User> getUsersByBranch(String branchID) throws Exception {
        List<User> userList = new ArrayList<>();
        String sql = "SELECT u.userID, u.userName, u.userEmail, u.userStatus, r.roleName "
                + "FROM user u "
                + "LEFT JOIN user_role ur ON u.userID = ur.userID "
                + "LEFT JOIN role r ON ur.roleID = r.roleID "
                + "WHERE u.branchID = ? AND u.userStatus = 'Active' ORDER BY u.userName ASC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, branchID);
            ResultSet rs = ps.executeQuery();

            Map<String, User> userMap = new LinkedHashMap<>();
            while (rs.next()) {
                String uid = rs.getString("userID");
                User u = userMap.get(uid);
                if (u == null) {
                    u = new User();
                    u.setUserID(uid);
                    u.setUserName(rs.getString("userName"));
                    u.setUserEmail(rs.getString("userEmail"));
                    u.setUserStatus(rs.getString("userStatus"));
                    userMap.put(uid, u);
                    userList.add(u);
                }
                String role = rs.getString("roleName");
                if (role != null) {
                    u.addRole(role);
                }
            }
        }
        return userList;
    }

    // --- Insert Staff Baru (Auto-Active & Multi-Role) ---
    public void insertUserWithMultipleRoles(User u, List<String> roles) throws Exception {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String sqlUser = "INSERT INTO user (userID, userName, userEmail, password, userStatus, branchID) VALUES (?,?,?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sqlUser)) {
                ps.setString(1, u.getUserID());
                ps.setString(2, u.getUserName());
                ps.setString(3, u.getUserEmail());
                ps.setString(4, PasswordUtil.hashPassword(u.getPassword()));
                ps.setString(5, "Active"); // Requirement: Auto Active
                ps.setString(6, u.getBranchID());
                ps.executeUpdate();
            }

            String sqlRole = "INSERT INTO user_role (userID, roleID) VALUES (?, (SELECT roleID FROM role WHERE roleName = ?))";
            try (PreparedStatement ps = con.prepareStatement(sqlRole)) {
                for (String rName : roles) {
                    ps.setString(1, u.getUserID());
                    ps.setString(2, rName);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

    // --- Update Staff (Nama, Email, Status & Roles) ---
    public void updateUserWithRoles(User u, List<String> roles) throws Exception {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String sqlUpd = "UPDATE user SET userName=?, userEmail=?, userStatus=? WHERE userID=?";
            try (PreparedStatement ps = con.prepareStatement(sqlUpd)) {
                ps.setString(1, u.getUserName());
                ps.setString(2, u.getUserEmail());
                ps.setString(3, u.getUserStatus());
                ps.setString(4, u.getUserID());
                ps.executeUpdate();
            }

            // Padam role lama dan masukkan baru
            try (PreparedStatement psDel = con.prepareStatement("DELETE FROM user_role WHERE userID=?")) {
                psDel.setString(1, u.getUserID());
                psDel.executeUpdate();
            }

            String sqlInsRole = "INSERT INTO user_role (userID, roleID) VALUES (?, (SELECT roleID FROM role WHERE roleName = ?))";
            try (PreparedStatement ps = con.prepareStatement(sqlInsRole)) {
                for (String rName : roles) {
                    ps.setString(1, u.getUserID());
                    ps.setString(2, rName);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (con != null) {
                con.close();
            }
        }
    }

    public void updateUserStatus(String userID, String status) throws Exception {
        String sql = "UPDATE user SET userStatus = ? WHERE userID = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, userID);
            ps.executeUpdate();
        }
    }

    public void updateBranch(String userID, String branchID) throws Exception {
        String sql = "UPDATE user SET branchID = ? WHERE userID = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, branchID);
            ps.setString(2, userID);
            ps.executeUpdate();
        }
    }

    public void updateProfile(User u, boolean updatePassword) throws Exception {
        String sql = updatePassword
                ? "UPDATE user SET userName = ?, password = ? WHERE userID = ?"
                : "UPDATE user SET userName = ? WHERE userID = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getUserName());
            if (updatePassword) {
                ps.setString(2, PasswordUtil.hashPassword(u.getPassword()));
                ps.setString(3, u.getUserID());
            } else {
                ps.setString(2, u.getUserID());
            }
            ps.executeUpdate();
        }
    }

    public void updateProfileImage(String userID, String imagePath) throws Exception {
        String sql = "UPDATE user SET profileImage = ? WHERE userID = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, imagePath);
            ps.setString(2, userID);
            ps.executeUpdate();
        }
    }
}
