package com.example.smartsleep.recievers;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.util.Log;

import java.io.IOException;

/**
 * Singleton class to control Alarm Ringing Sound
 */
public class AlarmSound {

    private final String TAG = "AlarmSound";

    private static AlarmSound mINSTANCE;
    private MediaPlayer mMediaPlayer;

    private AlarmSound() {
    }

    public static AlarmSound getInstance() {
        if (mINSTANCE == null) {
            mINSTANCE = new AlarmSound();
        }
        return mINSTANCE;
    }

    /**
     * Play Alarm Sound
     */
    public void playAlarmSound(Context context) {
        Log.i(TAG, "Playing alarm ringing sound");
        mMediaPlayer = new MediaPlayer();
        try {
            mMediaPlayer.setDataSource(context, getAlarmUri());
            final AudioManager audioManager = (AudioManager) context
                    .getSystemService(Context.AUDIO_SERVICE);
            if (audioManager != null &&
                    audioManager.getStreamVolume(AudioManager.STREAM_ALARM) != 0) {
                mMediaPlayer.setAudioStreamType(AudioManager.STREAM_ALARM);
                mMediaPlayer.setLooping(true);
                mMediaPlayer.prepare();
                mMediaPlayer.start();
            }
        } catch (IOException e) {
            System.out.println("Can't read Alarm uri: " + getAlarmUri());
        }
    }

    /**
     * Stop Alarm Sound currently playing
     */
    public void stopAlarmSound() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
        }
    }

    /**
     * Get alarm sound, try to get default, then notification, then ringtone
     *
     * @return URI for alarm sound
     */
    private Uri getAlarmUri() {
        Uri alert = RingtoneManager
                .getDefaultUri(RingtoneManager.TYPE_ALARM);
        if (alert == null) {
            alert = RingtoneManager
                    .getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
            if (alert == null) {
                alert = RingtoneManager
                        .getDefaultUri(RingtoneManager.TYPE_RINGTONE);
            }
        }
        return alert;
    }
}