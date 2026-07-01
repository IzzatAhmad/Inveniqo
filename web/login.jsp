<%-- 
    Document   : login
    Created on : Jan 19, 2026, 4:07:28 PM
    Author     : User
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Inveniqo</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', 'Segoe UI', sans-serif; }
        
        body {
            display: flex;
            height: 100vh;
            background-color: #f4f7f6;
        }

        /* Left Side (Branding/Visual) */
        .side-panel {
            flex: 1.2;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: white;
            padding: 40px;
            text-align: center;
        }

        .side-panel h1 { font-size: 3.5rem; letter-spacing: -1px; margin-bottom: 20px; color: #38bdf8; }
        .side-panel p { font-size: 1.2rem; opacity: 0.9; max-width: 450px; line-height: 1.6; }

        /* Right Side (Login Form) */
        .login-section {
            width: 480px;
            background: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 60px;
            box-shadow: -10px 0 30px rgba(0,0,0,0.05);
        }

        .login-section h2 { font-size: 1.8rem; margin-bottom: 8px; color: #1e293b; }
        .login-section p.subtitle { color: #64748b; margin-bottom: 35px; font-size: 0.95rem; }

        /* Alert Box Styles */
        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
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

        .input-group { margin-bottom: 25px; }
        .input-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #334155; font-size: 0.9rem; }
        .input-group input {
            width: 100%;
            padding: 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            transition: 0.2s;
        }

        .input-group input:focus { border-color: #38bdf8; box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.1); }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: #0284c7;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: 0.3s;
        }

        .btn-login:hover { background: #0369a1; }

        .footer-text { margin-top: 25px; text-align: center; font-size: 0.9rem; color: #64748b; }
        .footer-text a { color: #0284c7; text-decoration: none; font-weight: 600; }

        /* Responsive Design */
        @media (max-width: 850px) {
            .side-panel { display: none; }
            .login-section { width: 100%; padding: 40px; }
        }
    </style>
</head>
<body>

    <div class="side-panel">
        <h1>Inveniqo</h1>
        <p>The ultimate solution to manage your inventory, suppliers, and sales in one seamless platform.</p>
    </div>

    <div class="login-section">
        <h2>Welcome Back</h2>
        <p class="subtitle">Please enter your credentials to access the system.</p>

        <%-- Paparan Mesej Ralat atau Kejayaan --%>
        <% 
            String error = request.getParameter("error");
            String success = request.getParameter("success");

            if (error != null) {
                String errorMsg = "Invalid email or password.";
                if (error.equals("inactive")) errorMsg = "Account is inactive. Please contact your manager.";
                if (error.equals("system")) errorMsg = "A system error occurred. Please try again.";
        %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
            </div>
        <% 
            } 

            if (success != null && success.equals("registered")) { 
        %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> Registration successful! Please login.
            </div>
        <% } %>

        <form action="<%=request.getContextPath()%>/LoginServlet" method="post">
            <div class="input-group">
                <label>Email Address</label>
                <input type="email" name="email" placeholder="name@company.com" required>
            </div>
            <div class="input-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="••••••••" required>
            </div>
            <button type="submit" class="btn-login">Sign In</button>
        </form>

        <p class="footer-text">
            Register a new company? <a href="register.jsp">Get started here</a>
        </p>
    </div>

</body>
</html>