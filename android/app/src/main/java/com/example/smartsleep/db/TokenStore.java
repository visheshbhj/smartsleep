package com.example.smartsleep.db;

import android.content.Context;
import android.content.SharedPreferences;

import io.flutter.Log;

import static android.content.Context.MODE_PRIVATE;

public class TokenStore {

    private Context context;
    private String storeName;

    public TokenStore(Context context,String storeName){
        this.context=context;
        this.storeName = storeName;
    }

    private SharedPreferences getLocalSharedPreferences(){
        return context.getSharedPreferences(storeName, MODE_PRIVATE);
    }

    public String load(){

        SharedPreferences sharedPreferences = getLocalSharedPreferences();
        if(!sharedPreferences.getAll().containsKey("token")){
            store("");
            Log.i("Channel Load Token", "Token is Blank");
            return "";
        }
        Log.i("Channel Load Token", sharedPreferences.getAll().get("token").toString());
        return sharedPreferences.getAll().get("token").toString();
    }

    public void store(String token){
        SharedPreferences sharedPreferences = getLocalSharedPreferences();
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString("token",token);
        editor.apply();
    }

    public void clear(){
        SharedPreferences sharedPreferences = getLocalSharedPreferences();
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.clear();
        editor.apply();
        store(null);
    }

}

