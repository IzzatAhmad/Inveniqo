/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryDAO;
import dao.AnalyticsDAO;
import model.User;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            String branchID = loggedUser.getBranchID();
            
            AnalyticsDAO analyticsDAO = new AnalyticsDAO();
            InventoryDAO inventoryDAO = new InventoryDAO(); // Untuk ambil statistik asas produk
            
            // Dapatkan Metrik
            double todaysSales = analyticsDAO.getTodaysSales(branchID);
            List<Map<String, Object>> topProducts = analyticsDAO.getTopSellingProducts(branchID);
            List<Map<String, Object>> recentActivities = analyticsDAO.getRecentActivities(branchID);
            
            // Dapatkan status ringkas inventori daripada dao sedia ada
            int activeProducts = inventoryDAO.getTotalProductsCount(branchID);
            int lowStockAlerts = inventoryDAO.getLowStockCount(branchID);
            int pendingApprovalCount = inventoryDAO.getPendingApprovalCount(branchID);
            
            // 3. Set attributes untuk ditangkap oleh dashboard.jsp
            request.setAttribute("activeProducts", activeProducts);
            request.setAttribute("lowStockAlerts", lowStockAlerts);
            request.setAttribute("pendingApprovalCount", pendingApprovalCount);
            request.setAttribute("todaysSales", todaysSales);
            
            // Tolak ke dashboard.jsp utama
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp");
        }
    }
}