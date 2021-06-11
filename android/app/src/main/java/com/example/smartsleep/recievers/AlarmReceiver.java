package com.example.smartsleep.recievers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.PowerManager;

import com.example.smartsleep.db.Database;
import com.example.smartsleep.model.NativeAlarms;
import com.example.smartsleep.service.AlarmScheduler;
import com.example.smartsleep.service.AlarmService;

import java.util.List;

import io.flutter.Log;

import static android.os.Build.VERSION.SDK_INT;
import static com.example.smartsleep.service.AlarmScheduler.EXTRA_ID;
import static com.example.smartsleep.service.AlarmScheduler.SNOOZE_COUNT;

public class AlarmReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {

        AlarmScheduler scheduler = new AlarmScheduler(context);

        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            List<NativeAlarms> alarms = Database.getDatabase(context).alarmDao().getAll();
            if (alarms.size() > 0) {
                for (NativeAlarms alarm : alarms) {
                    scheduler.scheduleAlarm(alarm);
                }
            }
            return;
        }

        int id = intent.getIntExtra(EXTRA_ID, -1);
        int snooze_count = intent.getIntExtra(SNOOZE_COUNT, -1);

        NativeAlarms alarm = Database.getDatabase(context).alarmDao().get(id);

        Intent service = new Intent(context, AlarmService.class);
        service.setAction(intent.getAction());
        service.putExtra(EXTRA_ID, id);
        service.putExtra(SNOOZE_COUNT, snooze_count);

        Log.i(this.getClass().getSimpleName(), "Snooze " + snooze_count + ", Action " + intent.getAction() + " id " + id);

        if (id != -1) {

            switch (intent.getAction()) {
                case "ALARM_RING":

                    PowerManager.WakeLock wakeLock = AlarmWakeLock.createPartialWakeLock(context);
                    wakeLock.acquire(10 * 60 * 1000L /*10 minutes*/);

                    if (SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(service);
                    } else {
                        context.startService(service);
                    }
                    wakeLock.release();

                    break;

                case "ALARM_SNOOZE":
                    context.stopService(service);
                    if (snooze_count < 3) {
                        scheduler.scheduleSnooze(alarm, snooze_count);
                    }
                    if(snooze_count==3){
                        scheduler.scheduleAlarm(alarm);
                    }
                    break;
                case "ALARM_DISMISS":
                    context.stopService(service);
                    scheduler.scheduleAlarm(alarm);
                    break;
            }
        }
    }
}
