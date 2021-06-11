package com.example.smartsleep.recievers;

import android.content.Context;
import android.os.PowerManager;

public class AlarmWakeLock {
    private static PowerManager.WakeLock sCpuWakeLock;

    public static PowerManager.WakeLock createPartialWakeLock(Context context) {
        PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        return pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, AlarmWakeLock.class.getSimpleName());
    }
    public static void acquireCpuWakeLock(Context context) {
        if (sCpuWakeLock != null) {
            return;
        }
        sCpuWakeLock = createPartialWakeLock(context);
        sCpuWakeLock.acquire(10*60*1000L /*10 minutes*/);
    }

    public static void releaseCpuLock() {
        if (sCpuWakeLock != null) {
            sCpuWakeLock.release();
            sCpuWakeLock = null;
        }
    }

}
