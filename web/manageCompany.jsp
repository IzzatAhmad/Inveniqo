<%@ page import="java.util.List, java.util.ArrayList, model.User, model.Branch, model.Company" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Company companyInfo = (Company) request.getAttribute("companyInfo");
    List<Branch> branchList = (List<Branch>) request.getAttribute("branchList");
    if (branchList == null) branchList = new ArrayList<>();

    Branch selected = (Branch) request.getAttribute("selectedBranch");
    List<User> staffList = (List<User>) request.getAttribute("staffList");

    List<User> activeStaff = new ArrayList<>();
    if (staffList != null) {
        for (User u : staffList) {
            if ("Active".equalsIgnoreCase(u.getUserStatus())) {
                activeStaff.add(u);
            }
        }
    }
    String displayCompany = (companyInfo != null) ? companyInfo.getCompanyName() : "Inveniqo System";
    
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
    <title>Company Management | <%= displayCompany %></title>
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

        .section-card { background: white; padding: 25px; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); margin-bottom: 30px; border: 1px solid #e2e8f0; }
        .section-title { font-size: 1.2rem; font-weight: 600; color: #0f172a; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        
        /* COMPANY EDITOR FORM */
        .company-grid { display: grid; grid-template-columns: 200px 1fr; gap: 30px; }
        .logo-upload-container { display: flex; flex-direction: column; align-items: center; gap: 15px; }
        .logo-preview-box { width: 150px; height: 150px; border-radius: 16px; border: 2px dashed #cbd5e1; display: flex; align-items: center; justify-content: center; overflow: hidden; background: #f8fafc; position: relative; }
        .logo-preview-box img { width: 100%; height: 100%; object-fit: cover; }
        .logo-placeholder { font-size: 3rem; color: #cbd5e1; }
        
        .fields-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 8px; color: #475569; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; background: #f8fafc; transition: 0.2s; }
        .form-control:focus { outline: none; border-color: #0284c7; background: white; }
        .form-control[readonly] { background: #f1f5f9; color: #64748b; cursor: not-allowed; }

        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 12px 15px; background: #f8fafc; color: #64748b; font-size: 0.75rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        td { padding: 15px; border-bottom: 1px solid #f1f5f9; color: #334155; font-size: 0.9rem; }
        
        .badge { padding: 4px 10px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; margin-right: 4px; display: inline-block; }
        .role-Admin { background: #ede9fe; color: #5b21b6; }
        .role-Manager { background: #fef3c7; color: #92400e; }
        .role-Staff { background: #e0f2fe; color: #0369a1; }
        
        .btn { padding: 10px 18px; border-radius: 8px; border: none; cursor: pointer; font-weight: 600; font-size: 0.85rem; display: inline-flex; align-items: center; gap: 8px; transition: 0.2s; }
        .btn-primary { background: #0284c7; color: white; }
        .btn-primary:hover { background: #0369a1; }
        .btn-success { background: #16a34a; color: white; }
        .btn-success:hover { background: #15803d; }
        .btn-ghost { background: #f1f5f9; color: #64748b; }
        .btn-ghost:hover { background: #cbd5e1; }
        .action-btn { background: none; border: none; color: #94a3b8; cursor: pointer; font-size: 1.1rem; transition: 0.2s; margin-left: 8px; }
        .action-btn:hover { color: #0f172a; }
        .action-btn.delete:hover { color: #ef4444; }
        
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(15, 23, 42, 0.7); z-index: 1000; backdrop-filter: blur(4px); align-items: center; justify-content: center; }
        .modal-content { background:white; width:480px; padding:35px; border-radius:20px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); }
        
        .role-grid { display: grid; grid-template-columns: 1fr; gap: 8px; padding: 12px; border: 1px solid #e2e8f0; border-radius: 8px; background: #fcfcfc; }
        .role-option { display: flex; align-items: center; gap: 10px; font-size: 0.9rem; cursor: pointer; }
        
        .alert-msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; font-weight: 500; }
        .alert-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
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
        <a href="ManageCompanyServlet" class="nav-item active">
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
                <h1>Company Configuration</h1>
                <p>Manage profile, branches, and team roles</p>
            </div>

            <div class="user-profile">
                <img src="<%= headerProfileImg %>" alt="Profile">
                <div class="info">
                    <strong><%= loggedUser.getUserName() %></strong>
                    <span><%= String.join(" | ", loggedUser.getRoles()) %></span>
                </div>
            </div>
        </div>

        <!-- MESSAGES -->
        <% if (request.getParameter("success") != null) { %>
            <div class="alert-msg alert-success"><i class="fas fa-check-circle"></i> Action processed successfully.</div>
        <% } else if (request.getParameter("error") != null) { %>
            <div class="alert-msg alert-error"><i class="fas fa-exclamation-triangle"></i> Operation failed. Please check inputs.</div>
        <% } %>

        <% 
            boolean isHQManager = loggedUser.isAdmin(); // Admin represents HQ full control
        %>

        <% if (selected == null) { %>
            
            <!-- COMPANY PROFILE SECTION (Admin Only Editable, Manager Read-Only) -->
            <% if (companyInfo != null) { %>
                <div class="section-card">
                    <div class="section-title">
                        <i class="fas fa-info-circle" style="color:#0284c7;"></i> Company Profile Settings
                    </div>
                    
                    <form action="ManageCompanyServlet" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="updateCompany">
                        <div class="company-grid">
                            
                            <!-- Logo Preview & Upload -->
                            <div class="logo-upload-container">
                                <div class="logo-preview-box">
                                    <% if (companyInfo.getCompanyLogo() != null && !companyInfo.getCompanyLogo().isEmpty()) { %>
                                        <img src="<%= companyInfo.getCompanyLogo() %>" alt="Company Logo">
                                    <% } else { %>
                                        <div class="logo-placeholder"><i class="fas fa-image"></i></div>
                                    <% } %>
                                </div>
                                <% if (isHQManager) { %>
                                    <label class="btn btn-ghost" style="font-size:0.8rem;">
                                        <i class="fas fa-upload"></i> Upload Logo
                                        <input type="file" name="companyLogo" accept="image/*" style="display:none;" onchange="previewLogo(this)">
                                    </label>
                                <% } %>
                            </div>

                            <!-- Form Fields -->
                            <div>
                                <div class="fields-grid">
                                    <div class="form-group">
                                        <label>Company Name</label>
                                        <input type="text" name="companyName" class="form-control" value="<%= companyInfo.getCompanyName() %>" <%= isHQManager ? "" : "readonly" %> required>
                                    </div>
                                    <div class="form-group">
                                        <label>Company Email</label>
                                        <input type="email" name="companyEmail" class="form-control" value="<%= companyInfo.getCompanyEmail() %>" <%= isHQManager ? "" : "readonly" %> required>
                                    </div>
                                    <div class="form-group">
                                        <label>SSM Business Registration Number</label>
                                        <input type="text" name="businessRegNo" class="form-control" value="<%= companyInfo.getBusinessRegNo() %>" <%= isHQManager ? "" : "readonly" %> required>
                                    </div>
                                    <div class="form-group">
                                        <label>Company Address</label>
                                        <textarea name="companyAddress" class="form-control" rows="2" <%= isHQManager ? "" : "readonly" %>><%= companyInfo.getCompanyAddress() != null ? companyInfo.getCompanyAddress() : "" %></textarea>
                                    </div>
                                </div>
                                <% if (isHQManager) { %>
                                    <button type="submit" class="btn btn-success" style="margin-top: 15px;">
                                        <i class="fas fa-save"></i> Save Profile Details
                                    </button>
                                <% } %>
                            </div>

                        </div>
                    </form>
                </div>
            <% } %>

            <!-- BRANCHES SECTION -->
            <div class="section-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <div class="section-title" style="margin-bottom:0;">
                        <i class="fas fa-store" style="color:#0284c7;"></i> Branch Locations
                    </div>
                    <% if (isHQManager) { %>
                        <button class="btn btn-primary" onclick="openAddBranchModal()">
                            <i class="fas fa-plus"></i> Add New Branch
                        </button>
                    <% } %>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Branch Name</th>
                            <th>Address</th>
                            <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        int count = 1; 
                        for (Branch b : branchList) { 
                            // Admin views all, normal Manager only views their own branch
                            if (isHQManager || b.getBranchID().equals(loggedUser.getBranchID())) {
                        %>
                        <tr>
                            <td><%= count++ %></td>
                            <td>
                                <strong><%= b.getBranchName() %></strong>
                                <% if (count == 2) { %> <span class="badge role-Admin" style="font-size:0.6rem">HQ</span> <% } %>
                            </td>
                            <td style="color: #64748b;"><%= b.getBranchAddress() %></td>
                            <td style="text-align: right;">
                                <a href="ManageCompanyServlet?viewBranch=<%= b.getBranchID() %>" class="btn btn-ghost">
                                    <i class="fas fa-users"></i> Manage Staff
                                </a>
                                <% if (isHQManager) { %>
                                    <button class="action-btn" onclick="openEditBranchModal('<%= b.getBranchID() %>', '<%= b.getBranchName().replace("'", "\\'") %>', '<%= b.getBranchAddress().replace("'", "\\'") %>')">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                <% } %>
                            </td>
                        </tr>
                        <% 
                            } 
                        } 
                        %>
                    </tbody>
                </table>
            </div>

        <% } else { %>
            
            <!-- SELECTED BRANCH STAFF DETAILS -->
            <div class="header">
                <div class="welcome-msg">
                    <a href="ManageCompanyServlet" style="text-decoration:none; color:#0284c7; font-size: 0.85rem;"><i class="fas fa-arrow-left"></i> Back to Company Configuration</a>
                    <h1 style="margin-top:10px;"><%= selected.getBranchName() %></h1>
                    <p><%= selected.getBranchAddress() %></p>
                </div>
                <button class="btn btn-primary" onclick="openAddStaffModal()"><i class="fas fa-user-plus"></i> Add Staff</button>
            </div>

            <div class="section-card">
                <h3 style="margin-bottom: 20px; font-weight: 600; font-size: 1.1rem;">Active Team Members</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Staff Info</th>
                            <th>Roles</th>
                            <th>Transfer</th>
                            <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (!activeStaff.isEmpty()) { for (User s : activeStaff) { %>
                        <tr>
                            <td>
                                <strong><%= s.getUserName() %></strong><br>
                                <small style="color: #64748b;"><%= s.getUserEmail() %></small>
                            </td>
                            <td>
                                <% for (String r : s.getRoles()) { 
                                    String cls = "role-" + r; %>
                                    <span class="badge <%= cls %>"><%= r %></span>
                                <% } %>
                            </td>
                            <td>
                                <form action="ManageCompanyServlet" method="POST">
                                    <input type="hidden" name="action" value="assignBranch">
                                    <input type="hidden" name="userID" value="<%= s.getUserID() %>">
                                    <input type="hidden" name="currentBranchID" value="<%= selected.getBranchID() %>">
                                    <select name="branchID" onchange="if(confirm('Are you sure you want to transfer this staff?')) this.form.submit()" class="form-control" style="width: auto; padding: 4px 8px; font-size: 0.85rem;">
                                        <option value="">Move to...</option>
                                        <% for (Branch b : branchList) { if (!b.getBranchID().equals(selected.getBranchID())) { %>
                                            <option value="<%= b.getBranchID() %>"><%= b.getBranchName() %></option>
                                        <% } } %>
                                    </select>
                                </form>
                            </td>
                            <td style="text-align: right;">
                                <button class="action-btn" onclick="openEditStaffModal('<%= s.getUserID() %>', '<%= s.getUserName().replace("'", "\\'") %>', '<%= s.getUserEmail().replace("'", "\\'") %>', '<%= String.join(",", s.getRoles()) %>')">
                                    <i class="fas fa-user-edit"></i>
                                </button>
                                <button class="action-btn delete" onclick="deleteStaff('<%= s.getUserID() %>')">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </td>
                        </tr>
                        <% } } else { %>
                            <tr><td colspan="4" style="text-align:center; color: #64748b;">No active staff.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        <% } %>
    </div>

    <!-- ADD/EDIT STAFF MODAL -->
    <div id="staffModal" class="modal-overlay">
        <div class="modal-content">
            <h2 id="staffModalTitle" style="margin-bottom: 20px; font-weight:600; font-size: 1.3rem;">Staff Member</h2>
            <form action="ManageCompanyServlet" method="POST">
                <input type="hidden" name="action" id="staffAction" value="addStaff">
                <input type="hidden" name="branchID" value="<%= selected != null ? selected.getBranchID() : "" %>">
                <input type="hidden" name="userID" id="staffUserID">

                <div class="form-group">
                    <label>Full Name</label>
                    <input name="name" id="staffName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input name="email" id="staffEmail" type="email" class="form-control" required>
                </div>
                <div id="passField" class="form-group">
                    <label>Password</label>
                    <input name="password" id="staffPassword" type="password" class="form-control">
                </div>
                
                <div class="form-group">
                    <label>Roles</label>
                    <div class="role-grid">
                        <label class="role-option"><input type="checkbox" name="roles" value="Admin" id="role_Admin"> Admin</label>
                        <label class="role-option"><input type="checkbox" name="roles" value="Manager" id="role_Manager"> Manager</label>
                        <label class="role-option"><input type="checkbox" name="roles" value="Staff" id="role_Staff"> Staff</label>
                    </div>
                </div>

                <div style="display:flex; gap:10px; margin-top:25px;">
                    <button type="submit" class="btn btn-primary" style="flex:1; justify-content:center;">Save</button>
                    <button type="button" class="btn btn-ghost" onclick="toggleModal('staffModal', false)" style="flex:1; justify-content:center;">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ADD/EDIT BRANCH MODAL -->
    <div id="branchModal" class="modal-overlay">
        <div class="modal-content">
            <h2 id="branchModalTitle" style="font-weight:600; font-size: 1.3rem;">Branch Details</h2>
            <form action="ManageCompanyServlet" method="POST" style="margin-top:20px;">
                <input type="hidden" name="action" id="branchAction">
                <input type="hidden" name="branchID" id="branchID">
                <div class="form-group">
                    <label>Branch Name</label>
                    <input name="branchName" id="branchName" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Branch Address</label>
                    <textarea name="branchAddress" id="branchAddress" class="form-control" rows="2" required></textarea>
                </div>
                <div style="display:flex; gap:10px; margin-top: 20px;">
                    <button type="submit" class="btn btn-primary" style="flex:1; justify-content:center;">Save</button>
                    <button type="button" class="btn btn-ghost" onclick="toggleModal('branchModal', false)" style="flex:1; justify-content:center;">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function toggleModal(id, show) { 
            document.getElementById(id).style.display = show ? 'flex' : 'none'; 
        }

        function previewLogo(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const previewBox = document.querySelector(".logo-preview-box");
                    previewBox.innerHTML = `<img src="${e.target.result}" alt="Logo Preview">`;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function openAddBranchModal() {
            document.getElementById('branchAction').value = "add";
            document.getElementById('branchID').value = "";
            document.getElementById('branchName').value = "";
            document.getElementById('branchAddress').value = "";
            toggleModal('branchModal', true);
        }

        function openEditBranchModal(id, name, addr) {
            document.getElementById('branchAction').value = "edit";
            document.getElementById('branchID').value = id;
            document.getElementById('branchName').value = name;
            document.getElementById('branchAddress').value = addr;
            toggleModal('branchModal', true);
        }

        function openAddStaffModal() {
            document.getElementById('staffModalTitle').innerText = "Add Staff";
            document.getElementById('staffAction').value = "addStaff";
            document.getElementById('staffUserID').value = "";
            document.getElementById('staffName').value = "";
            document.getElementById('staffEmail').value = "";
            document.getElementById('passField').style.display = "block";
            document.getElementById('role_Admin').checked = false;
            document.getElementById('role_Manager').checked = false;
            document.getElementById('role_Staff').checked = true;
            toggleModal('staffModal', true);
        }

        function openEditStaffModal(id, name, email, rolesString) {
            document.getElementById('staffModalTitle').innerText = "Edit Staff";
            document.getElementById('staffAction').value = "editStaff";
            document.getElementById('staffUserID').value = id;
            document.getElementById('staffName').value = name;
            document.getElementById('staffEmail').value = email;
            document.getElementById('passField').style.display = "none";
            document.getElementById('role_Admin').checked = rolesString.includes("Admin");
            document.getElementById('role_Manager').checked = rolesString.includes("Manager");
            document.getElementById('role_Staff').checked = rolesString.includes("Staff");
            toggleModal('staffModal', true);
        }

        function deleteStaff(userID) {
            if (confirm("Are you sure you want to delete this staff member?")) {
                const form = document.createElement("form");
                form.method = "POST";
                form.action = "ManageCompanyServlet";
                form.innerHTML = `
                    <input type="hidden" name="action" value="deleteStaff">
                    <input type="hidden" name="userID" value="${userID}">
                    <input type="hidden" name="branchID" value="<%= selected != null ? selected.getBranchID() : "" %>">
                `;
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>
