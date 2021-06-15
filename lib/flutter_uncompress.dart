
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FlutterUncompress {

  static const MethodChannel _channel =
      const MethodChannel('flutter_uncompress');

  static bool _isFinishUncompress = true;
  static bool _isFinishCopy = true;
  static bool _isFinishTxtToFile = true;
  static bool _isTxtToFile = true;

  ///解压压缩包
  ///filePath 是压缩包路径  比如  /storage/emulated/0/Android/data/com.correct.flutter_uncompress_example/files/engine.zip
  ///uncompressPath 是解压后的路径  比如 /storage/emulated/0/Android/data/com.correct.flutter_uncompress_example/files/
  ///callback 获取解压进度
  ///onFinish：完成解压时的回调
  static Future<void> uncompress({required String filePath,required String uncompressPath,ValueChanged<int>? progress,VoidCallback? onFinish}) async {
    if(!_isFinishUncompress)return;
    _channel.setMethodCallHandler((call){
      switch(call.method){
        case 'progress':
          if(progress != null)
            progress(call.arguments);
          break;
        case 'progressFinish':
          if(onFinish != null)
            onFinish();
          break;
        default:
          break;
      }
      return Future.value(null);
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
  static Future copyFileByBytes({required Uint8List bytes,required String path,ValueChanged<int>? progress,VoidCallback? onFinish}) async {
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
    if(onFinish != null)
      onFinish();
  }

  ///字节流转换成文本文件的内容
  ///bytes: 字节流
  ///txtFile：文本文件
  ///progress: 进度
  ///onFinish：完成时的回调
  static Future bytesToTxtFile({required Uint8List bytes,required File txtFile,ValueChanged<int>? progress,VoidCallback? onFinish}) async{
    if(!_isFinishTxtToFile)return;
    _isFinishTxtToFile = false;

    ///文本文件不存在  就先创建一个
    if(!await txtFile.exists())
      await txtFile.create();

    IOSink _sink = txtFile.openWrite();

    // ///通过调用Object.toString 将bytes转换为String 并将结果写入
    // ///最后跟一个换行符
    // ///不用writeAll是因为writeAll执行速度慢
    // sink.writeln(bytes);

    ///已经写入的大小
    int _size = 0;

    ///记录每次写入的位置
    int _record = 0;

    ///每次写入的大小
    ///如果字节流大于1MB 则每次写入1MB
    ///否则每次写入1KB
    int _distance = 1024;
    if(bytes.length > 1024 * 1024)
      _distance = 1024 * 1024;

    while(_size < bytes.length){
      _record = _size;
      _size += _distance;
      if(_size > bytes.length)
        _size = bytes.length;

      ///因为写入的时候  可能会出现下面情况
      ///比如写入内容是 ...164, 8, 216][228, 54, 213...
      ///json.decode(list)的时候就会报错
      ///所以要修正写入内容
      ///sublist是含头不含尾的
      String _text = bytes.sublist(_record,_size).toString();

      ///如果有多段数据  并且是第一段数据
      ///结尾的 ] 改成 ,
      if(_record == 0 && _size < bytes.length){
        _text = _text.replaceFirst("]", ",",_text.length - 1);
      }
      ///如果有多段数据  并且不是第一段也不是最后一段
      ///开头的 [ 改成 空格   结尾的 ] 改成 ,
      else if(_record != 0 && _size < bytes.length){
        _text = _text.replaceFirst("[", " ",0);
        _text = _text.replaceFirst("]", ",",_text.length - 1);
      }
      ///如果有多段数据  并且是最后一段
      ///开头的 [ 改成 空格
      else if(_record != 0 && _size >= bytes.length){
        _text = _text.replaceFirst("[", " ",0);
      }

      _sink.write(_text);

      ///每次写完清空缓存区  防止OOM内存溢出
      await _sink.flush();

      ///传递当前进度
      if(progress != null)
        progress(_size * 100 ~/ bytes.length);
    }

    await _sink.close().whenComplete((){
      if(onFinish != null)
        onFinish();
      _isFinishTxtToFile = true;
    });
  }

  ///文本文件内容转换成文件
  ///txtFile: txt文件
  ///rawFile：要转换成的文件
  ///passSize: 已转换的大小
  ///onFinish：完成时的回调
  static Future txtToFile({required File txtFile,required File rawFile,ValueChanged<int>? passSize,VoidCallback? onFinish}) async{
    if(!_isTxtToFile)return;
    _isTxtToFile = false;
    if(!await rawFile.exists())
      await rawFile.create();
    IOSink _sink = rawFile.openWrite();

    ///数字列表
    List<int> _fixList = [];

    ///单次最大读取 65536 个字节
    txtFile.openRead().listen(
      (List<int> value) async {

        ///这里创建一个新数组来获取value的值
        ///因为通过流读取到的数据是一个固定长度的数组，无法修改！
        List<int> event = [];
        event.addAll(value);

        ///因为获取到的数据格式解码后可能有问题
        ///比如解码后可能是[22,11,  或  2,1,4  或  4]
        ///不一定是一个完整的数组，
        ///所以需要对数据进行修正
        _fixUint8List(event,_fixList);

        ///解码
        ///通过流获取到的数据 并不是记录在txt文件上的内容
        ///而是将txt文件上的内容转换成Unicode编码后的数据
        ///所以需要将流传来的数据解码成字符
        String _list1 = utf8.decode(event);

        ///这里的字符，实际上就已经是txt文件上的内容了
        ///但还需要将字符转换成数组 才能添加进IOSink
        ///解析 json 字符串，返回的是 Map<String, dynamic> 类型
        List<int> _list = new List<int>.from(json.decode(_list1));

        ///清空缓存区  防止OOM内存溢出
        ///Unhandled Exception: Bad state: StreamSink is bound to a stream
        ///调用IOSink.add  不要跟着调用flush()方法，不然会提示错误
        // await _sink.flush();

        _sink.add(_list);

        int size = await rawFile.length();

        if(passSize != null)
          passSize(size);
      },
      onDone: () async{
        await _sink.close();
        if(onFinish != null)
          onFinish();
        _isTxtToFile = true;
      },
    );
  }


  ///修正数据为一个正常的数组
  /// 10  ---  换行符
  /// 93  ---  ]
  /// 44  ---  ,
  /// 32  ---  空格
  /// 91  ---  [
  static void _fixUint8List(List<int> event,List<int> fixList){
    ///如果是 , 开头  则添加数字列表 再清空数字列表
    ///最后加上 [
    if(event[0] == 44){
      // event.removeAt(0);
      event.insertAll(0, fixList);
      fixList.clear();
      event.insert(0, 91);
    }
    ///如果是 空格 开头  则替换成 [
    else if(event[0] == 32){
      event[0] = 91;
    }
    ///如果是数字开头，并且数字列表为空  则表示上一个event是以 空格 结尾的
    ///此时在开头插入一个 [
    else if(fixList.length == 0 && event[0] != 91){
      event.insert(0, 91);
    }
    ///如果是数字开头，并且数字列表不为空  则表示上一个event是以 数字 结尾的
    ///此时在开头插入数字列表  然后再在开头插入一个 [
    ///最后记得清空数字列表
    else if(fixList.length != 0){
      event.insertAll(0, fixList);
      event.insert(0, 91);
      fixList.clear();
    }

    ///如果是 , 结尾  则替换成 ]
    if(event[event.length -1] == 44){
      event[event.length - 1] = 93;
    }
    ///如果是 空格 结尾  则去掉结尾  再替换新结尾为 ]
    else if(event[event.length - 1] == 32){
      event.removeLast();
      event[event.length - 1] = 93;
    }
    ///如果是 换行符 结尾 ，则去掉结尾
    else if(event[event.length - 1] == 10){
      event.removeLast();
    }
    ///如果是  ]  结尾，则不做处理
    else if(event[event.length - 1] == 93){

    }
    ///如果是数字结尾  则往前找到 空格  并记录空格之后的数字列表
    else{
      int _index = 1;
      ///循环直到找到 空格
      ///注意这里不要用add  用add就是从尾插到头了  比如50 48 用add 数字列表就是 48 50 了
      while(event[event.length - _index] != 32){
        // _fixList.add(event[event.length - _index]);
        fixList.insert(0, event[event.length - _index]);
        _index++;
      }

      ///去掉空格包括空格之后的数字
      for(int i = 0; i < _index;i++){
        event.removeLast();
      }
      event[event.length - 1] = 93;
    }
  }
}