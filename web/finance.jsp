<%-- 
    Document   : finance
    Created on : Jun 8, 2026, 3:41:26 PM
    Author     : User
--%>
<%@page import="java.util.List"%>
<%@page import="model.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String> roles = loggedUser.getRoles();
    String branchLabel = (loggedUser.getBranchName() != null) ? loggedUser.getBranchName() : "No Branch Assigned";
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <title>Inveniqo - Finance Report</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        :root {
            --bg-sidebar: #0f172a;
            --bg-body: #f8fafc;
            --primary-blue: #0284c7;
            --card-bg: #ffffff;
            --text-dark: #1e293b;
            --text-muted: #64748b;
            --success: #22c55e;
            --danger: #ef4444;
            --border-color: #e2e8f0;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-body);
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styling (Inveniqo Style) */
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

        /* Main Content Container */
        .main-content {
                margin-left: 260px;
                width: calc(100% - 260px);
                padding: 40px;
            }

        .header-title {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* KPI Cards Grid */
        .kpi-container {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .kpi-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .kpi-info h3 {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 500;
            margin-bottom: 8px;
        }

        .kpi-info p {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-dark);
        }

        .kpi-icon {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        /* Dashboard Bottom Layout (Graf + Table) */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }

        .section-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .section-card h2 {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 20px;
        }

        /* Recent Invoices Table */
        .recent-invoice-container {
            grid-column: span 2;
            margin-top: 10px;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        .data-table th {
            background-color: #f8fafc;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 13px;
            padding: 14px;
            border-bottom: 1px solid var(--border-color);
        }

        .data-table td {
            padding: 14px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-dark);
            font-size: 14px;
        }

        .data-table tr:last-child td {
            border-bottom: none;
        }

        .badge-success {
            background-color: #f0fdf4;
            color: var(--success);
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .finance-modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .finance-modal-card {
            background: white;
            width: 100%;
            max-width: 480px;
            border-radius: 16px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
            animation: slideUp 0.3s ease-out;
            overflow: hidden;
        }

        .finance-modal-header {
            padding: 20px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .finance-modal-header h3 {
            font-size: 1.1rem;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .finance-modal-close {
            background: none; border: none; font-size: 1.5rem; color: #94a3b8; cursor: pointer;
        }
        .finance-modal-close:hover { color: #334155; }

        .finance-modal-body { padding: 20px; }

        .pdf-option-card {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            margin-bottom: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .pdf-option-card:hover {
            border-color: #ef4444;
            background: #fff5f5;
            transform: translateY(-2px);
        }

        .pdf-icon {
            background: #fee2e2;
            color: #ef4444;
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
        }

        .pdf-text h4 { font-size: 0.95rem; color: #1e293b; margin-bottom: 2px; }
        .pdf-text p { font-size: 0.78rem; color: #64748b; line-height: 1.3; }

        @keyframes slideUp {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
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
            <a href="InventoryServlet" class="nav-item">
                <i class="fas fa-boxes"></i> Stock Control
            </a>
            <a href="DirectInvoiceServlet" class="nav-item">
                <i class="fas fa-file-invoice-dollar"></i> Direct Invoice
            </a>

            <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
            <div class="nav-group-label">Finance & Reports</div>
            <a href="FinanceServlet" class="nav-item active">
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
        <div class="header-title">
            <i class="fa-solid fa-wallet" style="color: var(--primary-blue);"></i> Financial Record
        </div>
        
        <form action="FinanceServlet" method="GET" style="display: flex; gap: 15px; margin-bottom: 25px; background: white; padding: 15px; border-radius: 12px; border: 1px solid #e2e8f0; align-items: flex-end;">
    
    <div style="display: flex; flex-direction: column; gap: 5px;">
        <label style="font-size: 0.75rem; font-weight: 600; color: #64748b;">Report Period</label>
        <select name="filterType" onchange="this.form.submit()" style="padding: 10px 15px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; background: white; color: #334155;">
            <option value="day" ${currentFilter == 'day' ? 'selected' : ''}>Today</option>
            <option value="month" ${currentFilter == 'month' ? 'selected' : ''}>This Month</option>
            <option value="year" ${currentFilter == 'year' ? 'selected' : ''}>This Year</option>
            <option value="custom" ${currentFilter == 'custom' ? 'selected' : ''}>Custom Range</option>
        </select>
    </div>

    <div style="display: flex; flex-direction: column; gap: 5px;">
        <label style="font-size: 0.75rem; font-weight: 600; color: #64748b;">Start Date</label>
        <input type="date" name="startDate" value="${startDate}" onchange="this.form.submit()" style="padding: 8px 15px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; background: white; color: #334155; height: 42px;">
    </div>

    <div style="display: flex; flex-direction: column; gap: 5px;">
        <label style="font-size: 0.75rem; font-weight: 600; color: #64748b;">End Date</label>
        <input type="date" name="endDate" value="${endDate}" onchange="this.form.submit()" style="padding: 8px 15px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; background: white; color: #334155; height: 42px;">
    </div>

    <div style="display: flex; flex-direction: column; gap: 5px;">
        <label style="font-size: 0.75rem; font-weight: 600; color: #64748b;">Branch Selection</label>
        <select name="branchID" onchange="this.form.submit()" style="padding: 10px 15px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; background: white; color: #334155;">
            <% if (loggedUser.isAdmin()) { %>
                <option value="all" ${currentBranchFilter == 'all' ? 'selected' : ''}>All Company</option>
                <c:forEach var="b" items="${branchList}">
                    <option value="${b.branchID}" ${currentBranchFilter == b.branchID ? 'selected' : ''}>${b.branchName}</option>
                </c:forEach>
            <% } else { %>
                <option value="<%= loggedUser.getBranchID() %>" selected><%= branchLabel %></option>
            <% } %>
        </select>
    </div>
        
    <button type="button" onclick="openFinanceModal()" style="background: #ef4444; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; display: flex; align-items: center; gap: 8px; height: 42px;">
        <i class="fas fa-file-pdf"></i> Print Report
    </button>
        
     <div id="financePdfModal" class="finance-modal-overlay">
    <div class="finance-modal-card">
        <div class="finance-modal-header">
            <h3><i class="fas fa-print" style="color: #ef4444;"></i> Pilihan Cetakan Dokumen</h3>
            <button type="button" class="finance-modal-close" onclick="closeFinanceModal()">&times;</button>
        </div>
        <div class="finance-modal-body">
            <p style="font-size: 0.85rem; color: #64748b; margin-bottom: 15px;">
                Sila pilih jenis format laporan kewangan yang anda mahu jana untuk tempoh pilihan semasa:
            </p>
            
            <div class="pdf-option-card" onclick="submitFinancePdf('summary')">
                <div class="pdf-icon"><i class="fas fa-file-invoice-dollar"></i></div>
                <div class="pdf-text">
                    <h4>Penyata Untung Rugi Ringkas</h4>
                    <p>Memaparkan ringkasan Jumlah Jualan, Kos Perbelanjaan, dan Untung Bersih sahaja.</p>
                </div>
            </div>

            <div class="pdf-option-card" onclick="submitFinancePdf('detailed')">
                <div class="pdf-icon"><i class="fas fa-list-alt"></i></div>
                <div class="pdf-text">
                    <h4>Laporan Aliran Tunai Detil</h4>
                    <p>Merangkumi Penyata Untung Rugi beserta lampiran senarai transaksi jualan terkini.</p>
                </div>
            </div>
        </div>
    </div>
</div>
</form>

        <div class="kpi-container">
            <div class="kpi-card">
                <div class="kpi-info">
                    <h3>Total Sales</h3>
                    <!-- FIX: Ditukar kepada totalRevenue selari dengan model BigDecimal -->
                    <p>RM <fmt:formatNumber value="${financialSummary.totalRevenue}" pattern="#,##0.00"/></p>
                </div>
                <div class="kpi-icon" style="background-color: #f0fdf4; color: var(--success);">
                    <i class="fa-solid fa-money-bill-wave"></i>
                </div>
            </div>

            <div class="kpi-card">
                <div class="kpi-info">
                    <h3>Total Expense (COGS)</h3>
                    <!-- FIX: Ditukar kepada totalCost selari dengan model BigDecimal -->
                    <p>RM <fmt:formatNumber value="${financialSummary.totalCost}" pattern="#,##0.00"/></p>
                </div>
                <div class="kpi-icon" style="background-color: #fef2f2; color: var(--danger);">
                    <i class="fa-solid fa-hand-holding-dollar"></i>
                </div>
            </div>

            <div class="kpi-card">
                <div class="kpi-info">
                    <h3>Net Profit</h3>
                    <!-- FIX: Ditukar kepada totalProfit selari dengan model BigDecimal -->
                    <p style="color: ${financialSummary.totalProfit >= 0 ? 'var(--success)' : 'var(--danger)'}">
                        RM <fmt:formatNumber value="${financialSummary.totalProfit}" pattern="#,##0.00"/>
                    </p>
                </div>
                <div class="kpi-icon" style="background-color: #e0f2fe; color: var(--primary-blue);">
                    <i class="fa-solid fa-chart-line"></i>
                </div>
            </div>

            <div class="kpi-card">
                <div class="kpi-info">
                    <h3>Transactions</h3>
                    <p><c:out value="${financialSummary.totalInvoices}"/></p>
                </div>
                <div class="kpi-icon" style="background-color: #faf5ff; color: #a855f7;">
                    <i class="fa-solid fa-receipt"></i>
                </div>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="section-card" style="grid-column: span 2;">
                <h2>Sales Trend Dashboard</h2>
                <div style="height: 300px; position: relative;">
                    <canvas id="financeChart"></canvas>
                </div>
            </div>

            <div class="section-card recent-invoice-container">
                <h2>Invoice Explorer Panel</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Invoice ID</th>
                            <th>Cawangan</th>
                            <th>Juruwang</th>
                            <th>Tarikh & Masa</th>
                            <th>Jumlah Amaun</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="sale" items="${recentSales}">
                            <tr>
                                <td style="font-weight: 600;">
                                    <a href="#" onclick="openReceiptModal('${sale.saleID}'); return false;" style="color: var(--primary-blue); text-decoration: underline;">
                                        ${sale.saleID}
                                    </a>
                                </td>
                                <!-- FIX: Menggunakan branchName dan staffName hasil JOIN table -->
                                <td><c:out value="${sale.branchName}"/></td>
                                <td><c:out value="${sale.staffName}"/></td>
                                <td><fmt:formatDate value="${sale.createdAt}" pattern="dd/MM/yyyy hh:mm a"/></td>
                                <td style="font-weight: 600;">RM <fmt:formatNumber value="${sale.totalAmount}" pattern="#,##0.00"/></td>
                                <td><span class="badge-success">Selesai</span></td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty recentSales}">
                            <tr>
                                <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                    Tiada data jualan ditemui buat masa sekarang.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- RECEIPT PREVIEW MODAL -->
    <div id="receiptModal" class="finance-modal-overlay">
        <div class="finance-modal-card" style="max-width: 700px; width: 80%; display: flex; flex-direction: column;">
            <div class="finance-modal-header" style="background: #0f172a; color: white;">
                <h3 style="color: white; margin: 0; font-size: 1.15rem; font-weight: 600;"><i class="fas fa-print"></i> Printable PDF Receipt</h3>
                <span id="closeModal" style="font-size: 28px; font-weight: bold; cursor: pointer; color: #94a3b8;" onclick="closeReceiptModal()">&times;</span>
            </div>
            <div style="padding: 20px; flex-grow: 1; height: 500px; background: #f8fafc;">
                <iframe id="receiptIframe" src="" style="width: 100%; height: 100%; border: none; border-radius: 8px; box-shadow: inset 0 2px 4px 0 rgba(0,0,0,0.06);"></iframe>
            </div>
            <div style="padding: 15px 20px; background: #f1f5f9; display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid #e2e8f0;">
                <a id="downloadReceiptBtn" href="" download style="background: #0284c7; color: white; padding: 10px 18px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 0.9rem; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fas fa-download"></i> Download PDF
                </a>
                <button type="button" onclick="closeReceiptModal()" style="background: white; color: #475569; border: 1px solid #cbd5e1; padding: 10px 18px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer;">
                    Close
                </button>
            </div>
        </div>
    </div>

    <script>
        const labels = [];
        const salesData = [];

        // FIX: Mapping sepadan dengan format pencetakan graf MonthlyReport terkini
        <c:forEach var="report" items="${monthlyReports}">
            labels.push('${report.formatMonth}');
            salesData.push(${report.monthlySales});
        </c:forEach>

        const ctx = document.getElementById('financeChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Sales (Jualan Bulanan)',
                        data: salesData,
                        backgroundColor: '#0284c7',
                        borderRadius: 6,
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'top' }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) { return 'RM ' + value; }
                        }
                    }
                }
            }
        });
        
        function openFinanceModal() {
            document.getElementById("financePdfModal").style.display = "flex";
        }

        function closeFinanceModal() {
            document.getElementById("financePdfModal").style.display = "none";
        }

        function submitFinancePdf(reportFormat) {
            var filterType = document.querySelector("select[name='filterType']").value;
            var branchID = document.querySelector("select[name='branchID']").value;
            var startDate = document.querySelector("input[name='startDate']").value;
            var endDate = document.querySelector("input[name='endDate']").value;
            
            var url = "ExportFinanceServlet?filterType=" + filterType 
                    + "&branchID=" + branchID 
                    + "&format=" + reportFormat
                    + "&startDate=" + encodeURIComponent(startDate)
                    + "&endDate=" + encodeURIComponent(endDate);
                    
            closeFinanceModal();
            window.location.href = url;
        }

        function openReceiptModal(receiptID) {
            const fileUrl = "receipts/" + receiptID + ".pdf";
            document.getElementById("receiptIframe").src = fileUrl;
            document.getElementById("downloadReceiptBtn").href = fileUrl;
            document.getElementById("receiptModal").style.display = "flex";
        }

        function closeReceiptModal() {
            document.getElementById("receiptModal").style.display = "none";
            document.getElementById("receiptIframe").src = "";
        }

        window.onclick = function(event) {
            var financeModal = document.getElementById("financePdfModal");
            var receiptModal = document.getElementById("receiptModal");
            if (event.target == financeModal) {
                closeFinanceModal();
            }
            if (event.target == receiptModal) {
                closeReceiptModal();
            }
        }
    </script>
</body>
</html>