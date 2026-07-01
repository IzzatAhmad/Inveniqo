package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Branch;
import util.DBConnection;

public class BranchDAO {

    public List<Branch> getBranchesByCompany(String companyID) throws Exception {
        List<Branch> list = new ArrayList<>();
        String sql = "SELECT * FROM branch WHERE companyID = ? ORDER BY branchName ASC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Branch b = new Branch();
                b.setBranchID(rs.getString("branchID"));
                b.setBranchName(rs.getString("branchName"));
                b.setBranchAddress(rs.getString("branchAddress"));
                b.setCompanyID(rs.getString("companyID"));
                list.add(b);
            }
        }
        return list;
    }

    public Branch getBranchByID(String branchID) throws Exception {
        Branch b = null;
        String sql = "SELECT * FROM branch WHERE branchID = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, branchID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                b = new Branch();
                b.setBranchID(rs.getString("branchID"));
                b.setBranchName(rs.getString("branchName"));
                b.setBranchAddress(rs.getString("branchAddress"));
            }
        }
        return b;
    }

    public void insertBranch(Branch b) throws Exception {
        String sql = "INSERT INTO branch (branchID, branchName, branchAddress, companyID) VALUES (?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, b.getBranchID());
            ps.setString(2, b.getBranchName());
            ps.setString(3, b.getBranchAddress());
            ps.setString(4, b.getCompanyID());
            ps.executeUpdate();
        }
    }

    public boolean updateBranch(Branch b) throws Exception {
        String sql = "UPDATE branch SET branchName = ?, branchAddress = ? WHERE branchID = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, b.getBranchName());
            ps.setString(2, b.getBranchAddress());
            ps.setString(3, b.getBranchID());
            return ps.executeUpdate() > 0;
        }
    }

    public String generateNextBranchID() throws Exception {
        String sql = "SELECT branchID FROM branch ORDER BY branchID DESC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String lastID = rs.getString("branchID");
                long number = Long.parseLong(lastID.substring(1));
                return String.format("B%09d", number + 1);
            }
            return "B000000001";
        }
    }

    public String getHQBranchID(String companyID) throws Exception {
        String sql = "SELECT branchID FROM branch WHERE companyID = ? ORDER BY branchID ASC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("branchID");
            }
        }
        return null;
    }
}
