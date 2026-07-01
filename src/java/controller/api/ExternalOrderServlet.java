/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.api;

import dao.ExternalIntegrationDAO;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/api/external/order")
public class ExternalOrderServlet extends HttpServlet {

    // Simulasi Token Keselamatan (API Key) untuk integrasi luar
    private static final String API_KEY_SECRET = "INVENIQO_SECURE_TOKEN_2026";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 1. Kawalan Keselamatan: Semak pengepala X-API-Key
        String clientApiKey = request.getHeader("X-API-Key");
        if (clientApiKey == null || !clientApiKey.equals(API_KEY_SECRET)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"error\",\"message\":\"Ralat Keselamatan: Kunci API tidak sah!\"}");
            return;
        }

        // 2. Baca Payload JSON daripada Request Body
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
        }

        String jsonRaw = jsonBuffer.toString();

        try {
            // Pengekstrakan String JSON secara manual/regex
            String productID = extractJsonValue(jsonRaw, "productID");
            if (productID.isEmpty()) productID = extractJsonValue(jsonRaw, "item_id");
            if (productID.isEmpty()) productID = extractJsonValue(jsonRaw, "product_id");
            if (productID.isEmpty()) productID = extractJsonValue(jsonRaw, "item_code");

            String branchID = extractJsonValue(jsonRaw, "branchID");
            if (branchID.isEmpty()) branchID = extractJsonValue(jsonRaw, "branch_id");
            if (branchID.isEmpty()) branchID = extractJsonValue(jsonRaw, "warehouse_id");
            if (branchID.isEmpty()) branchID = extractJsonValue(jsonRaw, "location_id");

            // FIX: Menangkap Variant SKU daripada payload luar untuk menjaga integriti stok variasi cawangan
            String variantSku = extractJsonValue(jsonRaw, "variantSku");
            if (variantSku.isEmpty()) variantSku = extractJsonValue(jsonRaw, "variant_sku");
            if (variantSku.isEmpty()) variantSku = extractJsonValue(jsonRaw, "sku");

            String qtyStr = extractJsonValue(jsonRaw, "quantity");
            int qty = qtyStr.isEmpty() ? 0 : Integer.parseInt(qtyStr);

            if (productID.isEmpty() || branchID.isEmpty() || qty <= 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"status\":\"error\",\"message\":\"Data parameter tidak lengkap atau kuantiti tidak sah.\"}");
                return;
            }

            // 3. Hubungi DAO untuk pemrosesan stok automatik
            ExternalIntegrationDAO integrationDAO = new ExternalIntegrationDAO();
            
            // Kita draf proses pemotongan stok berpusat yang turut menyokong kewujudan variantSku
            boolean success = integrationDAO.deductStockFromExternal(productID, branchID, variantSku, qty);

            if (success) {
                // FIX: SINKRONISASI PASARAN BERIKUTNYA (Mencegah Overselling Cross-Platform)
                // Sebaik sahaja stok cawangan dipotong oleh jualan Shopee, hantar baki terkini ke TikTok & Lazada!
                util.IntegrationGateway.syncStockToMarketplaces(productID, branchID);

                response.setStatus(HttpServletResponse.SC_OK);
                out.print("{\"status\":\"success\",\"message\":\"Stok berjaya dikemas kini daripada tempahan stor luar!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print("{\"status\":\"error\",\"message\":\"Gagal mengemas kini stok. Baki fizikal tidak mencukupi.\"}");
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"status\":\"error\",\"message\":\"Ralat dalaman sistem semasa memproses API: " + e.getMessage() + "\"}");
        }
    }

    // Helper method ringkas untuk parsing JSON secara native
    private String extractJsonValue(String json, String key) {
        try {
            String pattern = "\"" + key + "\"\\s*:\\s*\"?([^,\"}]+)\"?";
            java.util.regex.Pattern r = java.util.regex.Pattern.compile(pattern);
            java.util.regex.Matcher m = r.matcher(json);
            if (m.find()) {
                return m.group(1).trim();
            }
        } catch (Exception e) {
            return "";
        }
        return "";
    }
}