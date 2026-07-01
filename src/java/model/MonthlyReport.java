/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;

public class MonthlyReport {
    private String formatMonth; // Menyimpan rentetan format seperti "Jan 2026"
    private BigDecimal monthlySales = BigDecimal.ZERO;
    private BigDecimal monthlyExpenses = BigDecimal.ZERO;
    private BigDecimal monthlyProfit = BigDecimal.ZERO;

    public MonthlyReport() {}

    public String getFormatMonth() { return formatMonth; }
    public void setFormatMonth(String formatMonth) { this.formatMonth = formatMonth; }

    public BigDecimal getMonthlySales() { return monthlySales; }
    public void setMonthlySales(BigDecimal monthlySales) { this.monthlySales = monthlySales; }

    public BigDecimal getMonthlyExpenses() { return monthlyExpenses; }
    public void setMonthlyExpenses(BigDecimal monthlyExpenses) { this.monthlyExpenses = monthlyExpenses; }

    public BigDecimal getMonthlyProfit() { return monthlyProfit; }
    public void setMonthlyProfit(BigDecimal monthlyProfit) { this.monthlyProfit = monthlyProfit; }
}