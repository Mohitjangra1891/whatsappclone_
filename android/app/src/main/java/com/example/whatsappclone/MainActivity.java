package com.example.whatsappclone;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.media.MediaScannerConnection;
import android.net.Uri;
import java.io.File;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.whatsappclone/media_scan";  // Use your package name here

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("scanFile")) {
                                String path = call.argument("path");
                                scanFile(path);
                                result.success(null);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void scanFile(String path) {
        MediaScannerConnection.scanFile(this, new String[]{path}, null, (String path1, Uri uri) -> {

        });
    }

}
