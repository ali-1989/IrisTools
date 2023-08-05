package ir.iris.android_tools;

import android.os.Handler;
import android.os.Looper;
import android.app.Activity;

import androidx.annotation.NonNull;

import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class Assistance implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private FlutterPluginBinding pluginBinding;
    private MethodChannel channel;
    private final String mName = "assistance";
    static boolean flutterAppIsRun = false;
    private static Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        pluginBinding = flutterPluginBinding;
        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        channel = new MethodChannel(messenger, mName);
        channel.setMethodCallHandler(this);
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
                result.success("<------- Echo from Java -------->");
                break;
            }
            // dart: invokeMethodByArgs('echo_arg', [{'ali': 'baq'}])
            case "echo_arg": {
                Map<?, ?> arg1 = (Map<?, ?>) args.get(0);
                result.success(arg1);
                break;
            }
            case "throw_error": {
                throwWithTimer(call, result);
                break;
            }
            case "set_kv": {
                setKv(call, result);
                break;
            }
            case "get_kv": {
                getKv(call, result);
                break;
            }
            case "setAppIsRun": {
                flutterAppIsRun = true;
                result.success(true);
                break;
            }
            case "isAppRun": {
                result.success(flutterAppIsRun);
                break;
            }
            case "dismiss_notification": {
                dismissNotification(call, result);
                break;
            }
            case "move_app_to_back": {
                moveTaskToBack(call, result);
                break;
            }
            default:
                result.notImplemented();
                //result.success(null);
                break;
        }
    }

    private void throwWithTimer(MethodCall call, MethodChannel.Result result){
        Long dur = call.argument("delay");

        if(dur == null){
            dur = 10000L;
        }

        Handler handler = new Handler(Looper.getMainLooper());
        Runnable r = this::throwAnError;

        handler.postDelayed(r, dur);

        /*Timer timer = new Timer();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                 handler.post(r);
            }
        };

        timer.schedule(task, 15000L);*/
        result.success(true);
    }

    private void throwAnError(){
        double x = 0/0;
    }

    private void moveTaskToBack(MethodCall call, MethodChannel.Result result){
        if (activity != null) {
            activity.moveTaskToBack(true);
            result.success(true);
        }
        else {
            result.success(false);
        }
    }

    private void setKv(MethodCall call, MethodChannel.Result result){
        String key = call.argument("key");
        String type = call.argument("type");
        Object value = call.argument("value");

        if(type == null || type.equals("String")) {
            SharedPreferenceHelper.setString(pluginBinding.getApplicationContext(), key, value.toString());
        }

        if(type.equals("long")) {
            SharedPreferenceHelper.setLong(pluginBinding.getApplicationContext(), key, Long.parseLong(value.toString()));
        }

        if(type.equals("int")) {
            SharedPreferenceHelper.setInt(pluginBinding.getApplicationContext(), key, Integer.parseInt(value.toString()));
        }

        if(type.equals("bool")) {
            SharedPreferenceHelper.setBoolean(pluginBinding.getApplicationContext(), key, Boolean.parseBoolean(value.toString()));
        }

        result.success(true);
    }

    private void getKv(MethodCall call, MethodChannel.Result result){
        String key = call.argument("key");
        String type = call.argument("type");


        if(type == null || type.equals("String")) {
            result.success(SharedPreferenceHelper.getString(pluginBinding.getApplicationContext(), key));
        }

        if(type.equals("long")) {
            result.success(SharedPreferenceHelper.getLong(pluginBinding.getApplicationContext(), key));
        }

        if(type.equals("int")) {
            result.success(SharedPreferenceHelper.getInt(pluginBinding.getApplicationContext(), key));
        }

        if(type.equals("bool")) {
            result.success(SharedPreferenceHelper.getBool(pluginBinding.getApplicationContext(), key));
        }


    }

    private void dismissNotification(MethodCall call, MethodChannel.Result result){
        Integer id = call.argument("notification_id");
        NotificationHelper.dismissNotification(pluginBinding.getApplicationContext(), id);
        result.success(true);
    }

    ///==================================================== ActivityAware
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
        activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }
}
