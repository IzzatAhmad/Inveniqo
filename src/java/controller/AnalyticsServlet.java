package controller;

import dao.AnalyticsDAO;
import dao.PredictionDAO;
import model.User;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AnalyticsServlet")
public class AnalyticsServlet extends HttpServlet {
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
            PredictionDAO predictionDAO = new PredictionDAO();
            
            // Check showHistory parameter
            String showHistoryStr = request.getParameter("showHistory");
            boolean showHistory = "true".equalsIgnoreCase(showHistoryStr);
            
            // Tarik data kognitif sistem
            List<Map<String, Object>> topProducts = analyticsDAO.getTopSellingProducts(branchID);
            List<Map<String, Object>> recentActivities = analyticsDAO.getRecentActivities(branchID);
            List<Map<String, Object>> aiPredictions = predictionDAO.getStockPredictions(branchID, showHistory);
            
            request.setAttribute("topProducts", topProducts);
            request.setAttribute("recentActivities", recentActivities);
            request.setAttribute("aiPredictions", aiPredictions);
            request.setAttribute("showHistory", showHistory);

            // Fetch administrative security logs only if user matches system Admin role
            if (loggedUser.isAdmin()) {
                List<Map<String, Object>> securityLogs = analyticsDAO.getSecurityLogs();
                request.setAttribute("securityLogs", securityLogs);
            }
            
            // Hantar ke fail jsp baharu
            request.getRequestDispatcher("analytics.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("DashboardServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("approve".equalsIgnoreCase(action)) {
            String idStr = request.getParameter("predictionID");
            if (idStr != null) {
                try {
                    int predictionID = Integer.parseInt(idStr);
                    PredictionDAO predictionDAO = new PredictionDAO();
                    
                    String sku = predictionDAO.getSkuByPredictionID(predictionID);
                    boolean isSuccess = predictionDAO.approveReplenishment(predictionID);
                    
                    if (isSuccess) {
                        session.setAttribute("successMessage", "Replenishment approved and locked for SKU: " + sku);
                        // Log administrative security audit action
                        AnalyticsDAO.logSecurityAction(
                            loggedUser.getUserID(),
                            "Approved replenishment recommendation (PO pending) for SKU: " + sku + " (Prediction ID: " + predictionID + ")",
                            request.getRemoteAddr()
                        );
                    } else {
                        session.setAttribute("errorMessage", "Failed to approve replenishment.");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Error: " + e.getMessage());
                }
            }
        }

        response.sendRedirect("AnalyticsServlet");
    }
}