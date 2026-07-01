package controller;

import dao.InventoryDAO;
import model.Product;
import model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.Category;

@WebServlet("/InventoryServlet")
public class InventoryServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            InventoryDAO inventoryDAO = new InventoryDAO();

            // 1. Ambil parameter carian dan filter dari request UI
            String search = request.getParameter("search");
            String status = request.getParameter("status");
            String categoryParam = request.getParameter("categoryID");
            int categoryID = (categoryParam != null && !categoryParam.isEmpty()) ? Integer.parseInt(categoryParam) : 0;

            // FIX: Jika tiada status penapisan spesifik (In Stock/Low Stock/Out of Stock) dipilih, 
            // kita tetapkan secara lalai (default) kepada 'Active' supaya produk 'Inactive' (Soft Deleted) tidak keluar.
            if (status == null || status.trim().isEmpty()) {
                status = "Active";
            }

            // 2. Logik Kawalan Pagination (Maksimum 10 Item Sehalaman)
            int limit = 10;
            int currentPage = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                currentPage = Integer.parseInt(pageParam);
            }
            int offset = (currentPage - 1) * limit;

            // 3. Tarik data barangan mengikut cawangan aktif masing-masing
            List<Product> inventoryList = inventoryDAO.getInventoryByBranchFiltered(
                    loggedUser.getBranchID(), search, status, categoryID, limit, offset
            );
            
            // 4. Kira jumlah keseluruhan barangan & total halaman berdasarkan kriteria tapisan
            int totalRecords = inventoryDAO.getInventoryCount(loggedUser.getBranchID(), search, status, categoryID);
            int totalPages = (int) Math.ceil((double) totalRecords / limit);
            if (totalPages == 0) totalPages = 1;

            List<Category> categoryList = inventoryDAO.getCategoriesByCompany(loggedUser.getCompanyID());

            // 5. Simpan semua atribut untuk dipaparkan di inventory.jsp
            request.setAttribute("categoryList", categoryList);
            request.setAttribute("inventoryList", inventoryList);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("search", search);
            request.setAttribute("status", "Active".equals(status) ? "" : status); // Balikkan ke string kosong di UI jika status ialah Active tulen
            request.setAttribute("selectedCategory", categoryID);

            request.getRequestDispatcher("inventory.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?error=system");
        }
    }
}