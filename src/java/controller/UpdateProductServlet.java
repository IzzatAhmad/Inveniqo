package controller;

import dao.InventoryDAO;
import dao.ProductVariantDAO;
import model.Product;
import model.ProductVariant;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/UpdateProductServlet")
public class UpdateProductServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loggedUser = (User) request.getSession().getAttribute("loggedUser");
        
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            String pID = request.getParameter("productID");
            String name = request.getParameter("productName");
            String sku = request.getParameter("sku");
            String desc = request.getParameter("description");
            String catIDStr = request.getParameter("categoryID");
            String thresholdStr = request.getParameter("lowStockThreshold");
            String branchID = loggedUser.getBranchID(); // Ambil branchID aktif cawangan

            if (catIDStr == null || catIDStr.isEmpty()) {
                throw new Exception("Category ID is missing. Please select a category.");
            }

            int catID = Integer.parseInt(catIDStr);
            int threshold = (thresholdStr != null && !thresholdStr.isEmpty()) ? Integer.parseInt(thresholdStr) : 10;

            Product p = new Product();
            p.setProductID(pID);
            p.setProductName(name);
            p.setSku(sku);
            p.setCategoryID(catID);
            p.setDescription(desc);
            p.setLowStockThreshold(threshold);

            // Logik Khas Manager / Admin (Kebenaran Pricing)
            boolean isManager = loggedUser.isAdmin() || loggedUser.isManager();
            
            if (isManager) {
                String costStr = request.getParameter("costPrice");
                String sellStr = request.getParameter("sellingPrice");
                
                double cost = (costStr != null && !costStr.isEmpty()) ? Double.parseDouble(costStr) : 0.0;
                double sell = (sellStr != null && !sellStr.isEmpty()) ? Double.parseDouble(sellStr) : 0.0;
                
                p.setCostPrice(cost);
                p.setSellingPrice(sell);
            }

            InventoryDAO dao = new InventoryDAO();
            boolean success = dao.updateProduct(p, isManager);

            if (success) {
                String hasVariants = request.getParameter("hasVariants");
                String[] variantSizes = request.getParameterValues("variantSize[]");
                String[] variantColors = request.getParameterValues("variantColor[]");
                String[] variantSkus = request.getParameterValues("variantSku[]");
                String[] variantQties = request.getParameterValues("variantQty[]");
                String[] variantImagePaths = request.getParameterValues("variantImagePath[]");

                ProductVariantDAO pvDao = new ProductVariantDAO();
                
                if ("true".equals(hasVariants) && variantSkus != null) {
                    // FIX: Menggunakan deleteVariantsByProduct(pID, branchID) ikut acuan Langkah 3
                    pvDao.deleteVariantsByProduct(pID, branchID);
                    
                    int totalVariantStock = 0;
                    for (int i = 0; i < variantSkus.length; i++) {
                        String vSku = variantSkus[i];
                        if (vSku == null || vSku.trim().isEmpty()) continue;
                        
                        String vSize = (variantSizes != null && variantSizes.length > i) ? variantSizes[i] : "";
                        String vColor = (variantColors != null && variantColors.length > i) ? variantColors[i] : "";
                        int vQty = 0;
                        if (variantQties != null && variantQties.length > i && variantQties[i] != null && !variantQties[i].trim().isEmpty()) {
                            vQty = Integer.parseInt(variantQties[i].trim());
                        }
                        String vImagePath = (variantImagePaths != null && variantImagePaths.length > i) ? variantImagePaths[i] : "";
                        
                        ProductVariant pv = new ProductVariant();
                        pv.setProductID(pID);
                        pv.setSize(vSize);
                        pv.setColor(vColor);
                        pv.setVariantSku(vSku);
                        pv.setStockQty(vQty);
                        pv.setImagePath(vImagePath);
                        pv.setBranchID(branchID); // FIX: Wajib set branchID agar data tidak terapung tanpa hak milik cawangan
                        
                        // FIX: Memanggil nama method addProductVariant(pv) sesuai kod Langkah 3
                        pvDao.addProductVariant(pv);
                        totalVariantStock += vQty;
                    }
                    
                    // Sinc Total Stock berpusat ke cawangan induk product_branch
                    dao.updateBranchStockForVariants(pID, branchID, totalVariantStock);
                } else {
                    // FIX: Menggunakan kaedah getVariantsByProductID yang memerlukan branchID
                    List<ProductVariant> oldVariants = pvDao.getVariantsByProductID(pID, branchID);
                    if (oldVariants != null && !oldVariants.isEmpty()) {
                        pvDao.deleteVariantsByProduct(pID, branchID);
                        dao.updateBranchStockForVariants(pID, branchID, 0);
                    }
                }

                response.sendRedirect("InventoryServlet?success=updated");
            } else {
                request.getSession().setAttribute("errorMessage", "Failed to update database.");
                response.sendRedirect("InventoryServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Error: " + e.getMessage());
            response.sendRedirect("InventoryServlet");
        }
    }
}