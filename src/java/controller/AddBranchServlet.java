/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.BranchDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Branch;
import model.User;

@WebServlet("/AddBranchServlet")
public class AddBranchServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        String name = request.getParameter("branchName");
        String address = request.getParameter("branchAddress");

        try {
            BranchDAO dao = new BranchDAO();
            Branch b = new Branch();
            b.setBranchID(dao.generateNextBranchID());
            b.setBranchName(name);
            b.setBranchAddress(address);
            b.setCompanyID(user.getCompanyID());

            dao.insertBranch(b);
            response.sendRedirect("ManageBranchServlet?success=added");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ManageBranchServlet?error=failed");
        }
    }
}