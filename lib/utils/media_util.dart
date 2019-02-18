import 'package:flutter/services.dart';
import 'dart:io';

class MediaUtil {
  static MethodChannel mediaChannel = MethodChannel('com.jl.memory.media');

  static Future<List<File>> getAllImages(int maxSize) async {
    List<dynamic> paths = await mediaChannel
        .invokeMethod('getAllImages', <String, dynamic>{'maxSize': maxSize});
    List<File> files = List();
    if (paths != null) {
      for (int i = 0; i < paths.length; i++) {
        files.add(new File(paths[i]));
      }
    }
    return files;
  }

  static Future<List<int>> getVideoFrame(String path) async {
    List<dynamic> results = await mediaChannel
        .invokeMethod('getVideoFrame', <String, dynamic>{'path': path});
    List<int> bytes = List();
    for (int i = 0; i < results.length; i++) {
      bytes.add(results[i]);
    }
    return bytes;
  }

  static Future<File> getVideo() async{
    List<dynamic> result = await mediaChannel.invokeMethod('getVideo');
    String path = result[0];
    return new File(path);
  }

}
