# ── Stage 1: Build (Maven/Ant not needed – WAR already compiled) ──────────────
# Deploy the pre-compiled WAR directly into Tomcat 9 + JDK 21
# Following the smart_campus pattern: tomcat:9-jdk21 base image
FROM tomcat:9-jdk21

# Remove Tomcat's default sample webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the compiled WAR as ROOT.war so the app is served at http://host/
COPY dist/Inveniqo.war /usr/local/tomcat/webapps/ROOT.war

# Add MySQL JDBC driver (MariaDB-compatible) to Tomcat's lib directory
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar \
    /usr/local/tomcat/lib/mysql-connector-j.jar

# Expose Tomcat's default HTTP port
EXPOSE 8080

# Tomcat starts automatically via the base image CMD
