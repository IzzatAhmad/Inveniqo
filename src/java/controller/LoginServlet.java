package controller;

import dao.UserDAO;
import model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            UserDAO userDAO = new UserDAO();
            
            // 1. Authenticate user 
            // Method login() menarik data user, branchName, companyName, dan Roles
            User user = userDAO.login(email, password);

            // 2. Semak jika user wujud dan aktif
            if (user == null) {
                // Redirect jika email/password salah atau status Inactive
                response.sendRedirect("login.jsp?error=invalid");
                return;
            }

            // 3. IDENTIFIKASI HQ (Requirement Penting)
            // Kita tarik branchID pertama syarikat ini untuk tentukan HQ
            String hqBranchID = userDAO.getHQBranchID(user.getCompanyID());
            user.setHQBranchID(hqBranchID); // Pastikan anda telah tambah field ini di model User

            // 4. Set Session
            HttpSession session = request.getSession();
            
            // Simpan objek user yang lengkap ke dalam session
            session.setAttribute("loggedUser", user);
            
            // Simpan roles secara berasingan untuk memudahkan akses pantas di JSP
            session.setAttribute("userRoles", user.getRoles());

            // 5. Log untuk debugging (Boleh buang kemudian)
            System.out.println("Login Success: " + user.getUserName());
            System.out.println("User Branch: " + user.getBranchID());
            System.out.println("Company HQ Branch: " + hqBranchID);
            System.out.println("Is HQ Manager? " + user.isHQManager());

            // 6. Redirect ke Dashboard
            response.sendRedirect("DashboardServlet");

        } catch (Exception e) {
            e.printStackTrace();
            // Jika ada ralat database atau sistem
            response.sendRedirect("login.jsp?error=system");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Jika user cuba akses LoginServlet via URL, hantar balik ke login.jsp
        response.sendRedirect("login.jsp");
    }
}