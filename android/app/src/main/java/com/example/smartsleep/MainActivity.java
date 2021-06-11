package com.example.smartsleep;

import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.browser.customtabs.CustomTabsIntent;

import com.example.smartsleep.channel.AlarmHandler;
import com.example.smartsleep.db.Database;
import com.example.smartsleep.db.TokenStore;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.subjects.PublishSubject;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "app://smartsleep/channel";
    private static final String DB_CHANNEL = "app://smartsleep/db";
    public TokenStore tokenStore;
    boolean browserResume;
    AlarmHandler alarmHandler;
    PublishSubject<String> codePublisher = PublishSubject.create();
    Disposable codeSubscription;

    /*@Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }*/

    @Override
    public void onNewIntent(@NonNull Intent intent){
        super.onNewIntent(intent);
        browserResume = false;
        String[] data = intent.getData().getQuery().split("=");
        if(codeSubscription == null){
            Log.i(this.getClass().getSimpleName(),"Disposable Null");
        }else{
            Log.i(this.getClass().getSimpleName(),"Disposable Not Null");
        }

        this.codeListener();
        codePublisher.onNext(data[1]);
        alarmHandler = new AlarmHandler(new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), DB_CHANNEL),getApplicationContext(),Database.getDatabase(this));
        methodListeners();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.codeListener();
        alarmHandler = new AlarmHandler(new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), DB_CHANNEL),getApplicationContext(),Database.getDatabase(this));
        methodListeners();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(browserResume){
            codePublisher.onNext("BROWSER_RESUME");
            this.codeListener();
        }else {
            Log.i("OnResume","Successfull Resume App");
        }
    }

    private void initiateDeepLink(String link) {
        browserResume = true;
        CustomTabsIntent.Builder intentBuilder = new CustomTabsIntent.Builder();
        CustomTabsIntent tabsIntent = intentBuilder.build();
        intentBuilder.setShowTitle(false);
        intentBuilder.enableUrlBarHiding();
        tabsIntent.launchUrl(this, Uri.parse(link));
    }

    private void methodListeners(){
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)//"com.sleep.app/deeplink"
                .setMethodCallHandler((call, result) -> {
                    switch (call.method){
                        case "initiateDeepLink": initiateDeepLink(call.arguments.toString()); break;
                        case "getToken": result.success(tokenStore.load()); break;
                        case "storeToken": tokenStore.store(call.arguments.toString()); break;
                        case "removeToken": tokenStore.clear(); break;
                        case "initializeSharedPreferences": tokenStore = new TokenStore(getApplicationContext(),call.arguments.toString()); break;
                    }
                });
    }

    private void codeListener(){
        new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "app://smartsleep/code").setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object args, EventChannel.EventSink events) {
                        codeSubscription = codePublisher.observeOn(AndroidSchedulers.mainThread()).subscribe(events::success);
                    }

                    @Override
                    public void onCancel(Object args) {
                        if(codeSubscription!=null){
                            codeSubscription.dispose();
                            codeSubscription = null;
                        }
                    }
                }
        );
    }
}
