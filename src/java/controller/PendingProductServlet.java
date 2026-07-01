/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryDAO;
import model.Product;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/PendingProductServlet")
public class PendingProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Semak sesi pengguna (Hanya Manager yang boleh akses)
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        
        try {
            // 2. Panggil DAO untuk dapatkan senarai produk PENDING mengikut Company ID
            InventoryDAO dao = new InventoryDAO();
            List<Product> pendingList = dao.getPendingProducts(loggedUser.getCompanyID());

            // 3. Simpan senarai dalam request attribute untuk digunakan oleh JSP
            request.setAttribute("pendingList", pendingList);
            
            

            // 4. Forward ke halaman pending_approval.jsp
            request.getRequestDispatcher("pendingApproval.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // Jika berlaku error, hantar balik ke page utama
            response.sendRedirect("InventoryServlet?error=db_error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Biasanya doGet sudah mencukupi untuk memaparkan senarai,
        // tetapi kita halakan doPost ke doGet jika perlu.
        doGet(request, response);
    }
}