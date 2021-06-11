package com.example.smartsleep.model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;

import io.flutter.Log;
import lombok.Data;

@Entity(tableName = "alarms")
@Data
public class NativeAlarms {

    @ColumnInfo(name = "alarmId")
    @SerializedName("alarmId")
    @PrimaryKey
    @Expose
    public Integer alarmId;
    @SerializedName("deleted")
    @Expose
    public Boolean deleted;
    @SerializedName("enabled")
    @Expose
    public Boolean enabled;
    @ColumnInfo(name = "recurring")
    @SerializedName("recurring")
    @Expose
    public Boolean recurring;
    @SerializedName("snoozeCount")
    @Expose
    public Integer snoozeCount;
    @SerializedName("snoozeLength")
    @Expose
    public Integer snoozeLength;
    @SerializedName("syncedToDevice")
    @Expose
    public Boolean syncedToDevice;
    @ColumnInfo(name = "time")
    @SerializedName("time")
    @Expose
    public String time;
    @SerializedName("vibe")
    @Expose
    public String vibe;
    @ColumnInfo(name = "weekDays")
    @SerializedName("weekDays")
    @Expose
    public ArrayList<String> weekDays;

    /**
     * Custom Data
     */
    @ColumnInfo(name = "deviceId")
    @SerializedName("deviceId")
    @Expose
    public String deviceId;
    @ColumnInfo(name = "isSynced")
    @SerializedName("isSynced")
    @Expose
    public Boolean isSynced;

    @ColumnInfo(name = "differentTime")
    @SerializedName("differentTime")
    @Expose
    public String differentTime;
    @ColumnInfo(name = "isDifferentTime")
    @SerializedName("isDifferentTime")
    @Expose
    public Boolean isDifferentTime;

}