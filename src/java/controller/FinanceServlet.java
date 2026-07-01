package controller;

import dao.InventoryDAO;
import model.User;
import model.FinancialSummary;
import model.MonthlyReport;
import model.Sales;
import model.Branch;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/FinanceServlet")
public class FinanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User loggedUser = (User) session.getAttribute("loggedUser");
        
        // PENGUATKUASAAN KESELAMATAN: Hanya Admin dan Manager sahaja boleh melihat data kewangan syarikat
        if (!loggedUser.isAdmin() && !loggedUser.isManager()) {
            session.setAttribute("errorMessage", "Access Denied: You do not have permission to view Financial Reports.");
            response.sendRedirect("InventoryServlet");
            return;
        }

        try {
            // Kita gunakan InventoryDAO atau FinanceDAO yang menyokong query Join Table
            dao.InventoryDAO inventoryDAO = new dao.InventoryDAO();

            // 1. Ambil parameter pilihan penapis masa, tarikh spesifik & cawangan dari UI
            String filterType = request.getParameter("filterType");
            if (filterType == null || filterType.isEmpty()) {
                filterType = "month"; // Lalai: Bulanan
            }

            // Menjaga konsep multi-branch: 
            // Jika user ialah Manager, dia dikunci untuk melihat cawangan dia sahaja.
            // Jika user ialah Admin, dia boleh menapis cawangan menggunakan parameter 'branchID' (Default: all).
            String branchID = request.getParameter("branchID");
            if (loggedUser.isManager()) {
                branchID = loggedUser.getBranchID(); 
            } else if (branchID == null || branchID.isEmpty()) {
                branchID = "all"; 
            }

            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");

            // Jika pengguna memilih penapis berbentuk 'custom', pastikan julat tarikh tidak kosong
            if ("custom".equals(filterType) && (startDate == null || endDate == null || startDate.isEmpty() || endDate.isEmpty())) {
                filterType = "month"; // Fallback jika tarikh tersilap isi
            }

            // 2. Proses data kewangan (Pastikan query SQL di dalam DAO anda menggunakan INNER JOIN ke jadual 'user' dan 'branch' untuk mendapatkan NAMA, bukan sekadar ID)
            // Contoh query yang sepatutnya di DAO: SELECT s.*, b.branchName, u.userName FROM sales s JOIN branch b ON s.branchID = b.branchID JOIN user u ON s.soldBy = u.userID...
            model.FinancialSummary summary = inventoryDAO.getFilteredFinancialSummary(branchID, filterType, startDate, endDate);
            List<model.MonthlyReport> monthlyReports = inventoryDAO.getMonthlyReports(loggedUser.getCompanyID());
            List<model.Sales> recentSales = inventoryDAO.getFilteredSalesWithNames(branchID, filterType, startDate, endDate);

            // 3. Tarik senarai cawangan penuh jika user adalah Admin (Untuk tujuan dropdown filter)
            if (loggedUser.isAdmin()) {
                List<model.Branch> branchList = inventoryDAO.getBranchesByCompany(loggedUser.getCompanyID());
                request.setAttribute("branchList", branchList);
            }

            // 4. Set parameter status ke halaman finance.jsp
            request.setAttribute("financialSummary", summary);
            request.setAttribute("monthlyReports", monthlyReports);
            request.setAttribute("recentSales", recentSales);
            request.setAttribute("currentFilter", filterType);
            request.setAttribute("currentBranchFilter", branchID);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);

            request.getRequestDispatcher("finance.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "System Error loading financial framework: " + e.getMessage());
            response.sendRedirect("DashboardServlet");
        }
    }

    @Override
    public String getServletInfo() {
        return "Inveniqo Central Financial Core Report Controller Engine";
    }
}