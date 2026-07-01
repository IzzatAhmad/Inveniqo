/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

public class Sales {
    private String saleID;
    private String branchID;
    private String branchName; // Ditambah untuk memegang nama cawangan
    private double totalAmount;
    private double amountPaid;
    private double change;
    private String soldBy;
    private String staffName;  // Ditambah untuk memegang nama pekerja (username)
    private String customerName;
    private Timestamp createdAt;

    public Sales() {}

    // Getter & Setter Asas
    public String getSaleID() { return saleID; }
    public void setSaleID(String saleID) { this.saleID = saleID; }

    public String getBranchID() { return branchID; }
    public void setBranchID(String branchID) { this.branchID = branchID; }

    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public double getAmountPaid() { return amountPaid; }
    public void setAmountPaid(double amountPaid) { this.amountPaid = amountPaid; }

    public double getChange() { return change; }
    public void setChange(double change) { this.change = change; }

    public String getSoldBy() { return soldBy; }
    public void setSoldBy(String soldBy) { this.soldBy = soldBy; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}