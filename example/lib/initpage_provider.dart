import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_uncompress/flutter_uncompress.dart';
import 'package:path_provider/path_provider.dart';

class InitPageProvider with ChangeNotifier{

  int _progress = 0;
  int get progress => _progress;

  String _text = '';
  String get text => _text;

  ///当解压
  Future onUncompress({String path}) async{
    String dir = path == null ? (await getExternalStorageDirectory()).path + '/' : path;
    await FlutterUncompress.uncompress(
        filePath: dir + '测试压缩.zip',
        uncompressPath: dir,
        progress: (value) async{
          if(_progress == value)return;
          _text = '数据加载中...';
          _progress = value;
          print("当前进度是$value");

          if(_progress == 100){
            File zip = File(dir + '测试压缩.zip');
            await zip.delete();
            _text = '完成加载';
          }
          notifyListeners();
        },
      onFinish: () {
        print('完成解压操作');
        _text = "";
        notifyListeners();
      },
    );
  }

  ///当复制文件
  Future onCopyFile() async{
    String dir = (await getExternalStorageDirectory()).path + '/测试压缩.zip';
    ByteData data = await PlatformAssetBundle().load('local/测试压缩.zip');
    Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await FlutterUncompress.copyFileByBytes(
      bytes: bytes,
      path: dir,
      progress: (value) {
        // if(_progress == value && value % 10 != 0)return;
        _text = '数据初始化...';
        _progress = value;
        notifyListeners();
        // print("当前----------进度$value");
      },

      onFinish: ()async {
        // print("完成复制");
        await onUncompress();
      },
    );
    // await onUncompress();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}