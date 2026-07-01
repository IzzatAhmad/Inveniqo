<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.User" %>
<%@ page import="model.Product" %>
<%@ page import="model.ProductVariant" %>
<%@ page import="model.Category" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String branchLabel = (loggedUser.getBranchName() != null) ? loggedUser.getBranchName() : "No Branch Assigned";
    List<Product> products = (List<Product>) request.getAttribute("branchProductList");
    List<Category> categories = (List<Category>) request.getAttribute("categoryList");
    Map<String, List<ProductVariant>> variantsMap = (Map<String, List<ProductVariant>>) request.getAttribute("productVariantsMap");

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
        <title>Direct Invoice | Inveniqo</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
            body { background-color: #f8fafc; display: flex; color: #1e293b; }
            
            /* SIDEBAR styling */
            .sidebar { width: 260px; background: #0f172a; height: 100vh; color: white; padding: 25px 20px; position: fixed; display: flex; flex-direction: column; z-index: 100; }
            .logo { font-size: 1.7rem; font-weight: 800; color: #38bdf8; margin-bottom: 40px; letter-spacing: -1px; }
            .nav-group-label { font-size: 0.7rem; color: #64748b; text-transform: uppercase; letter-spacing: 1px; margin: 20px 0 10px 10px; font-weight: 700; }
            .nav-item { padding: 12px 15px; display: flex; align-items: center; color: #94a3b8; text-decoration: none; border-radius: 10px; margin-bottom: 4px; transition: 0.2s; font-size: 0.9rem; }
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
            
            /* POS LAYOUT */
            .pos-container { display: flex; gap: 25px; align-items: flex-start; }
            
            /* LEFT PANE: PRODUCT PICKER */
            .product-pane { flex: 1.5; background: white; padding: 25px; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
            
            /* CATEGORY TABS */
            .tabs-container { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 20px; border-bottom: 2px solid #f1f5f9; padding-bottom: 12px; }
            .tab-btn { background: #f1f5f9; border: none; padding: 8px 16px; border-radius: 8px; font-weight: 600; color: #475569; cursor: pointer; transition: 0.2s; font-size: 0.85rem; }
            .tab-btn.active { background: #0284c7; color: white; }
            .tab-btn:hover:not(.active) { background: #cbd5e1; }
            
            /* SELECT ALL CONTROL */
            .select-all-container { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 10px 15px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
            .select-all-label { display: flex; align-items: center; gap: 10px; font-size: 0.9rem; font-weight: 600; color: #334155; cursor: pointer; }
            .select-all-checkbox { width: 18px; height: 18px; cursor: pointer; accent-color: #0284c7; }
            
            /* PRODUCT GRID/LIST */
            .product-list-scroller { max-height: calc(100vh - 350px); overflow-y: auto; scrollbar-width: thin; padding-right: 5px; }
            
            /* Variant sub-rows UI layout */
            .product-group-container { border: 1px solid #e2e8f0; border-radius: 12px; margin-bottom: 15px; overflow: hidden; background: #fff; }
            .product-parent-header { background: #f8fafc; padding: 12px 16px; font-size: 0.95rem; font-weight: 700; color: #0f172a; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
            .product-parent-badge { font-size: 0.75rem; background: #e0f2fe; color: #0369a1; padding: 2px 8px; border-radius: 9999px; font-weight: 600; }
            
            .product-item-row { display: flex; align-items: center; gap: 15px; padding: 12px 20px; cursor: pointer; transition: 0.2s; border-bottom: 1px solid #f1f5f9; }
            .product-item-row:last-child { border-bottom: none; }
            .product-item-row:hover { background: #f0f9ff; }
            
            .item-thumb { width: 44px; height: 44px; border-radius: 8px; object-fit: cover; border: 1px solid #e2e8f0; background: #f8fafc; }
            .item-details { flex: 1; display: flex; flex-direction: column; }
            .item-name { font-weight: 600; font-size: 0.9rem; color: #0f172a; }
            .item-sku { font-size: 0.75rem; color: #94a3b8; margin-top: 2px; }
            .item-meta { display: flex; align-items: center; gap: 20px; text-align: right; }
            .item-price { font-weight: 700; font-size: 0.95rem; color: #0284c7; min-width: 80px; }
            .item-stock { font-size: 0.8rem; font-weight: 600; padding: 4px 10px; border-radius: 6px; background: #f1f5f9; color: #475569; min-width: 80px; text-align: center; }
            
            .product-item-row.out-of-stock { opacity: 0.6; background: #fafafa; cursor: not-allowed; }
            .product-item-row.out-of-stock .item-stock { background: #fee2e2; color: #ef4444; }
            .product-item-row.out-of-stock:hover { background: #fafafa; }

            /* RIGHT PANE: BILLING CART */
            .billing-pane { flex: 1; background: white; padding: 25px; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display: flex; flex-direction: column; height: calc(100vh - 180px); position: sticky; top: 40px; }
            .cart-title { font-size: 1.15rem; font-weight: 700; color: #0f172a; border-bottom: 2px solid #f1f5f9; padding-bottom: 12px; }
            .cart-items-container { flex: 1; overflow-y: auto; margin-top: 15px; border-bottom: 1px solid #e2e8f0; scrollbar-width: thin; }
            .empty-cart-text { text-align: center; color: #94a3b8; margin-top: 40px; font-size: 0.9rem; }
            
            .cart-row { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px dashed #f1f5f9; }
            .cart-item-info { flex: 1; padding-right: 10px; }
            .cart-item-name { font-size: 0.85rem; font-weight: 600; color: #0f172a; line-height: 1.3; }
            .cart-item-price { font-size: 0.8rem; color: #0284c7; font-weight: 600; margin-top: 3px; display: block; }
            .cart-controls { display: flex; align-items: center; gap: 8px; }
            .btn-qty { width: 26px; height: 26px; border-radius: 6px; border: none; background: #f1f5f9; font-weight: 700; color: #475569; cursor: pointer; transition: 0.2s; }
            .btn-qty:hover { background: #cbd5e1; }
            .qty-val { font-size: 0.85rem; font-weight: 700; width: 24px; text-align: center; }
            
            .btn-remove-item { border: none; background: #fee2e2; color: #ef4444; width: 26px; height: 26px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; margin-left: 5px; }
            .btn-remove-item:hover { background: #fecaca; }
            
            /* CHECKOUT pane */
            .checkout-pane { margin-top: 20px; }
            .summary-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 0.9rem; color: #475569; font-weight: 500; }
            .summary-row.grand-total { font-size: 1.3rem; font-weight: 700; color: #0f172a; border-top: 1px solid #e2e8f0; padding-top: 12px; margin-top: 10px; }
            .btn-issue { width: 100%; background: #16a34a; color: white; border: none; padding: 14px; border-radius: 10px; font-size: 1rem; font-weight: 600; margin-top: 15px; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 12px rgba(22, 163, 74, 0.2); }
            .btn-issue:hover { background: #15803d; }
            
            .alert-msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; font-weight: 500; }
            .alert-error { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
            .alert-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
            
            /* MODAL RECEIPT */
            .modal-receipt-overlay { display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(15, 23, 42, 0.6); align-items: center; justify-content: center; backdrop-filter: blur(4px); }
            .modal-receipt-content { background-color: white; border-radius: 16px; width: 80%; max-width: 700px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); overflow: hidden; display: flex; flex-direction: column; animation: modalFadeIn 0.3s ease; }
            @keyframes modalFadeIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
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
            <a href="DirectInvoiceServlet" class="nav-item active">
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

        <!-- MAIN WINDOW -->
        <div class="main-content">
            <div class="header">
                <div class="welcome-msg">
                    <h1>Direct Invoice</h1>
                    <p>Issue instant offline prepaid invoices | Cawangan: <strong><%= branchLabel %></strong></p>
                </div>

                <div class="user-profile">
                    <img src="<%= headerProfileImg %>" alt="Profile">
                    <div class="info">
                        <strong><%= loggedUser.getUserName() %></strong>
                        <span><%= String.join(" | ", loggedUser.getRoles()) %></span>
                    </div>
                </div>
            </div>

            <!-- FEEDBACK MESSAGES -->
            <%
                String status = request.getParameter("status");
                String receiptID = request.getParameter("receipt");
                if ("success".equals(status) && receiptID != null) {
            %>
                <div class="alert-msg alert-success">
                    <i class="fas fa-check-circle"></i> Direct Sales Invoice generated successfully!
                    Invoice ID: <a href="#" id="receiptLink" data-receipt="<%= receiptID %>" style="color: #15803d; font-weight: 700; text-decoration: underline; cursor: pointer;"><%= receiptID %></a>.
                </div>
            <% } %>
            
            <% if (request.getParameter("error") != null) { %>
                <div class="alert-msg alert-error">
                    <i class="fas fa-exclamation-triangle"></i> Failed to process invoice: <%= request.getParameter("msg") != null ? request.getParameter("msg") : "Invalid inputs or database error." %>
                </div>
            <% } %>

            <!-- POS GRID SYSTEM -->
            <div class="pos-container">
                
                <!-- LEFT SIDE: SELECT PRODUCT / VARIANTS -->
                <div class="product-pane">
                    
                    <!-- CATEGORIES TABS -->
                    <div class="tabs-container">
                        <button type="button" class="tab-btn active" onclick="switchCategory('ALL')">All Products</button>
                        <% if (categories != null) {
                            for (Category cat : categories) { %>
                            <button type="button" class="tab-btn" onclick="switchCategory('<%= cat.getCategoryID() %>')">
                                <%= cat.getCategoryName() %>
                            </button>
                        <% }
                        } %>
                    </div>

                    <!-- SELECT ALL IN CATEGORY CHECKBOX -->
                    <div class="select-all-container" id="selectAllCategoryBar">
                        <label class="select-all-label">
                            <input type="checkbox" id="selectAllCategoryCheckbox" class="select-all-checkbox" onchange="toggleSelectAllCategory(this)">
                            <span>Select All Products in Category</span>
                        </label>
                    </div>

                    <!-- PRODUCT LIST SCROLLER -->
                    <div class="product-list-scroller" id="productGridContainer">
                        <% if (products != null && !products.isEmpty()) {
                            for (Product p : products) {
                                List<ProductVariant> vars = (variantsMap != null) ? variantsMap.get(p.getProductID()) : null;
                                boolean hasVars = (vars != null && !vars.isEmpty());
                                String pImage = (p.getProductImage() != null && !p.getProductImage().isEmpty()) ? p.getProductImage() : "uploads/product/defaultproduct.png";
                        %>
                            <% if (hasVars) { %>
                                <!-- Variants Group Layout Container -->
                                <div class="product-group-container" data-category="<%= p.getCategoryID() %>">
                                    <div class="product-parent-header">
                                        <span><%= p.getProductName() %></span>
                                        <span class="product-parent-badge">Variants Available</span>
                                    </div>
                                    <% for (ProductVariant v : vars) {
                                        String vLabel = p.getProductName() + " - " + v.getColor() + " / " + v.getSize();
                                        String vImg = (v.getImagePath() != null && !v.getImagePath().isEmpty()) ? v.getImagePath() : pImage;
                                    %>
                                        <div class="product-item-row <%= (v.getStockQty() <= 0) ? "out-of-stock" : "" %>" 
                                             data-category="<%= p.getCategoryID() %>"
                                             data-product-id="<%= p.getProductID() %>"
                                             data-variant-sku="<%= v.getVariantSku() %>"
                                             data-name="<%= vLabel %>"
                                             data-price="<%= p.getSellingPrice() %>"
                                             data-stock="<%= v.getStockQty() %>"
                                             onclick="handleItemClick(this)">
                                            <img src="<%= vImg %>" class="item-thumb" alt="variant">
                                            <div class="item-details">
                                                <span class="item-name"><%= vLabel %></span>
                                                <span class="item-sku">SKU: <%= v.getVariantSku() %></span>
                                            </div>
                                            <div class="item-meta">
                                                <span class="item-price">RM<%= String.format("%.2f", p.getSellingPrice()) %></span>
                                                <span class="item-stock"><%= v.getStockQty() %> units</span>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <!-- Single Product without variants -->
                                <div class="product-group-container" data-category="<%= p.getCategoryID() %>">
                                    <!-- FIX: Mengubah getQuantity() kepada getCurrentStock() selari dengan Model Class Langkah 2 -->
                                    <div class="product-item-row <%= (p.getCurrentStock() <= 0) ? "out-of-stock" : "" %>" 
                                         data-category="<%= p.getCategoryID() %>"
                                         data-product-id="<%= p.getProductID() %>"
                                         data-variant-sku=""
                                         data-name="<%= p.getProductName() %>"
                                         data-price="<%= p.getSellingPrice() %>"
                                         data-stock="<%= p.getCurrentStock() %>"
                                         onclick="handleItemClick(this)">
                                        <img src="<%= pImage %>" class="item-thumb" alt="product">
                                        <div class="item-details">
                                            <span class="item-name"><%= p.getProductName() %></span>
                                            <span class="item-sku">SKU: <%= p.getSku() %></span>
                                        </div>
                                        <div class="item-meta">
                                            <span class="item-price">RM<%= String.format("%.2f", p.getSellingPrice()) %></span>
                                            <span class="item-stock"><%= p.getCurrentStock() %> units</span>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        <% }
                        } else { %>
                            <p style="color:#94a3b8; text-align:center; padding:40px;">No active products in stock for this branch.</p>
                        <% } %>
                    </div>
                </div>

                <!-- RIGHT SIDE: BILLING CART -->
                <div class="billing-pane">
                    <h3 class="cart-title">Invoice Billing Cart</h3>
                    
                    <form action="DirectInvoiceServlet" method="POST" id="invoiceForm" onsubmit="return validateFormSubmit()">
                        <!-- Hidden inputs for mapping product cart properties -->
                        <div id="cartHiddenInputs"></div>

                        <div style="margin-top: 15px; margin-bottom: 15px;">
                            <label style="font-size: 0.85rem; font-weight: 600; color: #475569; display: block; margin-bottom: 5px;">Customer Name <span style="color:red;">*</span></label>
                            <input type="text" name="customerName" class="form-control" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 8px;" placeholder="e.g. Walk-in Customer" required>
                        </div>

                        <div class="cart-items-container" id="cartContainer">
                            <p class="empty-cart-text" id="emptyCartMessage">Your cart is empty. Click items to add.</p>
                        </div>

                        <div class="checkout-pane">
                            <div class="summary-row">
                                <span>Subtotal</span>
                                <span>RM <span id="txtSubtotal">0.00</span></span>
                            </div>
                            <div class="summary-row grand-total">
                                <span>Grand Total</span>
                                <span>RM <span id="txtGrandTotal">0.00</span></span>
                            </div>
                            
                            <button type="submit" class="btn-issue">
                                <i class="fas fa-check-circle"></i> Issue Prepaid Invoice
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </div>

        <!-- RECEIPT PREVIEW MODAL -->
        <div id="receiptModal" class="modal-receipt-overlay">
            <div class="modal-receipt-content">
                <div style="padding: 20px; background: #0f172a; color: white; display: flex; justify-content: space-between; align-items: center;">
                    <h3 style="margin: 0; font-size: 1.15rem; font-weight: 600;"><i class="fas fa-print"></i> Printable PDF Receipt</h3>
                    <span id="closeModal" style="font-size: 28px; font-weight: bold; cursor: pointer; color: #94a3b8;" onclick="closeReceiptModal()">&times;</span>
                </div>
                <div style="padding: 20px; flex-grow: 1; height: 500px; background: #f8fafc;">
                    <iframe id="receiptIframe" src="" style="width: 100%; height: 100%; border: none; border-radius: 8px; box-shadow: inset 0 2px 4px 0 rgba(0,0,0,0.06);"></iframe>
                </div>
                <div style="padding: 15px 20px; background: #f1f5f9; display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid #e2e8f0;">
                    <a id="downloadReceiptBtn" href="" download style="background: #0284c7; color: white; padding: 10px 18px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 0.9rem; display: inline-flex; align-items: center; gap: 8px;">
                        <i class="fas fa-download"></i> Download PDF
                    </a>
                    <button type="button" onclick="closeReceiptModal()" style="background: white; color: #475569; border: 1px solid #cbd5e1; padding: 10px 18px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer;">
                        Close
                    </button>
                </div>
            </div>
        </div>

        <script>
            let cart = [];
            let activeCategory = 'ALL';

            // Active items in the selected tab categories
            function switchCategory(catID) {
                activeCategory = catID;
                
                // Update tabs active state
                const tabButtons = document.querySelectorAll('.tab-btn');
                tabButtons.forEach(btn => {
                    btn.classList.remove('active');
                });
                event.target.classList.add('active');

                // Filter products list display
                const groups = document.querySelectorAll('.product-group-container');
                groups.forEach(g => {
                    const itemCat = g.getAttribute('data-category');
                    if (catID === 'ALL' || itemCat === catID) {
                        g.style.display = 'block';
                    } else {
                        g.style.display = 'none';
                    }
                });

                // Reset select all checkbox
                document.getElementById('selectAllCategoryCheckbox').checked = false;
                
                // Show/hide select all bar based on Category ID select
                const selectAllBar = document.getElementById('selectAllCategoryBar');
                if (catID === 'ALL') {
                    selectAllBar.style.display = 'none';
                } else {
                    selectAllBar.style.display = 'flex';
                }
            }

            // Initially hide Category Select All checkbox if ALL tab is active
            window.addEventListener('DOMContentLoaded', () => {
                document.getElementById('selectAllCategoryBar').style.display = 'none';
                
                // Setup PDF receipt modal events
                const modal = document.getElementById("receiptModal");
                const receiptLink = document.getElementById("receiptLink");
                const receiptIframe = document.getElementById("receiptIframe");
                const downloadBtn = document.getElementById("downloadReceiptBtn");

                if (receiptLink) {
                    receiptLink.addEventListener("click", function(e) {
                        e.preventDefault();
                        const receiptID = this.getAttribute("data-receipt");
                        const fileUrl = "receipts/" + receiptID + ".pdf";
                        receiptIframe.src = fileUrl;
                        downloadBtn.href = fileUrl;
                        modal.style.display = "flex";
                    });
                }
            });

            function closeReceiptModal() {
                document.getElementById("receiptModal").style.display = "none";
                document.getElementById("receiptIframe").src = "";
            }

            // Check if item card click event should push product or variant SKU
            function handleItemClick(element) {
                if (element.classList.contains('out-of-stock')) {
                    alert("❌ Out of stock! This variant has no stock units left.");
                    return;
                }
                const productID = element.getAttribute('data-product-id');
                const variantSku = element.getAttribute('data-variant-sku');
                const name = element.getAttribute('data-name');
                const price = parseFloat(element.getAttribute('data-price')) || 0;
                const stock = parseInt(element.getAttribute('data-stock')) || 0;

                addItemToCart(productID, variantSku, name, price, stock);
            }

            function addItemToCart(productID, variantSku, name, price, stock) {
                const uniqueKey = productID + "_" + variantSku;
                let existing = cart.find(item => item.key === uniqueKey);

                if (existing) {
                    if (existing.qty >= stock) {
                        alert("❌ Maximum branch stock limit (" + stock + " units) reached for this variant!");
                        return;
                    }
                    existing.qty++;
                } else {
                    cart.push({
                        key: uniqueKey,
                        productID: productID,
                        variantSku: variantSku,
                        name: name,
                        price: price,
                        qty: 1,
                        stock: stock
                    });
                }
                updateCartUI();
            }

            function updateCartUI() {
                const container = document.getElementById('cartContainer');
                const hiddenInputs = document.getElementById('cartHiddenInputs');
                
                container.innerHTML = '';
                hiddenInputs.innerHTML = '';

                if (cart.length === 0) {
                    container.innerHTML = '<p class="empty-cart-text" id="emptyCartMessage">Your cart is empty. Click items to add.</p>';
                    document.getElementById('txtSubtotal').innerText = '0.00';
                    document.getElementById('txtGrandTotal').innerText = '0.00';
                    return;
                }

                let total = 0;
                cart.forEach((item, index) => {
                    const rowSubtotal = item.price * item.qty;
                    total += rowSubtotal;

                    // Visible Cart row layout
                    const div = document.createElement('div');
                    div.className = 'cart-row';
                    div.innerHTML = `
                        <div class="cart-item-info">
                            <span class="cart-item-name">${item.name}</span>
                            <span class="cart-item-price">RM ${item.price.toFixed(2)}</span>
                        </div>
                        <div class="cart-controls">
                            <button type="button" class="btn-qty" onclick="changeQty('${item.key}', -1)">-</button>
                            <span class="qty-val">${item.qty}</span>
                            <button type="button" class="btn-qty" onclick="changeQty('${item.key}', 1)">+</button>
                            <button type="button" class="btn-remove-item" onclick="removeItem('${item.key}')">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    `;
                    container.appendChild(div);

                    // Form submission inputs parameters mapping
                    hiddenInputs.innerHTML += `
                        <input type="hidden" name="productID[]" value="${item.productID}">
                        <input type="hidden" name="variantSku[]" value="${item.variantSku}">
                        <input type="hidden" name="quantity[]" value="${item.qty}">
                        <input type="hidden" name="pricePerUnit[]" value="${item.price}">
                    `;
                });

                document.getElementById('txtSubtotal').innerText = total.toFixed(2);
                document.getElementById('txtGrandTotal').innerText = total.toFixed(2);
            }

            function changeQty(key, delta) {
                const item = cart.find(i => i.key === key);
                if (item) {
                    item.qty += delta;
                    if (item.qty > item.stock) {
                        alert("❌ Maximum branch stock limit (" + item.stock + " units) reached for this variant!");
                        item.qty = item.stock;
                    }
                    if (item.qty <= 0) {
                        removeItem(key);
                    } else {
                        updateCartUI();
                    }
                }
            }

            function removeItem(key) {
                cart = cart.filter(i => i.key !== key);
                updateCartUI();
            }

            // Select all active products inside the selected category tab
            function toggleSelectAllCategory(checkbox) {
                if (activeCategory === 'ALL') return;

                if (checkbox.checked) {
                    // Query all product row nodes that belong to the active category
                    const categoryRows = document.querySelectorAll(`.product-item-row[data-category='${activeCategory}']`);
                    let addedAny = false;
                    categoryRows.forEach(row => {
                        if (!row.classList.contains('out-of-stock')) {
                            const productID = row.getAttribute('data-product-id');
                            const variantSku = row.getAttribute('data-variant-sku');
                            const name = row.getAttribute('data-name');
                            const price = parseFloat(row.getAttribute('data-price')) || 0;
                            const stock = parseInt(row.getAttribute('data-stock')) || 0;

                            addItemToCart(productID, variantSku, name, price, stock);
                            addedAny = true;
                        }
                    });
                    if (!addedAny) {
                        alert("⚠️ No in-stock items found in this category to add.");
                        checkbox.checked = false;
                    }
                } else {
                    // Remove all items in the active category from the cart
                    cart = cart.filter(item => {
                        // Find matching row category ID
                        const itemRow = document.querySelector(`.product-item-row[data-product-id='${item.productID}'][data-variant-sku='${item.variantSku}']`);
                        if (itemRow) {
                            const itemCat = itemRow.getAttribute('data-category');
                            return itemCat !== activeCategory;
                        }
                        return true;
                    });
                    updateCartUI();
                }
            }

            function validateFormSubmit() {
                if (cart.length === 0) {
                    alert("❌ Billing error: Cart is empty! Please select at least one product or variant.");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
