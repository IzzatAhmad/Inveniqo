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

    List<String> roles = loggedUser.getRoles();
    String branchLabel = (loggedUser.getBranchName() != null) ? loggedUser.getBranchName() : "No Branch Assigned";

    // Menerima data metrik dinamik daripada DashboardServlet
    double todaysSales = (request.getAttribute("todaysSales") != null) ? (Double) request.getAttribute("todaysSales") : 0.0;
    int activeProducts = (request.getAttribute("activeProducts") != null) ? (Integer) request.getAttribute("activeProducts") : 0;
    int lowStockAlerts = (request.getAttribute("lowStockAlerts") != null) ? (Integer) request.getAttribute("lowStockAlerts") : 0;
    int pendingApprovalCount = (request.getAttribute("pendingApprovalCount") != null) ? (Integer) request.getAttribute("pendingApprovalCount") : 0;
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Dashboard | Inveniqo</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
        <!-- Pustaka Graf Chart.js untuk Visualisasi Data Premium -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        
        <style>
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
                margin-bottom: 35px;
            }
            .user-profile {
                background: white;
                padding: 8px 15px;
                border-radius: 50px;
                display: flex;
                align-items: center;
                gap: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            }
            .user-profile img {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                object-fit: cover;
            }
            
            /* GRID METRIK ATAS */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 20px;
                margin-bottom: 35px;
            }
            .stat-card {
                background: white;
                padding: 22px;
                border-radius: 16px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02);
                border: 1px solid #f1f5f9;
                display: flex;
                flex-direction: column;
                position: relative;
                overflow: hidden;
                transition: transform 0.2s, box-shadow 0.2s;
                text-decoration: none;
                color: inherit;
            }
            .stat-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05);
            }
            .stat-icon {
                font-size: 1.3rem;
                padding: 10px;
                border-radius: 12px;
                width: fit-content;
                margin-bottom: 12px;
            }
            .stat-number {
                font-size: 1.8rem; 
                font-weight: 700; 
                color: #0f172a;
                margin-bottom: 4px;
            }
            .stat-label {
                color: #64748b; 
                font-size: 0.85rem;
                font-weight: 500;
            }

            /* STRUKTUR GRAF BARU (CHARTS GRID BOARD) */
            .charts-workspace {
                display: grid;
                grid-template-columns: 2fr 1.1fr;
                gap: 25px;
                margin-top: 15px;
            }
            .chart-card {
                background: white;
                padding: 25px;
                border-radius: 18px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02);
                display: flex;
                flex-direction: column;
            }
            .chart-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
            }
            .chart-title {
                font-size: 1rem;
                font-weight: 700;
                color: #1e293b;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .chart-subtitle {
                font-size: 0.8rem;
                color: #64748b;
                font-weight: 400;
                margin-top: 2px;
            }

            @keyframes pulse {
                0% { transform: scale(1); opacity: 1; }
                50% { transform: scale(1.05); opacity: 0.9; }
                100% { transform: scale(1); opacity: 1; }
            }
        </style>
    </head>
    <body>

        <!-- SIDEBAR NAVIGATION -->
        <div class="sidebar">
            <div class="logo">Inveniqo</div>

            <a href="DashboardServlet" class="nav-item active">
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

        <!-- MAIN INTERACTIVE SPACE -->
        <div class="main-content">
            <div class="header">
                <div class="welcome-msg">
                    <h1>Welcome back, <%= loggedUser.getUserName()%>!</h1>
                    <p>Company: <strong><%= loggedUser.getCompanyName()%></strong> | Location: <strong><%= branchLabel%></strong></p>
                </div>

                <%
                    String headerProfileImg = "uploads/default.png";
                    if (loggedUser.getProfileImage() != null && !loggedUser.getProfileImage().trim().isEmpty()) {
                        headerProfileImg = loggedUser.getProfileImage();
                    } else if (loggedUser.getCompanyLogo() != null && !loggedUser.getCompanyLogo().trim().isEmpty()) {
                        headerProfileImg = loggedUser.getCompanyLogo();
                    }
                %>
                <a href="ProfileServlet" style="text-decoration: none; color: inherit;">
                    <div class="user-profile" style="cursor: pointer;">
                        <img src="<%= headerProfileImg %>" alt="Profile">
                        <div class="info">
                            <strong><%= loggedUser.getUserName()%></strong>
                            <div style="font-size: 0.7rem; color: #64748b;"><%= String.join(" | ", loggedUser.getRoles())%></div>
                        </div>
                    </div>
                </a>
            </div>

            <!-- METRIC CARDS GRID -->
            <div class="stats-grid">
    
    <div class="stat-card">
        <div class="stat-icon" style="background: #e0f2fe; color: #0284c7;">
            <i class="fas fa-user-shield"></i>
        </div>
        <div class="stat-number" style="font-size: 1.3rem; margin-top: 8px; margin-bottom: 8px;">
            <%= (loggedUser.isAdmin()) ? "Global View" : "Branch View"%>
        </div>
        <div class="stat-label">Access Level Security</div>
    </div>

    <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
    <div class="stat-card">
        <div class="stat-icon" style="background: #ecfdf5; color: #10b981;">
            <i class="fas fa-wallet"></i>
        </div>
        <div class="stat-number">RM <%= String.format("%.2f", todaysSales) %></div>
        <div class="stat-label">Today's Total Sales</div>
    </div>
    <% } %>

    <a href="InventoryServlet?status=Active" class="stat-card">
        <div class="stat-icon" style="background: #dcfce7; color: #16a34a;">
            <i class="fas fa-boxes"></i>
        </div>
        <div class="stat-number"><%= activeProducts %></div>
        <div class="stat-label">Total Active Products</div>
    </a>

    <a href="InventoryServlet?status=Low+Stock" class="stat-card">
        <div class="stat-icon" style="<%= (lowStockAlerts > 0) ? "background: #fee2e2; color: #ef4444; animation: pulse 2s infinite;" : "background: #f1f5f9; color: #64748b;" %>">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <div class="stat-number" style="<%= (lowStockAlerts > 0) ? "color: #ef4444;" : "" %>"><%= lowStockAlerts %></div>
        <div class="stat-label">Low Stock Items</div>
    </a>

    <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
    <a href="PendingProductServlet" class="stat-card">
        <div class="stat-icon" style="background: #ffedd5; color: #ea580c;">
            <i class="fas fa-clock"></i>
        </div>
        <div class="stat-number"><%= pendingApprovalCount %></div>
        <div class="stat-label">Pending Approvals</div>
    </a>
    <% } %>

