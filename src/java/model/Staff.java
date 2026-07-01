/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Staff extends User {
    public Staff(String userID, String userName, String userEmail, String password, String branchID, String companyID) {
        // super() memanggil constructor User.java
        super(userID, userName, userEmail, password, branchID);
        this.setCompanyID(companyID);
        this.addRole("Staff");
    }
}
