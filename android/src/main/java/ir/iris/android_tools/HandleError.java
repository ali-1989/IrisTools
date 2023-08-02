package ir.iris.android_tools;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class HandleError implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private final String mName = "error_handler";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        channel = new MethodChannel(messenger, mName);
        channel.setMethodCallHandler(this);
        throwWithTimer();
        // context = flutterPluginBinding.getApplicationContext()
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        methodHandler(methodCall, result);
    }

    private void initWithEngine(FlutterEngine flutterEngine){
        //channel = new MethodChannel(getFlutterView(), mName);
        channel = new MethodChannel(flutterEngine.getDartExecutor(), mName);
        channel.setMethodCallHandler(this::methodHandler);
    }

    private void methodHandler(final MethodCall call, final MethodChannel.Result result) {
        List<?> args = (List<?>) call.arguments;

        switch (call.method) {
            case "echo": {
                result.success("<---------- Echo from Java ------------>");
                break;
            }
            // dart: invokeMethodByArgs('echo-arg', [{'ali': 'baq'}])
            case "echo-arg": {
                Map<?, ?> arg1 = (Map<?, ?>) args.get(0);
                result.success(arg1);
                break;
            }
            default:
                result.notImplemented();
                //result.success(null);
                break;
        }
    }

    private void throwWithTimer(){
        Handler handler = new Handler(Looper.getMainLooper());

        Runnable r = new Runnable() {
            @Override
            public void run() {
                throwAnError();
            }
        };

        handler.postDelayed(r, 15000L);

        /*Timer timer = new Timer();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                throwAnError();
            }
        };

        timer.schedule(task, 15000L);*/
    }

    private void throwAnError(){
        double x = 0/0;
    }



    /*private void setDartHandler(MethodCall call, Result result){
        Long id = call.argument("handle_id");
        SharedPreferenceHelper.setLong(getApplicationContext(), "dart_handler_id", id);
    }

    private void dismissNotification(MethodCall call, Result result){
        Integer id = call.argument("notification_id");
        NotificationHelper.dismissNotification(getApplicationContext(), id);
    }*/
}
