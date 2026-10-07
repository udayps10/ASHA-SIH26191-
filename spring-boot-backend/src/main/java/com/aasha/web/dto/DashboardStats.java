package com.aasha.web.dto;

public class DashboardStats {
    private long totalNormalRecords;
    private long totalCriticalRecords;
    private long totalCamps;
    private long atCampCount;
    private long identifiedCount;
    private long unidentifiedCount;

    public long getTotalNormalRecords() { return totalNormalRecords; }
    public void setTotalNormalRecords(long totalNormalRecords) { this.totalNormalRecords = totalNormalRecords; }
    public long getTotalCriticalRecords() { return totalCriticalRecords; }
    public void setTotalCriticalRecords(long totalCriticalRecords) { this.totalCriticalRecords = totalCriticalRecords; }
    public long getTotalCamps() { return totalCamps; }
    public void setTotalCamps(long totalCamps) { this.totalCamps = totalCamps; }
    public long getAtCampCount() { return atCampCount; }
    public void setAtCampCount(long atCampCount) { this.atCampCount = atCampCount; }
    public long getIdentifiedCount() { return identifiedCount; }
    public void setIdentifiedCount(long identifiedCount) { this.identifiedCount = identifiedCount; }
    public long getUnidentifiedCount() { return unidentifiedCount; }
    public void setUnidentifiedCount(long unidentifiedCount) { this.unidentifiedCount = unidentifiedCount; }
}
