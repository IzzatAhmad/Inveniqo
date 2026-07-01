/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;

public class FinancialSummary {
    private int totalInvoices;
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private BigDecimal totalCost = BigDecimal.ZERO;
    private BigDecimal totalProfit = BigDecimal.ZERO;
    private String branchName; // Ditambah untuk menyokong getBranchCashflowSummary()

    public FinancialSummary() {}

    // Constructor Penuh
    public FinancialSummary(BigDecimal totalRevenue, BigDecimal totalCost, BigDecimal totalProfit, int totalInvoices) {
        this.totalRevenue = totalRevenue;
        this.totalCost = totalCost;
        this.totalProfit = totalProfit;
        this.totalInvoices = totalInvoices;
    }

    // Getter & Setter (Kekal menggunakan BigDecimal demi ketepatan audit)
    public int getTotalInvoices() { return totalInvoices; }
    public void setTotalInvoices(int totalInvoices) { this.totalInvoices = totalInvoices; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalSales(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; } // Alias match sedia ada

    public BigDecimal getTotalCost() { return totalCost; }
    public void setTotalExpenses(BigDecimal totalCost) { this.totalCost = totalCost; } // Alias match sedia ada

    public BigDecimal getTotalProfit() { return totalProfit; }
    public void setNetProfit(BigDecimal totalProfit) { this.totalProfit = totalProfit; } // Alias match sedia ada

    public int getTotalTransactions() { return totalInvoices; }
    public void setTotalTransactions(int totalInvoices) { this.totalInvoices = totalInvoices; } // Alias match sedia ada

    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }
}