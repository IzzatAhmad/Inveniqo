/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Category {
    private int categoryID;
    private String categoryName;

    // Constructor untuk memudahkan DAO
    public Category(int categoryID, String categoryName) {
        this.categoryID = categoryID;
        this.categoryName = categoryName;
    }

    // Getters
    public int getCategoryID() { return categoryID; }
    public String getCategoryName() { return categoryName; }
    
    // Setters
    public void setCategoryID(int categoryID) { this.categoryID = categoryID; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
}
