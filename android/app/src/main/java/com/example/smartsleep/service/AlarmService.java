package com.example.smartsleep.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.example.smartsleep.AlarmActivity;
import com.example.smartsleep.R;
import com.example.smartsleep.db.Database;
import com.example.smartsleep.model.NativeAlarms;
import com.example.smartsleep.recievers.AlarmReceiver;
import com.example.smartsleep.recievers.AlarmSound;
import com.example.smartsleep.recievers.AlarmWakeLock;

import static android.app.NotificationManager.IMPORTANCE_HIGH;
import static android.os.Build.VERSION.SDK_INT;
import static com.example.smartsleep.service.AlarmScheduler.EXTRA_ID;
import static com.example.smartsleep.service.AlarmScheduler.SNOOZE_COUNT;

public class AlarmService extends Service {

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);

        AlarmWakeLock.acquireCpuWakeLock(this);
        int snooze_count = intent.getIntExtra(SNOOZE_COUNT, -1);

        NativeAlarms alarm = Database.getDatabase(this).alarmDao().get(intent.getIntExtra(EXTRA_ID, -1));

        final NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        this.createNotificationChannel(notificationManager);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat
                .Builder(this, "ALARM CHANNEL")
                .setDefaults(NotificationCompat.DEFAULT_LIGHTS)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setSmallIcon(R.drawable.ic_alarm_black_18dp)
                .setAutoCancel(false)
                .setLocalOnly(true)
                .setWhen(0)
                .setOngoing(true);

        notificationBuilder.addAction(R.drawable.ic_alarm_off_24px, "Dismiss", getDismiss(alarm.alarmId));
        notificationBuilder.addAction(R.drawable.ic_snooze_24px, "Snooze", getSnooze(alarm.alarmId,snooze_count));
        Intent fullscreenIntent = new Intent(this, AlarmActivity.class);
        fullscreenIntent.setAction("fullscreen_activity");
        fullscreenIntent.putExtra(EXTRA_ID, alarm.alarmId);
        fullscreenIntent.putExtra(SNOOZE_COUNT, snooze_count);
        fullscreenIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_NO_USER_ACTION);

        notificationBuilder.setFullScreenIntent(
                PendingIntent.getActivity(this, alarm.alarmId, fullscreenIntent, PendingIntent.FLAG_UPDATE_CURRENT)
                , true
        );

        if (alarm.isDifferentTime) {
            notificationBuilder.setContentTitle(alarm.differentTime);
        } else {
            notificationBuilder.setContentTitle(alarm.time);
        }
        AlarmSound.getInstance().playAlarmSound(this);
        startForeground(alarm.alarmId, notificationBuilder.build());


        return Service.START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(this.getClass().getSimpleName(), "Service Destroy Called");
        AlarmWakeLock.releaseCpuLock();
        AlarmSound.getInstance().stopAlarmSound();
        stopForeground(true);
        stopSelf();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void createNotificationChannel(NotificationManager notificationManager) {
        if (SDK_INT >= Build.VERSION_CODES.O) {
            final NotificationChannel channel = new NotificationChannel("ALARM CHANNEL", "Alarms", IMPORTANCE_HIGH);
            channel.setBypassDnd(true);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private PendingIntent getDismiss(int id) {
        Intent intent = new Intent(this, AlarmReceiver.class);
        intent.setAction("ALARM_DISMISS");
        intent.putExtra(EXTRA_ID, id);
        intent.putExtra(SNOOZE_COUNT, 0);
        return PendingIntent.getBroadcast(this, id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    private PendingIntent getSnooze(int id,int count) {
        Intent intent = new Intent(this, AlarmReceiver.class);
        intent.setAction("ALARM_SNOOZE");
        intent.putExtra(EXTRA_ID, id);
        intent.putExtra(SNOOZE_COUNT, count);
        return PendingIntent.getBroadcast(this, id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

}
