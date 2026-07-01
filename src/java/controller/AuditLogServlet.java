/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.AuditLogDAO;
import model.User;
import model.AuditLog;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AuditLogServlet")
public class AuditLogServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User loggedUser = (User) session.getAttribute("loggedUser");

        // SEKATAN KETAT: Hanya peranan Admin korporat tulen sahaja boleh melihat jejak audit ini
        if (!loggedUser.isAdmin()) {
            session.setAttribute("errorMessage", "Access Denied: Restricted access to System Security Audit Logs.");
            response.sendRedirect("InventoryServlet");
            return;
        }

        try {
            AuditLogDAO auditDAO = new AuditLogDAO();
            List<model.AuditLog> auditLogsList = auditDAO.getRecentAuditLogs();
            
            request.setAttribute("auditLogsList", auditLogsList);
            request.getRequestDispatcher("audit_logs.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Ralat memuatkan panel keselamatan: " + e.getMessage());
            response.sendRedirect("DashboardServlet");
        }
    }
}