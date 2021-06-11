package com.example.smartsleep.db;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import com.example.smartsleep.model.NativeAlarms;

import java.util.List;

import io.reactivex.Flowable;
import io.reactivex.Single;

import static androidx.room.OnConflictStrategy.IGNORE;

@Dao
public interface AlarmDao {

    @Query("select * from alarms")
    List<NativeAlarms> getAll();

    @Query("select * from alarms where alarmId=:id")
    NativeAlarms get(int id);

    @Insert(onConflict = IGNORE)
    void insert(NativeAlarms alarm);

    @Update
    void update(NativeAlarms alarm);

    @Delete
    void delete(NativeAlarms alarm);

    @Query("Delete from alarms where alarmId=:id")
    void deleteById(int id);

    @Query("Delete from alarms")
    void deleteAll();

}
