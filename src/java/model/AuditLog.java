/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

public class AuditLog {
    private int logID;
    private String userID;
    private String username;
    private String action;
    private String details;
    private String ipAddress;
    private Timestamp timestamp;

    // Constructor Kosong
    public AuditLog() {}

    // Getter dan Setter yang betul
    public int getLogID() { 
        return logID; 
    }
    public void setLogID(int logID) { 
        this.logID = logID; 
    }

    public String getUserID() { 
        return userID; 
    }
    public void setUserID(String userID) { 
        this.userID = userID; 
    }

    public String getUsername() { 
        return username; 
    }
    public void setUsername(String username) { 
        this.username = username; 
    }

    public String getAction() { 
        return action; 
    }
    public void setAction(String action) { 
        this.action = action; 
    }

    public String getDetails() { 
        return details; 
    }
    public void setDetails(String details) { 
        this.details = details; 
    }

    public String getIpAddress() { 
        return ipAddress; 
    }
    public void setIpAddress(String ipAddress) { 
        this.ipAddress = ipAddress; 
    }

    public Timestamp getTimestamp() { 
        return timestamp; 
    }
    public void setTimestamp(Timestamp timestamp) { 
        this.timestamp = timestamp; 
    }
}