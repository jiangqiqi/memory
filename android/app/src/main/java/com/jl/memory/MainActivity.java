package com.jl.memory;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;

import com.zhihu.matisse.Matisse;
import com.zhihu.matisse.MimeType;
import com.zhihu.matisse.engine.impl.PicassoEngine;
import com.zhihu.matisse.filter.Filter;
import com.zhihu.matisse.internal.entity.CaptureStrategy;
import com.zhihu.matisse.listener.OnCheckedListener;
import com.zhihu.matisse.listener.OnSelectedListener;

import java.io.File;
import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final int REQUEST_CODE_CHOOSE = 23;
    private static final String MEDIA_CHANNEL = "com.jl.memory.media";
    private MethodChannel.Result channelResult;
    private static final String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(getFlutterView(), MEDIA_CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        channelResult = result;
                        switch (methodCall.method){
                            case "getAllImages":
                                int maxSize = methodCall.argument("maxSize");
                                getAllImages(maxSize);
                                break;
                            case "getVideo":
                                getVideo();
                                break;
                            case "getVideoFrame":
                                String path = methodCall.argument("path");
                                getVideoFrame(path,result);
                                break;
                        }
                    }
                }
        );
    }

    /**
     * 获取视频第一帧
     */
    private void getVideoFrame(String path,MethodChannel.Result result){
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        File file = new File("videos/butterfly.mp4");
        Log.e(TAG,"file is exists : " + file.exists());
        if (file.exists()){
            mmr.setDataSource(file.getAbsolutePath());
            byte [] bytes = mmr.getEmbeddedPicture();
            result.success(new String(bytes));
        }
    }

    /**
     * 获取相册照片
     * @param maxSize
     */
    private void getAllImages(int maxSize) {
        Matisse.from(this)
                .choose(MimeType.ofImage(), false)
                .countable(true)
                .capture(true)
                .captureStrategy(
                        new CaptureStrategy(true, "com.zhihu.matisse.sample.fileprovider", "test"))
                .maxSelectable(maxSize)
                .addFilter(new GifSizeFilter(320, 320, 5 * Filter.K * Filter.K))
                .gridExpectedSize(
                        getResources().getDimensionPixelSize(R.dimen.grid_expected_size))
                .restrictOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT)
                .thumbnailScale(0.85f)
                .showSingleMediaType(true)
//                                            .imageEngine(new GlideEngine())  // for glide-V3
                .imageEngine(new Glide4Engine())    // for glide-V4
                .setOnSelectedListener(new OnSelectedListener() {
                    @Override
                    public void onSelected(
                            @NonNull List<Uri> uriList, @NonNull List<String> pathList) {
                        // DO SOMETHING IMMEDIATELY HERE
                        Log.e("onSelected", "onSelected: pathList=" + pathList);

                    }
                })
                .originalEnable(true)
                .maxOriginalSize(10)
                .autoHideToolbarOnSingleTap(true)
                .setOnCheckedListener(new OnCheckedListener() {
                    @Override
                    public void onCheck(boolean isChecked) {
                        // DO SOMETHING IMMEDIATELY HERE
                        Log.e("isChecked", "onCheck: isChecked=" + isChecked);
                    }
                })
                .forResult(REQUEST_CODE_CHOOSE);
    }

    /**
     * 获取视频
     */
    private void getVideo(){
        Log.e(TAG,"getVideo is excute ");
        Matisse.from(this)
                .choose(MimeType.ofVideo())
                .showSingleMediaType(true)
                .countable(false)
                .addFilter(new GifSizeFilter(320, 320, 5 * Filter.K * Filter.K))
                .maxSelectable(9)
                .originalEnable(true)
                .maxOriginalSize(10)
                .imageEngine(new PicassoEngine())
                .forResult(REQUEST_CODE_CHOOSE);
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_CHOOSE && resultCode == RESULT_OK) {
            Log.e("OnActivityResult ", Matisse.obtainPathResult(data).toString());
            if (channelResult!=null){
                channelResult.success(Matisse.obtainPathResult(data));
            }
        }
    }



}
