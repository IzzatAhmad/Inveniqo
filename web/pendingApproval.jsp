<%-- 
    Document   : pendingApproval
    Created on : Apr 23, 2026, 8:22:00 AM
    Author     : User
--%>

<%@page import="model.Category"%>
<%@ page import="model.User, model.Product, java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    List<Product> inventoryList = (List<Product>) request.getAttribute("inventoryList");
    List<Category> catList = (List<Category>) request.getAttribute("categoryList");

    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Pending Approval | Inveniqo</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
            /* CSS Standard Inveniqo */
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Inter', sans-serif;
            }
            body {
                background-color: #f8fafc;
                display: flex;
            }
            .sidebar {
                width: 260px;
                background: #0f172a;
                height: 100vh;
                color: white;
                padding: 25px 20px;
                position: fixed;
                display: flex;
                flex-direction: column;
                z-index: 100;
            }
            .logo {
                font-size: 1.7rem;
                font-weight: 800;
                color: #38bdf8;
                margin-bottom: 40px;
                letter-spacing: -1px;
            }
            .nav-group-label {
                font-size: 0.7rem;
                color: #64748b;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin: 20px 0 10px 10px;
                font-weight: 700;
            }
            .nav-item {
                padding: 12px 15px;
                display: flex;
                align-items: center;
                color: #94a3b8;
                text-decoration: none;
                border-radius: 10px;
                margin-bottom: 4px;
                transition: 0.2s;
                font-size: 0.9rem;
            }
            .nav-item:hover {
                background: #1e293b;
                color: #38bdf8;
            }
            .nav-item.active {
                background: #0284c7;
                color: white;
            }
            .nav-item i {
                margin-right: 12px;
                width: 20px;
                text-align: center;
            }
            .main-content {
                margin-left: 260px;
                width: calc(100% - 260px);
                padding: 40px;
            }
            .header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
            }
            .section-card {
                background: white;
                padding: 25px;
                border-radius: 16px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th {
                text-align: left;
                padding: 15px;
                background: #f8fafc;
                color: #64748b;
                font-size: 0.75rem;
                text-transform: uppercase;
                border-bottom: 1px solid #e2e8f0;
            }
            td {
                padding: 15px;
                border-bottom: 1px solid #f1f5f9;
                color: #334155;
                font-size: 0.9rem;
            }
            .badge {
                padding: 6px 12px;
                border-radius: 6px;
                font-size: 0.75rem;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }
            /* Badge Pending Baru untuk Staff */
            .badge-pending {
                background: #ffedd5;
                color: #9a3412;
                border: 1px solid #fed7aa;
            }
            .btn-add {
                background: #0284c7;
                color: white;
                padding: 10px 20px;
                border-radius: 8px;
                text-decoration: none;
                font-weight: 600;
                font-size: 0.9rem;
                display: flex;
                align-items: center;
                gap: 8px;
                border:none;
                cursor:pointer;
            }
            .table-prod-img {
                width: 45px;
                height: 45px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #f1f5f9;
            }
            .form-control {
                width: 100%;
                padding: 10px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
            }
        </style>
    </head>
    <body>

        <!-- SIDEBAR NAVIGATION -->
        <div class="sidebar">
            <div class="logo">Inveniqo</div>

            <a href="DashboardServlet" class="nav-item">
                <i class="fas fa-th-large"></i> Dashboard
            </a>

            <a href="AnalyticsServlet" class="nav-item">
                <i class="fas fa-brain" style="color: #a855f7;"></i> Analytics & AI Prediction
            </a>

            <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
            <div class="nav-group-label">Administration</div>
            <a href="ManageCompanyServlet" class="nav-item">
                <i class="fas fa-building"></i> Manage Company
            </a>
            <% } %>

            <div class="nav-group-label">Inventory</div>
            <a href="InventoryServlet" class="nav-item active">
                <i class="fas fa-boxes"></i> Stock Control
            </a>
            <a href="DirectInvoiceServlet" class="nav-item">
                <i class="fas fa-file-invoice-dollar"></i> Direct Invoice
            </a>

            <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
            <div class="nav-group-label">Finance & Reports</div>
            <a href="FinanceServlet" class="nav-item">
                <i class="fas fa-chart-pie"></i> Financial Stats
            </a>
            <% } %>
            
            <a href="integration.jsp" class="nav-item">
                <i class="fas fa-network-wired"></i> API Integration
            </a>

            <div style="margin-top: auto;">
                <a href="LogoutServlet" class="nav-item" style="color: #fb7185;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <%
                    String errorMsg = (String) session.getAttribute("errorMessage");
                    if (errorMsg != null) {
                %>
                <div id="errorAlert" style="background: #fee2e2; color: #991b1b; padding: 15px; border-radius: 10px; border: 1px solid #fecaca; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; width: 100%;">
                    <span><i class="fas fa-exclamation-circle"></i> <%= errorMsg%></span>
                    <button onclick="this.parentElement.style.display = 'none'" style="background:none; border:none; color:#991b1b; cursor:pointer;">&times;</button>
                </div>
                <%
                        session.removeAttribute("errorMessage");
                    }
                %>
                <div>
                    <h1 style="font-size: 1.5rem; color: #1e293b;">Inventory Stock Control</h1>
                    <p style="color: #64748b; font-size: 0.9rem;">Branch: <strong><%= loggedUser.getBranchName()%></strong></p>
                </div>
                <% if (loggedUser.getRoles().contains("Manager") || loggedUser.getRoles().contains("Staff")) { %>
                <button onclick="document.getElementById('addProductModal').style.display = 'flex'" class="btn-add">
                    <i class="fas fa-plus"></i> Add New Product
                </button>
                <% } %>
            </div>
            
            <div style="display: flex; gap: 20px; margin-top: 15px; border-bottom: 1px solid #e2e8f0;">
                <a href="InventoryServlet" style="padding: 10px 0; color: #64748b; text-decoration: none;">Active Stocks</a>
                <a href="PendingProductServlet" style="padding: 10px 0; color: #0284c7; border-bottom: 2px solid #0284c7; text-decoration: none; font-weight: 600;">Pending Approval</a>
                <% if (loggedUser.getRoles().contains("Manager")) { %>
                <a href="StockHistoryServlet" style="padding: 10px 0; color: #64748b; text-decoration: none;">Stock History</a>
                <% } %>
            </div>

            <div class="section-card">
                <table>
                    <thead>
                        <tr>
                            <th>Product Details</th>
                            <th>Category</th>
                            <th><%= loggedUser.getRoles().contains("Manager") ? "Set Pricing & Action" : "Status" %></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Product> pendingList = (List<Product>) request.getAttribute("pendingList");
                            if (pendingList != null && !pendingList.isEmpty()) {
                                for (Product p : pendingList) {
                        %>
                        <tr>
                            <td>
                                <div style="display: flex; gap: 12px;">
                                    <img src="<%= p.getProductImage()%>" class="table-prod-img">
                                    <div>
                                        <strong><%= p.getProductName()%></strong><br>
                                        <small style="color: #94a3b8;">SKU: <%= p.getSku()%></small>
                                    </div>
                                </div>
                            </td>
                            <td><%= p.getCategoryName()%></td>
                            <td>
                                <%-- JIKA USER IALAH MANAGER: Papar Borang Kelulusan --%>
                                <% if (loggedUser.getRoles().contains("Manager")) { %>
                                    <form action="ApproveProductServlet" method="POST" style="display: flex; gap: 10px; align-items: center;">
                                        <input type="hidden" name="productID" value="<%= p.getProductID()%>">
                                        <input type="number" step="0.01" name="costPrice" placeholder="Cost (RM)" class="form-control" style="width: 120px;" required>
                                        <input type="number" step="0.01" name="sellingPrice" placeholder="Selling (RM)" class="form-control" style="width: 120px;" required>
                                        <button type="submit" class="btn-add" style="background: #10b981;">
                                            <i class="fas fa-check"></i> Approve
                                        </button>
                                    </form>
                                
                                <%-- JIKA USER IALAH STAFF: Papar Status Badge Sahaja --%>
                                <% } else { %>
                                    <span class="badge badge-pending">
                                        <i class="fas fa-clock"></i> Pending Manager's Approval
                                    </span>
                                <% } %>
                            </td>
                        </tr>
                        <% }
                } else { %>
                        <tr>
                            <td colspan="3" style="text-align: center; padding: 40px; color: #94a3b8;">
                                <i class="fas fa-clipboard-check" style="font-size: 2rem; display: block; margin-bottom: 10px;"></i>
                                No pending products found. All clear!
                            </td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>