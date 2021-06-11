package com.example.smartsleep.model;

import java.util.List;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Device {

    @SerializedName("battery")
    @Expose
    public String battery;
    @SerializedName("batteryLevel")
    @Expose
    public Integer batteryLevel;
    @SerializedName("deviceVersion")
    @Expose
    public String deviceVersion;
    @SerializedName("features")
    @Expose
    public List<Object> features = null;
    @SerializedName("id")
    @Expose
    public String id;
    @SerializedName("lastSyncTime")
    @Expose
    public String lastSyncTime;
    @SerializedName("type")
    @Expose
    public String type;
    @SerializedName("mac")
    @Expose
    public String mac;

}