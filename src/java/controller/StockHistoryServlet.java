/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryDAO;
import model.User;
import model.StockTransaction;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/StockHistoryServlet")
public class StockHistoryServlet extends HttpServlet {
    
    private final InventoryDAO inventoryDAO = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        // Sekatan keselamatan: Pastikan pengguna telah log masuk
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // Ambil sejarah transaksi berdasarkan cawangan pengguna yang sedang aktif
            List<StockTransaction> historyList = inventoryDAO.getTransactionHistory(loggedUser.getBranchID());
            
            // Simpan senarai dalam request attribute untuk dipaparkan di JSP
            request.setAttribute("historyList", historyList);
            
            // Hantar (forward) ke halaman UI stockHistory.jsp
            request.getRequestDispatcher("stockHistory.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Gagal memuatkan sejarah transaksi: " + e.getMessage());
            response.sendRedirect("InventoryServlet");
        }
    }
}