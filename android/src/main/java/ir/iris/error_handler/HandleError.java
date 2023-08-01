package ir.iris.error_handler;

import androidx.annotation.NonNull;

import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class HandleError implements MethodCallHandler, FlutterPlugin {
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        channel = new MethodChannel(messenger, "error_handler");
        channel.setMethodCallHandler(this);
        // flutterPluginBinding.getApplicationContext()
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

    private void init(FlutterEngine flutterEngine){
        //FlutterView view = getFlutterView();
        //MethodChannel myChannel = new MethodChannel(view, "error_handler");
        channel = new MethodChannel(flutterEngine.getDartExecutor(), "error_handler");

        channel.setMethodCallHandler(this::methodHandler);
    }

    private void methodHandler(final MethodCall call, final MethodChannel.Result result) {
        List<?> args = (List<?>)call.arguments;

        switch (call.method) {
            case "getConfiguration": {
                Map<?, ?> configuration = (Map<?, ?>)args.get(0);
                result.success(null);
                //invokeMethod("onConfigurationChanged", configuration);
                break;
            }
            case "echo": {
                result.success("Echo from java");
                break;
            }
            case "throw_error": {
                throwAnError();
                break;
            }
            default:
                //result.notImplemented();
                result.success(null);
                break;
        }
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
