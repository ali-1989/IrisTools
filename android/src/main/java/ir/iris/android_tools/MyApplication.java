package ir.iris.android_tools;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {
    public void onCreate () {
        super.onCreate();

        Thread.setDefaultUncaughtExceptionHandler(this::handleUncaughtException);
    }

    public void handleUncaughtException(Thread thread, Throwable e) {
        PackageManager manager = this.getPackageManager();
        String model = Build.MODEL;
        String txt = "";

        if (!model.startsWith(Build.MANUFACTURER)) {
            model = Build.MANUFACTURER + " (" + model + ")";
        }

        try {
            PackageInfo info = manager.getPackageInfo(this.getPackageName(),0);
            txt = "packageName: " + info.packageName + " |model: " + model;
            txt += " |versionName: " + info.versionName;
        }
        catch (PackageManager.NameNotFoundException ignored) {}

        txt += " |SDK_INT: " + Build.VERSION.SDK_INT;
        txt += " |error: " + e.toString();

        Log.i(">>>> UncaughtException", txt);

        //System.exit(1);
    }
}