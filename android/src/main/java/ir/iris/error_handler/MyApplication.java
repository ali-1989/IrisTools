package ir.iris.error_handler;

import android.app.Application;
import android.util.Log;

public class MyApplication extends Application {
    public void onCreate () {
        super.onCreate();

        Thread.setDefaultUncaughtExceptionHandler(this::handleUncaughtException);
    }

    public void handleUncaughtException (Thread thread, Throwable e) {
        e.printStackTrace();
        Log.i(">>>> UncaughtException", e.toString());

        //System.exit(1); // kill off the crashed app
    }
}