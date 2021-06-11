package com.example.smartsleep.service;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import com.example.smartsleep.model.NativeAlarms;
import com.example.smartsleep.recievers.AlarmReceiver;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import io.flutter.Log;

public class AlarmScheduler {

    AlarmManager alarmManager;
    Context context;

    public static final String EXTRA_ID = "extra_id";
    public static final String SNOOZE_COUNT = "extra_snooze_count";

    public static SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mmXXX");

    public AlarmScheduler(Context context) {
        this.context = context;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            this.alarmManager = context.getSystemService(AlarmManager.class);
        }else{
            this.alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        }
    }

    public void scheduleAlarm(NativeAlarms alarm){
        Log.d(this.getClass().getSimpleName(),"Starting Alarm Scheduler");

        Calendar current = Calendar.getInstance();
        Calendar currentAlarm;
        if(alarm.isDifferentTime){
            currentAlarm = getCalendarInstance(alarm.differentTime);
        }else {
            currentAlarm = getCalendarInstance(alarm.time);
        }

        if(alarm.recurring){
            int count = 0;
            List<Integer> weeks = getWeekInInt(alarm);
            while(count<7){
                if(weeks.contains(currentAlarm.get(Calendar.DAY_OF_WEEK)) && currentAlarm.after(current)){
                    break;
                }else{
                    currentAlarm.add(Calendar.DATE,1);
                    count++;
                }
            }
        }else{
            if (!currentAlarm.after(current)) {
                //Find Next Day & Set Alarm
                currentAlarm.add(Calendar.DATE,1);
            }
        }
        alarmManager.setAlarmClock(new AlarmManager.AlarmClockInfo(currentAlarm.getTimeInMillis(),getRingingAlarmPendingIntent(alarm.alarmId)),getRingingAlarmPendingIntent(alarm.alarmId));
        Log.d(this.getClass().getSimpleName(),"Alarm Scheduler End");
    }

    public void scheduleSnooze(NativeAlarms alarm,int snooze_count){
        Calendar currentAlarm;

        if(alarm.isDifferentTime){
            currentAlarm = getCalendarInstance(alarm.differentTime);
        }else {
            currentAlarm = getCalendarInstance(alarm.time);
        }
        ++snooze_count;
        currentAlarm.add(Calendar.MINUTE,10*snooze_count);
        /*alarmManager.setAlarmClock(
                new AlarmManager.AlarmClockInfo(currentAlarm.getTimeInMillis(),getSnoozeAlarmPendingIntent(alarm.alarmId,snooze_count))
                ,getSnoozeAlarmPendingIntent(alarm.alarmId,snooze_count)
        );*/
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP,currentAlarm.getTimeInMillis(),getSnoozeAlarmPendingIntent(alarm.alarmId,snooze_count));
        }else{
            alarmManager.setExact(AlarmManager.RTC_WAKEUP,currentAlarm.getTimeInMillis(),getSnoozeAlarmPendingIntent(alarm.alarmId,snooze_count));
        }
    }

    public List<Integer> getWeekInInt(NativeAlarms alarm){
        List<Integer> weekDays = new ArrayList<>();

        for(String day : alarm.weekDays){
            weekDays.add(weekMap.get(day.toUpperCase()));
        }
        return weekDays;
    }

    public void cancelAlarm(NativeAlarms alarm){
        Intent intent = new Intent(context, AlarmReceiver.class);
        intent.putExtra(EXTRA_ID, alarm.alarmId);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, alarm.alarmId, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        alarmManager.cancel(pendingIntent);
    }

    public PendingIntent getRingingAlarmPendingIntent(int alarmId){
        Intent intent = new Intent(context, AlarmReceiver.class);
        intent.setAction("ALARM_RING");
        intent.putExtra(EXTRA_ID, alarmId);
        intent.putExtra(SNOOZE_COUNT, 0);
        return PendingIntent.getBroadcast(context, alarmId, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    public PendingIntent getSnoozeAlarmPendingIntent(int alarmId,int count){
        Intent intent = new Intent(context, AlarmReceiver.class);
        intent.setAction("ALARM_RING");
        intent.putExtra(EXTRA_ID, alarmId);
        intent.putExtra(SNOOZE_COUNT, count);
        return PendingIntent.getBroadcast(context, alarmId, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    public Calendar getCalendarInstance(String time){
        Calendar calendar = Calendar.getInstance();
        Calendar current = Calendar.getInstance(Locale.getDefault());
        try {
            Date date = timeFormat.parse(time);
            current.setTime(date);
            current.set(calendar.get(Calendar.YEAR),calendar.get(Calendar.MONTH),calendar.get(Calendar.DATE));
            current.set(Calendar.SECOND,0);
            current.set(Calendar.MILLISECOND,0);
            return  current;
        } catch (ParseException e) {
            e.printStackTrace();
            return null;
        }
    }

    static HashMap<String,Integer> weekMap = new HashMap<>();

    static{
        weekMap.put("SUNDAY",Calendar.SUNDAY);
        weekMap.put("MONDAY",Calendar.MONDAY);
        weekMap.put("TUESDAY",Calendar.TUESDAY);
        weekMap.put("WEDNESDAY",Calendar.WEDNESDAY);
        weekMap.put("THURSDAY",Calendar.THURSDAY);
        weekMap.put("FRIDAY",Calendar.FRIDAY);
        weekMap.put("SATURDAY",Calendar.SATURDAY);
    }

}
