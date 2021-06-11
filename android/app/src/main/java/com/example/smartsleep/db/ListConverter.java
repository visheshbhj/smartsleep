package com.example.smartsleep.db;

import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.util.ArrayList;

public class ListConverter {
    @TypeConverter
    public static ArrayList<String> fromString(String value) {
        return new Gson().fromJson(value, new TypeToken<ArrayList<String>>() {}.getType());
    }
    @TypeConverter
    public static String fromArrayList(ArrayList<String> list) {
        Gson gson = new Gson();
        String json = gson.toJson(list);
        return json;
    }
}
