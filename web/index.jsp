<%-- 
    Document   : index
    Created on : Jan 19, 2026, 3:58:30 PM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Welcome to Inveniqo</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
</head>
<body style="background-image: url('${pageContext.request.contextPath}/wallpaper.jpg'); background-size: cover; background-repeat: no-repeat;">
    <div class="form-container" style="margin-top: 200px">
        <h1>Welcome to Inveniqo</h1>
        <p>Inveniqo is a smart inventory management platform </p>
        <div class="btn-group">
            <a class="btn" href="${pageContext.request.contextPath}/login.jsp">Login</a>
            <a class="btn" href="${pageContext.request.contextPath}/register.jsp">Register</a>
        </div>
    </div>
</body>
</html>

