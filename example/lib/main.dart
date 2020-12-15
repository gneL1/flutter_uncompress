import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_uncompress/flutter_uncompress.dart';
import 'package:flutter_uncompress_example/initpage.dart';
import 'package:path_provider/path_provider.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color(0xffc5c5c5)),
      debugShowCheckedModeBanner: false, // 设置这一属性即可
      title: 'Flutter Demo',
      home: InitPage(),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    // FlutterUncompress.onGetProgress(callback: (value) {
    //   print("当前进度：" + value.toString());
    // },);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () async{
                  // String dir = (await getExternalStorageDirectory()).path + '/TestZip.zip';
                  // String dir = (await getExternalStorageDirectory()).path + '/';
                  // ByteData data = await PlatformAssetBundle().load('local/TestZip.zip');
                  // Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

                  // FlutterUncompress.copyFile(bytes: bytes, copyPath: dir);
                  // File file = File(dir + "TestZip.zip");
                  // await file.writeAsBytes(bytes);
                  // writeToFile(bytes,'$dir/$filename');
                },
                child: Text('按钮'),
                color: Colors.lightBlueAccent,
              ),
              
              FlatButton(
                onPressed: () async{
                  // String dir = (await getExternalStorageDirectory()).path + '/';
                  // FlutterUncompress.uncompress(filePath: dir + 'TestZip.zip', uncompressPath: dir + 'test/');

                },
                color: Colors.red,
                child: Text('按钮'),
              ),

              FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => InitPage()));
                },
                color: Colors.green,
                child: Text('按钮'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
