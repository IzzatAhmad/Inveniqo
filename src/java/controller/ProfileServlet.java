/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;

@WebServlet("/ProfileServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class ProfileServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        // Data sudah ada dalam session "loggedUser", terus ke JSP
        request.getRequestDispatcher("myProfile.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        UserDAO uDao = new UserDAO();

        try {
            String newName = request.getParameter("userName");
            String newPass = request.getParameter("password");
            
            // 1. Update Nama & Password (jika diisi)
            loggedUser.setUserName(newName);
            boolean updatePass = (newPass != null && !newPass.trim().isEmpty());
            if (updatePass) loggedUser.setPassword(newPass);
            
            uDao.updateProfile(loggedUser, updatePass);

            // 2. Handle Image Upload
            Part filePart = request.getPart("profileImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = "profile_" + loggedUser.getUserID() + ".jpg";
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                filePart.write(uploadPath + File.separator + fileName);
                String dbPath = "uploads/" + fileName;
                uDao.updateProfileImage(loggedUser.getUserID(), dbPath);
                loggedUser.setProfileImage(dbPath); // Update object dalam session
            }

            session.setAttribute("loggedUser", loggedUser);
            response.sendRedirect("ProfileServlet?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ProfileServlet?error=1");
        }
    }
}