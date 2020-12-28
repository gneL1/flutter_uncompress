# flutter_uncompress

解压`zip`文件的插件.  

## 示例
* `FlutterUncompress.uncompress` -- 解压`zip`  
```dart
String dir = (await getExternalStorageDirectory()).path + '/';

await FlutterUncompress.uncompress(
    filePath: dir + '/测试压缩.zip',
    uncompressPath: dir,
    progress: (value) async{
      ...
    },
    onFinish: () {
      ...
    },
);
```

* `FlutterUncompress.copyFileByBytes` -- 通过字节流复制文件  
```dart
String dir = (await getExternalStorageDirectory()).path + '/测试压缩.zip';
ByteData data = await PlatformAssetBundle().load('local/测试压缩.zip');
Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

await FlutterUncompress.copyFileByBytes(
    bytes: bytes, 
    path: dir,
    progress: (value) {
      ...
    },
    onFinish: () {
      ...
    },
);
```

* `FlutterUncompress.bytesToTxtFile` -- 字节流转`txt`文本文件  
```dart
String _name = '测试压缩';
ByteData data = await PlatformAssetBundle().load('local/$_name.zip');
Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

String dir = (await getExternalStorageDirectory()).path;
File _file = File(dir + '/$_name.txt');

await FlutterUncompress.bytesToTxtFile(
    bytes: bytes,
    txtFile: _file,
    progress: (value) {
      ...
    },
    onFinish: () async{
      ...
    }
);
```

* `txt`文本文件还原成原文件  
```dart
String dir = (await getExternalStorageDirectory()).path;
String _name = '测试压缩';
File _file = File(dir + '/$_name.txt');
File _rawFile = File(dir + '/$_name.zip')

await FlutterUncompress.txtToFile(
    txtFile: _file,
    rawFile: _rawFile,
    passSize: (value) {
      ...
    },
    onFinish: () {
      ...
    }
);
```
## 引用
```yaml
flutter_uncompress:
    git:
      url: git://github.com/gneL1/flutter_uncompress.git
      ref: main
```