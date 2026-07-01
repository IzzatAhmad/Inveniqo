<%@ page import="model.User, java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String statusMsg = request.getParameter("success") != null ? "Profile updated successfully!" : "";
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Profile | Inveniqo</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
            /* CSS menyamai Dashboard anda */
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
                display: flex;
                justify-content: center;
            }

            .profile-card {
                background: white;
                width: 100%;
                max-width: 600px;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
            }
            .image-section {
                text-align: center;
                margin-bottom: 30px;
                position: relative;
            }
            .profile-pic {
                width: 120px;
                height: 120px;
                border-radius: 50%;
                object-fit: cover;
                border: 4px solid #f1f5f9;
            }
            .upload-btn {
                position: absolute;
                bottom: 0;
                right: 50%;
                transform: translateX(60px);
                background: #0284c7;
                color: white;
                width: 35px;
                height: 35px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                border: 3px solid white;
            }

            .form-group {
                margin-bottom: 20px;
            }
            .form-group label {
                display: block;
                font-size: 0.85rem;
                font-weight: 600;
                color: #64748b;
                margin-bottom: 8px;
            }
            .form-control {
                width: 100%;
                padding: 12px;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                background: #f8fafc;
                font-size: 0.95rem;
            }
            .form-control:read-only {
                background: #f1f5f9;
                cursor: not-allowed;
                color: #94a3b8;
            }

            .btn-update {
                width: 100%;
                padding: 14px;
                background: #0284c7;
                color: white;
                border: none;
                border-radius: 10px;
                font-weight: 700;
                cursor: pointer;
                transition: 0.3s;
                margin-top: 10px;
            }
            .btn-update:hover {
                background: #0369a1;
            }
            .alert-success {
                background: #ecfdf5;
                color: #059669;
                padding: 15px;
                border-radius: 10px;
                margin-bottom: 20px;
                font-size: 0.9rem;
                text-align: center;
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
            <div class="profile-card">
                <h2 style="margin-bottom: 30px; color: #1e293b;">Account Settings</h2>

                <% if (!statusMsg.isEmpty()) {%>
                <div class="alert-success"><%= statusMsg%></div>
                <% }%>

                <form action="ProfileServlet" method="POST" enctype="multipart/form-data">
                    <div class="image-section">
                        <%
                            String avatarPath = "uploads/default.png";
                            if (loggedUser.getProfileImage() != null && !loggedUser.getProfileImage().trim().isEmpty()) {
                                avatarPath = loggedUser.getProfileImage();
                            } else if (loggedUser.getCompanyLogo() != null && !loggedUser.getCompanyLogo().trim().isEmpty()) {
                                avatarPath = loggedUser.getCompanyLogo();
                            }
                        %>
                        <img src="<%= avatarPath %>" class="profile-pic" id="preview">
                        <label for="file-input" class="upload-btn"><i class="fas fa-camera"></i></label>
                        <input id="file-input" type="file" name="profileImage" style="display:none;" onchange="previewImage(this)">
                    </div>

                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="userName" class="form-control" value="<%= loggedUser.getUserName()%>" required>
                    </div>

                    <div class="form-group">
                        <label>Email Address (Cannot change)</label>
                        <input type="email" class="form-control" value="<%= loggedUser.getUserEmail()%>" readonly>
                    </div>

                    <div class="form-row" style="display:flex; gap:15px;">
                        <div class="form-group" style="flex:1;">
                            <label>Company</label>
                            <input type="text" class="form-control" value="<%= loggedUser.getCompanyName()%>" readonly>
                        </div>
                        <div class="form-group" style="flex:1;">
                            <label>Branch</label>
                            <input type="text" class="form-control" value="<%= loggedUser.getBranchName()%>" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>New Password (Leave blank to keep current)</label>
                        <input type="password" name="password" class="form-control" placeholder="••••••••">
                        <small style="color:#64748b; font-size:0.75rem;">Security tip: Use at least 8 characters.</small>
                    </div>

                    <button type="submit" class="btn-update">Save Changes</button>
                </form>
            </div>
        </div>

        <script>
            function previewImage(input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        document.getElementById('preview').src = e.target.result;
                    }
                    reader.readAsDataURL(input.files[0]);
                }
            }
        </script>
    </body>
</html>