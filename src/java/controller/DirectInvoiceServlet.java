package controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Image;

import dao.InventoryDAO;
import dao.ProductVariantDAO;
import dao.CompanyDAO;
import model.Product;
import model.ProductVariant;
import model.Category;
import model.Company;
import model.User;
import util.DBConnection;

@WebServlet("/DirectInvoiceServlet")
public class DirectInvoiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        User loggedUser = (User) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            InventoryDAO inventoryDAO = new InventoryDAO();
            ProductVariantDAO variantDAO = new ProductVariantDAO();

            String branchID = loggedUser.getBranchID();
            String companyID = loggedUser.getCompanyID();

            List<Category> categoryList = inventoryDAO.getCategoriesByCompany(companyID);
            request.setAttribute("categoryList", categoryList);

            List<Product> branchProductList = inventoryDAO.getInventoryByBranch(branchID);
            request.setAttribute("branchProductList", branchProductList);

            Map<String, List<ProductVariant>> productVariantsMap = new HashMap<>();
            for (Product p : branchProductList) {
                // FIX: Menghantar branchID bersama untuk menyokong skema DB Langkah 3
                List<ProductVariant> variants = variantDAO.getVariantsByProductID(p.getProductID(), branchID);
                productVariantsMap.put(p.getProductID(), variants);
            }
            request.setAttribute("productVariantsMap", productVariantsMap);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("direct_invoice.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        User loggedUser = (User) request.getSession().getAttribute("loggedUser");
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String customerName = request.getParameter("customerName");
        String[] productIDs = request.getParameterValues("productID[]");
        String[] variantSkus = request.getParameterValues("variantSku[]");
        String[] quantitiesStr = request.getParameterValues("quantity[]");
        String[] pricesStr = request.getParameterValues("pricePerUnit[]");

        if (productIDs == null || productIDs.length == 0 || customerName == null || customerName.trim().isEmpty()) {
            response.sendRedirect("DirectInvoiceServlet?error=missing_data");
            return;
        }

        String branchID = loggedUser.getBranchID();
        String userID = loggedUser.getUserID();
        String saleID = "INV-" + (System.currentTimeMillis() / 1000);

        Connection conn = null;
        PreparedStatement psSale = null;
        PreparedStatement psDetail = null;
        PreparedStatement psUpdateStock = null;
        PreparedStatement psUpdateVariantStock = null;
        PreparedStatement psStockHistory = null;
        PreparedStatement psCost = null;

        String relativeReceiptPath = "receipts/" + saleID + ".pdf";

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            double totalAmount = 0.0;
            List<String> validProductIDs = new ArrayList<>();
            List<String> validVariantSkus = new ArrayList<>();
            List<Integer> validQuantities = new ArrayList<>();
            List<Double> validPrices = new ArrayList<>();

            for (int i = 0; i < productIDs.length; i++) {
                if (productIDs[i] == null || productIDs[i].trim().isEmpty()) {
                    continue;
                }
                int qty = Integer.parseInt(quantitiesStr[i]);
                double price = Double.parseDouble(pricesStr[i]);
                if (qty <= 0) {
                    throw new Exception("Quantity must be greater than zero.");
                }
                validProductIDs.add(productIDs[i]);
                validVariantSkus.add((variantSkus != null && i < variantSkus.length) ? variantSkus[i] : "");
                validQuantities.add(qty);
                validPrices.add(price);
                totalAmount += qty * price;
            }

            if (validProductIDs.isEmpty()) {
                throw new Exception("No valid items in the invoice.");
            }

            String sqlSale = "INSERT INTO sales (saleID, branchID, totalAmount, amountPaid, `change`, soldBy, customerName) VALUES (?, ?, ?, ?, ?, ?, ?)";
            psSale = conn.prepareStatement(sqlSale);
            psSale.setString(1, saleID);
            psSale.setString(2, branchID);
            psSale.setDouble(3, totalAmount);
            psSale.setDouble(4, totalAmount); 
            psSale.setDouble(5, 0.0); 
            psSale.setString(6, userID);
            psSale.setString(7, customerName);
            psSale.executeUpdate();

            String sqlDetail = "INSERT INTO sales_detail (saleID, productID, quantity, pricePerUnit, costPrice, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
            String sqlUpdateStock = "UPDATE product_branch SET quantity = quantity - ? WHERE productID = ? AND branchID = ?";
            
            // FIX: Tambah filter branchID pada query variasi bagi melindungi integriti data cawangan lain
            String sqlUpdateVariantStock = "UPDATE product_variants SET stock_qty = stock_qty - ? WHERE variant_sku = ? AND branchID = ?";
            String sqlCost = "SELECT costPrice FROM product WHERE productID = ?";
            String sqlStockHistory = "INSERT INTO stock_transaction (productID, branchID, transactionType, quantity, reason, remarks, userID, evidencePath) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            psDetail = conn.prepareStatement(sqlDetail);
            psUpdateStock = conn.prepareStatement(sqlUpdateStock);
            psUpdateVariantStock = conn.prepareStatement(sqlUpdateVariantStock);
            psCost = conn.prepareStatement(sqlCost);
            psStockHistory = conn.prepareStatement(sqlStockHistory);

            for (int i = 0; i < validProductIDs.size(); i++) {
                String pID = validProductIDs.get(i);
                String vSku = validVariantSkus.get(i);
                int qty = validQuantities.get(i);
                double price = validPrices.get(i);
                double subtotal = qty * price;

                double costPrice = 0.0;
                psCost.setString(1, pID);
                try (ResultSet rsCost = psCost.executeQuery()) {
                    if (rsCost.next()) {
                        costPrice = rsCost.getDouble("costPrice");
                    }
                }

                psDetail.setString(1, saleID);
                psDetail.setString(2, pID);
                psDetail.setInt(3, qty);
                psDetail.setDouble(4, price);
                psDetail.setDouble(5, costPrice);
                psDetail.setDouble(6, subtotal);
                psDetail.addBatch();

                psUpdateStock.setInt(1, qty);
                psUpdateStock.setString(2, pID);
                psUpdateStock.setString(3, branchID);
                psUpdateStock.addBatch();

                if (vSku != null && !vSku.trim().isEmpty()) {
                    psUpdateVariantStock.setInt(1, qty);
                    psUpdateVariantStock.setString(2, vSku);
                    psUpdateVariantStock.setString(3, branchID); // FIX: Memetakan ke parameter ke-3 (branchID)
                    psUpdateVariantStock.addBatch();
                }

                psStockHistory.setString(1, pID);
                psStockHistory.setString(2, branchID);
                psStockHistory.setString(3, "OUT");
                psStockHistory.setInt(4, qty);
                psStockHistory.setString(5, "Direct Invoice");
                psStockHistory.setString(6, "Invoice No: " + saleID + " for " + customerName);
                psStockHistory.setString(7, userID);
                psStockHistory.setString(8, relativeReceiptPath);
                psStockHistory.addBatch();
            }

            psDetail.executeBatch();
            psUpdateStock.executeBatch();
            if (variantSkus != null) {
                psUpdateVariantStock.executeBatch();
            }
            psStockHistory.executeBatch();

            // GENERATE PDF
            try {
                String appPath = request.getServletContext().getRealPath("/");
                if (appPath == null) {
                    appPath = System.getProperty("user.home") + File.separator + "inveniqo_files";
                }
                String savePath = appPath + File.separator + "receipts";
                
                File fileSaveDir = new File(savePath);
                if (!fileSaveDir.exists()) {
                    fileSaveDir.mkdirs(); 
                }

                File receiptFile = new File(savePath + File.separator + saleID + ".pdf");
                Document document = new Document();
                PdfWriter.getInstance(document, new FileOutputStream(receiptFile));
                
                document.open(); 

                Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);
                Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
                Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 10);

                CompanyDAO companyDAO = new CompanyDAO();
                Company company = companyDAO.getCompanyByID(loggedUser.getCompanyID());
                boolean logoAdded = false;

                if (company != null && company.getCompanyLogo() != null && !company.getCompanyLogo().trim().isEmpty()) {
                    String logoPath = company.getCompanyLogo();
                    // FIX: Normalisasi path pemisah fail logo untuk mengelakkan ralat pembacaan iText OS
                    String absoluteLogoPath = request.getServletContext().getRealPath("/") + File.separator + logoPath;
                    File logoFile = new File(absoluteLogoPath);
                    if (!logoFile.exists()) {
                        logoFile = new File(logoPath);
                    }
                    if (logoFile.exists() && logoFile.isFile()) {
                        try {
                            Image logoImg = Image.getInstance(logoFile.getAbsolutePath());
                            logoImg.scaleToFit(100, 50);
                            logoImg.setAlignment(Paragraph.ALIGN_CENTER);
                            document.add(logoImg);
                            logoAdded = true;
                        } catch (Exception imgEx) {
                            imgEx.printStackTrace();
                        }
                    }
                }

                if (!logoAdded) {
                    Font fallbackFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, new BaseColor(2, 132, 199));
                    Paragraph fallbackHeader = new Paragraph("Inveniqo ERP Suite", fallbackFont);
                    fallbackHeader.setAlignment(Paragraph.ALIGN_CENTER);
                    document.add(fallbackHeader);
                }

                Paragraph title = new Paragraph("\nDIRECT SALES INVOICE\n", titleFont);
                title.setAlignment(Paragraph.ALIGN_CENTER);
                document.add(title);

                document.add(new Paragraph("Invoice ID : " + saleID, normalFont));
                document.add(new Paragraph("Customer   : " + customerName, normalFont));
                document.add(new Paragraph("Branch ID  : " + branchID, normalFont));
                document.add(new Paragraph("Issued By  : " + loggedUser.getUserName(), normalFont));
                document.add(new Paragraph("Date       : " + new java.util.Date(), normalFont));
                document.add(new Paragraph("----------------------------------------------------------------------------------\n\n", normalFont));

                PdfPTable table = new PdfPTable(3);
                table.setWidthPercentage(100);
                table.setWidths(new float[]{5f, 2f, 3f});

                PdfPCell cell1 = new PdfPCell(new Paragraph("Product ID / Name", boldFont));
                PdfPCell cell2 = new PdfPCell(new Paragraph("Qty", boldFont));
                PdfPCell cell3 = new PdfPCell(new Paragraph("Subtotal (RM)", boldFont));
                
                cell1.setBorder(PdfPCell.NO_BORDER);
                cell2.setBorder(PdfPCell.NO_BORDER);
                cell3.setBorder(PdfPCell.NO_BORDER);
                
                table.addCell(cell1);
                table.addCell(cell2);
                table.addCell(cell3);

                for (int i = 0; i < validProductIDs.size(); i++) {
                    String pID = validProductIDs.get(i);
                    String vSku = validVariantSkus.get(i);
                    int qty = validQuantities.get(i);
                    double price = validPrices.get(i);
                    double sub = qty * price;

                    String itemLabel = pID;
                    if (vSku != null && !vSku.trim().isEmpty()) {
                        itemLabel += " (" + vSku + ")";
                    }

                    PdfPCell pNameCell = new PdfPCell(new Paragraph(itemLabel, normalFont));
                    PdfPCell qtyCell = new PdfPCell(new Paragraph(String.valueOf(qty), normalFont));
                    PdfPCell priceCell = new PdfPCell(new Paragraph(String.format("%.2f", sub), normalFont));

                    pNameCell.setBorder(PdfPCell.NO_BORDER);
                    qtyCell.setBorder(PdfPCell.NO_BORDER);
                    priceCell.setBorder(PdfPCell.NO_BORDER);

                    table.addCell(pNameCell);
                    table.addCell(qtyCell);
                    table.addCell(priceCell);
                }
                document.add(table);

                document.add(new Paragraph("\n----------------------------------------------------------------------------------", normalFont));
                document.add(new Paragraph(String.format("Grand Total Amount : RM %.2f", totalAmount), boldFont));
                document.add(new Paragraph("Status             : Instant Pre-Paid", boldFont));
                document.add(new Paragraph("----------------------------------------------------------------------------------\n", normalFont));

                Paragraph footer = new Paragraph("THANK YOU FOR YOUR TRANSACTION", boldFont);
                footer.setAlignment(Paragraph.ALIGN_CENTER);
                document.add(footer);

                document.close(); 

            } catch (Exception pdfEx) {
                System.err.println("Gagal menjana PDF fizikal resit:");
                pdfEx.printStackTrace();
            }

            conn.commit();

            try {
                for (String pID : validProductIDs) {
                    util.IntegrationGateway.syncStockToMarketplaces(pID, branchID);
                }
            } catch (Exception syncEx) {
                syncEx.printStackTrace();
            }

            response.sendRedirect("DirectInvoiceServlet?status=success&receipt=" + saleID);

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            response.sendRedirect("DirectInvoiceServlet?error=failed&msg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } finally {
            try {
                if (psSale != null) psSale.close();
                if (psDetail != null) psDetail.close();
                if (psUpdateStock != null) psUpdateStock.close();
                if (psUpdateVariantStock != null) psUpdateVariantStock.close();
                if (psStockHistory != null) psStockHistory.close();
                if (psCost != null) psCost.close();
                if (conn != null) conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}