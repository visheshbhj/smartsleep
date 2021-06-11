package com.example.smartsleep.model;

import java.util.List;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Alarm {

    @SerializedName("trackerAlarms")
    @Expose
    public List<NativeAlarms> nativeAlarms = null;

}