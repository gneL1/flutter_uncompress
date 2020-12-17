
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'initpage_provider.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {

  InitPageProvider _provider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _provider = InitPageProvider();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _provider)
      ],
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.redAccent,
                    image: DecorationImage(
                      image: AssetImage('local/home_bg_img.png'),
                      fit: BoxFit.fill
                    ),
                  ),
                  alignment: Alignment.center,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaY: 4,sigmaX: 4),
                    child: Container(
                      color: Colors.white.withOpacity(0),
                    ),
                  ),
                ),

                Image.asset(
                  'local/加载.gif',
                ),

                Selector<InitPageProvider,int>(
                  selector: (context, _provider) {
                    return _provider.progress;
                  },
                  builder: (context, _progress, child) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        "$_progress%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 56
                        ),
                      ),
                    );
                  },
                ),

                Selector<InitPageProvider,String>(
                  selector: (context, _provider) {
                    return _provider.text;
                  },
                  builder: (context, _text, child) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 64
                        ),
                        child: Text(
                          _text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                Align(
                  alignment: Alignment.topRight,
                  child: FlatButton(
                    onPressed: _provider.onCopyFile,
                    // onPressed: () async{
                    //   Directory dir2 = await getApplicationDocumentsDirectory();
                    //   print("路径$dir2");
                    // },
                    color: Colors.red,

                  ),
                )

              ],
            ),
          ),

          // body: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     SizedBox(
          //       width: double.infinity,
          //       height: 0,
          //     ),
          //     Container(
          //       width: double.infinity,
          //       height: double.infinity,
          //       child: Container(
          //         color: Colors.yellow,
          //       ),
          //       // child: Stack(
          //       //   children: [
          //       //     Container(
          //       //       color: Colors.green,
          //       //     )
          //       //
          //       //     // Selector<InitPageProvider,int>(
          //       //     //   selector: (context, _provider) {
          //       //     //     return _provider.progress;
          //       //     //   },
          //       //     //   builder: (context, _progress, child) {
          //       //     //     return Container(
          //       //     //       width: _progress * 6.0,
          //       //     //       height: 44,
          //       //     //       margin: EdgeInsets.symmetric(
          //       //     //           horizontal: 4,
          //       //     //           vertical: 4
          //       //     //       ),
          //       //     //       color: Colors.lightBlue.withOpacity(0.5),
          //       //     //     );
          //       //     //   },
          //       //     // ),
          //       //   ],
          //       // )
          //     ),
          //
          //     // Container(
          //     //   child: FlatButton(
          //     //     color: Colors.blue,
          //     //     child: Text('开始'),
          //     //     onPressed: _provider.onCopyFile,
          //     //   ),
          //     // ),
          //     // Container(
          //     //   width: 400,
          //     //   height: 400,
          //     //   // color: Colors.redAccent,
          //     //   // alignment: Alignment.bottomLeft,
          //     //   alignment: Alignment.center,
          //     //   child: FlatButton(
          //     //     onPressed: () async{
          //     //       // ByteData data = await PlatformAssetBundle().load('local/加载.gif');
          //     //       // Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          //     //       // Codec codec = await PaintingBinding.instance.instantiateImageCodec(bytes);
          //     //       // print("帧数是" + codec.frameCount.toString());
          //     //       // print("重复吗" + codec.repetitionCount.toString());
          //     //       // var infos = [];
          //     //       // for(int i = 0; i < codec.frameCount;i++){
          //     //       //   FrameInfo frameInfo = await codec.getNextFrame();
          //     //       //   infos.add(ImageInfo(image: frameInfo.image));
          //     //       // }
          //     //       // print(infos);
          //     //
          //     //       Directory dir1 = await getApplicationSupportDirectory();
          //     //       print("路径$dir1");
          //     //
          //     //
          //     //       Directory dir2 = await getApplicationDocumentsDirectory();
          //     //       print("路径$dir2");
          //     //
          //     //       File file = File(dir2.path + "/test.txt");
          //     //       await file.create();
          //     //
          //     //
          //     //       await dir2.list(recursive: true).forEach((e){
          //     //         print(e.path);
          //     //       }).then((v){
          //     //         print("遍历完毕");
          //     //       });
          //     //
          //     //     },
          //     //     color: Colors.green,
          //     //   ),
          //     //   // child: Image(
          //     //   //   // color: Colors.green,
          //     //   //   image: AssetImage(
          //     //   //     'local/加载.gif',
          //     //   //   ),
          //     //   //   height: 400,
          //     //   //   width: 400,
          //     //   //
          //     //   // ),
          //     // )
          //   ],
          // ),
        ),
      ),
    );
  }
}
