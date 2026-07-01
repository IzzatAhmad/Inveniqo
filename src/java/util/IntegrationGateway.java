package util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class IntegrationGateway {

    /**
     * Mengambil baki stok fizikal terkini daripada product_branch
     * dan menolaknya (sync) ke kedai atas talian Shopee, TikTok Shop, & Lazada.
     */
    public static void syncStockToMarketplaces(String productID, String branchID) {
        int currentStock = 0;
        
        // 1. Tarik kuantiti stok fizikal cawangan yang paling sah dari DB
        String sql = "SELECT quantity FROM product_branch WHERE productID = ? AND branchID = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, productID);
            ps.setString(2, branchID);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentStock = rs.getInt("quantity");
                }
            }
            
            // 2. Cetak log audit sistem ke konsol server sebagai penanda jejak
            System.out.println("[INTEGRATION GATEWAY] Memulakan sinkronisasi automatik untuk Product ID: " + productID);
            System.out.println("[INTEGRATION GATEWAY] Baki Stok Semasa Cawangan " + branchID + ": " + currentStock + " unit.");

            // 3. Jalankan simulasi hantaran API Payload JSON ke platform luar
            simulateApiCall("Shopee My API", productID, currentStock);
            simulateApiCall("TikTok Shop API", productID, currentStock);
            simulateApiCall("Lazada Open API", productID, currentStock);

        } catch (Exception e) {
            System.err.println("[INTEGRATION ERROR] Gagal menyelaraskan stok ke marketplace: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Fungsi simulasi HTTP Webhook/REST API Request ke Cloud Server Marketplace.
     */
    private static void simulateApiCall(String platform, String productID, int stock) {
        try {
            // Dalam sistem pengeluaran (production), URL ini diganti dengan endpoint rasmi platform
            // Contoh: https://api.shopee.com.my/v2/product/update_stock
            URL url = new URL("https://httpbin.org/post"); 
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setRequestProperty("Accept", "application/json");
            conn.setDoOutput(true);

            // Membina Payload JSON tegar mengikut dokumentasi Open API Malaysia Marketplace
            String jsonPayload = String.format(
                "{\"item_id\":\"%s\",\"update_stock\":%d,\"timestamp\":%d,\"marketplace\":\"%s\"}",
                productID, stock, System.currentTimeMillis() / 1000, platform
            );

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            if (code == 200 || code == 201) {
                System.out.println(">> [API SUCCESS] Stok berjaya dikemas kini di " + platform + " (HTTP Code: " + code + ")");
            } else {
                System.err.println(">> [API FAILED] " + platform + " memulangkan ralat komunikasi HTTP Code: " + code);
            }
            conn.disconnect();

        } catch (Exception ex) {
            System.err.println(">> [API CRASH] Kegagalan sambungan rangkaian ke " + platform + ": " + ex.getMessage());
        }
    }
}