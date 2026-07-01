package model;

public class Company {

    private String companyID;
    private String companyName;
    private String companyEmail;
    private String businessRegNo;

    private String companyAddress;
    private String companyLogo;

    public Company() {
    }

    // Constructor yang lebih lengkap
    public Company(String companyID, String companyName, String companyEmail, String businessRegNo, String companyAddress, String companyLogo) {
        this.companyID = companyID;
        this.companyName = companyName;
        this.companyEmail = companyEmail;
        this.businessRegNo = businessRegNo;
        this.companyAddress = companyAddress;
        this.companyLogo = companyLogo;
    }

    // Getters & Setters
    public String getCompanyID() {
        return companyID;
    }

    public void setCompanyID(String companyID) {
        this.companyID = companyID;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getCompanyEmail() {
        return companyEmail;
    }

    public void setCompanyEmail(String companyEmail) {
        this.companyEmail = companyEmail;
    }

    public String getBusinessRegNo() {
        return businessRegNo;
    }

    public void setBusinessRegNo(String businessRegNo) {
        this.businessRegNo = businessRegNo;
    }

    public String getCompanyAddress() {
        return companyAddress;
    }

    public void setCompanyAddress(String companyAddress) {
        this.companyAddress = companyAddress;
    }

    public String getCompanyLogo() {
        return companyLogo;
    }

    public void setCompanyLogo(String companyLogo) {
        this.companyLogo = companyLogo;
    }
}
