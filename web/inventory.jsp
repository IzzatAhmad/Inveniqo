<%@page import="model.Category"%>
<%@ page import="model.User, model.Product, model.ProductVariant, dao.ProductVariantDAO, java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    List<Product> inventoryList = (List<Product>) request.getAttribute("inventoryList");
    List<Category> catList = (List<Category>) request.getAttribute("categoryList");

    int currentPage = (request.getAttribute("currentPage") != null) ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPages = (request.getAttribute("totalPages") != null) ? (Integer) request.getAttribute("totalPages") : 1;
    String searchVal = (request.getAttribute("search") != null) ? (String) request.getAttribute("search") : "";
    String statusVal = (request.getAttribute("status") != null) ? (String) request.getAttribute("status") : "";
    int selectedCat = (request.getAttribute("selectedCategory") != null) ? (Integer) request.getAttribute("selectedCategory") : 0;

    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Inventory | Inveniqo</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
            /* CSS Standard Inveniqo */
            * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
            body { background-color: #f8fafc; display: flex; }
            main-content::-webkit-scrollbar { display: none; }
            .sidebar { width: 260px; background: #0f172a; height: 100vh; color: white; padding: 25px 20px; position: fixed; display: flex; flex-direction: column; z-index: 100; }
            .logo { font-size: 1.7rem; font-weight: 800; color: #38bdf8; margin-bottom: 40px; letter-spacing: -1px; }
            .nav-group-label { font-size: 0.7rem; color: #64748b; text-transform: uppercase; letter-spacing: 1px; margin: 20px 0 10px 10px; font-weight: 700; }
            .nav-item { padding: 12px 15px; display: flex; align-items: center; color: #94a3b8; text-decoration: none; border-radius: 10px; margin-bottom: 4px; transition: 0.2s; font-size: 0.9rem; }
            .nav-item:hover { background: #1e293b; color: #38bdf8; }
            .nav-item.active { background: #0284c7; color: white; }
            .nav-item i { margin-right: 12px; width: 20px; text-align: center; }
            .main-content { margin-left: 260px; width: calc(100% - 260px); padding: 40px; scrollbar-width: none; -ms-overflow-style: none; overflow-y: auto; }
            .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
            .section-card { background: white; padding: 25px; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #f1f5f9; }
            table { width: 100%; border-collapse: collapse; }
            th { text-align: left; padding: 15px; background: #f8fafc; color: #64748b; font-size: 0.75rem; text-transform: uppercase; border-bottom: 1px solid #e2e8f0; }
            td { padding: 15px; border-bottom: 1px solid #f1f5f9; color: #334155; font-size: 0.9rem; vertical-align: middle; }
            .badge { padding: 5px 12px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; }
            .status-instock { background: #dcfce7; color: #166534; }
            .status-lowstock { background: #fef3c7; color: #92400e; border: 1px solid #f59e0b; }
            .status-outofstock { background: #fee2e2; color: #991b1b; }
            .btn-add { background: #0284c7; color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 0.9rem; display: flex; align-items: center; gap: 8px; border:none; cursor:pointer; }
            .table-prod-img { width: 45px; height: 45px; object-fit: cover; border-radius: 8px; border: 1px solid #f1f5f9; background: #e2e8f0; }
            .modal-overlay { display:none; position:fixed; inset:0; background:rgba(15, 23, 42, 0.7); z-index: 1000; backdrop-filter: blur(4px); align-items: center; justify-content: center; }
            .modal-content { background:white; width:520px; padding:35px; border-radius:20px; max-height: 90vh; overflow-y: auto; }
            .form-group { margin-bottom: 15px; }
            .form-group label { display: block; margin-bottom: 5px; font-size: 0.85rem; font-weight: 600; color: #475569; }
            .form-control { width: 100%; padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff; color: #334155; font-size: 0.9rem; box-sizing: border-box; display: block; }
            .form-control:focus { outline: none; border-color: #0284c7; }
            .prod-img-preview { width: 70px; height: 70px; object-fit: cover; border-radius: 10px; border: 2px dashed #cbd5e1; }
            .btn-manage-stock { background: #10b981; color: white; border: none; padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 5px; height: 32px; transition: 0.2s; }
            .btn-manage-stock:hover { background: #059669; }
            .modal-tabs { display: flex; gap: 10px; margin-bottom: 20px; background: #f1f5f9; padding: 4px; border-radius: 8px; }
            .modal-tab-btn { flex: 1; padding: 10px; border: none; background: none; border-radius: 6px; font-weight: 600; font-size: 0.85rem; color: #64748b; cursor: pointer; transition: 0.2s; }
            .modal-tab-btn.active-tab { background: white; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
            .filter-container { display: flex; justify-content: space-between; align-items: center; gap: 15px; margin-bottom: 20px; background: white; padding: 15px; border-radius: 12px; border: 1px solid #e2e8f0; }
            .search-box { position: relative; flex: 1; }
            .search-box input { width: 100%; padding: 10px 15px 10px 40px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; }
            .search-box i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #94a3b8; }
            .filter-select { padding: 10px 15px; border: 1px solid #cbd5e1; border-radius: 8px; color: #334155; font-size: 0.9rem; background: white; }
            .btn-export { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; padding: 10px 15px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; display: flex; align-items: center; gap: 6px; }
            .btn-export:hover { background: #e2e8f0; }
            .pagination-container { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 15px; border-top: 1px solid #e2e8f0; }
            .pagination-buttons { display: flex; gap: 5px; }
            .page-btn { padding: 8px 14px; border: 1px solid #cbd5e1; background: white; border-radius: 6px; color: #334155; text-decoration: none; font-size: 0.85rem; font-weight: 500; cursor: pointer; }
            .page-btn.active { background: #0284c7; color: white; border-color: #0284c7; }
            .page-btn.disabled { color: #cbd5e1; border-color: #f1f5f9; cursor: not-allowed; pointer-events: none; }
            .variant-list-container { margin-top: 8px; display: flex; flex-direction: column; gap: 4px; }
            .variant-row-item { font-size: 0.8rem; background: #f8fafc; border: 1px solid #e2e8f0; padding: 4px 10px; border-radius: 6px; color: #475569; display: flex; align-items: center; justify-content: space-between; width: 100%; max-width: 320px; }
        </style>
    </head>
    <body>

        <!-- SIDEBAR NAVIGATION -->
        <div class="sidebar">
            <div class="logo">Inveniqo</div>
            <a href="DashboardServlet" class="nav-item"><i class="fas fa-th-large"></i> Dashboard</a>
            <a href="AnalyticsServlet" class="nav-item"><i class="fas fa-brain" style="color: #a855f7;"></i> Analytics & AI Prediction</a>

            <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
            <div class="nav-group-label">Administration</div>
            <a href="ManageCompanyServlet" class="nav-item"><i class="fas fa-building"></i> Manage Company</a>
            <% } %>

            <div class="nav-group-label">Inventory</div>
            <a href="InventoryServlet" class="nav-item active"><i class="fas fa-boxes"></i> Stock Control</a>
            <a href="DirectInvoiceServlet" class="nav-item"><i class="fas fa-file-invoice-dollar"></i> Direct Invoice</a>

            <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
            <div class="nav-group-label">Finance & Reports</div>
            <a href="FinanceServlet" class="nav-item"><i class="fas fa-chart-pie"></i> Financial Stats</a>
            <% } %>

            <a href="integration.jsp" class="nav-item"><i class="fas fa-network-wired"></i> API Integration</a>

            <div style="margin-top: auto;">
                <a href="LogoutServlet" class="nav-item" style="color: #fb7185;"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>

        <div class="main-content">
            <div class="header">
                <%
                    String errorMsg = (String) session.getAttribute("errorMessage");
                    if (errorMsg != null) {
                %>
                <div id="errorAlert" style="background: #fee2e2; color: #991b1b; padding: 15px; border-radius: 10px; border: 1px solid #fecaca; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; width: 100%;">
                    <span><i class="fas fa-exclamation-circle"></i> <%= errorMsg%></span>
                    <button onclick="this.parentElement.style.display = 'none'" style="background:none; border:none; color:#991b1b; cursor:pointer;">&times;</button>
                </div>
                <%
                        session.removeAttribute("errorMessage");
                    }
                %>
                <div>
                    <h1 style="font-size: 1.5rem; color: #1e293b;">Inventory Stock Control</h1>
                    <p style="color: #64748b; font-size: 0.9rem;">Branch: <strong><%= loggedUser.getBranchName()%></strong></p>
                </div>
                <% if (loggedUser.isAdmin() || loggedUser.isManager() || loggedUser.isStaff()) { %>
                <button onclick="document.getElementById('addProductModal').style.display = 'flex'" class="btn-add">
                    <i class="fas fa-plus"></i> Add New Product
                </button>
                <% } %>
            </div>

            <div style="display: flex; gap: 20px; margin-top: 15px; border-bottom: 1px solid #e2e8f0;">
                <a href="InventoryServlet" style="padding: 10px 0; color: #0284c7; border-bottom: 2px solid #0284c7; text-decoration: none; font-weight: 600;">Active Stocks</a>
                <a href="PendingProductServlet" style="padding: 10px 0; color: #64748b; text-decoration: none;">Pending Approval</a>
                <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
                <a href="StockHistoryServlet" style="padding: 10px 0; color: #64748b; text-decoration: none;">Stock History</a>
                <% } %>
            </div>
            
            <form action="InventoryServlet" method="GET" class="filter-container">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" name="search" placeholder="Search products by name or SKU..." value="<%= searchVal %>">
                </div>
                
                <select name="status" class="filter-select" onchange="this.form.submit()">
                    <option value="">All Statuses</option>
                    <option value="In Stock" <%= statusVal.equals("In Stock")?"selected":"" %>>In Stock</option>
                    <option value="Low Stock" <%= statusVal.equals("Low Stock")?"selected":"" %>>Low Stock</option>
                    <option value="Out of Stock" <%= statusVal.equals("Out of Stock")?"selected":"" %>>Out of Stock</option>
                    <option value="Active" <%= statusVal.equals("Active")?"selected":"" %>>Status: Active</option>
                    <option value="Pending" <%= statusVal.equals("Pending")?"selected":"" %>>Status: Pending</option>
                </select>

                <select name="categoryID" class="filter-select" onchange="this.form.submit()">
                    <option value="0">All Categories</option>
                    <% if (catList != null) {
                        for (Category c : catList) { %>
                            <option value="<%= c.getCategoryID() %>" <%= (selectedCat == c.getCategoryID())?"selected":"" %>><%= c.getCategoryName() %></option>
                    <%  }
                       } %>
                </select>
                
                <button type="button" onclick="exportInventory('excel')" class="btn-export"><i class="fas fa-file-excel" style="color: #16a34a;"></i> Excel</button>
                <button type="button" onclick="exportInventory('pdf')" class="btn-export"><i class="fas fa-file-pdf" style="color: #dc2626;"></i> PDF</button>
            </form>

            <!-- MODAL: ADD PRODUCT -->
            <div id="addProductModal" class="modal-overlay">
                <div class="modal-content">
                    <h2 style="margin-bottom:5px; color:#0f172a;"><i class="fas fa-plus-circle" style="color:#0284c7;"></i> Add New Product</h2>
                    <p style="color:#64748b; font-size:0.85rem; margin-bottom:20px;">Register the new product information in the system.</p>

                    <form id="addProductForm" action="AddProductServlet" method="POST" enctype="multipart/form-data" onsubmit="return validateProductForm('add')">
                        <div style="display: flex; gap: 15px; align-items: center; background: #f8fafc; padding: 12px; border-radius: 12px; margin-bottom: 15px; border: 1px solid #e2e8f0;">
                            <div style="text-align: center;">
                                <img id="imgPreview" src="uploads/product/defaultproduct.png" class="prod-img-preview">
                            </div>
                            <div style="flex: 1;">
                                <label style="display:block; margin-bottom:5px; font-size:0.8rem; font-weight:600; color:#475569;">Product Image</label>
                                <input type="file" name="productImage" onchange="previewImg(this)" accept="image/*" style="font-size: 0.8rem; width:100%;">
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Product Name</label>
                            <input type="text" name="productName" class="form-control" placeholder="E.g. Wireless Mouse" required>
                        </div>

                        <div style="display:flex; gap:12px;">
                            <div class="form-group" style="flex:1;">
                                <label>SKU / Barcode</label>
                                <input type="text" name="sku" class="form-control" placeholder="ITEM-001" required>
                            </div>
                            <div class="form-group" style="flex:1;">
                                <label>Category</label>
                                <div style="display: flex; gap: 6px;">
                                    <select name="categoryID" id="categorySelect" class="form-control" style="flex: 1;">
                                        <% if (catList != null) {
                                                for (Category c : catList) {%>
                                        <option value="<%= c.getCategoryID()%>"><%= c.getCategoryName()%></option>
                                        <% }
                                            } %>
                                    </select>
                                    <button type="button" onclick="addNewCategory()" class="btn-add" style="padding: 0 12px; background: #64748b;" title="Add Category">
                                        <i class="fas fa-plus"></i>
                                    </button>
                                    <button type="button" onclick="deleteSelectedCategory()" class="btn-add" style="padding: 0 12px; background: #ef4444;" title="Delete Selected Category">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Description</label>
                            <textarea name="description" class="form-control" rows="2" placeholder="Product details or specifications..."></textarea>
                        </div>

                        <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
                        <div style="display:flex; gap:12px;">
                            <div class="form-group" style="flex:1;">
                                <label>Cost Price (RM)</label>
                                <input type="number" step="0.01" name="costPrice" class="form-control" placeholder="0.00" required>
                            </div>
                            <div class="form-group" style="flex:1;">
                                <label>Selling Price (RM)</label>
                                <input type="number" step="0.01" name="sellingPrice" class="form-control" placeholder="0.00" required>
                            </div>
                        </div>
                        <% } else { %>
                        <input type="hidden" name="costPrice" value="0.00">
                        <input type="hidden" name="sellingPrice" value="0.00">
                        <% } %>

                        <div class="form-group">
                            <label>Low Stock Threshold</label>
                            <input type="number" name="lowStockThreshold" class="form-control" value="10" min="1">
                        </div>

                        <input type="hidden" name="hasVariants" id="addHasVariants" value="false">
                        <div style="margin-top: 20px; border-top: 1px dashed #cbd5e1; padding-top: 15px; margin-bottom: 15px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                                <label style="font-size: 0.85rem; font-weight: 600; color: #475569;"><i class="fas fa-tags" style="color:#0284c7;"></i> Product Variants</label>
                                <button type="button" class="btn-add" style="padding: 4px 10px; font-size: 0.75rem; background: #64748b; height: auto;" onclick="addVariantRow('add')">
                                    <i class="fas fa-plus"></i> Add Variant
                                </button>
                            </div>
                            <div id="addVariantsContainer"></div>
                        </div>

                        <div style="display:flex; gap:10px; margin-top:25px;">
                            <button type="submit" class="btn-add" style="flex:1; background:#0284c7; justify-content:center;">Save Product</button>
                            <button type="button" onclick="closeAndResetModal('addProductModal', 'addProductForm', 'addVariantsContainer', 'addHasVariants')" style="flex:1; background:#f1f5f9; border-radius:8px; border:none; cursor:pointer; color:#334155;">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- MODAL: EDIT PRODUCT -->
            <div id="editProductModal" class="modal-overlay">
                <div class="modal-content">
                    <h2 style="margin-bottom:5px; color:#0f172a;"><i class="fas fa-edit" style="color:#475569;"></i> Edit Product Details</h2>
                    <p style="color:#64748b; font-size:0.85rem; margin-bottom:20px;">Update product metadata and variants info.</p>

                    <form id="editProductForm" action="UpdateProductServlet" method="POST" onsubmit="return validateProductForm('edit')">
                        <input type="hidden" name="productID" id="editProductID">

                        <div class="form-group">
                            <label>Product Name</label>
                            <input type="text" name="productName" id="editProductName" class="form-control" required>
                        </div>

                        <div style="display:flex; gap:12px;">
                            <div class="form-group" style="flex:1;">
                                <label>SKU / Barcode</label>
                                <input type="text" name="sku" id="editSku" class="form-control" required>
                            </div>
                            <div class="form-group" style="flex:1;">
                                <label>Category</label>
                                <select name="categoryID" id="editCategorySelect" class="form-control" style="flex: 1;">
                                    <% if (catList != null) {
                                            for (Category c : catList) {%>
                                    <option value="<%= c.getCategoryID()%>"><%= c.getCategoryName()%></option>
                                    <% }
                                        } %>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Description</label>
                            <textarea name="description" id="editDescription" class="form-control" rows="2"></textarea>
                        </div>

                        <div class="form-group">
                            <label>Low Stock Threshold</label>
                            <input type="number" name="lowStockThreshold" id="editThreshold" class="form-control" min="1">
                        </div>

                        <div style="display:flex; gap:12px; padding:15px; background:#f8fafc; border-radius:12px; border:1px solid #e2e8f0; margin-bottom:15px;">
                            <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
                            <div class="form-group" style="flex:1; margin-bottom:0;">
                                <label>Cost Price (RM)</label>
                                <input type="number" step="0.01" name="costPrice" id="editCostPrice" class="form-control">
                            </div>
                            <div class="form-group" style="flex:1; margin-bottom:0;">
                                <label>Selling Price (RM)</label>
                                <input type="number" step="0.01" name="sellingPrice" id="editSellingPrice" class="form-control">
                            </div>
                            <% } else { %>
                            <div class="form-group" style="flex:1; margin-bottom:0;">
                                <label>Cost Price (RM)</label>
                                <input type="text" value="••••••" class="form-control" readonly style="background:#e2e8f0; color:#94a3b8; font-weight:bold; letter-spacing:2px; border:1px dashed #cbd5e1; text-align:center;">
                                <input type="hidden" name="costPrice" value="0.0">
                            </div>
                            <div class="form-group" style="flex:1; margin-bottom:0;">
                                <label>Selling Price (RM)</label>
                                <input type="number" step="0.01" name="sellingPrice" id="editSellingPrice" class="form-control" readonly style="background:#e2e8f0; color:#64748b;">
                            </div>
                            <% } %>
                        </div>

                        <input type="hidden" name="hasVariants" id="editHasVariants" value="false">
                        <div style="margin-top: 20px; border-top: 1px dashed #cbd5e1; padding-top: 15px; margin-bottom: 15px;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
                                <label style="font-size: 0.85rem; font-weight: 600; color: #475569;"><i class="fas fa-tags" style="color:#475569;"></i> Product Variants</label>
                                <button type="button" class="btn-add" style="padding: 4px 10px; font-size: 0.75rem; background: #64748b; height: auto;" onclick="addVariantRow('edit')">
                                    <i class="fas fa-plus"></i> Add Variant
                                </button>
                            </div>
                            <div id="editVariantsContainer"></div>
                        </div>

                        <div style="display:flex; gap:10px; margin-top:25px;">
                            <button type="submit" class="btn-add" style="flex:1; background:#16a34a; justify-content:center;">Update Changes</button>
                            <button type="button" onclick="closeAndResetModal('editProductModal', 'editProductForm', 'editVariantsContainer', 'editHasVariants')" style="flex:1; background:#f1f5f9; border:none; border-radius:8px; cursor:pointer; color:#334155;">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- MODAL: MANAGE STOCK (IN/OUT BERPUSAT & IKUT VARIASI) -->
            <div id="manageStockModal" class="modal-overlay">
                <div class="modal-content">
                    <h2 style="margin-bottom:5px; color:#0f172a;"><i class="fas fa-boxes"></i> Manage Inventory Stock</h2>
                    <p style="color:#64748b; font-size:0.85rem; margin-bottom:20px;">Product: <strong id="lblProdName" style="color:#0f172a;">-</strong> (<span id="lblProdSku">-</span>)</p>

                    <div class="modal-tabs">
                        <button type="button" id="tabIn" class="modal-tab-btn active-tab" onclick="switchStockTab('in')"><i class="fas fa-plus-circle"></i> Stock In</button>
                        <button type="button" id="tabOut" class="modal-tab-btn" onclick="switchStockTab('out')"><i class="fas fa-minus-circle"></i> Stock Out</button>
                    </div>

                    <form id="stockTransactionForm" action="StockInServlet" method="POST" enctype="multipart/form-data" onsubmit="return validateStockForm()">
                        <input type="hidden" name="productID" id="txtProductID">
                        <input type="hidden" id="txtTransactionType" value="in">

                        <div class="form-group">
                            <label>Current Branch Total Stock</label>
                            <input type="text" id="txtCurrentQty" class="form-control" style="background:#f1f5f9; font-weight:bold; color:#0f172a;" readonly>
                        </div>

                        <div class="form-group" id="variantSelectorGroup" style="display:none;">
                            <label>*Select Variant to Adjust</label>
                            <select name="variantSku" id="optVariantSku" class="form-control" onchange="updateSelectedVariantStock()"></select>
                        </div>

                        <div class="form-group">
                            <label id="lblQtyInput">*Quantity to Add (Stock In)</label>
                            <input type="number" name="quantity" id="txtAmount" class="form-control" placeholder="Enter number of units" min="1" required>
                        </div>

                        <div class="form-group" id="groupReasonIn">
                            <label>*Reason for Stock In</label>
                            <select name="reason" id="optReasonIn" class="form-control" required>
                                <option value="" disabled selected>-- Reason for restock --</option>
                                <option value="Supply Restock">Supply Restock</option>
                                <option value="Customer Return">Customer Return</option>
                                <option value="Inventory Adjustment">Inventory Adjustment</option>
                            </select>
                        </div>

                        <div class="form-group" id="groupReasonOut" style="display:none;">
                            <label>*Reason for Stock Out</label>
                            <select name="reason" id="optReasonOut" class="form-control">
                                <option value="" disabled selected>-- Reason for stock out --</option>
                                <option value="Damaged">Damaged</option>
                                <option value="Expired">Expired</option>
                                <option value="Theft/Missing">Theft / Missing</option>
                                <option value="Internal Usage">Internal Usage</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Remarks / Notes</label>
                            <textarea name="remarks" id="txtRemarks" class="form-control" rows="2" placeholder="Notes or reference number..." required></textarea>
                        </div>

                        <div class="form-group">
                            <label id="lblInvoiceInput">*Upload Proof Document (PDF/Images)</label>
                            <input type="file" name="evidenceFile" class="form-control" accept="image/*,application/pdf" style="font-size: 0.8rem;" required>
                        </div>

                        <div style="display:flex; gap:10px; margin-top:25px;">
                            <button type="submit" id="btnSubmitTransaction" class="btn-add" style="flex:1; background:#16a34a; justify-content:center;">Confirm Stock In</button>
                            <button type="button" onclick="closeManageStockModal()" style="flex:1; background:#f1f5f9; border:none; border-radius:8px; cursor:pointer; color:#334155;">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- TABEL SENARAI STOK UTAMA -->
            <div class="section-card">
                <table>
                    <thead>
                        <tr>
                            <th>Product Info</th>
                            <th>Category</th>
                            <% if (loggedUser.isAdmin() || loggedUser.isManager()) { %>
                            <th>Cost Price</th>
                            <% } %>
                            <th>Selling Price</th>
                            <th>Total Stock</th>
                            <th>Status</th>
                            <th style="text-align: right; width: 180px;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (inventoryList != null && !inventoryList.isEmpty()) {
                                ProductVariantDAO pvDAO = new ProductVariantDAO();
                                for (Product p : inventoryList) {
                                    String statusClass = p.getStockStatus().replace(" ", "").toLowerCase();
                                    String imgPath = (p.getProductImage() != null && !p.getProductImage().isEmpty()) ? p.getProductImage() : "uploads/product/defaultproduct.png";
                                    
                                    // FIX: Menghantar loggedUser.getBranchID() bersama untuk mematuhi pengasingan multi-branch Langkah 3
                                    List<ProductVariant> variantList = pvDAO.getVariantsByProductID(p.getProductID(), loggedUser.getBranchID());

                                    StringBuilder jsonSb = new StringBuilder("[");
                                    if (variantList != null) {
                                        for (int idx = 0; idx < variantList.size(); idx++) {
                                            ProductVariant v = variantList.get(idx);
                                            if (idx > 0) jsonSb.append(",");
                                            jsonSb.append(String.format("{\"size\":\"%s\",\"color\":\"%s\",\"variantSku\":\"%s\",\"stockQty\":%d,\"imagePath\":\"%s\"}",
                                                v.getSize() != null ? v.getSize().replace("\\", "\\\\\\\\").replace("\"", "\\\"") : "",
                                                v.getColor() != null ? v.getColor().replace("\\", "\\\\\\\\").replace("\"", "\\\"") : "",
                                                v.getVariantSku() != null ? v.getVariantSku().replace("\\", "\\\\\\\\").replace("\"", "\\\"") : "",
                                                v.getStockQty(),
                                                v.getImagePath() != null ? v.getImagePath().replace("\\", "\\\\\\\\").replace("\"", "\\\"") : ""
                                            ));
                                        }
                                    }
                                    jsonSb.append("]");
                                    String variantsJson = jsonSb.toString().replace("\"", "&quot;");
                         %>
                        <tr>
                            <td>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <img src="<%= imgPath%>" class="table-prod-img" alt="product">
                                    <div>
                                        <strong><%= p.getProductName()%></strong><br>
                                        <small style="color: #94a3b8;">SKU: <%= p.getSku()%></small>
                                        
                                        <% if (variantList != null && !variantList.isEmpty()) { %>
                                        <div class="variant-list-container">
                                            <% for (ProductVariant v : variantList) { 
                                                String varImgHtml = "";
                                                if (v.getImagePath() != null && !v.getImagePath().isEmpty()) {
                                                    varImgHtml = String.format("<img src=\"%s\" style=\"width: 16px; height: 16px; border-radius: 4px; object-fit: cover; margin-right: 4px; vertical-align: middle;\" alt=\"variant\">", v.getImagePath());
                                                }
                                            %>
                                            <div class="variant-row-item">
                                                <span>
                                                    <%= varImgHtml %>
                                                    <i class="fas fa-tag" style="font-size: 0.65rem; color: #94a3b8; margin-right: 4px;"></i>
                                                    <%= (v.getSize() != null && !v.getSize().isEmpty()) ? v.getSize() : "-" %> / 
                                                    <%= (v.getColor() != null && !v.getColor().isEmpty()) ? v.getColor() : "-" %>
                                                </span>
                                                <span style="font-weight: 600; color: #0284c7;">Qty: <%= v.getStockQty() %></span>
                                            </div>
                                            <% } %>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>
                            </td>
                            <td><%= p.getCategoryName()%></td>
                            <% if (loggedUser.isAdmin() || loggedUser.isManager()) {%>
                            <td>RM <%= String.format("%.2f", p.getCostPrice())%></td>
                            <% }%>
                            <td>RM <%= String.format("%.2f", p.getSellingPrice())%></td>
                            <td style="font-weight: 700; font-size: 1rem;"><%= p.getCurrentStock()%></td>
                            <td><span class="badge status-<%= statusClass%>"><%= p.getStockStatus()%></span></td>
                            <td style="text-align: right;">
                                <div style="display: flex; gap: 6px; justify-content: flex-end; align-items: center;">

                                    <button type="button" class="btn-manage-stock"
                                            data-id="<%= p.getProductID()%>"
                                            data-name="<%= p.getProductName().replace("'", "\\'")%>"
                                            data-sku="<%= p.getSku()%>"
                                            data-qty-total="<%= p.getCurrentStock()%>"
                                            data-variants="<%= variantsJson%>"
                                            onclick="openManageStockModal(this)">
                                        <i class="fas fa-boxes"></i> Manage
                                    </button>

                                    <button type="button" class="btn-edit-trigger"
                                            data-id="<%= p.getProductID()%>"
                                            data-name="<%= p.getProductName() != null ? p.getProductName().replace("\"", "&quot;").replace("'", "\\'") : ""%>"
                                            data-sku="<%= p.getSku() != null ? p.getSku() : ""%>"
                                            data-category="<%= p.getCategoryID()%>"
                                            data-description="<%= p.getDescription() != null ? p.getDescription().replace("\"", "&quot;").replace("\n", " ").replace("\r", " ").replace("'", "\\'") : ""%>"
                                            data-threshold="<%= p.getLowStockThreshold()%>"
                                            data-cost="<%= p.getCostPrice()%>"
                                            data-sell="<%= p.getSellingPrice()%>"
                                            data-variants="<%= variantsJson%>"
                                            onclick="openEditModal(this)"
                                            style="background: #f1f5f9; border: none; padding: 8px; border-radius: 6px; color: #334155; cursor: pointer; height: 32px; display: inline-flex; align-items: center;">
                                        <i class="fas fa-edit"></i>
                                    </button>

                                    <% if (loggedUser.isAdmin() || loggedUser.isManager()) {%>
                                    <button type="button" onclick="confirmDelete('<%= p.getProductID()%>')" 
                                            style="background: #fee2e2; border: none; padding: 8px; border-radius: 6px; color: #991b1b; cursor: pointer; height: 32px; display: inline-flex; align-items: center;">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% }
                        } else { %>
                        <tr><td colspan="7" style="text-align: center; color: #94a3b8; padding: 40px;">No products found.</td></tr>
                        <% }%>
                    </tbody>
                </table>

                <div class="pagination-container">
                    <div style="font-size: 0.85rem; color: #64748b;">
                        Showing page <strong><%= currentPage%></strong> of <strong><%= totalPages%></strong>
                    </div>
                    <div class="pagination-buttons">
                        <a href="InventoryServlet?page=<%= currentPage - 1%>&search=<%= searchVal%>&status=<%= statusVal%>&categoryID=<%= selectedCat%>" class="page-btn <%= (currentPage == 1) ? "disabled" : ""%>">
                            <i class="fas fa-chevron-left"></i> Previous
                        </a>
                        <%
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, startPage + 4);
                            for (int i = startPage; i <= endPage; i++) {
                        %>
                        <a href="InventoryServlet?page=<%= i%>&search=<%= searchVal%>&status=<%= statusVal%>&categoryID=<%= selectedCat%>" class="page-btn <%= (currentPage == i) ? "active" : ""%>">
                            <%= i%>
                        </a>
                        <% }%>
                        <a href="InventoryServlet?page=<%= currentPage + 1%>&search=<%= searchVal%>&status=<%= statusVal%>&categoryID=<%= selectedCat%>" class="page-btn <%= (currentPage == totalPages) ? "disabled" : ""%>">
                            Next <i class="fas fa-chevron-right"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function previewImg(input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        document.getElementById('imgPreview').src = e.target.result;
                    }
                    reader.readAsDataURL(input.files[0]);
                }
            }

            function addNewCategory() {
                const catName = prompt("Enter new category name:");
                if (catName && catName.trim() !== "") {
                    fetch('AddCategoryServlet?name=' + encodeURIComponent(catName), {method: 'POST'})
                            .then(response => response.json())
                            .then(data => {
                                if (data.success) {
                                    const select = document.getElementById('categorySelect');
                                    select.add(new Option(catName, data.newID));
                                    select.value = data.newID;
                                    alert("Category added!");
                                }
                            });
                }
            }

            function openEditModal(buttonElement) {
                document.getElementById('editProductID').value = buttonElement.dataset.id || '';
                document.getElementById('editProductName').value = buttonElement.dataset.name || '';
                document.getElementById('editSku').value = buttonElement.dataset.sku || '';
                document.getElementById('editThreshold').value = buttonElement.dataset.threshold || '';
                document.getElementById('editDescription').value = buttonElement.dataset.description || '';

                const categorySelect = document.getElementById('editCategorySelect');
                const categoryValue = String(buttonElement.dataset.category).trim();
                for (let i = 0; i < categorySelect.options.length; i++) {
                    if (categorySelect.options[i].value.trim() === categoryValue) {
                        categorySelect.selectedIndex = i;
                        break;
                    }
                }

                if (document.getElementById('editCostPrice')) document.getElementById('editCostPrice').value = buttonElement.dataset.cost || '0.00';
                if (document.getElementById('editSellingPrice')) document.getElementById('editSellingPrice').value = buttonElement.dataset.sell || '0.00';

                document.getElementById('editVariantsContainer').innerHTML = '';
                document.getElementById('editHasVariants').value = 'false';
                try {
                    const variants = JSON.parse(buttonElement.dataset.variants || '[]');
                    if (variants && variants.length > 0) {
                        variants.forEach(v => {
                            addVariantRow('edit', v.size, v.color, v.variantSku, v.stockQty, v.imagePath || '');
                        });
                    }
                } catch (e) {
                    console.error("Error parsing variants JSON: ", e);
                }
                document.getElementById('editProductModal').style.display = 'flex';
            }

            function addVariantRow(type, size = '', color = '', sku = '', qty = 0, imagePath = '') {
                const container = document.getElementById(type + 'VariantsContainer');
                const hasVariantsInput = document.getElementById(type + 'HasVariants');
                
                if (!container) {
                    console.error("Ralat: Kontainer " + type + "VariantsContainer tidak ditemui!");
                    return;
                }
                
                hasVariantsInput.value = 'true';
                
                const rowId = 'var_row_' + type + '_' + Date.now() + '_' + Math.floor(Math.random() * 1000);
                const rowDiv = document.createElement('div');
                rowDiv.id = rowId;
                rowDiv.className = 'variant-row';
                rowDiv.style = 'display: flex; gap: 8px; align-items: center; margin-bottom: 8px;';
                
                let qtyInputHtml = ``;
                if (type === 'add') {
                    qtyInputHtml = `<input type="hidden" name="variantQty[]" class="var-qty-input" value="0">`;
                } else {
                    qtyInputHtml = `<input type="number" name="variantQty[]" class="form-control var-qty-input" style="flex:1; padding: 6px 8px; font-size: 0.8rem;" placeholder="Qty" value="${qty}" min="0" oninput="updateInitialStockSum('${type}')">`;
                }

                rowDiv.innerHTML = `
                    <input type="text" name="variantSize[]" class="form-control" style="flex:1; padding: 6px 8px; font-size: 0.8rem;" placeholder="Size" value="${size}">
                    <input type="text" name="variantColor[]" class="form-control" style="flex:1; padding: 6px 8px; font-size: 0.8rem;" placeholder="Color" value="${color}">
                    <input type="text" name="variantSku[]" class="form-control" style="flex:1.5; padding: 6px 8px; font-size: 0.8rem;" placeholder="Variant SKU" value="${sku}" required>
                    ${qtyInputHtml}
                    <input type="text" name="variantImagePath[]" class="form-control" style="flex:1.5; padding: 6px 8px; font-size: 0.8rem;" placeholder="Image Path" value="${imagePath}">
                    <button type="button" onclick="removeVariantRow('${type}', '${rowId}')" class="btn-remove-variant" style="background: #fee2e2; color: #ef4444; border: none; padding: 6px 10px; border-radius: 6px; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; height: 32px;">
                        <i class="fas fa-trash"></i>
                    </button>
                `;
                container.appendChild(rowDiv);
                updateInitialStockSum(type);
            }

            function removeVariantRow(type, rowId) {
                const row = document.getElementById(rowId);
                if (row) {
                    row.remove();
                } else {
                    console.error("Ralat: Baris " + rowId + " tidak ditemui untuk dipadam.");
                }

                const container = document.getElementById(type + 'VariantsContainer');
                const hasVariantsInput = document.getElementById(type + 'HasVariants');
                
                if (container && container.children.length === 0) {
                    hasVariantsInput.value = 'false';
                }
                updateInitialStockSum(type);
            }

            function updateInitialStockSum(type) {
                const container = document.getElementById(type + 'VariantsContainer');
                if (!container) return;
                const qtyInputs = container.querySelectorAll('.var-qty-input');
                let totalQty = 0;
                qtyInputs.forEach(input => { totalQty += parseInt(input.value) || 0; });
                
                if (type === 'add') {
                    const initialStockInput = document.getElementById('addInitialStock');
                    if (initialStockInput) {
                        if (qtyInputs.length > 0) {
                            initialStockInput.value = totalQty;
                            initialStockInput.readOnly = true;
                            initialStockInput.style.background = '#f1f5f9';
                        } else {
                            initialStockInput.readOnly = false;
                            initialStockInput.style.background = '#ffffff';
                        }
                    }
                }
            }

            function validateProductForm(type) {
                return true;
            }

            function closeAndResetModal(modalId, formId, containerId, hasVariantsId) {
                const modal = document.getElementById(modalId);
                if (modal) modal.style.display = 'none';
                
                const form = document.getElementById(formId);
                if (form) form.reset();
                
                const container = document.getElementById(containerId);
                if (container) container.innerHTML = '';
                
                const hasVariants = document.getElementById(hasVariantsId);
                if (hasVariants) hasVariants.value = 'false';

                if (formId === 'addProductForm') {
                    const imgPreview = document.getElementById('imgPreview');
                    if (imgPreview) imgPreview.src = 'uploads/product/defaultproduct.png';
                }
            }

            function deleteSelectedCategory() {
                const select = document.getElementById('categorySelect');
                const categoryID = select.value;
                const categoryName = select.options[select.selectedIndex].text;
                if (!categoryID) {
                    alert("Please select a category to delete.");
                    return;
                }
                if (confirm(`Are you sure you want to delete the category "${categoryName}"? This will fail if any active products are mapped to it.`)) {
                    fetch('DeleteCategoryServlet?categoryID=' + categoryID, { method: 'POST' })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                select.remove(select.selectedIndex);
                                alert("Category deleted successfully.");
                            } else {
                                alert("❌ Error: " + data.message);
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            alert("Failed to delete category due to network or server error.");
                        });
                }
            }

            function confirmDelete(id) {
                if (confirm("Are you sure you want to delete this product?")) {
                    window.location.href = "DeleteProductServlet?id=" + id;
                }
            }

            let currentProductStockRaw = 0;
            let activeProductVariants = [];

            function openManageStockModal(buttonElement) {
                const id = buttonElement.getAttribute('data-id');
                const name = buttonElement.getAttribute('data-name');
                const sku = buttonElement.getAttribute('data-sku');
                currentProductStockRaw = parseInt(buttonElement.getAttribute('data-qty-total')) || 0;

                document.getElementById('txtProductID').value = id || '';
                document.getElementById('lblProdName').innerText = name || '';
                document.getElementById('lblProdSku').innerText = sku || '';
                document.getElementById('txtCurrentQty').value = currentProductStockRaw + " Units";

                const selectVariant = document.getElementById('optVariantSku');
                const variantGroup = document.getElementById('variantSelectorGroup');
                selectVariant.innerHTML = '';
                
                try {
                    activeProductVariants = JSON.parse(buttonElement.getAttribute('data-variants') || '[]');
                    if (activeProductVariants && activeProductVariants.length > 0) {
                        variantGroup.style.display = 'block';
                        activeProductVariants.forEach(v => {
                            let label = (v.size ? "Size: " + v.size : "") + " " + (v.color ? "Color: " + v.color : "") + " (" + v.variantSku + ")";
                            let option = new Option(label, v.variantSku);
                            selectVariant.add(option);
                        });
                        updateSelectedVariantStock();
                    } else {
                        variantGroup.style.display = 'none';
                    }
                } catch(e) {
                    variantGroup.style.display = 'none';
                }

                document.getElementById('txtAmount').value = '';
                document.getElementById('txtRemarks').value = '';
                switchStockTab('in');
                document.getElementById('manageStockModal').style.display = 'flex';
            }

            function updateSelectedVariantStock() {
                const selectedSku = document.getElementById('optVariantSku').value;
                const match = activeProductVariants.find(v => v.variantSku === selectedSku);
                if (match) {
                    document.getElementById('txtCurrentQty').value = match.stockQty + " Units (Variant Total)";
                }
            }

            function switchStockTab(type) {
                const typeHidden = document.getElementById('txtTransactionType');
                const formElement = document.getElementById('stockTransactionForm');
                const groupReasonIn = document.getElementById('groupReasonIn');
                const groupReasonOut = document.getElementById('groupReasonOut');
                const optReasonIn = document.getElementById('optReasonIn');
                const optReasonOut = document.getElementById('optReasonOut');
                const lblQtyInput = document.getElementById('lblQtyInput');
                const btnSubmit = document.getElementById('btnSubmitTransaction');

                typeHidden.value = type;

                if (type === 'in') {
                    document.getElementById('tabIn').classList.add('active-tab');
                    document.getElementById('tabOut').classList.remove('active-tab');
                    formElement.action = "StockInServlet";
                    groupReasonIn.style.display = 'block';
                    groupReasonOut.style.display = 'none';
                    optReasonIn.required = true;
                    optReasonOut.required = false;
                    lblQtyInput.innerText = "*Quantity to Add (Stock In)";
                    btnSubmit.innerText = "Confirm Stock In";
                    btnSubmit.style.background = "#16a34a";
                } else {
                    document.getElementById('tabOut').classList.add('active-tab');
                    document.getElementById('tabIn').classList.remove('active-tab');
                    formElement.action = "StockOutServlet";
                    groupReasonIn.style.display = 'none';
                    groupReasonOut.style.display = 'block';
                    optReasonIn.required = false;
                    optReasonOut.required = true;
                    lblQtyInput.innerText = "*Quantity to Deduct (Stock Out)";
                    btnSubmit.innerText = "Confirm Stock Out";
                    btnSubmit.style.background = "#e11d48";
                }
                
                if (activeProductVariants && activeProductVariants.length > 0) {
                    updateSelectedVariantStock();
                } else {
                    document.getElementById('txtCurrentQty').value = currentProductStockRaw + " Units";
                }
            }

            function validateStockForm() {
                const type = document.getElementById('txtTransactionType').value;
                const amt = parseInt(document.getElementById('txtAmount').value) || 0;
                
                let limitStock = currentProductStockRaw;
                if (activeProductVariants && activeProductVariants.length > 0) {
                    const selectedSku = document.getElementById('optVariantSku').value;
                    const match = activeProductVariants.find(v => v.variantSku === selectedSku);
                    if (match) limitStock = match.stockQty;
                }

                if (type === 'out' && amt > limitStock) {
                    alert("❌ Sekatan Sistem: Kuantiti pembuangan 'Stock Out' tidak boleh melebihi baki simpanan fizikal semasa!");
                    return false;
                }

                const fileInput = document.querySelector("#stockTransactionForm input[name='evidenceFile']");
                if (!fileInput || fileInput.files.length === 0) {
                    alert("❌ Validation Error: Transaction proof document (evidence file) is mandatory!");
                    return false;
                }

                return true;
            }

            function closeManageStockModal() {
                document.getElementById('manageStockModal').style.display = 'none';
            }

            function exportInventory(type) {
                const search = document.querySelector("input[name='search']").value;
                const status = document.querySelector("select[name='status']").value;
                const categoryID = document.querySelector("select[name='categoryID']").value;
                window.location.href = "ExportInventoryServlet?type=" + type + "&search=" + encodeURIComponent(search) + "&status=" + encodeURIComponent(status) + "&categoryID=" + categoryID;
            }
        </script>
    </body>
</html>