package controller;

import dao.BranchDAO;
import dao.UserDAO;
import dao.CompanyDAO;
import model.Branch;
import model.User;
import model.Company;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.util.Arrays;
import java.util.List;

@WebServlet({"/ManageBranchServlet", "/ManageCompanyServlet"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10)
public class ManageBranchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");

        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            BranchDAO branchDao = new BranchDAO();
            UserDAO userDAO = new UserDAO();
            CompanyDAO companyDAO = new CompanyDAO();
            String companyID = loggedUser.getCompanyID();

            // Fetch company details
            Company companyInfo = companyDAO.getCompanyByID(companyID);
            request.setAttribute("companyInfo", companyInfo);

            List<Branch> branchList = branchDao.getBranchesByCompany(companyID);
            request.setAttribute("branchList", branchList);

            String selectedID = request.getParameter("viewBranch");
            if (selectedID != null && !selectedID.isEmpty()) {
                Branch selectedBranch = branchDao.getBranchByID(selectedID);
                // Load only active users by default
                List<User> staffList = userDAO.getUsersByBranch(selectedID); 

                request.setAttribute("selectedBranch", selectedBranch);
                request.setAttribute("staffList", staffList);
            }

            request.getRequestDispatcher("manageCompany.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?error=failed");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User loggedUser = (User) session.getAttribute("loggedUser");
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        BranchDAO branchDao = new BranchDAO();
        UserDAO userDAO = new UserDAO();
        CompanyDAO companyDAO = new CompanyDAO();

        String currentBranchID = request.getParameter("branchID");

        try {
            if ("updateCompany".equals(action)) {
                // Update Company Profile
                String cName = request.getParameter("companyName");
                String cEmail = request.getParameter("companyEmail");
                String regNo = request.getParameter("businessRegNo");
                String address = request.getParameter("companyAddress");

                Company c = companyDAO.getCompanyByID(loggedUser.getCompanyID());
                c.setCompanyName(cName);
                c.setCompanyEmail(cEmail);
                c.setBusinessRegNo(regNo);
                c.setCompanyAddress(address);

                // Handle Logo upload
                Part part = request.getPart("companyLogo");
                if (part != null && part.getSize() > 0) {
                    String fileName = "logo_" + c.getCompanyID() + "_" + System.currentTimeMillis() + ".jpg";
                    String savePath = getServletContext().getRealPath("/") + "uploads" + File.separator + "company";
                    File fileSaveDir = new File(savePath);
                    if (!fileSaveDir.exists()) fileSaveDir.mkdirs();
                    part.write(savePath + File.separator + fileName);
                    String logoPath = "uploads/company/" + fileName;
                    c.setCompanyLogo(logoPath);
                    loggedUser.setCompanyLogo(logoPath); // sync in session
                }

                companyDAO.updateCompany(c);
                loggedUser.setCompanyName(cName); // sync in session
            }
            else if ("add".equals(action)) {
                Branch b = new Branch();
                b.setBranchID(branchDao.generateNextBranchID());
                b.setBranchName(request.getParameter("branchName"));
                b.setBranchAddress(request.getParameter("branchAddress"));
                b.setCompanyID(loggedUser.getCompanyID());
                branchDao.insertBranch(b);
            } 
            else if ("addStaff".equals(action)) {
                User newUser = new User();
                try (Connection con = util.DBConnection.getConnection()) {
                    newUser.setUserID(userDAO.generateNextUserID(con));
                }
                newUser.setUserName(request.getParameter("name"));
                newUser.setUserEmail(request.getParameter("email"));
                newUser.setPassword(request.getParameter("password"));
                newUser.setBranchID(currentBranchID);
                newUser.setUserStatus("Active"); // Auto Active

                String[] roles = request.getParameterValues("roles");
                userDAO.insertUserWithMultipleRoles(newUser, Arrays.asList(roles));
            } 
            else if ("editStaff".equals(action)) {
                User u = new User();
                u.setUserID(request.getParameter("userID"));
                u.setUserName(request.getParameter("name"));
                u.setUserEmail(request.getParameter("email"));
                u.setUserStatus("Active"); // Default active in UI cleanup
                
                String[] roles = request.getParameterValues("roles");
                userDAO.updateUserWithRoles(u, Arrays.asList(roles));
            }
            else if ("deleteStaff".equals(action)) {
                String deleteUserID = request.getParameter("userID");
                userDAO.deleteUser(deleteUserID);
            }
            else if ("edit".equals(action)) {
                Branch b = new Branch();
                b.setBranchID(request.getParameter("branchID"));
                b.setBranchName(request.getParameter("branchName"));
                b.setBranchAddress(request.getParameter("branchAddress"));
                branchDao.updateBranch(b);
            } 
            else if ("assignBranch".equals(action)) {
                userDAO.updateBranch(request.getParameter("userID"), request.getParameter("branchID"));
                currentBranchID = request.getParameter("currentBranchID");
            }

            String redirectUrl = "ManageCompanyServlet?success=1" + (currentBranchID != null ? "&viewBranch=" + currentBranchID : "");
            response.sendRedirect(redirectUrl);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ManageCompanyServlet?error=1" + (currentBranchID != null ? "&viewBranch=" + currentBranchID : ""));
        }
    }
}