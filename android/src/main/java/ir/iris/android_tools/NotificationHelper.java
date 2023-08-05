package ir.iris.android_tools;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
//import androidx.core.app.RemoteInput;
//import android.app.PendingIntent;
//import android.content.Intent;

public class NotificationHelper {
    static private final String CHANNEL_ID = "c_01";
    static private final String CHANNEL_NAME = "flutter_app";
    static private final int NOTIFICATION_ID = 101;

    static void createChannel(Context context) {
        NotificationManagerCompat manager = NotificationManagerCompat.from(context);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance);
            channel.setDescription("channel");
            channel.enableVibration(false);
            channel.enableLights(true);

            manager.createNotificationChannel(channel);
        }
    }

    static void dismissNotification(Context context, int notificationId) {
        NotificationManagerCompat.from(context).cancel(null, notificationId);
    }
}