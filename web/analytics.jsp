<%-- 
    Document   : analytics
    Created on : Jun 10, 2026, 9:27:08 PM
    Author     : User
--%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Map<String, Object>> aiPredictions = (List<Map<String, Object>>) request.getAttribute("aiPredictions");
    List<Map<String, Object>> topProducts = (List<Map<String, Object>>) request.getAttribute("topProducts");
    List<Map<String, Object>> recentActivities = (List<Map<String, Object>>) request.getAttribute("recentActivities");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Inveniqo Insight | AI Analytics</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
        body { background-color: #f8fafc; display: flex; }
        
        /* Sidebar & Layout Styles */
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
        
        .main-content { margin-left: 260px; width: calc(100% - 260px); padding: 40px; }
        
        /* AI Panel Dashboard banner */
        .ai-banner { background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%); color: white; padding: 30px; border-radius: 20px; margin-bottom: 35px; box-shadow: 0 10px 15px -3px rgba(168, 85, 247, 0.2); }
        
        .grid-split { display: grid; grid-template-columns: 1.8fr 1.2fr; gap: 25px; margin-bottom: 30px; }
        .section-card { background: white; padding: 25px; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02); }
        .section-title { font-size: 1.1rem; font-weight: 700; color: #0f172a; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        
        /* Table Style */
        .ai-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; text-align: left; }
        .ai-table th { padding: 12px; background: #f8fafc; color: #64748b; font-weight: 600; border-bottom: 1px solid #e2e8f0; }
        .ai-table td { padding: 14px 12px; border-bottom: 1px solid #f1f5f9; color: #334155; }
        
        .ai-badge { padding: 5px 10px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; color: white; display: inline-block; }
        
        /* Leaderboard & Activity */
        .top-item { display: flex; justify-content: space-between; align-items: center; padding: 12px; border: 1px solid #f1f5f9; border-radius: 12px; background: #f8fafc; margin-bottom: 10px; }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="logo">Inveniqo</div>

        <a href="DashboardServlet" class="nav-item">
            <i class="fas fa-th-large"></i> Dashboard
        </a>

        <a href="AnalyticsServlet" class="nav-item active">
            <i class="fas fa-brain" style="color: #a855f7;"></i> Analytics & AI Prediction
        </a>

        <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
        <div class="nav-group-label">Administration</div>
        <a href="ManageCompanyServlet" class="nav-item">
            <i class="fas fa-building"></i> Manage Company
        </a>
        <% } %>

        <div class="nav-group-label">Inventory</div>
        <a href="InventoryServlet" class="nav-item">
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

    <!-- CONTENT SPACE -->
    <div class="main-content">
        
        <!-- AI INTELLIGENCE HEADER BANNER -->
        <div class="ai-banner">
            <h1 style="font-size: 1.8rem; font-weight: 800; margin-bottom: 5px;"><i class="fas fa-robot"></i> Inveniqo Predictive AI Insights</h1>
            <p style="opacity: 0.9; font-size: 0.95rem;">Enjin pintar menganalisis corak kelakuan (behaviour) sistem serta kekerapan jualan 30 hari lalu untuk meramal keperluan stok syarikat.</p>
        </div>

        <!-- NOTIFICATION ALERTS -->
        <% if (session.getAttribute("successMessage") != null) { %>
            <div style="background-color: #d1fae5; border-left: 4px solid #10b981; color: #065f46; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; font-weight: 500;">
                <i class="fas fa-check-circle"></i> <%= session.getAttribute("successMessage") %>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div style="background-color: #fee2e2; border-left: 4px solid #ef4444; color: #991b1b; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; font-weight: 500;">
                <i class="fas fa-exclamation-circle"></i> <%= session.getAttribute("errorMessage") %>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>

        <!-- SEKSYEN UTAMA: JADUAL PREDICTIONS AI -->
        <div class="section-card" style="margin-bottom: 35px;">
            <div class="section-title" style="display: flex; justify-content: space-between; align-items: center; width: 100%; gap: 15px; flex-wrap: wrap;">
                <span style="display: flex; align-items: center; gap: 10px;">
                    <i class="fas fa-chart-line" style="color: #a855f7;"></i> Ramalan Inventori & Cadangan Pesanan Pembelian (PO)
                </span>
                <a href="AnalyticsServlet?showHistory=<%= !(Boolean)request.getAttribute("showHistory") %>" 
                   style="background: #a855f7; color: white; padding: 8px 16px; border-radius: 8px; text-decoration: none; font-size: 0.8rem; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; transition: background 0.2s;">
                    <i class="fas fa-history"></i> 
                    <%= ((Boolean)request.getAttribute("showHistory")) ? "Lihat Ramalan Terkini Sahaja" : "Lihat Semua Sejarah Ramalan" %>
                </a>
            </div>
            
            <table class="ai-table">
                <thead>
                    <tr>
                        <th>Nama Produk (SKU)</th>
                        <th>Tarikh Ramalan</th>
                        <th>Stok Semasa</th>
                        <th>Velocity Harian</th>
                        <th>Jangka Hayat</th>
                        <th>Status AI</th>
                        <th>Cadangan Qty</th>
                        <th>Tindakan PO</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        if (aiPredictions != null && !aiPredictions.isEmpty()) {
                            for (Map<String, Object> pred : aiPredictions) {
                                String status = (String) pred.get("status");
                                int reqQty = (Integer) pred.get("recommendedQty");
                    %>
                    <tr>
                        <td>
                            <strong><%= pred.get("productName") %></strong><br>
                            <span style="font-size: 0.75rem; color:#94a3b8;"><%= pred.get("sku") %></span>
                        </td>
                        <td>
                            <span style="font-size: 0.8rem; color: #64748b;">
                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy hh:mm a").format(pred.get("computedDate")) %>
                            </span>
                        </td>
                        <td><span style="font-weight:600;"><%= pred.get("stockCurrent") %> unit</span></td>
                        <td><%= String.format("%.2f unit / hari", (Double)pred.get("dailyVelocity")) %></td>
                        <td>
                            <% int days = (Integer) pred.get("daysLeft"); %>
                            <%= (days >= 999) ? "Tiada Risiko (Stok Statik)" : "Dijangka Habis Dalam " + days + " Hari" %>
                        </td>
                        <td>
                            <span class="ai-badge" style="background-color: <%= pred.get("badgeColor") %>;">
                                <%= pred.get("statusAction") %>
                            </span>
                        </td>
                        <td>
                            <%= (reqQty > 0) ? "<strong style='color:#a855f7;'>+ " + reqQty + " unit</strong>" : "<span style='color:#94a3b8;'>Belum Perlu</span>" %>
                        </td>
                        <td>
                            <% if ("Processed".equalsIgnoreCase(status)) { %>
                                <button type="button" disabled style="background: #e2e8f0; color: #94a3b8; padding: 6px 12px; border: none; border-radius: 6px; font-size: 0.75rem; font-weight: 600; cursor: not-allowed; display: inline-flex; align-items: center; gap: 4px;">
                                    <i class="fas fa-lock"></i> Processed (PO)
                                </button>
                            <% } else if (reqQty > 0) { %>
                                <form action="AnalyticsServlet" method="POST" style="margin: 0; display: inline;">
                                    <input type="hidden" name="action" value="approve">
                                    <input type="hidden" name="predictionID" value="<%= pred.get("predictionID") %>">
                                    <button type="submit" style="background: #22c55e; color: white; padding: 6px 12px; border: none; border-radius: 6px; font-size: 0.75rem; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; transition: background 0.2s;">
                                        <i class="fas fa-check-circle"></i> Approve PO
                                    </button>
                                </form>
                            <% } else { %>
                                <span style="font-size: 0.75rem; color: #94a3b8; font-style: italic;">No Action</span>
                            <% } %>
                        </td>
                    </tr>
                    <% 
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="8" style="text-align:center; padding: 25px; color:#94a3b8;">
                            Sistem memerlukan sekurang-kurangnya beberapa rekod transaksi jualan untuk memulakan ramalan corak tingkah laku produk.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- SPLIT GRID UNTUK DATA SEJARAH ASAL -->
        <div class="grid-split">
            <div class="section-card">
                <div class="section-title"><i class="fas fa-fire" style="color:#ef4444;"></i> Item Terlaris Semasa</div>
                <% 
                    if (topProducts != null && !topProducts.isEmpty()) {
                        for (Map<String, Object> prod : topProducts) { 
                %>
                    <div class="top-item">
                        <div>
                            <h4><%= prod.get("productName") %></h4>
                            <span style="font-size:0.75rem; color:#94a3b8;">SKU: <%= prod.get("sku") %></span>
                        </div>
                        <div style="text-align:right; font-weight:600; color:#16a34a;"><%= prod.get("totalQtySold") %> Unit Terjual</div>
                    </div>
                <%      }
                    } else { 
                %>
                    <div style="text-align: center; color: #94a3b8; padding: 20px; font-size: 0.85rem;">
                        <i class="fas fa-chart-bar" style="font-size: 1.5rem; margin-bottom: 10px; display: block; opacity: 0.5;"></i>
                        Tiada data jualan mencukupi.
                    </div>
                <%  } %>
            </div>

            <div class="section-card">
                <div class="section-title"><i class="fas fa-stream" style="color:#3b82f6;"></i> Log Aliran Kerja Terkini</div>
                <% 
                    if (recentActivities != null && !recentActivities.isEmpty()) {
                        for (Map<String, Object> act : recentActivities) { 
                %>
                    <div class="top-item" style="font-size:0.8rem;">
                        <span><%= act.get("type") %> - <strong><%= act.get("reference") %></strong></span>
                        <span style="color:#64748b;"><%= act.get("user") %></span>
                    </div>
                <%      }
                    } else { 
                %>
                    <div style="text-align: center; color: #94a3b8; padding: 20px; font-size: 0.85rem;">
                        <i class="fas fa-history" style="font-size: 1.5rem; margin-bottom: 10px; display: block; opacity: 0.5;"></i>
                        Tiada rekod aktiviti terkini.
                    </div>
                <%  } %>
            </div>
        </div>

        <% if (loggedUser.isAdmin()) { %>
            <!-- ADMINISTRATIVE SECURITY AUDIT LOGS -->
            <div class="section-card" style="margin-top: 35px;">
                <div class="section-title" style="color: #ef4444;">
                    <i class="fas fa-shield-alt"></i> Administrative Security Audit Logs (Admin Only)
                </div>
                <table class="ai-table">
                    <thead>
                        <tr>
                            <th>Log ID</th>
                            <th>Aktiviti / Tindakan Keselamatan</th>
                            <th>Nama Akaun Kakitangan</th>
                            <th>Alamat IP</th>
                            <th>Tarikh & Masa Log</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            List<Map<String, Object>> securityLogs = (List<Map<String, Object>>) request.getAttribute("securityLogs");
                            if (securityLogs != null && !securityLogs.isEmpty()) {
                                for (Map<String, Object> log : securityLogs) {
                        %>
                        <tr>
                            <td style="font-weight: 600; color: #64748b;">#<%= log.get("logID") %></td>
                            <td style="font-weight: 500; color: #0f172a;"><%= log.get("action") %></td>
                            <td>
                                <span style="background: #f1f5f9; color: #334155; padding: 4px 8px; border-radius: 6px; font-weight: 600; font-size: 0.8rem;">
                                    <%= log.get("staffName") != null ? log.get("staffName") : "System Process" %>
                                </span>
                            </td>
                            <td style="font-family: monospace; color: #475569;"><%= log.get("ipAddress") %></td>
                            <td>
                                <span style="font-size: 0.8rem; color: #64748b;">
                                    <%= new java.text.SimpleDateFormat("dd/MM/yyyy hh:mm a").format(log.get("logDate")) %>
                                </span>
                            </td>
                        </tr>
                        <% 
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" style="text-align:center; padding: 25px; color:#94a3b8;">
                                Tiada rekod log audit keselamatan dijumpai.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </div>
</body>
</html>
