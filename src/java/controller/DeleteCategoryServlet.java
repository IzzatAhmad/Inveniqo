package controller;

import dao.InventoryDAO;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/DeleteCategoryServlet")
public class DeleteCategoryServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        User loggedUser = (User) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null) {
            out.write("{\"success\":false,\"message\":\"Unauthorized: Please log in first.\"}");
            return;
        }
        try {
            String catIdStr = request.getParameter("categoryID");
            if (catIdStr == null || catIdStr.trim().isEmpty()) {
                out.write("{\"success\":false,\"message\":\"Missing category ID.\"}");
                return;
            }
            int categoryID = Integer.parseInt(catIdStr.trim());
            InventoryDAO dao = new InventoryDAO();
            boolean success = dao.deleteCategory(categoryID);
            if (success) {
                out.write("{\"success\":true}");
            } else {
                out.write("{\"success\":false,\"message\":\"Category not found or could not be deleted.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") + "\"}");
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
