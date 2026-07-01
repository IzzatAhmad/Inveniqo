/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.*;
import util.DBConnection;
import model.Company;

public class CompanyDAO {

    // 1. Jana ID Automatik (C001, C002...)
    public String generateNextCompanyID(Connection con) throws Exception {
        String sql = "SELECT companyID FROM company ORDER BY companyID DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String lastID = rs.getString("companyID"); // Contoh: "C001"
                int number = Integer.parseInt(lastID.substring(1)); // Ambil "001" -> 1
                return String.format("C%03d", number + 1); // Jadi "C002"
            } else {
                return "C001"; // Jika database kosong
            }
        }
    }

    // 2. Masukkan data syarikat (Termasuk Business Reg No)
    public void insertCompany(Company company, Connection con) throws Exception {
        // Tambah column businessRegNo dalam SQL
        String sql = "INSERT INTO company (companyID, companyName, companyEmail, businessRegNo) VALUES (?,?,?,?)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, company.getCompanyID());
            ps.setString(2, company.getCompanyName());
            ps.setString(3, company.getCompanyEmail());
            ps.setString(4, company.getBusinessRegNo()); // Pastikan ini ada dalam model Company.java
            ps.executeUpdate();
        }
    }

    // 3. Semakan e-mel syarikat sedia ada
    public boolean isCompanyEmailExists(String email, Connection con) throws Exception {
        String sql = "SELECT 1 FROM company WHERE companyEmail=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        }
    }

    // 4. Ambil syarikat berdasarkan ID
    public Company getCompanyByID(String companyID) throws Exception {
        String sql = "SELECT * FROM company WHERE companyID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Company c = new Company();
                    c.setCompanyID(rs.getString("companyID"));
                    c.setCompanyName(rs.getString("companyName"));
                    c.setCompanyEmail(rs.getString("companyEmail"));
                    c.setBusinessRegNo(rs.getString("businessRegNo"));
                    
                    String addr = rs.getString("companyAddress");
                    if (addr == null || addr.trim().isEmpty()) {
                        // query first branch address as fallback
                        String sqlBranch = "SELECT branchAddress FROM branch WHERE companyID = ? ORDER BY branchID ASC LIMIT 1";
                        try (PreparedStatement psBranch = con.prepareStatement(sqlBranch)) {
                            psBranch.setString(1, companyID);
                            try (ResultSet rsB = psBranch.executeQuery()) {
                                if (rsB.next()) {
                                    addr = rsB.getString("branchAddress");
                                }
                            }
                        }
                    }
                    
                    c.setCompanyAddress(addr);
                    c.setCompanyLogo(rs.getString("companyLogo"));
                    return c;
                }
            }
        }
        return null;
    }

    // 5. Kemaskini syarikat
    public boolean updateCompany(Company c) throws Exception {
        String sql = "UPDATE company SET companyName = ?, companyEmail = ?, businessRegNo = ?, companyAddress = ?, companyLogo = ? WHERE companyID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getCompanyName());
            ps.setString(2, c.getCompanyEmail());
            ps.setString(3, c.getBusinessRegNo());
            ps.setString(4, c.getCompanyAddress());
            ps.setString(5, c.getCompanyLogo());
            ps.setString(6, c.getCompanyID());
            return ps.executeUpdate() > 0;
        }
    }
}
