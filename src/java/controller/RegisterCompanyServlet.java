package controller;

import dao.UserDAO;
import dao.UserRoleDAO;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.User;
import util.DBConnection;
// Import PasswordUtil jika anda gunakannya untuk hashing
// import util.PasswordUtil;

@WebServlet("/RegisterCompanyServlet")
public class RegisterCompanyServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Ambil data dari form
        String companyName = request.getParameter("companyName");
        String brn = request.getParameter("businessRegNo");
        String companyEmail = request.getParameter("companyEmail");
        String branchName = request.getParameter("branchName");
        String branchAddress = request.getParameter("branchAddress");
        
        String managerName = request.getParameter("managerName");
        String managerEmail = request.getParameter("managerEmail");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // 2. Validasi Password
        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=Password%20not%20match");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // 🔥 Start Transaction

            UserDAO userDAO = new UserDAO();
            UserRoleDAO roleDAO = new UserRoleDAO();

            // 3. Generate ID (Tetap perlu companyID untuk simpan ke table branch)
            String companyID = userDAO.generateNextCompanyID(con); 
            String branchID  = userDAO.generateNextBranchID(con);  
            String userID    = userDAO.generateNextUserID(con);

            // 4. INSERT INTO company
            String sqlComp = "INSERT INTO company (companyID, companyName, companyEmail, businessRegNo, companyAddress) VALUES (?,?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sqlComp)) {
                ps.setString(1, companyID);
                ps.setString(2, companyName);
                ps.setString(3, companyEmail);
                ps.setString(4, brn);
                ps.setString(5, branchAddress);
                ps.executeUpdate();
            }

            // 5. INSERT INTO branch (Hubungkan dengan companyID)
            String sqlBranch = "INSERT INTO branch (branchID, branchName, branchAddress, companyID) VALUES (?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sqlBranch)) {
                ps.setString(1, branchID);
                ps.setString(2, branchName);
                ps.setString(3, branchAddress);
                ps.setString(4, companyID);
                ps.executeUpdate();
            }

            // 6. INSERT INTO user (Manager)
            // 🔥 Perhatikan: Tiada setCompanyID() di sini mengikut requirement baru
            User newUser = new User();
            newUser.setUserID(userID);
            newUser.setUserName(managerName);
            newUser.setUserEmail(managerEmail);
            newUser.setPassword(password); // Disarankan hash: PasswordUtil.hash(password)
            newUser.setBranchID(branchID);
            newUser.setUserStatus("Active"); // Pastikan default adalah Active
            
            userDAO.insertUser(newUser, con);

            // 7. ASSIGN ROLE (Manager)
            // Gunakan String "Manager" jika anda ikut cadangan 'Inheritance' Role
            // Jika database anda masih guna ID (R1), kekalkan "R1"
            // Manager pertama selalunya dapat R1 secara default
            roleDAO.assignRole(userID, "R1", con);
            
            // 8. COMMIT
            con.commit();
            response.sendRedirect("login.jsp?success=registered");

        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=Registration failed: " + e.getMessage());
        } finally {
            if (con != null) {
                try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}