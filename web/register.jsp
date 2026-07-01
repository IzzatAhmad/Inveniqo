<%-- 
    Document   : register
    Created on : Jan 19, 2026, 12:54:56 PM
    Author     : User
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Register Company | Inveniqo</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            * {
                margin:0;
                padding:0;
                box-sizing:border-box;
                font-family:'Inter', 'Segoe UI', sans-serif;
            }
            body {
                background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                display:flex;
                justify-content:center;
                align-items: center;
                min-height: 100vh;
                padding:40px 20px;
            }
            .reg-container {
                width:100%;
                max-width:750px;
                background:white;
                padding:40px;
                border-radius:16px;
                box-shadow:0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
            }
            .header {
                text-align:center;
                margin-bottom:35px;
            }
            .header h1 {
                color:#0284c7;
                font-size:2.5rem;
                letter-spacing: -1px;
            }
            .header p {
                color:#64748b;
                margin-top:8px;
                font-size: 1rem;
            }
            .section-title {
                font-size:0.85rem;
                color:#0284c7;
                font-weight:700;
                margin:30px 0 15px;
                padding-bottom:8px;
                border-bottom:1px solid #e2e8f0;
                text-transform:uppercase;
                letter-spacing:1px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .grid {
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:20px;
            }
            .input-group {
                margin-bottom:15px;
            }
            .input-group label {
                display:block;
                margin-bottom:8px;
                font-size:0.85rem;
                font-weight:600;
                color:#334155;
            }
            .input-group input, .input-group textarea {
                width:100%;
                padding:12px 16px;
                border:1px solid #cbd5e1;
                border-radius:8px;
                outline:none;
                font-size: 0.95rem;
                transition: 0.2s;
            }
            .input-group input:focus {
                border-color:#38bdf8;
                box-shadow:0 0 0 3px rgba(56,189,248,0.1);
            }
            .full-width {
                grid-column:span 2;
            }
            .btn-register {
                width:100%;
                padding:16px;
                background:#0284c7;
                color:white;
                border:none;
                border-radius:8px;
                font-size:1rem;
                font-weight:600;
                cursor:pointer;
                margin-top:30px;
                transition:0.3s;
                box-shadow: 0 4px 6px -1px rgba(2, 132, 199, 0.3);
            }
            .btn-register:hover {
                background:#0369a1;
                transform: translateY(-1px);
            }

            /* Alert Styles */
            .alert {
                padding: 14px;
                border-radius: 8px;
                margin-bottom: 25px;
                font-size: 0.9rem;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .alert-error {
                background: #fee2e2;
                color: #ef4444;
                border: 1px solid #fecaca;
            }
            .alert-success {
                background: #d1fae5;
                color: #059669;
                border: 1px solid #a7f3d0;
            }

            .footer-link {
                text-align: center;
                margin-top: 25px;
                font-size: 0.9rem;
                color: #64748b;
            }
            .footer-link a {
                color: #0284c7;
                text-decoration: none;
                font-weight: 600;
            }

            @media (max-width:600px) {
                .grid {
                    grid-template-columns:1fr;
                }
                .full-width {
                    grid-column: span 1;
                }
                .reg-container {
                    padding: 25px;
                }
            }
        </style>
    </head>
    <body>

        <div class="reg-container">
            <div class="header">
                <h1>Inveniqo</h1>
                <p>Register your company and start managing inventory</p>
            </div>

            <%-- Alert Handling --%>
            <% if (request.getParameter("error") != null) {%>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= request.getParameter("error")%>
            </div>
            <% } %>

            <% if (request.getParameter("success") != null) {%>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= request.getParameter("success")%>
            </div>
            <% }%>

            <%-- Bahagian Form Sahaja --%>
            <form action="<%=request.getContextPath()%>/RegisterCompanyServlet" method="post">
                <div class="section-title"><i class="fas fa-building"></i> Company & Main Branch</div>
                <div class="grid">
                    <div class="input-group full-width">
                        <label>Company Name</label>
                        <input type="text" name="companyName" placeholder="e.g. Inveniqo Global Sdn Bhd" required>
                    </div>
                    <div class="input-group">
                        <label>Main Branch Name (HQ)</label>
                        <input type="text" name="branchName" placeholder="e.g. Headquarters KL" required>
                    </div>
                    <div class="input-group">
                        <label>Company Email (General)</label>
                        <input type="email" name="companyEmail" placeholder="admin@company.com" required>
                    </div>
                    <div class="input-group full-width">
                        <label>HQ Address</label>
                        <textarea rows="2" name="branchAddress" placeholder="Street address of your HQ" required></textarea>
                    </div>
                </div>

                <div class="section-title"><i class="fas fa-user-shield"></i> Master Manager Account</div>
                <div class="grid">
                    <div class="input-group">
                        <label>Your Full Name</label>
                        <input type="text" name="managerName" required>
                    </div>
                    <div class="input-group">
                        <label>Login Email</label>
                        <input type="email" name="managerEmail" required>
                    </div>
                    <div class="input-group">
                        <label>Password</label>
                        <input type="password" name="password" minlength="8" required>
                    </div>
                    <div class="input-group">
                        <label>Confirm Password</label>
                        <input type="password" name="confirmPassword" required>
                    </div>
                </div>
                <button type="submit" class="btn-register">Complete Registration</button>
            </form>

            <div class="footer-link">
                Already have an account? <a href="login.jsp">Login here</a>
            </div>
        </div>

    </body>
</html>