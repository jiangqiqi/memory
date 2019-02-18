import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';

class SrcSelectList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SrcSelectListState();
}

class _SrcSelectListState extends State<SrcSelectList> {
  static const MethodChannel methodChannel =
      MethodChannel('com.jl.memory.media');
  List<File> result;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        title: const Text('模块名称'),
        centerTitle: true,
      ),
//      body: Column(
//        children: <Widget>[
//          Expanded(
//              child: SafeArea(
//                  top: false,
//                  bottom: false,
//                  child: FutureBuilder<List<File>>(
//                    future: getAllImages(),
//                    builder: (BuildContext context,
//                        AsyncSnapshot<List<File>> snapshot) {
//                      if (snapshot.connectionState == ConnectionState.done &&
//                          snapshot.data != null) {
//                        return GridView.count(
//                          crossAxisCount: 4,
//                          mainAxisSpacing: 2.0,
//                          crossAxisSpacing: 2.0,
//                          padding: const EdgeInsets.all(2.0),
//                          childAspectRatio: 1.0,
//                          children: snapshot.data.map<Widget>((File file) {
//                            return Image.file(
//                              file,
//                              fit: BoxFit.cover,
//                              scale: 0.1,
//                              filterQuality: FilterQuality.low,
//                            );
//                          }).toList(),
//                        );
//                      } else {
//                        return Container(
//                          alignment: Alignment.center,
//                          child: CircularProgressIndicator(),
//                        );
//                      }
//                    },
//                  )))
//        ],
//      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.edit),
          onPressed: getAllVideos),
    );
  }

  void getAllImages() async{
    await methodChannel.invokeMethod('getAllImages');
  }

  void getAllVideos() async{
    await methodChannel.invokeMethod('getAllVideos');
  }

//  Future<List<File>> getAllImages() async {
//    List<dynamic> paths = await methodChannel.invokeMethod('getAllImages');
//    List<File> files = new List();
//    for (int i = 0; i < paths.length; i++) {
//      print('result is : ' + paths[i]);
//      files.add(new File(paths[i]));
//    }
//    return files;
//  }
}

void main() => runApp(MaterialApp(
      home: SrcSelectList(),
    ));
