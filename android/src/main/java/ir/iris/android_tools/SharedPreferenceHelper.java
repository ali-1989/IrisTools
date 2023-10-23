package ir.iris.android_tools;

import android.content.Context;
import android.content.SharedPreferences;

public class SharedPreferenceHelper {
    private final static String SHARED_PREFS_FILE_NAME = "flutter_kv";

    static SharedPreferences getSharedPreferences(Context context){
        //PreferenceManager.getDefaultSharedPreferences(context);
        return context.getSharedPreferences(SHARED_PREFS_FILE_NAME, 0);
    }

    static void setString(Context context, String key, String value){
        SharedPreferences.Editor editor = getSharedPreferences(context).edit();
        editor.putString(key, value);
        editor.apply();
    }

    static void setInt(Context context, String key, Integer value) {
        SharedPreferences.Editor editor = getSharedPreferences(context).edit();
        editor.putInt(key, value);
        editor.apply();
    }

    static void setLong(Context context, String key, Long value) {
        SharedPreferences.Editor editor = getSharedPreferences(context).edit();
        editor.putLong(key, value);
        editor.apply();
    }

    static void setBoolean(Context context, String key, Boolean value) {
        SharedPreferences.Editor editor = getSharedPreferences(context).edit();
        editor.putBoolean(key, value);
        editor.apply();
    }

    static String getString(Context context, String key) {
        return getSharedPreferences(context).getString(key, "");
    }

    static int getInt(Context context, String key) {
        return getSharedPreferences(context).getInt(key, 0);
    }

    static Long getLong(Context context, String key) {
        return getSharedPreferences(context).getLong(key, -1L);
    }

   static boolean getBool(Context context, String key) {
        return getSharedPreferences(context).getBoolean(key, false);
    }

    static boolean has(Context context, String key) {
        return getSharedPreferences(context).contains(key);
    }
}