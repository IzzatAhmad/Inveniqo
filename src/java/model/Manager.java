package model;

public class Manager extends User {
    
    // Constructor
    public Manager(String userID, String userName, String userEmail, String password, String branchID, String companyID) {
        // Panggil constructor super (User) yang sepadan
        super(userID, userName, userEmail, password, branchID); 
        this.setCompanyID(companyID); // Set companyID secara manual
        this.addRole("Manager");
    }
}