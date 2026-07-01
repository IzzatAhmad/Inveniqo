package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;

public class DBConnection {

    private static boolean migrated = false;

    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Read from environment variables — Docker sets DB_HOST=db; local dev defaults to localhost
        String host = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost";
        String port = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "3306";
        String name = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "inveniqo";
        String user = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
        String pass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "";

        String url = "jdbc:mysql://" + host + ":" + port + "/" + name
                   + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

        Connection conn = DriverManager.getConnection(url, user, pass);

        
        if (!migrated) {
            try {
                DatabaseMetaData meta = conn.getMetaData();
                try (ResultSet rs = meta.getColumns(null, null, "product_variants", "imagePath")) {
                    if (!rs.next()) {
                        try (Statement stmt = conn.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE product_variants ADD COLUMN imagePath VARCHAR(255) NULL");
                        }
                    }
                }
                // Self-healing table creation for ai_predictions
                try (Statement stmt = conn.createStatement()) {
                    stmt.executeUpdate(
                        "CREATE TABLE IF NOT EXISTS ai_predictions (" +
                        "predictionID INT AUTO_INCREMENT PRIMARY KEY, " +
                        "branchID VARCHAR(255) NOT NULL, " +
                        "productID VARCHAR(255) NOT NULL, " +
                        "sku VARCHAR(255) NOT NULL, " +
                        "stockCurrent INT NOT NULL, " +
                        "dailyVelocity DOUBLE NOT NULL, " +
                        "daysLeft INT NOT NULL, " +
                        "recommendedQty INT NOT NULL, " +
                        "statusAction VARCHAR(255) NOT NULL, " +
                        "badgeColor VARCHAR(50) NOT NULL, " +
                        "status VARCHAR(50) DEFAULT 'Pending', " +
                        "computedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
                    );
                }
                // Self-healing table creation for security_logs
                try (Statement stmt = conn.createStatement()) {
                    stmt.executeUpdate(
                        "CREATE TABLE IF NOT EXISTS security_logs (" +
                        "logID INT AUTO_INCREMENT PRIMARY KEY, " +
                        "userID VARCHAR(255) NOT NULL, " +
                        "action VARCHAR(255) NOT NULL, " +
                        "ipAddress VARCHAR(255) NULL, " +
                        "logDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
                    );
                }
                migrated = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        return conn;
    }
}

