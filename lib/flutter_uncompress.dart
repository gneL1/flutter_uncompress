
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FlutterUncompress {

  static const MethodChannel _channel =
      const MethodChannel('flutter_uncompress');

  static bool _isFinishUncompress = true;
  static bool _isFinishCopy = true;

  ///解压压缩包
  ///filePath 是压缩包路径  比如  /storage/emulated/0/Android/data/com.correct.flutter_uncompress_example/files/engine.zip
  ///uncompressPath 是解压后的路径  比如 /storage/emulated/0/Android/data/com.correct.flutter_uncompress_example/files/
  ///callback 获取解压进度
  ///onFinish：完成解压时的回调
  static Future uncompress({@required String filePath,@required String uncompressPath,ValueChanged<int> progress,VoidCallback onFinish}) async {
    if(!_isFinishUncompress)return;
    _channel.setMethodCallHandler((call){
      switch(call.method){
        case 'progress':
          if(progress != null)
            progress(call.arguments);
          break;
        case 'progressFinish':
          onFinish();
          break;
        default:
          break;
      }
      return;
    });
    _isFinishUncompress = false;
    try{
      await _channel.invokeMethod('uncompressZipFile',{'filePath':filePath,'uncompressPath':uncompressPath});
      _isFinishUncompress = true;
    }
    catch(e){
      _isFinishUncompress = true;
    }
  }

  ///通过字节流复制文件
  ///bytes: 要复制的字节流
  ///path: 复制后所在地的路径 比如/storage/emulated/0/Android/data/com.correct.flutter_uncompress_example/files/engine.zip
  ///progress: 复制进度
  ///onFinish：完成复制时的回调
  static Future copyFileByBytes({@required Uint8List bytes,@required String path,ValueChanged<int> progress,VoidCallback onFinish}) async {
    if(!_isFinishCopy)return;
    _isFinishCopy = false;
    int distance = bytes.length ~/ 100;
    int _start = 0;

    //目标文件
    File target = File(path);

    //以WRITE方式打开文件，创建缓存IOSink
    IOSink sink = target.openWrite();
    //文件大小
    int fileLength = bytes.lengthInBytes;
    //已读取文件大小
    int count = 0;

    for(int i = 0; i < 100; i++){
      _start = 0 + i * distance;
      List<int> value;
      if(i != 99)
        value = bytes.sublist(_start,_start + distance);
      else
        value = bytes.sublist(_start,bytes.length);

      count = count + value.length;

      //百分比进度
      double num = (count * 100) / fileLength;
      if(progress != null)progress(num.toInt());

      //添加数据到缓存池
      sink.add(value);
    }

    //关闭缓存
    await sink.close();
    _isFinishCopy = true;
    onFinish();
  }
}
