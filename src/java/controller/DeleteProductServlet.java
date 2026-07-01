/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productID = request.getParameter("id");
        
        try {
            InventoryDAO dao = new InventoryDAO();
            // Memanggil fungsi dwi-tugas pintar (smart delete)
            boolean success = dao.smartDeleteProduct(productID); 
            
            if (success) {
                response.sendRedirect("InventoryServlet?success=deleted");
            } else {
                response.sendRedirect("InventoryServlet?error=not_found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("InventoryServlet?error=delete_failed");
        }
    }
}