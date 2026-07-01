package controller;

import dao.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/ReactivateUserServlet")
public class ReactivateUserServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userID = request.getParameter("userID");
        try {
            UserDAO dao = new UserDAO();
            if(dao.reactivateUser(userID)) {
                response.sendRedirect("ManageUserServlet?success=restored");
            } else {
                response.sendRedirect("ManageUserServlet?error=not_found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ManageUserServlet?error=system");
        }
    }
}