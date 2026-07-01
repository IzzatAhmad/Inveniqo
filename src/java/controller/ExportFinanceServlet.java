package controller;

import dao.FinanceDAO;
import model.FinancialSummary;
import model.Sales; 
import model.User;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.math.BigDecimal;
import dao.CompanyDAO;
import model.Company;
import java.io.File;
import com.itextpdf.text.Image;

import com.itextpdf.text.Document;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Element;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfWriter;

@WebServlet("/ExportFinanceServlet")
public class ExportFinanceServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String filterType = request.getParameter("filterType");
        String branchID = request.getParameter("branchID");
        String format = request.getParameter("format"); 
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        if (filterType == null || filterType.isEmpty()) filterType = "month";
        if (branchID == null || branchID.isEmpty()) branchID = "all";
        if (format == null || format.isEmpty()) format = "summary";

        try {
            FinanceDAO financeDAO = new FinanceDAO();
            FinancialSummary summary = financeDAO.getFilteredFinancialSummary(branchID, filterType, startDate, endDate);

            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=Penyata_Kewangan_" + filterType + "_" + format + ".pdf");

            Document document = new Document(PageSize.A4, 40, 40, 50, 50);
            
            try (OutputStream out = response.getOutputStream()) {
                PdfWriter.getInstance(document, out);
                document.open();

                Font titleFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, new BaseColor(15, 23, 42));
                Font subTitleFont = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, BaseColor.GRAY);
                Font boldFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.BLACK);
                Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.BLACK);

                // --- HEADER DOKUMEN ---
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
                    String absoluteLogoPath = getServletContext().getRealPath("/") + File.separator + logoPath;
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

                document.add(new Paragraph(" "));

                String namaFormat = format.equalsIgnoreCase("detailed") ? "LAPORAN ALIRAN TUNAI DETIL" : "PENYATA UNTUNG RUGI RINGKAS";
                Paragraph reportTitle = new Paragraph(namaFormat, titleFont);
                reportTitle.setAlignment(Element.ALIGN_CENTER);
                document.add(reportTitle);

                String tempohText = "Hari Ini (Daily)";
                if (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty()) {
                    tempohText = startDate + " hingga " + endDate;
                } else if ("month".equalsIgnoreCase(filterType)) {
                    tempohText = "Bulan Ini (Monthly)";
                } else if ("year".equalsIgnoreCase(filterType)) {
                    tempohText = "Tahun Ini (Yearly)";
                }

                Paragraph filterDetails = new Paragraph("Tempoh: " + tempohText + " | Kod Cawangan: " + branchID.toUpperCase(), subTitleFont);
                filterDetails.setAlignment(Element.ALIGN_CENTER);
                document.add(filterDetails);
                
                document.add(new Paragraph(" ")); 
                document.add(new Paragraph("Tarikh Cetakan: " + new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()), subTitleFont));
                document.add(new Paragraph("----------------------------------------------------------------------------------------------------------------------------------", subTitleFont));

                // --- SEKSYEN 1: JADUAL UNTUNG RUGI UTAMA ---
                document.add(new Paragraph("Kira-kira Untung Rugi:", boldFont));
                
                PdfPTable tableSummary = new PdfPTable(2);
                tableSummary.setWidthPercentage(100);
                tableSummary.setSpacingBefore(10f);
                tableSummary.setSpacingAfter(20f);
                tableSummary.setWidths(new float[]{75f, 25f});

                // FIX: Diubah kepada .getTotalRevenue() dan .getTotalCost() mengikut model BigDecimal terkini
                addFinanceRow(tableSummary, "JUMLAH PENDAPATAN JUALAN (REVENUE) (+)", String.format("RM %,.2f", summary.getTotalRevenue()), boldFont, true);
                addFinanceRow(tableSummary, "KOS PERBELANJAAN PRODUK (EXPENSES) (-)", String.format("RM %,.2f", summary.getTotalCost()), normalFont, false);
                addFinanceRow(tableSummary, "------------------------------------------------------------------------------------------", "--------------------------", normalFont, false);

                // FIX: Menangani pengiraan warna net profit berasaskan objek BigDecimal
                BaseColor statusColor = summary.getTotalProfit().compareTo(BigDecimal.ZERO) >= 0
                        ? new BaseColor(22, 101, 52)
                        : new BaseColor(153, 27, 27);
                Font profitFont = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, statusColor);
                
                addFinanceRow(tableSummary, "UNTUNG / (RUGI) BERSIH (NET PROFIT)", String.format("RM %,.2f", summary.getTotalProfit()), profitFont, true);
                document.add(tableSummary);

                // --- SEKSYEN 2: STRUKTUR SENARAI TRANSAKSI ---
                if ("detailed".equalsIgnoreCase(format)) {
                    document.add(new Paragraph("Lampiran Sejarah Aliran Tunai / Transaksi Jualan:", boldFont));
                    document.add(new Paragraph(" "));

                    PdfPTable tableTx = new PdfPTable(5);
                    tableTx.setWidthPercentage(100);
                    tableTx.setSpacingBefore(8f);
                    tableTx.setWidths(new float[]{20f, 20f, 20f, 25f, 15f});

                    String[] headers = {"Invoice ID", "Branch Name", "Juruwang", "Tarikh & Masa", "Jumlah Amaun"};
                    for (String header : headers) {
                        PdfPCell cell = new PdfPCell(new Phrase(header, boldFont));
                        cell.setBackgroundColor(new BaseColor(226, 232, 240)); 
                        cell.setPadding(6);
                        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                        tableTx.addCell(cell);
                    }

                    List<Sales> recentSales = financeDAO.getFilteredSales(branchID, filterType, startDate, endDate);
                    
                    if (recentSales != null && !recentSales.isEmpty()) {
                        for (Sales sale : recentSales) {
                            tableTx.addCell(new PdfPCell(new Phrase(sale.getSaleID(), normalFont)));

                            // FIX: Menggunakan .getBranchName() berbanding .getBranchID()
                            tableTx.addCell(new PdfPCell(new Phrase(sale.getBranchName(), normalFont)));

                            // FIX: Menggunakan .getStaffName() berbanding .getSoldBy()
                            tableTx.addCell(new PdfPCell(new Phrase(sale.getStaffName(), normalFont)));

                            // FIX: Menggunakan .getCreatedAt() berbanding .getSaleDate()
                            PdfPCell cDate = new PdfPCell(new Phrase(new SimpleDateFormat("dd/MM/yyyy hh:mm a").format(sale.getCreatedAt()), normalFont));
                            tableTx.addCell(cDate);

                            PdfPCell cAmount = new PdfPCell(new Phrase(String.format("RM %,.2f", sale.getTotalAmount()), normalFont));
                            cAmount.setHorizontalAlignment(Element.ALIGN_RIGHT);
                            tableTx.addCell(cAmount);
                        }
                    } else {
                        PdfPCell emptyCell = new PdfPCell(new Phrase("Tiada rekod transaksi dijumpai untuk tempoh ini.", subTitleFont));
                        emptyCell.setColspan(5);
                        emptyCell.setPadding(10);
                        emptyCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                        tableTx.addCell(emptyCell);
                    }
                    document.add(tableTx);
                }

                // --- FOOTER DOKUMEN ---
                document.add(new Paragraph(" "));
                document.add(new Paragraph("Ringkasan Operasi Ringkas:", boldFont));
                document.add(new Paragraph("Jumlah Kekerapan Transaksi POS: " + summary.getTotalInvoices() + " kali", normalFont));
                
                document.add(new Paragraph(" "));
                document.add(new Paragraph("----------------------------------------------------------------------------------------------------------------------------------", subTitleFont));
                Paragraph footerNote = new Paragraph("* Penyata ini dijana secara automatik menerusi sistem Inveniqo ERP. Data yang dicetak adalah muktamad mengikut integriti rekod pangkalan data.", subTitleFont);
                footerNote.setAlignment(Element.ALIGN_CENTER);
                document.add(footerNote);

                document.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Ralat Sistem Semasa Menjana Fail PDF Kewangan: " + e.getMessage());
        }
    }

    private void addFinanceRow(PdfPTable table, String description, String amount, Font font, boolean hasBackground) {
        PdfPCell cellDesc = new PdfPCell(new Phrase(description, font));
        PdfPCell cellAmount = new PdfPCell(new Phrase(amount, font));

        cellDesc.setPadding(8);
        cellAmount.setPadding(8);
        cellAmount.setHorizontalAlignment(Element.ALIGN_RIGHT);

        if (hasBackground) {
            BaseColor lightRowColor = new BaseColor(248, 250, 252);
            cellDesc.setBackgroundColor(lightRowColor);
            cellAmount.setBackgroundColor(lightRowColor);
        }

        cellDesc.setBorder(PdfPCell.NO_BORDER);
        cellAmount.setBorder(PdfPCell.NO_BORDER);

        table.addCell(cellDesc);
        table.addCell(cellAmount);
    }
}