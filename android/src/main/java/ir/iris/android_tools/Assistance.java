package ir.iris.android_tools;

import android.os.Handler;
import android.os.Looper;
import android.app.Activity;

import androidx.annotation.NonNull;

import java.util.HashMap;
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
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        pluginBinding = flutterPluginBinding;
        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        channel = new MethodChannel(messenger, mName);
        channel.setMethodCallHandler(this);
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
        List<?> argList = (List<?>) call.arguments;

        switch (call.method) {
            case "echo": {
                result.success("<------- Echo from Java -------->");
                break;
            }
            // dart: invokeMethodByArgs('echo_arg', [{'ali': 'baq'}])
            case "echo_arg": {
                Map<?, ?> arg1 = (Map<?, ?>) argList.get(0);
                //Collections.<String, Object>unmodifiableMap(arg1);
                result.success(arg1);
                break;
            }
            // dart: invokeMethodByArgs('throw_error', [{'delay': 15000}])
            case "throw_error": {
                Map<String, ?> arg1 = (Map<String, ?>) argList.get(0);
                throwWithTimer(arg1, result);
                break;
            }
            case "set_kv": {
                Map<?, ?> arg1 = (Map<?, ?>) argList.get(0);
                Map<String, Object> kv = castMap(arg1);
                setKv(kv, result);
                break;
            }
            case "get_kv": {
                Map<?, ?> arg1 = (Map<?, ?>) argList.get(0);
                Map<String, Object> kv = castMap(arg1);
                getKv(kv, result);
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
                Map<?, ?> arg1 = (Map<?, ?>) argList.get(0);
                Map<String, Object> kv = castMap(arg1);
                dismissNotification(kv, result);
                break;
            }
            case "move_app_to_back": {
                moveTaskToBack(result);
                break;
            }
            default:
                result.notImplemented();
                //result.success(null);
                break;
        }
    }

    private void throwWithTimer(Map<String, ?> arg, MethodChannel.Result result){
        Long dur =  10000L;

        Object delay = arg.get("delay");

        if(delay != null){
            dur = Long.parseLong(delay.toString());
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

    private void moveTaskToBack(MethodChannel.Result result){
        if (activity != null) {
            activity.moveTaskToBack(true);
            result.success(true);
        }
        else {
            result.success(false);
        }
    }

    private Map<String, Object> castMap(Map<?, ?> input){
        Map<String, Object> newMap = new HashMap<>();

        for(Object strKey: input.keySet()) {
            newMap.put(String.valueOf(strKey), input.get(strKey));
        }

        /*for (Map.Entry<?, ?> entry : input.entrySet()) {
            if (entry.getKey() instanceof String) {
                newMap.put((String) entry.getKey(), entry.getValue());
            }
        }*/

        return newMap;
    }

    private void setKv(Map<String, Object> kv, MethodChannel.Result result){
        String key = kv.get("key").toString();
        Object typeOrg = kv.get("type");
        String type = typeOrg == null? null : typeOrg.toString();
        Object value = kv.get("value");
        String valueString = value == null? null : value.toString();

        if(type == null || type.equals("String")) {
            SharedPreferenceHelper.setString(pluginBinding.getApplicationContext(), key, valueString);
        }

        else if(type.equals("long")) {
            SharedPreferenceHelper.setLong(pluginBinding.getApplicationContext(), key, valueString == null? null :Long.parseLong(valueString));
        }

        else if(type.equals("int")) {
            SharedPreferenceHelper.setInt(pluginBinding.getApplicationContext(), key, valueString == null? null :Integer.parseInt(valueString));
        }

        else if(type.equals("bool")) {
            SharedPreferenceHelper.setBoolean(pluginBinding.getApplicationContext(), key, Boolean.parseBoolean(valueString));
        }

        result.success(true);
    }

    private void getKv(Map<String, Object> kv, MethodChannel.Result result){
        String key = kv.get("key").toString();
        Object typeOrg = kv.get("type");
        String type = typeOrg == null? null : typeOrg.toString();


        if(type == null || type.equals("String")) {
            result.success(SharedPreferenceHelper.getString(pluginBinding.getApplicationContext(), key));
        }

        else if(type.equals("long")) {
            result.success(SharedPreferenceHelper.getLong(pluginBinding.getApplicationContext(), key));
        }

        else if(type.equals("int")) {
            result.success(SharedPreferenceHelper.getInt(pluginBinding.getApplicationContext(), key));
        }

        else if(type.equals("bool")) {
            result.success(SharedPreferenceHelper.getBool(pluginBinding.getApplicationContext(), key));
        }
    }

    private void dismissNotification(Map<String, Object> kv, MethodChannel.Result result){
        int id = (int) kv.get("notification_id");
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
