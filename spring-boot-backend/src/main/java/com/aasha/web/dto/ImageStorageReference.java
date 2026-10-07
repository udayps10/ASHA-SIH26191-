package com.aasha.web.dto;

import java.util.Map;

public class ImageStorageReference {
    private String provider;
    private String storageId;
    private String assetId;
    private String resourceType;
    private String deliveryType;
    private String accessType;
    private String contentType;
    private int sizeBytes;

    public ImageStorageReference() {}

    public ImageStorageReference(String provider, String storageId, String assetId,
                                  String resourceType, String deliveryType, String accessType,
                                  String contentType, int sizeBytes) {
        this.provider = provider;
        this.storageId = storageId;
        this.assetId = assetId;
        this.resourceType = resourceType;
        this.deliveryType = deliveryType;
        this.accessType = accessType;
        this.contentType = contentType;
        this.sizeBytes = sizeBytes;
    }

    public Map<String, Object> toJson() {
        return Map.of(
            "provider", provider,
            "storageId", storageId,
            "assetId", assetId,
            "resourceType", resourceType,
            "deliveryType", deliveryType,
            "accessType", accessType,
            "contentType", contentType,
            "sizeBytes", sizeBytes
        );
    }

    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getStorageId() { return storageId; }
    public void setStorageId(String storageId) { this.storageId = storageId; }
    public String getAssetId() { return assetId; }
    public void setAssetId(String assetId) { this.assetId = assetId; }
    public String getResourceType() { return resourceType; }
    public void setResourceType(String resourceType) { this.resourceType = resourceType; }
    public String getDeliveryType() { return deliveryType; }
    public void setDeliveryType(String deliveryType) { this.deliveryType = deliveryType; }
    public String getAccessType() { return accessType; }
    public void setAccessType(String accessType) { this.accessType = accessType; }
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    public int getSizeBytes() { return sizeBytes; }
    public void setSizeBytes(int sizeBytes) { this.sizeBytes = sizeBytes; }
}
