package dao;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import model.Product;
import util.DBConnection;

public class InventoryDAO {

    /**
     * 1. Menambah produk baharu dengan penguatkuasaan mutlak SIFAR STOK (0).
     * Stok hanya boleh ditambah kemudian menerusi proses rasmi Stock In.
     */
    public boolean addProduct(Product p, String branchID) throws Exception {
        String sqlProduct = "INSERT INTO product (productID, productName, sku, categoryID, costPrice, "
                + "sellingPrice, companyID, productImage, description, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        // FIX: Kuantiti (quantity) diwajibkan set terus kepada nilai 0 secara lalai
        String sqlBranch = "INSERT INTO product_branch (productID, branchID, quantity, low_stock_threshold) "
                + "VALUES (?, ?, 0, ?)";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sqlProduct);
                 PreparedStatement ps2 = con.prepareStatement(sqlBranch)) {

                ps1.setString(1, p.getProductID());
                ps1.setString(2, p.getProductName());
                ps1.setString(3, p.getSku());
                ps1.setInt(4, p.getCategoryID());
                ps1.setDouble(5, p.getCostPrice());
                ps1.setDouble(6, p.getSellingPrice());
                ps1.setString(7, p.getCompanyID());
                ps1.setString(8, p.getProductImage());
                ps1.setString(9, p.getDescription());
                ps1.setString(10, p.getStatus());
                ps1.executeUpdate();

                ps2.setString(1, p.getProductID());
                ps2.setString(2, branchID);
                ps2.setInt(3, p.getLowStockThreshold());
                ps2.executeUpdate();

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<Product> getInventoryByBranch(String branchID) throws Exception {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, c.categoryName, pb.quantity, pb.low_stock_threshold "
                + "FROM product p "
                + "JOIN category c ON p.categoryID = c.categoryID "
                + "JOIN product_branch pb ON p.productID = pb.productID "
                + "WHERE pb.branchID = ? AND p.status = 'Active' ";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, branchID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductID(rs.getString("productID"));
                    p.setProductName(rs.getString("productName"));
                    p.setSku(rs.getString("sku"));
                    p.setCategoryID(rs.getInt("categoryID"));
                    p.setCategoryName(rs.getString("categoryName"));
                    p.setDescription(rs.getString("description"));
                    p.setCostPrice(rs.getDouble("costPrice"));
                    p.setSellingPrice(rs.getDouble("sellingPrice"));
                    p.setCurrentStock(rs.getInt("quantity"));
                    p.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                    p.setProductImage(rs.getString("productImage"));
                    p.setStatus(rs.getString("status"));
                    products.add(p);
                }
            }
        }
        return products;
    }
    
    public List<Product> getInventoryByBranchFiltered(String branchID, String search, String status, int categoryID, int limit, int offset) throws Exception {
        List<Product> products = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, c.categoryName, " +
            "COALESCE(pb.quantity, 0) as quantity, " +
            "COALESCE(pb.low_stock_threshold, 10) as low_stock_threshold " +
            "FROM product p " +
            "JOIN category c ON p.categoryID = c.categoryID " +
            "LEFT JOIN product_branch pb ON p.productID = pb.productID AND pb.branchID = ? " +
            "WHERE p.companyID = (SELECT companyID FROM branch WHERE branchID = ? ) "
        );

        if (status != null && (status.equalsIgnoreCase("Active") || status.equalsIgnoreCase("Pending"))) {
            sql.append("AND p.status = ? ");
        } else {
            sql.append("AND p.status = 'Active' ");
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.productName LIKE ? OR p.sku LIKE ?) ");
        }
        if (status != null && !status.isEmpty()) {
            if (status.equalsIgnoreCase("In Stock")) {
                sql.append("AND COALESCE(pb.quantity, 0) > COALESCE(pb.low_stock_threshold, 10) ");
            } else if (status.equalsIgnoreCase("Low Stock")) {
                sql.append("AND COALESCE(pb.quantity, 0) <= COALESCE(pb.low_stock_threshold, 10) AND COALESCE(pb.quantity, 0) > 0 ");
            } else if (status.equalsIgnoreCase("Out of Stock")) {
                sql.append("AND COALESCE(pb.quantity, 0) <= 0 ");
            }
        }
        if (categoryID > 0) {
            sql.append("AND p.categoryID = ? ");
        }

        sql.append("ORDER BY p.productName ASC LIMIT ? OFFSET ?");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setString(paramIndex++, branchID);
            ps.setString(paramIndex++, branchID);

            if (status != null && (status.equalsIgnoreCase("Active") || status.equalsIgnoreCase("Pending"))) {
                ps.setString(paramIndex++, status);
            }
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            if (categoryID > 0) {
                ps.setInt(paramIndex++, categoryID);
            }
            
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductID(rs.getString("productID"));
                    p.setProductName(rs.getString("productName"));
                    p.setSku(rs.getString("sku"));
                    p.setCategoryID(rs.getInt("categoryID"));
                    p.setCategoryName(rs.getString("categoryName"));
                    p.setDescription(rs.getString("description"));
                    p.setCostPrice(rs.getDouble("costPrice"));
                    p.setSellingPrice(rs.getDouble("sellingPrice"));
                    p.setCurrentStock(rs.getInt("quantity"));
                    p.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                    p.setProductImage(rs.getString("productImage"));
                    p.setStatus(rs.getString("status"));
                    products.add(p);
                }
            }
        }
        return products;
    }

    public int getInventoryCount(String branchID, String search, String status, int categoryID) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM product p " +
            "LEFT JOIN product_branch pb ON p.productID = pb.productID AND pb.branchID = ? " +
            "WHERE p.companyID = (SELECT companyID FROM branch WHERE branchID = ?) "
        );

        if (status != null && (status.equalsIgnoreCase("Active") || status.equalsIgnoreCase("Pending"))) {
            sql.append("AND p.status = ? ");
        } else {
            sql.append("AND p.status = 'Active' ");
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.productName LIKE ? OR p.sku LIKE ?) ");
        }
        if (status != null && !status.isEmpty()) {
            if (status.equalsIgnoreCase("In Stock")) {
                sql.append("AND COALESCE(pb.quantity, 0) > COALESCE(pb.low_stock_threshold, 10) ");
            } else if (status.equalsIgnoreCase("Low Stock")) {
                sql.append("AND COALESCE(pb.quantity, 0) <= COALESCE(pb.low_stock_threshold, 10) AND COALESCE(pb.quantity, 0) > 0 ");
            } else if (status.equalsIgnoreCase("Out of Stock")) {
                sql.append("AND COALESCE(pb.quantity, 0) <= 0 ");
            }
        }
        if (categoryID > 0) {
            sql.append("AND p.categoryID = ? ");
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setString(paramIndex++, branchID);
            ps.setString(paramIndex++, branchID);

            if (status != null && (status.equalsIgnoreCase("Active") || status.equalsIgnoreCase("Pending"))) {
                ps.setString(paramIndex++, status);
            }
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            if (categoryID > 0) {
                ps.setInt(paramIndex++, categoryID);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<Category> getCategoriesByCompany(String companyID) throws Exception {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM category WHERE companyID = ? ORDER BY categoryName ASC";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Category(rs.getInt("categoryID"), rs.getString("categoryName")));
                }
            }
        }
        return list;
    }

    public int addCategory(String name, String companyID) throws Exception {
        String sql = "INSERT INTO category (categoryName, companyID) VALUES (?, ?)";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, companyID);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public boolean approveProduct(String productID, double cost, double sell) throws Exception {
        String sql = "UPDATE product SET costPrice = ?, sellingPrice = ?, status = 'Active' WHERE productID = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, cost);
            ps.setDouble(2, sell);
            ps.setString(3, productID);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Product> getPendingProducts(String companyID) throws Exception {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.*, c.categoryName FROM product p "
                + "JOIN category c ON p.categoryID = c.categoryID "
                + "WHERE p.companyID = ? AND p.status = 'Pending'";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductID(rs.getString("productID"));
                    p.setProductName(rs.getString("productName"));
                    p.setSku(rs.getString("sku"));
                    p.setCategoryName(rs.getString("categoryName"));
                    p.setDescription(rs.getString("description"));
                    p.setProductImage(rs.getString("productImage"));
                    products.add(p);
                }
            }
        }
        return products;
    }

    public boolean updateProduct(Product p, boolean isManager) throws Exception {
        String sqlProduct = "UPDATE product SET productName = ?, sku = ?, categoryID = ?, description = ? ";

        if (isManager) {
            sqlProduct += ", costPrice = ?, sellingPrice = ? ";
        }

        sqlProduct += " WHERE productID = ?";
        String sqlThreshold = "UPDATE product_branch SET low_stock_threshold = ? WHERE productID = ?";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sqlProduct);
                    PreparedStatement ps2 = con.prepareStatement(sqlThreshold)) {

                int i = 1;
                ps1.setString(i++, p.getProductName());
                ps1.setString(i++, p.getSku());
                ps1.setInt(i++, p.getCategoryID());
                ps1.setString(i++, p.getDescription());

                if (isManager) {
                    ps1.setDouble(i++, p.getCostPrice());
                    ps1.setDouble(i++, p.getSellingPrice());
                }

                ps1.setString(i, p.getProductID());
                ps1.executeUpdate();

                ps2.setInt(1, p.getLowStockThreshold());
                ps2.setString(2, p.getProductID());
                ps2.executeUpdate();

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public boolean updateBranchStockForVariants(String productID, String branchID, int totalVariantStock) throws Exception {
        String checkSql = "SELECT COUNT(*) FROM product_branch WHERE productID = ? AND branchID = ?";
        String insertSql = "INSERT INTO product_branch (productID, branchID, quantity, low_stock_threshold) VALUES (?, ?, ?, 10)";
        String updateSql = "UPDATE product_branch SET quantity = ? WHERE productID = ? AND branchID = ?";
        
        try (Connection con = DBConnection.getConnection()) {
            boolean exists = false;
            try (PreparedStatement checkPs = con.prepareStatement(checkSql)) {
                checkPs.setString(1, productID);
                checkPs.setString(2, branchID);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        exists = true;
                    }
                }
            }
            
            if (exists) {
                try (PreparedStatement updatePs = con.prepareStatement(updateSql)) {
                    updatePs.setInt(1, totalVariantStock); 
                    updatePs.setString(2, productID);
                    updatePs.setString(3, branchID);
                    return updatePs.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement insertPs = con.prepareStatement(insertSql)) {
                    insertPs.setString(1, productID);
                    insertPs.setString(2, branchID);
                    insertPs.setInt(3, totalVariantStock);
                    return insertPs.executeUpdate() > 0;
                }
            }
        }
    }

    public boolean processStockIn(String productID, String branchID, int quantity, String userID, String reason, String remarks, String evidencePath, String location) throws Exception {
        String sqlUpdateBranch = "UPDATE product_branch SET quantity = quantity + ? WHERE productID = ? AND branchID = ?";
        String sqlInsertLog = "INSERT INTO stock_transaction (productID, userID, branchID, transactionType, quantity, reason, remarks, evidencePath, createdAt) "
                + "VALUES (?, ?, ?, 'IN', ?, ?, ?, ?, NOW())";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                boolean exists = false;
                try (PreparedStatement psCheck = con.prepareStatement("SELECT 1 FROM product_branch WHERE productID = ? AND branchID = ?")) {
                    psCheck.setString(1, productID);
                    psCheck.setString(2, branchID);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        exists = rs.next();
                    }
                }
                
                if (!exists) {
                    try (PreparedStatement psIns = con.prepareStatement("INSERT INTO product_branch (productID, branchID, quantity, low_stock_threshold) VALUES (?, ?, 0, 10)")) {
                        psIns.setString(1, productID);
                        psIns.setString(2, branchID);
                        psIns.executeUpdate();
                    }
                }

                try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdateBranch);
                     PreparedStatement psInsert = con.prepareStatement(sqlInsertLog)) {

                    psUpdate.setInt(1, quantity);
                    psUpdate.setString(2, productID);
                    psUpdate.setString(3, branchID);
                    psUpdate.executeUpdate();

                    psInsert.setString(1, productID);
                    psInsert.setString(2, userID);
                    psInsert.setString(3, branchID);
                    psInsert.setInt(4, quantity);
                    psInsert.setString(5, reason);
                    psInsert.setString(6, remarks);
                    psInsert.setString(7, evidencePath);
                    psInsert.executeUpdate();
                }

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public boolean processStockOut(String productID, String branchID, int quantity, String userID, String reason, String remarks, String evidencePath, String location) throws Exception {
        String sqlCheckStock = "SELECT quantity FROM product_branch WHERE productID = ? AND branchID = ?";
        String sqlUpdateBranch = "UPDATE product_branch SET quantity = quantity - ? WHERE productID = ? AND branchID = ?";
        String sqlInsertLog = "INSERT INTO stock_transaction (productID, userID, branchID, transactionType, quantity, reason, remarks, evidencePath, createdAt) "
                + "VALUES (?, ?, ?, 'OUT', ?, ?, ?, ?, NOW())";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                boolean exists = false;
                try (PreparedStatement psCheck = con.prepareStatement("SELECT 1 FROM product_branch WHERE productID = ? AND branchID = ?")) {
                    psCheck.setString(1, productID);
                    psCheck.setString(2, branchID);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        exists = rs.next();
                    }
                }
                
                if (!exists) {
                    try (PreparedStatement psIns = con.prepareStatement("INSERT INTO product_branch (productID, branchID, quantity, low_stock_threshold) VALUES (?, ?, 0, 10)")) {
                        psIns.setString(1, productID);
                        psIns.setString(2, branchID);
                        psIns.executeUpdate();
                    }
                }

                int currentQty = 0;
                try (PreparedStatement psCheck = con.prepareStatement(sqlCheckStock)) {
                    psCheck.setString(1, productID);
                    psCheck.setString(2, branchID);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            currentQty = rs.getInt("quantity");
                        }
                    }
                }

                if (quantity > currentQty) {
                    throw new Exception("Kuantiti pemotongan melebihi baki stok semasa cawangan!");
                }

                try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdateBranch)) {
                    psUpdate.setInt(1, quantity);
                    psUpdate.setString(2, productID);
                    psUpdate.setString(3, branchID);
                    psUpdate.executeUpdate();
                }

                try (PreparedStatement psInsert = con.prepareStatement(sqlInsertLog)) {
                    psInsert.setString(1, productID);
                    psInsert.setString(2, userID);
                    psInsert.setString(3, branchID);
                    psInsert.setInt(4, quantity);
                    psInsert.setString(5, reason);
                    psInsert.setString(6, remarks);
                    psInsert.setString(7, evidencePath);
                    psInsert.executeUpdate();
                }

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    public List<model.StockTransaction> getTransactionHistory(String branchID) throws Exception {
        List<model.StockTransaction> list = new ArrayList<>();
        String sql = "SELECT st.*, p.productName, p.sku, u.username "
                + "FROM stock_transaction st "
                + "JOIN product p ON st.productID = p.productID "
                + "JOIN user u ON st.userID = u.userID "
                + "WHERE st.branchID = ? "
                + "ORDER BY st.createdAt DESC";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, branchID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.StockTransaction t = new model.StockTransaction();
                    t.setTransactionID(rs.getInt("transactionID"));
                    t.setProductID(rs.getString("productID"));
                    t.setProductName(rs.getString("productName"));
                    t.setSku(rs.getString("sku"));
                    t.setUserName(rs.getString("username"));
                    t.setTransactionType(rs.getString("transactionType"));
                    t.setQuantity(rs.getInt("quantity"));
                    t.setReason(rs.getString("reason"));
                    t.setRemarks(rs.getString("remarks"));
                    t.setEvidencePath(rs.getString("evidencePath"));
                    t.setCreatedAt(rs.getTimestamp("createdAt"));
                    list.add(t);
                }
            }
        }
        return list;
    }

    public int getTotalProductsCount(String branchID) {
        int count = 0;
        String query = "SELECT COUNT(*) FROM product p "
                + "WHERE p.companyID = (SELECT companyID FROM branch WHERE branchID = ?) AND p.status = 'Active'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, branchID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public int getLowStockCount(String branchID) {
        int count = 0;
        String query = "SELECT COUNT(*) FROM product p "
                + "LEFT JOIN product_branch pb ON p.productID = pb.productID AND pb.branchID = ? "
                + "WHERE p.companyID = (SELECT companyID FROM branch WHERE branchID = ?) "
                + "AND COALESCE(pb.quantity, 0) > 0 "
                + "AND COALESCE(pb.quantity, 0) <= COALESCE(pb.low_stock_threshold, 10) "
                + "AND p.status = 'Active'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, branchID);
            ps.setString(2, branchID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public int getPendingApprovalCount(String branchID) {
        int count = 0;
        String query = "SELECT COUNT(*) FROM product p "
                + "WHERE p.companyID = (SELECT companyID FROM branch WHERE branchID = ?) AND p.status = 'Pending'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, branchID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public boolean smartDeleteProduct(String productID) throws Exception {
        String sqlCheckSales = "SELECT COUNT(*) FROM sales_detail WHERE productID = ?";
        String sqlCheckLogs = "SELECT COUNT(*) FROM stock_transaction WHERE productID = ?";
        
        int totalTransactions = 0;
        
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sqlCheckSales)) {
                ps.setString(1, productID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalTransactions += rs.getInt(1);
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(sqlCheckLogs)) {
                ps.setString(1, productID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalTransactions += rs.getInt(1);
                    }
                }
            }

            if (totalTransactions > 0) {
                String sqlSoft = "UPDATE product SET status = 'Inactive' WHERE productID = ?";
                try (PreparedStatement ps = con.prepareStatement(sqlSoft)) {
                    ps.setString(1, productID);
                    return ps.executeUpdate() > 0;
                }
            } else {
                con.setAutoCommit(false);
                try {
                    String sqlDelBranch = "DELETE FROM product_branch WHERE productID = ?";
                    try (PreparedStatement ps = con.prepareStatement(sqlDelBranch)) {
                        ps.setString(1, productID);
                        ps.executeUpdate();
                    }
                    
                    String sqlDelProd = "DELETE FROM product WHERE productID = ?";
                    int rows = 0;
                    try (PreparedStatement ps = con.prepareStatement(sqlDelProd)) {
                        ps.setString(1, productID);
                        rows = ps.executeUpdate();
                    }
                    
                    con.commit();
                    return rows > 0;
                } catch (Exception e) {
                    con.rollback();
                    throw e;
                } finally {
                    con.setAutoCommit(true);
                }
            }
        }
    }

    public boolean deleteCategory(int categoryID) throws Exception {
        String sqlCheck = "SELECT COUNT(*) FROM product WHERE categoryID = ? AND status = 'Active'";
        String sqlDelete = "DELETE FROM category WHERE categoryID = ?";
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement psCheck = con.prepareStatement(sqlCheck)) {
                    psCheck.setInt(1, categoryID);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            throw new Exception("Cannot delete category: Active products are still mapped to it.");
                        }
                    }
                }
                int deleted = 0;
                try (PreparedStatement psDelete = con.prepareStatement(sqlDelete)) {
                    psDelete.setInt(1, categoryID);
                    deleted = psDelete.executeUpdate();
                }
                con.commit();
                return deleted > 0;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }
    
    /**
     * A. Mengira Ringkasan Kewangan Terfilter (Total Revenue, Total Cost, Profit, Total Invoices)
     * FIX: Diubah suai sepenuhnya untuk mengembalikan data berasaskan model BigDecimal yang sah.
     */
    public model.FinancialSummary getFilteredFinancialSummary(String branchID, String filterType, String startDate, String endDate) throws Exception {
        model.FinancialSummary summary = new model.FinancialSummary();
        
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT s.saleID) as totalInvoices, " +
            "COALESCE(SUM(sd.subtotal), 0.00) as totalRevenue, " +
            "COALESCE(SUM(sd.quantity * sd.costPrice), 0.00) as totalCost " +
            "FROM sales s " +
            "JOIN sales_detail sd ON s.saleID = sd.saleID " +
            "WHERE 1=1 "
        );

        if (!"all".equalsIgnoreCase(branchID)) {
            sql.append("AND s.branchID = ? ");
        }

        // FIX: Menukarkan s.createdAt kepada s.saleDate mengikut skema DB asal anda
        if ("custom".equalsIgnoreCase(filterType) && startDate != null && endDate != null) {
            sql.append("AND s.saleDate BETWEEN ? AND ? ");
        } else if ("month".equalsIgnoreCase(filterType)) {
            sql.append("AND MONTH(s.saleDate) = MONTH(NOW()) AND YEAR(s.saleDate) = YEAR(NOW()) ");
        } else if ("year".equalsIgnoreCase(filterType)) {
            sql.append("AND YEAR(s.saleDate) = YEAR(NOW()) ");
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int pIdx = 1;
            if (!"all".equalsIgnoreCase(branchID)) {
                ps.setString(pIdx++, branchID);
            }
            if ("custom".equalsIgnoreCase(filterType) && startDate != null && endDate != null) {
                ps.setString(pIdx++, startDate + " 00:00:00");
                ps.setString(pIdx++, endDate + " 23:59:59");
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal revenue = rs.getBigDecimal("totalRevenue");
                    BigDecimal cost = rs.getBigDecimal("totalCost");
                    BigDecimal profit = revenue.subtract(cost);
                    
                    summary.setTotalTransactions(rs.getInt("totalInvoices"));
                    summary.setTotalSales(revenue);
                    summary.setTotalExpenses(cost);
                    summary.setNetProfit(profit);
                }
            }
        }
        return summary;
    }

    /**
     * B. Menarik Sejarah Invoice (Recent Sales) Bersama Nama Cawangan & Nama Pekerja
     */
    public List<model.Sales> getFilteredSalesWithNames(String branchID, String filterType, String startDate, String endDate) throws Exception {
        List<model.Sales> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, b.branchName, u.username as staffName " +
            "FROM sales s " +
            "JOIN branch b ON s.branchID = b.branchID " +
            "JOIN user u ON s.soldBy = u.userID " +
            "WHERE 1=1 "
        );

        if (!"all".equalsIgnoreCase(branchID)) {
            sql.append("AND s.branchID = ? ");
        }

        // FIX: Menukarkan s.createdAt kepada s.saleDate
        if ("custom".equalsIgnoreCase(filterType) && startDate != null && endDate != null) {
            sql.append("AND s.saleDate BETWEEN ? AND ? ");
        } else if ("month".equalsIgnoreCase(filterType)) {
            sql.append("AND MONTH(s.saleDate) = MONTH(NOW()) AND YEAR(s.saleDate) = YEAR(NOW()) ");
        }

        sql.append("ORDER BY s.saleDate DESC"); // FIX: Tukar order key juga

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int pIdx = 1;
            if (!"all".equalsIgnoreCase(branchID)) {
                ps.setString(pIdx++, branchID);
            }
            if ("custom".equalsIgnoreCase(filterType) && startDate != null && endDate != null) {
                ps.setString(pIdx++, startDate + " 00:00:00");
                ps.setString(pIdx++, endDate + " 23:59:59");
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.Sales s = new model.Sales();
                    s.setSaleID(rs.getString("saleID"));
                    s.setBranchID(rs.getString("branchID"));
                    s.setBranchName(rs.getString("branchName")); 
                    s.setSoldBy(rs.getString("soldBy"));
                    s.setStaffName(rs.getString("staffName"));   
                    s.setCustomerName(rs.getString("customerName"));
                    s.setTotalAmount(rs.getDouble("totalAmount"));
                    s.setCreatedAt(rs.getTimestamp("saleDate")); // FIX: Map dari lajur saleDate ke model
                    list.add(s);
                }
            }
        }
        return list;
    }

    /**
     * C. Menarik Laporan Graf Jualan Bulanan Syarikat bagi Tahun Semasa
     * FIX: Diubah suai untuk dipetakan ke setFormatMonth dan setMonthlySales (BigDecimal) model.
     */
    public List<model.MonthlyReport> getMonthlyReports(String companyID) throws Exception {
        List<model.MonthlyReport> list = new ArrayList<>();
        // FIX: Menukarkan s.createdAt kepada s.saleDate di dalam fungsi DATE_FORMAT dan WHERE clause
        String sql = "SELECT DATE_FORMAT(s.saleDate, '%b %Y') as bln, SUM(s.totalAmount) as jualan " +
                     "FROM sales s " +
                     "JOIN branch b ON s.branchID = b.branchID " +
                     "WHERE b.companyID = ? AND YEAR(s.saleDate) = YEAR(NOW()) " +
                     "GROUP BY YEAR(s.saleDate), MONTH(s.saleDate), DATE_FORMAT(s.saleDate, '%b %Y') " +
                     "ORDER BY MONTH(s.saleDate) ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.MonthlyReport r = new model.MonthlyReport();
                    r.setFormatMonth(rs.getString("bln"));
                    r.setMonthlySales(rs.getBigDecimal("jualan"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    /**
     * D. Menarik Senarai Penuh Cawangan bagi Mengisi Dropdown Filter (Khusus Peranan Admin)
     */
    public List<model.Branch> getBranchesByCompany(String companyID) throws Exception {
        List<model.Branch> list = new ArrayList<>();
        String sql = "SELECT * FROM branch WHERE companyID = ? ORDER BY branchName ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, companyID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.Branch b = new model.Branch();
                    b.setBranchID(rs.getString("branchID"));
                    b.setBranchName(rs.getString("branchName"));
                    b.setCompanyID(rs.getString("companyID"));
                    list.add(b);
                }
            }
        }
        return list;
    }
}