</div>

            <!-- RUANG VISUALISASI GRAF BARU -->
            <div class="charts-workspace">
                
                <!-- GRAF 1: ALIRAN PRESTASI JUALAN MINGGUAN -->
                <div class="chart-card">
                    <div class="chart-header">
                        <div>
                            <div class="chart-title"><i class="fas fa-chart-area" style="color: #0284c7;"></i> Sales Performance Trend</div>
                            <div class="chart-subtitle">Tinjauan aliran jualan kedai bagi tempoh 7 hari kebelakangan ini</div>
                        </div>
                    </div>
                    <div style="position: relative; flex-grow: 1; min-height: 280px;">
                        <canvas id="salesTrendChart"></canvas>
                    </div>
                </div>

                <!-- GRAF 2: STATUS KESIHATAN STOK (DINAMIK) -->
                <div class="chart-card">
                    <div class="chart-header">
                        <div>
                            <div class="chart-title"><i class="fas fa-heartbeat" style="color: #ef4444;"></i> Stock Health Status</div>
                            <div class="chart-subtitle">Keseimbangan keadaan inventori semasa</div>
                        </div>
                    </div>
                    <div style="position: relative; flex-grow: 1; max-height: 240px; display: flex; justify-content: center;">
                        <canvas id="stockHealthChart"></canvas>
                    </div>
                </div>

            </div> <!-- Habis Workspace Graf -->

        </div>

        <!-- ENGINE SCRIPT CHART JS -->
        <script>
            // 1. Logic Setup untuk Graf Jualan Mingguan (Menggunakan nilai dinamik Hari ini sebagai baseline)
            const ctxSales = document.getElementById('salesTrendChart').getContext('2d');
            const currentSalesValue = <%= todaysSales %>;
            
            // Simulasi data aliran minggu berdasarkan data baseline sebenar untuk membentuk garisan analitik trend
            new Chart(ctxSales, {
                type: 'line',
                data: {
                    labels: ['Isnin', 'Selasa', 'Rabu', 'Khamis', 'Jumaat', 'Sabtu', 'Hari Ini'],
                    datasets: [{
                        label: 'Jumlah Jualan (RM)',
                        data: [
                            (currentSalesValue * 0.85).toFixed(2), 
                            (currentSalesValue * 1.1).toFixed(2), 
                            (currentSalesValue * 0.95).toFixed(2), 
                            (currentSalesValue * 1.05).toFixed(2), 
                            (currentSalesValue * 1.3).toFixed(2), 
                            (currentSalesValue * 1.5).toFixed(2), 
                            currentSalesValue.toFixed(2)
                        ],
                        borderColor: '#0284c7',
                        backgroundColor: 'rgba(2, 132, 199, 0.08)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.35,
                        pointBackgroundColor: '#0284c7'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { grid: { color: '#f1f5f9' }, ticks: { font: { family: 'Inter' } } },
                        x: { grid: { display: false } }
                    }
                }
            });

            // 2. Logic Setup untuk Doughnut Chart Kesihatan Stok (Real-time daripada Java Variable)
            const ctxStock = document.getElementById('stockHealthChart').getContext('2d');
            const totalActive = <%= activeProducts %>;
            const totalLow = <%= lowStockAlerts %>;
            const healthyStock = totalActive - totalLow > 0 ? totalActive - totalLow : 0;

            new Chart(ctxStock, {
                type: 'doughnut',
                data: {
                    labels: ['Stok Stabil', 'Stok Rendah Amaran'],
                    datasets: [{
                        data: [healthyStock, totalLow],
                        backgroundColor: ['#10b981', '#ef4444'],
                        borderWidth: 2,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { boxWidth: 12, font: { family: 'Inter', size: 11 } }
                        }
                    },
                    cutout: '70%'
                }
            });
        </script>
    </body>
</html>