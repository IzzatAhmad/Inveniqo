/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.ArrayList;
import java.util.List;

public class User {

    protected String userID;
    protected String userName;
    protected String userEmail;
    protected String password;
    protected String userStatus;
    protected String branchID;
    protected String profileImage;
    
    // Data tambahan untuk paparan (Bukan dari table User)
    protected String branchName;
    protected String companyName;
    protected String companyID;
    protected String companyLogo;
    // Simpan senarai role untuk sokong multi-role
    protected List<String> roles = new ArrayList<>();

    public User() {
    }

    // Constructor lengkap
   public User(String userID, String userName, String userEmail, String password, String branchID) {
        this.userID = userID;
        this.userName = userName;
        this.userEmail = userEmail;
        this.password = password;
        this.branchID = branchID;
        this.userStatus = "Active";
    }

    // Helper methods untuk check akses di JSP/Controller
    public boolean isAdmin() {
        return roles.contains("Admin");
    }

    public boolean isManager() {
        return roles.contains("Manager");
    }

    public boolean isStaff() {
        return roles.contains("Staff");
    }

    public String getCompanyLogo() {
        return companyLogo;
    }

    public void setCompanyLogo(String companyLogo) {
        this.companyLogo = companyLogo;
    }

    public void addRole(String role) {
        if (role != null && !this.roles.contains(role)) {
            this.roles.add(role);
        }
    }

    public List<String> getRoles() {
        return roles;
    }
    
    // --- Getters & Setters Standard ---
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

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getBranchID() {
        return branchID;
    }

    public void setBranchID(String branchID) {
        this.branchID = branchID;
    }

    public String getProfileImage() {
        return profileImage;
    }

    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }

    public String getUserStatus() {
        return userStatus;
    }

    public void setUserStatus(String userStatus) {
        this.userStatus = userStatus;
    }
    
    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getCompanyID() {
        return companyID;
    }

    public void setCompanyID(String companyID) {
        this.companyID = companyID;
    }
    
    private String hqBranchID;

    // Getter dan Setter
    public String getHQBranchID() { return hqBranchID; }
    public void setHQBranchID(String hqBranchID) { this.hqBranchID = hqBranchID; }
    
    // Helper method untuk semak jika Manager HQ (Admin)
    public boolean isHQManager() {
        return this.getRoles().contains("Admin") && 
               this.getBranchID() != null && 
               this.getBranchID().equals(this.hqBranchID);
    }
    
}