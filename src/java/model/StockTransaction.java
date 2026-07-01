package model;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

import java.sql.Timestamp;

public class StockTransaction {
    private int transactionID;
    private String productID;
    private String productName; // Ditambah untuk paparan UI (dari JOIN query)
    private String sku;         // Ditambah untuk paparan UI (dari JOIN query)
    private String userID;
    private String userName;    // Ditambah untuk paparan UI (dari JOIN query)
    private String branchID;
    private String transactionType; // 'IN' atau 'OUT'
    private int quantity;
    private String reason;
    private String remarks;
    private String evidencePath;
    private Timestamp createdAt;

    // Constructor Kosong (Default)
    public StockTransaction() {
    }

    // Constructor Penuh (Optional - berguna jika diperlukan nanti)
    public StockTransaction(int transactionID, String productID, String userID, String branchID, 
                            String transactionType, int quantity, String reason, String remarks, 
                            String evidencePath, Timestamp createdAt) {
        this.transactionID = transactionID;
        this.productID = productID;
        this.userID = userID;
        this.branchID = branchID;
        this.transactionType = transactionType;
        this.quantity = quantity;
        this.reason = reason;
        this.remarks = remarks;
        this.evidencePath = evidencePath;
        this.createdAt = createdAt;
    }

    // ==========================================
    // GETTERS AND SETTERS
    // ==========================================

    public int getTransactionID() {
        return transactionID;
    }

    public void setTransactionID(int transactionID) {
        this.transactionID = transactionID;
    }

    public String getProductID() {
        return productID;
    }

    public void setProductID(String productID) {
        this.productID = productID;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getUserID() {
        return userID;
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getBranchID() {
        return branchID;
    }

    public void setBranchID(String branchID) {
        this.branchID = branchID;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public String getEvidencePath() {
        return evidencePath;
    }

    public void setEvidencePath(String evidencePath) {
        this.evidencePath = evidencePath;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
