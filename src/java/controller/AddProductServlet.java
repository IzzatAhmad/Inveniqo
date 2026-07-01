package controller;

import dao.InventoryDAO;
import dao.ProductVariantDAO;
import model.ProductVariant;
import java.io.File;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import model.Product;
import model.User;

@WebServlet("/AddProductServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10)
public class AddProductServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User loggedUser = (User) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null) { response.sendRedirect("login.jsp"); return; }
        
        try {
            String pID = "P" + System.currentTimeMillis();
            String name = request.getParameter("productName");
            String sku = request.getParameter("sku");
            int catID = Integer.parseInt(request.getParameter("categoryID"));
            String status = (loggedUser.isAdmin() || loggedUser.isManager()) ? "Active" : "Pending";
            String desc = request.getParameter("description");
            double cost = Double.parseDouble(request.getParameter("costPrice"));
            double sell = Double.parseDouble(request.getParameter("sellingPrice"));
            int alert = Integer.parseInt(request.getParameter("lowStockThreshold"));
            String branchID = loggedUser.getBranchID(); // Ambil cawangan aktif

            // Parse Variants
            String hasVariants = request.getParameter("hasVariants");
            
            String[] variantSizes = request.getParameterValues("variantSize[]");
            String[] variantColors = request.getParameterValues("variantColor[]");
            String[] variantSkus = request.getParameterValues("variantSku[]");
            String[] variantImagePaths = request.getParameterValues("variantImagePath[]");

            // Handle Image Upload
            Part part = request.getPart("productImage");
            String fileName = "uploads/product/defaultproduct.png";
            
            if (part != null && part.getSize() > 0) {
                String timestamp = String.valueOf(System.currentTimeMillis());
                String fileExt = "jpg";
                String submittedFileName = part.getSubmittedFileName();
                if (submittedFileName != null && submittedFileName.contains(".")) {
                    fileExt = submittedFileName.substring(submittedFileName.lastIndexOf(".") + 1);
                }
                String newFileName = "prod_" + pID + "_" + timestamp + "." + fileExt;
                String savePath = getServletContext().getRealPath("/") + "uploads" + File.separator + "product";
                File fileSaveDir = new File(savePath);
                if (!fileSaveDir.exists()) fileSaveDir.mkdirs();
                part.write(savePath + File.separator + newFileName);
                fileName = "uploads/product/" + newFileName;
            }

            Product p = new Product();
            p.setProductID(pID);
            p.setProductName(name);
            p.setSku(sku);
            p.setCategoryID(catID);
            p.setDescription(desc);
            p.setCostPrice(cost);
            p.setSellingPrice(sell);
            p.setLowStockThreshold(alert);
            p.setCompanyID(loggedUser.getCompanyID());
            p.setProductImage(fileName);
            p.setStatus(status);

            new InventoryDAO().addProduct(p, branchID);

            if ("true".equals(hasVariants) && variantSkus != null) {
                ProductVariantDAO pvDao = new ProductVariantDAO();
                for (int i = 0; i < variantSkus.length; i++) {
                    String vSku = variantSkus[i];
                    if (vSku == null || vSku.trim().isEmpty()) continue;
                    
                    String vSize = (variantSizes != null && variantSizes.length > i) ? variantSizes[i] : "";
                    String vColor = (variantColors != null && variantColors.length > i) ? variantColors[i] : "";
                    String vImagePath = (variantImagePaths != null && variantImagePaths.length > i) ? variantImagePaths[i] : "";
                    
                    ProductVariant pv = new ProductVariant();
                    pv.setProductID(pID);
                    pv.setSize(vSize);
                    pv.setColor(vColor);
                    pv.setVariantSku(vSku);
                    pv.setStockQty(0); // Wajib mula dengan 0 kuantiti
                    pv.setImagePath(vImagePath);
                    pv.setBranchID(branchID); // FIX: Mengunci rujukan hak milik cawangan bagi variasi
                    
                    // FIX: Ditukar kepada addProductVariant selari dengan DAO Langkah 3
                    pvDao.addProductVariant(pv);
                }
            }

            response.sendRedirect("InventoryServlet?success=added");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("InventoryServlet?error=failed");
        }
    }
}