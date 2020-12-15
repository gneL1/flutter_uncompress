
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
              ),
              SizedBox(
                width: 600,
                height: 44,
                child: Stack(
                  children: [
                    Selector<InitPageProvider,int>(
                      selector: (context, _provider) {
                        return _provider.progress;
                      },
                      builder: (context, _progress, child) {
                        return Container(
                          width: _progress * 6.0,
                          height: 44,
                          margin: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4
                          ),
                          color: Colors.lightBlue.withOpacity(0.5),
                        );
                      },
                    ),
                    Container(
                      width: 600,
                      height: 44,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.lightBlue,
                              width: 4
                          )
                      ),
                      alignment: Alignment.center,
                      child: Selector<InitPageProvider,String>(
                        selector: (context, _provider) {
                          return _provider.text;
                        },
                        builder: (context, _text, child) {
                          return Text(_text,style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                          ),);
                        },
                      ),
                    )
                  ],
                )
              ),

              Container(
                child: FlatButton(
                  color: Colors.blue,
                  child: Text('开始'),
                  onPressed: _provider.onCopyFile,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
