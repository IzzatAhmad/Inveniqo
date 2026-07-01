/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryDAO;
import dao.ProductVariantDAO; 
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;

@WebServlet("/StockInServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class StockInServlet extends HttpServlet {

    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final ProductVariantDAO variantDAO = new ProductVariantDAO(); 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            String productID = request.getParameter("productID");
            String variantSku = request.getParameter("variantSku"); 
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String reason = request.getParameter("reason");
            String remarks = request.getParameter("remarks");
            
            String branchID = loggedUser.getBranchID(); 
            String userID = loggedUser.getUserID();     

            // Urusan muat naik fail dokumen/resit bukti
            Part evidencePart = request.getPart("evidenceFile");
            if (evidencePart == null || evidencePart.getSize() == 0) {
                throw new Exception("Transaction proof document (evidence file) is mandatory and cannot be empty!");
            }
            String evidencePath = "";
            
            String fileName = java.nio.file.Paths.get(evidencePart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "evidence";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();
            
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            evidencePart.write(uploadPath + File.separator + uniqueFileName);
            evidencePath = "uploads/evidence/" + uniqueFileName;

            // 1. PANGGIL DAO UNTUK PROSES STOCK IN BERPUSAT 
            boolean isSuccess = inventoryDAO.processStockIn(productID, branchID, quantity, userID, reason, remarks, evidencePath, "");

            // 2. SINKRONISASI STOK VARIASI (FIX: Menghantar branchID demi menjaga penempatan cawangan)
            if (isSuccess && variantSku != null && !variantSku.trim().isEmpty()) {
                variantDAO.updateVariantStock(variantSku, branchID, quantity, "IN");
            }

            if (isSuccess) {
                session.setAttribute("successMessage", "Transaksi Stock In berjaya diproses!");
            } else {
                session.setAttribute("errorMessage", "Gagal memproses kemasukan stok.");
            }
            
            response.sendRedirect("InventoryServlet");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Ralat sistem: " + e.getMessage());
            response.sendRedirect("InventoryServlet");
        }
    }
}