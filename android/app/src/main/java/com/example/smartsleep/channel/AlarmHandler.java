package com.example.smartsleep.channel;

import android.content.Context;

import androidx.annotation.NonNull;

import com.example.smartsleep.db.Database;
import com.example.smartsleep.model.NativeAlarms;
import com.example.smartsleep.service.AlarmScheduler;
import com.google.gson.Gson;

import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AlarmHandler implements MethodChannel.MethodCallHandler {

    MethodChannel channel;
    Context context;
    Database database;
    Gson gson;
    AlarmScheduler alarmScheduler;

    public AlarmHandler(MethodChannel channel,Context context, Database database) {
        this.channel = channel;
        this.context = context;
        this.database = database;
        this.gson = new Gson();
        this.channel.setMethodCallHandler(this);
        alarmScheduler = new AlarmScheduler(this.context);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        NativeAlarms alarm;
        switch (call.method){
            case "getAll":
                List<NativeAlarms> alarmsList = database.alarmDao().getAll();
                result.success(alarmsList.size()==0 ? "[]" : gson.toJson(alarmsList));
                break;
            case "get":
                try{
                    result.success(gson.toJson(database.alarmDao().get(Integer.parseInt(call.arguments.toString()))));
                }catch (Exception e){
                    result.success("NOT_FOUND");
                }
                break;
            case "insert"://Also creates alarms here
                alarm = gson.fromJson(call.arguments.toString(), NativeAlarms.class);
                database.alarmDao().insert(alarm);
                alarmScheduler.scheduleAlarm(alarm);
                break;
            case "update"://Update alarms here
                alarm = gson.fromJson(call.arguments.toString(), NativeAlarms.class);
                database.alarmDao().update(alarm);
                alarmScheduler.scheduleAlarm(alarm);
                break;
            case "delete"://remove alarm
                alarm = gson.fromJson(call.arguments.toString(), NativeAlarms.class);
                database.alarmDao().delete(alarm);
                alarmScheduler.cancelAlarm(alarm);
                break;
            case "deleteById"://remove alarm
                database.alarmDao().deleteById(Integer.parseInt(call.arguments.toString()));
                break;
            case "deleteAll"://remove alarm
                database.alarmDao().deleteAll();
                break;
        }
    }
}
