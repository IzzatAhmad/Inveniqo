<%@ page import="model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String branchLabel = (loggedUser.getBranchName() != null) ? loggedUser.getBranchName() : "No Branch Assigned";
    
    String headerProfileImg = "uploads/default.png";
    if (loggedUser.getProfileImage() != null && !loggedUser.getProfileImage().trim().isEmpty()) {
        headerProfileImg = loggedUser.getProfileImage();
    } else if (loggedUser.getCompanyLogo() != null && !loggedUser.getCompanyLogo().trim().isEmpty()) {
        headerProfileImg = loggedUser.getCompanyLogo();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>API Integration | Inveniqo</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght=300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
        body { background-color: #f8fafc; display: flex; color: #1e293b; }
        
        /* SIDEBAR styling */
        .sidebar { width: 260px; background: #0f172a; height: 100vh; color: white; padding: 25px 20px; position: fixed; display: flex; flex-direction: column; z-index: 100; }
        .logo { font-size: 1.7rem; font-weight: 800; color: #38bdf8; margin-bottom: 40px; letter-spacing: -1px; }
        .nav-group-label { font-size: 0.7rem; color: #64748b; text-transform: uppercase; letter-spacing: 1px; margin: 20px 0 10px 10px; font-weight: 700; }
        .nav-item { padding: 12px 15px; display: flex; align-items: center; color: #94a3b8; text-decoration: none; border-radius: 10px; margin-bottom: 4px; font-size: 0.9rem; transition: 0.2s; }
        .nav-item:hover { background: #1e293b; color: #38bdf8; }
        .nav-item.active { background: #0284c7; color: white; }
        .nav-item i { margin-right: 12px; width: 20px; text-align: center; }
        
        .main-content { margin-left: 260px; width: calc(100% - 260px); padding: 40px; }
        
        /* HEADER styling */
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .welcome-msg h1 { font-size: 1.8rem; font-weight: 700; color: #0f172a; }
        .welcome-msg p { color: #64748b; font-size: 0.9rem; margin-top: 4px; }
        
        .user-profile { display: flex; align-items: center; gap: 12px; background: white; padding: 8px 16px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        .user-profile img { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid #e2e8f0; }
        .user-profile .info { display: flex; flex-direction: column; }
        .user-profile .info strong { font-size: 0.9rem; color: #1e293b; }
        .user-profile .info span { font-size: 0.75rem; color: #64748b; }

        .grid-container { display: grid; grid-template-columns: 1.2fr 1fr; gap: 30px; }
        .card { background: white; padding: 25px; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }
        .card-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; color: #0f172a; }
        
        .info-box { background: #f8fafc; border: 1px solid #e2e8f0; padding: 15px; border-radius: 10px; margin-bottom: 15px; font-size: 0.85rem; color: #475569; }
        .code-block { font-family: monospace; background: #0f172a; color: #38bdf8; padding: 10px 14px; border-radius: 6px; margin-top: 8px; font-size: 0.85rem; word-break: break-all; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 8px; color: #475569; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; background: #f8fafc; transition: 0.2s; }
        .form-control:focus { outline: none; border-color: #0284c7; background: white; }
        
        .payload-editor { font-family: monospace; background: #0f172a; color: #10b981; border: none; border-radius: 8px; width: 100%; height: 220px; padding: 15px; font-size: 0.85rem; resize: vertical; }
        .payload-editor:focus { outline: none; box-shadow: 0 0 0 2px #0284c7; }

        .btn-action { background: #0284c7; color: white; border: none; padding: 12px 20px; border-radius: 8px; font-size: 0.95rem; font-weight: 600; cursor: pointer; width: 100%; display: flex; align-items: center; justify-content: center; gap: 8px; transition: 0.2s; }
        .btn-action:hover { background: #0369a1; }
        
        .console-log { background: #0f172a; color: #f8fafc; font-family: monospace; padding: 15px; border-radius: 8px; height: 150px; overflow-y: auto; font-size: 0.8rem; border-left: 4px solid #cbd5e1; margin-top: 8px; white-space: pre-wrap; }
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
        <a href="FinanceServlet" class="nav-item">
            <i class="fas fa-chart-pie"></i> Financial Stats
        </a>
        <% } %>
        
        <a href="integration.jsp" class="nav-item active">
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
                <h1>E-Commerce API Integration</h1>
                <p>Simulate WooCommerce, Shopee, Lazada & TikTok webhook connections | Cawangan: <strong><%= branchLabel %></strong></p>
            </div>

            <div class="user-profile">
                <img src="<%= headerProfileImg %>" alt="Profile">
                <div class="info">
                    <strong><%= loggedUser.getUserName() %></strong>
                    <span><%= String.join(" | ", loggedUser.getRoles()) %></span>
                </div>
            </div>
        </div>

        <div class="grid-container">
            
            <!-- Credentials & Webhook Details -->
            <div class="card">
                <div class="card-title">
                    <i class="fas fa-key" style="color: #eab308;"></i> API Credentials & Webhook Endpoint
                </div>
                
                <div class="info-box">
                    <strong>1. Sandbox Webhook Endpoint Target</strong><br>
                    Use this URL inside Shopee, TikTok Shop, or WooCommerce developers configuration:
                    <div class="code-block" id="urlBlock">http://localhost:8080/Inveniqo3/api/external/order</div>
                </div>

                <div class="info-box">
                    <strong>2. Authorization Header Token</strong><br>
                    Every API request must present this security header:
                    <div class="code-block">X-API-Key : INVENIQO_SECURE_TOKEN_2026</div>
                </div>

                <div class="info-box" style="border-left: 4px solid #38bdf8; background: #f0f9ff;">
                    <strong><i class="fas fa-info-circle"></i> How Stock Synchronization Works:</strong><br>
                    When a customer places an order on external e-commerce sites (Shopee, TikTok, Lazada), the system will deduct stock from <strong>Store Room</strong> first. If the Store Room stock is depleted, it automatically deducts the remaining amount from the <strong>Display Room</strong> to ensure zero inventory discrepancies.
                </div>
            </div>

            <!-- E-Commerce Sandbox Simulator -->
            <div class="card">
                <div class="card-title">
                    <i class="fas fa-laptop-code" style="color: #0284c7;"></i> Malaysia E-Commerce Sandbox
                </div>
                <p style="font-size: 0.85rem; color: #64748b; margin-bottom: 20px;">
                    Select platform and edit raw payload to simulate automated incoming orders.
                </p>

                <form id="simulatorForm" onsubmit="runSimulation(event)">
                    <div class="form-group">
                        <label for="platformSelector">Select Platform Integration</label>
                        <select id="platformSelector" class="form-control" onchange="loadPayloadTemplate()">
                            <option value="woocommerce">WooCommerce / Shopify (Standard)</option>
                            <option value="shopee">Shopee Malaysia (v2 API)</option>
                            <option value="tiktok">TikTok Shop (Webhook)</option>
                            <option value="lazada">Lazada OP</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="rawPayload">JSON Raw Payload Body</label>
                        <textarea id="rawPayload" class="payload-editor" required></textarea>
                    </div>

                    <button type="submit" class="btn-action" id="btnSimulate">
                        <i class="fas fa-play"></i> Send Webhook Request
                    </button>
                </form>

                <div style="margin-top: 20px;">
                    <span style="font-size: 0.8rem; font-weight:700; color:#475569;">Simulator Console Output:</span>
                    <div class="console-log" id="consoleOutput">Console Idle. Select a template and click Send.</div>
                </div>
            </div>

        </div>
    </div>

    <!-- JavaScript payload configurations -->
    <script>
        document.getElementById('urlBlock').innerText = window.location.origin + "/Inveniqo3/api/external/order";

        const branchID = "<%= loggedUser.getBranchID() %>";
        const templates = {
            woocommerce: JSON.stringify({
                productID: "P123456",
                branchID: branchID,
                quantity: 2
            }, null, 2),
            shopee: JSON.stringify({
                platform: "Shopee",
                branch_id: branchID,
                item_id: "P123456",
                shop_id: "SHOP-MY-882",
                quantity: 1
            }, null, 2),
            tiktok: JSON.stringify({
                platform: "TikTok Shop",
                warehouse_id: branchID,
                product_id: "P123456",
                quantity: 2
            }, null, 2),
            lazada: JSON.stringify({
                platform: "Lazada",
                location_id: branchID,
                item_code: "P123456",
                quantity: 1
            }, null, 2)
        };

        function loadPayloadTemplate() {
            const platform = document.getElementById("platformSelector").value;
            document.getElementById("rawPayload").value = templates[platform];
        }

        window.onload = function() {
            loadPayloadTemplate();
        };

        function runSimulation(event) {
            event.preventDefault();
            
            const consoleOutput = document.getElementById('consoleOutput');
            const btn = document.getElementById('btnSimulate');
            const rawBody = document.getElementById('rawPayload').value;
            
            consoleOutput.innerText = ">> Initiating request...\n>> Body: " + rawBody + "\n";
            btn.disabled = true;
            btn.style.background = "#64748b";

            fetch('api/external/order', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-API-Key': 'INVENIQO_SECURE_TOKEN_2026'
                },
                body: rawBody
            })
            .then(async response => {
                const text = await response.text();
                let data = {};
                try {
                    data = JSON.parse(text);
                } catch(e) {
                    data = { message: text };
                }
                
                if (response.ok) {
                    consoleOutput.style.borderLeft = "4px solid #10b981";
                    consoleOutput.innerText = ">> RESPONSE SUCCESS (" + response.status + ")\n" + 
                                           ">> Message: " + (data.message || data.status || "Success") + "\n" +
                                           ">> Stock synchronized correctly on database.";
                } else {
                    consoleOutput.style.borderLeft = "4px solid #ef4444";
                    consoleOutput.innerText = ">> RESPONSE ERROR (" + response.status + ")\n" +
                                           ">> Error details: " + (data.message || text);
                }
            })
            .catch(error => {
                consoleOutput.style.borderLeft = "4px solid #ef4444";
                consoleOutput.innerText = ">> HTTP REQUEST FAILED:\n" + error;
            })
            .finally(() => {
                btn.disabled = false;
                btn.style.background = "#0284c7";
            });
        }
    </script>
</body>
</html>
