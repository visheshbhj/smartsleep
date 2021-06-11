package com.example.smartsleep;

import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageButton;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.example.smartsleep.recievers.AlarmReceiver;

import static com.example.smartsleep.service.AlarmScheduler.EXTRA_ID;
import static com.example.smartsleep.service.AlarmScheduler.SNOOZE_COUNT;

public class AlarmActivity extends AppCompatActivity {

    ImageButton alarmOff;
    ImageButton snooze;

    private void hideNavigationBar() {
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                | WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON);

        if(Build.VERSION.SDK_INT>= Build.VERSION_CODES.O_MR1){
            setTurnScreenOn(true);
        }

        getWindow().setBackgroundDrawable(new ColorDrawable(ContextCompat.getColor(this,android.R.color.black)));

        hideNavigationBar();

        sendBroadcast(new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS));

        setContentView(R.layout.alarm_activity);
        //getActionBar().hide();
        getWindow().setBackgroundDrawable(new ColorDrawable(ContextCompat.getColor(this,android.R.color.black)));

        alarmOff = findViewById(R.id.alarmOff);
        snooze = findViewById(R.id.snooze);

        alarmOff.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent result = new Intent(AlarmActivity.this,AlarmReceiver.class);
                result.setAction("ALARM_DISMISS");
                result.putExtra(EXTRA_ID,getIntent().getIntExtra(EXTRA_ID,-1));
                sendBroadcast(result);
                finish();
            }
        });

        snooze.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent result = new Intent(AlarmActivity.this,AlarmReceiver.class);
                result.setAction("ALARM_SNOOZE");
                result.putExtra(EXTRA_ID,getIntent().getIntExtra(EXTRA_ID,-1));
                result.putExtra(SNOOZE_COUNT,getIntent().getIntExtra(SNOOZE_COUNT,-1));
                sendBroadcast(result);
                finish();
            }
        });

    }

    @Override
    public void onBackPressed() {
        //Disable Back Press
    }
}
