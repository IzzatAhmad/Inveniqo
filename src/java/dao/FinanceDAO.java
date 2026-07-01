/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.FinancialSummary;
import model.MonthlyReport;
import util.DBConnection;

public class FinanceDAO {

    // 1. Mengambil data Ringkasan Besar untuk Kad KPI (Total Sales, Expenses, Profit, & Transactions)
    public FinancialSummary getFinancialSummary() throws Exception {
        FinancialSummary summary = new FinancialSummary();
        String query = "SELECT "
                + "COALESCE(SUM(s.totalAmount), 0.00) AS total_sales, "
                + "COALESCE(SUM(sd.quantity * sd.costPrice), 0.00) AS total_expenses, "
                + "COALESCE(SUM(s.totalAmount) - SUM(sd.quantity * sd.costPrice), 0.00) AS net_profit, "
                + "COUNT(DISTINCT s.saleID) AS total_transactions "
                + "FROM sales s "
                + "LEFT JOIN sales_detail sd ON s.saleID = sd.saleID";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                summary.setTotalSales(rs.getBigDecimal("total_sales"));
                summary.setTotalExpenses(rs.getBigDecimal("total_expenses"));
                summary.setNetProfit(rs.getBigDecimal("net_profit"));
                summary.setTotalTransactions(rs.getInt("total_transactions"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return summary;
    }

    // 2. Mengambil data Grafik Trend Bulanan (Sales vs Expenses vs Profit)
    public List<MonthlyReport> getMonthlyReports() {
        List<MonthlyReport> list = new ArrayList<>();
        String query = "SELECT "
                + "DATE_FORMAT(s.createdAt, '%b %Y') AS format_month, " // FIX: Menggunakan createdAt
                + "COALESCE(SUM(sd.subtotal), 0.00) AS monthly_sales, "
                + "COALESCE(SUM(sd.quantity * sd.costPrice), 0.00) AS monthly_expenses, "
                + "COALESCE(SUM(sd.subtotal) - SUM(sd.quantity * sd.costPrice), 0.00) AS monthly_profit "
                + "FROM sales s "
                + "JOIN sales_detail sd ON s.saleID = sd.saleID "
                + "GROUP BY YEAR(s.createdAt), MONTH(s.createdAt), DATE_FORMAT(s.createdAt, '%b %Y') "
                + "ORDER BY YEAR(s.createdAt) ASC, MONTH(s.createdAt) ASC";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                MonthlyReport report = new MonthlyReport();
                report.setFormatMonth(rs.getString("format_month"));
                report.setMonthlySales(rs.getBigDecimal("monthly_sales"));
                report.setMonthlyExpenses(rs.getBigDecimal("monthly_expenses"));
                report.setMonthlyProfit(rs.getBigDecimal("monthly_profit"));
                list.add(report);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception ex) {
            Logger.getLogger(FinanceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
    
    // 3. Mengambil data 5 Transaksi Terkini (Recent Invoices)
    public List<model.Sales> getRecentSales() {
        List<model.Sales> list = new ArrayList<>();
        String query = "SELECT s.saleID, b.branchName, s.createdAt, s.totalAmount, u.userName AS staffName "
                + "FROM sales s "
                + "JOIN branch b ON s.branchID = b.branchID "
                + "LEFT JOIN user u ON s.soldBy = u.userID "
                + "ORDER BY s.createdAt DESC "
                + "LIMIT 5";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                model.Sales sale = new model.Sales();
                sale.setSaleID(rs.getString("saleID"));
                sale.setBranchName(rs.getString("branchName")); // Mapped Normalized Name
                sale.setCreatedAt(rs.getTimestamp("createdAt"));
                sale.setTotalAmount(rs.getDouble("totalAmount"));
                sale.setStaffName(rs.getString("staffName"));   // Mapped Normalized Name
                list.add(sale);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception ex) {
            Logger.getLogger(FinanceDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
    
    // 4. Ringkasan Kewangan Terfilter Dinamik dengan Sokongan Julat Tarikh dan Cawangan
    public FinancialSummary getFilteredFinancialSummary(String branchID, String filterType, String startDate, String endDate) {
        FinancialSummary summary = new FinancialSummary();
        
        StringBuilder query = new StringBuilder(
            "SELECT " +
            "COALESCE(SUM(s.totalAmount), 0.00) AS total_sales, " +
            "COALESCE(SUM(sd.quantity * sd.costPrice), 0.00) AS total_expenses, " +
            "COALESCE(SUM(s.totalAmount) - SUM(sd.quantity * sd.costPrice), 0.00) AS net_profit, " +
            "COUNT(DISTINCT s.saleID) AS total_transactions " +
            "FROM sales s " +
            "LEFT JOIN sales_detail sd ON s.saleID = sd.saleID " +
            "WHERE 1=1 "
        );

        if (branchID != null && !branchID.isEmpty() && !"all".equalsIgnoreCase(branchID)) {
            query.append("AND s.branchID = ? ");
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            query.append("AND DATE(s.createdAt) >= ? ");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            query.append("AND DATE(s.createdAt) <= ? ");
        }

        if ((startDate == null || startDate.trim().isEmpty()) && (endDate == null || endDate.trim().isEmpty())) {
            if ("day".equalsIgnoreCase(filterType)) {
                query.append("AND DATE(s.createdAt) = CURDATE() ");
            } else if ("month".equalsIgnoreCase(filterType)) {
                query.append("AND MONTH(s.createdAt) = MONTH(CURDATE()) AND YEAR(s.createdAt) = YEAR(CURDATE()) ");
            } else if ("year".equalsIgnoreCase(filterType)) {
                query.append("AND YEAR(s.createdAt) = YEAR(CURDATE()) ");
            }
        }

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query.toString())) {
            
            int paramIndex = 1;
            if (branchID != null && !branchID.isEmpty() && !"all".equalsIgnoreCase(branchID)) {
                ps.setString(paramIndex++, branchID);
            }
            if (startDate != null && !startDate.trim().isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.setTotalSales(rs.getBigDecimal("total_sales"));
                    summary.setTotalExpenses(rs.getBigDecimal("total_expenses"));
                    summary.setNetProfit(rs.getBigDecimal("net_profit"));
                    summary.setTotalTransactions(rs.getInt("total_transactions"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return summary;
    }

    // 5. Sejarah Jualan Terfilter (Filtered Sales)
    public List<model.Sales> getFilteredSales(String branchID, String filterType, String startDate, String endDate) {
        List<model.Sales> list = new ArrayList<>();
        StringBuilder query = new StringBuilder(
            "SELECT s.saleID, b.branchName, s.createdAt, s.totalAmount, u.userName AS soldBy " +
            "FROM sales s " +
            "JOIN branch b ON s.branchID = b.branchID " +
            "LEFT JOIN user u ON s.soldBy = u.userID " +
            "WHERE 1=1 "
        );

        if (branchID != null && !branchID.isEmpty() && !"all".equalsIgnoreCase(branchID)) {
            query.append("AND s.branchID = ? ");
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            query.append("AND DATE(s.createdAt) >= ? ");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            query.append("AND DATE(s.createdAt) <= ? ");
        }

        if ((startDate == null || startDate.trim().isEmpty()) && (endDate == null || endDate.trim().isEmpty())) {
            if ("day".equalsIgnoreCase(filterType)) {
                query.append("AND DATE(s.createdAt) = CURDATE() ");
            } else if ("month".equalsIgnoreCase(filterType)) {
                query.append("AND MONTH(s.createdAt) = MONTH(CURDATE()) AND YEAR(s.createdAt) = YEAR(CURDATE()) ");
            } else if ("year".equalsIgnoreCase(filterType)) {
                query.append("AND YEAR(s.createdAt) = YEAR(CURDATE()) ");
            }
        }

        query.append("ORDER BY s.createdAt DESC");

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query.toString())) {
            
            int paramIndex = 1;
            if (branchID != null && !branchID.isEmpty() && !"all".equalsIgnoreCase(branchID)) {
                ps.setString(paramIndex++, branchID);
            }
            if (startDate != null && !startDate.trim().isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.trim().isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.Sales sale = new model.Sales();
                    sale.setSaleID(rs.getString("saleID"));
                    sale.setBranchName(rs.getString("branchName")); 
                    sale.setCreatedAt(rs.getTimestamp("createdAt"));
                    sale.setTotalAmount(rs.getDouble("totalAmount"));
                    sale.setStaffName(rs.getString("soldBy")); 
                    list.add(sale);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. Aliran Tunai Pecahan Setiap Cawangan (Branch Cashflow Summary)
    public List<model.FinancialSummary> getBranchCashflowSummary() {
        List<model.FinancialSummary> list = new ArrayList<>();
        String query = "SELECT b.branchName, " +
                       "COALESCE(SUM(s.totalAmount), 0.00) AS total_sales, " +
                       "COALESCE(SUM(sd.quantity * sd.costPrice), 0.00) AS total_expenses, " +
                       "COALESCE(SUM(s.totalAmount) - SUM(sd.quantity * sd.costPrice), 0.00) AS net_profit " +
                       "FROM branch b " +
                       "LEFT JOIN sales s ON b.branchID = s.branchID " +
                       "LEFT JOIN sales_detail sd ON s.saleID = sd.saleID " +
                       "GROUP BY b.branchID, b.branchName";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                FinancialSummary fs = new FinancialSummary();
                fs.setTotalSales(rs.getBigDecimal("total_sales"));
                fs.setTotalExpenses(rs.getBigDecimal("total_expenses"));
                fs.setNetProfit(rs.getBigDecimal("net_profit"));
                fs.setBranchName(rs.getString("branchName")); 
                list.add(fs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}