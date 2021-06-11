package com.example.smartsleep.db;

import android.content.Context;

import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

import com.example.smartsleep.model.NativeAlarms;

@androidx.room.Database(entities = {NativeAlarms.class}, version = 1, exportSchema = false)
@TypeConverters({ListConverter.class})
public abstract class Database extends RoomDatabase {
    public abstract AlarmDao alarmDao();

    private static Database database;

    public static Database getDatabase(Context context) {
        if(database==null){
            database = Room.databaseBuilder(context.getApplicationContext(),Database.class,"alarm-db")
                    .fallbackToDestructiveMigration()
                    .allowMainThreadQueries()
                    .build();
        }
        return database;
    }
}
