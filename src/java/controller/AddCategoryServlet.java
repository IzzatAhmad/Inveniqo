/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.User;

/**
 *
 * @author User
 */
@WebServlet("/AddCategoryServlet")
public class AddCategoryServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession().getAttribute("loggedUser");
        String name = request.getParameter("name");
        
        try {
            int newID = new InventoryDAO().addCategory(name, user.getCompanyID());
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"newID\": " + newID + "}");
        } catch (Exception e) {
            response.getWriter().write("{\"success\": false}");
        }
    }
}