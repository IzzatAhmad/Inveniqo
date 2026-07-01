/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryDAO;
import model.Product;
import model.User;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import dao.CompanyDAO;
import model.Company;
import java.io.File;
import com.itextpdf.text.Image;
import com.itextpdf.text.Font;
import com.itextpdf.text.Element;

// Library untuk PDF standard
import com.itextpdf.text.Document;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.BaseColor;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfWriter;

@WebServlet("/ExportInventoryServlet")
public class ExportInventoryServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String type = request.getParameter("type"); // 'excel' atau 'pdf'
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String categoryParam = request.getParameter("categoryID");
        int categoryID = (categoryParam != null && !categoryParam.isEmpty()) ? Integer.parseInt(categoryParam) : 0;

        try {
            InventoryDAO inventoryDAO = new InventoryDAO();
            
            // Tarik laporan penuh tanpa limit pagination (Set limit besar 100000)
            List<Product> list = inventoryDAO.getInventoryByBranchFiltered(
                    loggedUser.getBranchID(), search, status, categoryID, 100000, 0
            );

            if ("excel".equalsIgnoreCase(type)) {
                // EXPORT EXCEL VIA COMPATIBLE CSV (Bebas ralat ClassNotFound Apache POI)
                response.setContentType("text/csv; charset=UTF-8");
                response.setHeader("Content-Disposition", "attachment; filename=Inventory_Report_" + loggedUser.getBranchID() + ".csv");
                
                try (OutputStream os = response.getOutputStream()) {
                    // Tulis UTF-8 BOM bytes supaya Excel Microsoft auto-detect tulisan dengan betul
                    os.write(new byte[] { (byte)0xEF, (byte)0xBB, (byte)0xBF });
                    
                    PrintWriter writer = new PrintWriter(os);
                    writer.println("Product ID,Product Name,SKU,Cost Price (RM),Selling Price (RM),Stock Quantity,Status");
                    
                    for (Product p : list) {
                        String stockStatus = p.getCurrentStock() <= 0 ? "Out of Stock" : (p.getCurrentStock() <= p.getLowStockThreshold() ? "Low Stock" : "In Stock");
                        writer.println(String.format("\"%s\",\"%s\",\"%s\",%.2f,%.2f,%d,\"%s\"",
                            p.getProductID(),
                            p.getProductName().replace("\"", "\"\""),
                            p.getSku(),
                            p.getCostPrice(),
                            p.getSellingPrice(),
                            p.getCurrentStock(),
                            stockStatus
                        ));
                    }
                    writer.flush();
                }
            } else if ("pdf".equalsIgnoreCase(type)) {
                exportToPDF(response, list, loggedUser);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            response.getWriter().println("Ralat mengeksport data: " + e.getMessage());
        }
    }

    private void exportToPDF(HttpServletResponse response, List<Product> list, User loggedUser) throws IOException {
        String branchName = loggedUser.getBranchName();
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=Inventory_Report_" + branchName + ".pdf");

        Document document = new Document(PageSize.A4);
        try (OutputStream out = response.getOutputStream()) {
            PdfWriter.getInstance(document, out);
            document.open();

            // Dynamic Company Branding Header
            CompanyDAO companyDAO = new CompanyDAO();
            Company company = null;
            try {
                company = companyDAO.getCompanyByID(loggedUser.getCompanyID());
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            boolean logoAdded = false;
            if (company != null && company.getCompanyLogo() != null && !company.getCompanyLogo().trim().isEmpty()) {
                String logoPath = company.getCompanyLogo();
                String absoluteLogoPath = getServletContext().getRealPath("/") + logoPath;
                File logoFile = new File(absoluteLogoPath);
                if (!logoFile.exists()) {
                    logoFile = new File(logoPath);
                }
                if (logoFile.exists() && logoFile.isFile()) {
                    try {
                        Image logoImg = Image.getInstance(logoFile.getAbsolutePath());
                        logoImg.scaleToFit(120, 60);
                        logoImg.setAlignment(Element.ALIGN_CENTER);
                        document.add(logoImg);
                        logoAdded = true;
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            if (!logoAdded) {
                Font fallbackFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD, new BaseColor(2, 132, 199));
                Paragraph fallbackHeader = new Paragraph("Inveniqo ERP Suite", fallbackFont);
                fallbackHeader.setAlignment(Element.ALIGN_CENTER);
                document.add(fallbackHeader);
            }

            Font titleFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.DARK_GRAY);
            Paragraph titlePara = new Paragraph("INVENIQO - LAPORAN KAWALAN STOK", titleFont);
            titlePara.setAlignment(Element.ALIGN_CENTER);
            document.add(titlePara);

            Font subTitleFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.GRAY);
            Paragraph branchPara = new Paragraph("Cawangan: " + branchName.toUpperCase(), subTitleFont);
            branchPara.setAlignment(Element.ALIGN_CENTER);
            document.add(branchPara);
            document.add(new Paragraph(" "));

            PdfPTable table = new PdfPTable(6);
            table.setWidthPercentage(100);
            table.setSpacingBefore(10f);

            String[] headers = {"Product Name", "SKU", "Cost", "Price", "Qty", "Status"};
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header));
                cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                cell.setPadding(5);
                table.addCell(cell);
            }

            for (Product p : list) {
                table.addCell(p.getProductName());
                table.addCell(p.getSku());
                table.addCell(String.format("%.2f", p.getCostPrice()));
                table.addCell(String.format("%.2f", p.getSellingPrice()));
                table.addCell(String.valueOf(p.getCurrentStock()));
                
                String stockStatus = p.getCurrentStock() <= 0 ? "Out of Stock" : (p.getCurrentStock() <= p.getLowStockThreshold() ? "Low Stock" : "In Stock");
                table.addCell(stockStatus);
            }

            document.add(table);
            document.close();
        } catch (Exception e) {
            throw new IOException(e.getMessage());
        }
    }
}