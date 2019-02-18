import 'package:flutter/material.dart';
import 'package:memory/model/classification.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:memory/model/memory.dart';
import 'package:video_player/video_player.dart';
import 'video_full_screen.dart';
import 'image_full_screen.dart';
import 'package:memory/utils/media_util.dart';
import 'dart:io';
enum SelectType{
  TEXT,
  SHOOT,
  PICTURE,
  VIDEO
}


class MemoryList extends StatefulWidget {
  MemoryList({this.classification});

  final Classification classification;

  @override
  State<StatefulWidget> createState() =>
      MemoryListState(classification: classification);
}

class MemoryListState extends State<MemoryList> {
  MemoryListState({this.classification});

  final Classification classification;
  final List<VideoPlayerController> controllers = List<VideoPlayerController>();

  @override
  void dispose() {
    super.dispose();
    for (VideoPlayerController controller in controllers) {
      controller.dispose();
    }
    controllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classification.title),
        centerTitle: true,
      ),
//      body: buildItem(context),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return buildListTileOfImage(context);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: 10),
//      body: FutureBuilder(
//          //从链上查询数据
//          future: request(),
//          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//            print('snapshot : $snapshot');
//            if (snapshot.connectionState == ConnectionState.done &&
//                snapshot.data != null) {
//              return ListView.separated(
//                  itemBuilder: (BuildContext context, int index) {
//                    return buildListTileOfImage(context);
//                  },
//                  separatorBuilder: (BuildContext context, int index) {
//                    return Divider();
//                  },
//                  itemCount: 10);
//            } else {
//              return Container(
//                alignment: Alignment.topCenter,
//                margin: EdgeInsets.only(top: 50.0),
//                child: Column(
//                  mainAxisSize: MainAxisSize.min,
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  children: <Widget>[
//                    CircularProgressIndicator(),
//                    SizedBox(
//                      height: 20.0,
//                    ),
//                    Text(
//                      '正在加载数据。。。',
//                      style: TextStyle(
//                        fontSize: 18.0,
//                      ),
//                    )
//                  ],
//                ),
//              );
//            }
//          }),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.edit),
          onPressed: showSelectDialog),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void showSelectDialog() {
    showDialog<SelectType>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 20.0,top: 10.0,bottom: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context,SelectType.TEXT);
                    },
                    child: Text(
                      '纯文字',
                      style: TextStyle(fontSize: 20.0,color: Colors.black54),
                    ),
                  )),
              Divider(),
              Padding(
                  padding: EdgeInsets.only(left: 20.0,top: 10.0,bottom: 10.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context,SelectType.SHOOT);
                      },
                      child: Text(
                        '拍摄',
                        style: TextStyle(fontSize: 20.0,color: Colors.black54),
                      ))),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 20.0,top: 10.0,bottom: 5.0),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context,SelectType.PICTURE);
                    },
                    child: Text(
                      '从相册选择照片',
                      style: TextStyle(fontSize: 20.0,color: Colors.black54),
                    )),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 20.0,top: 10.0,bottom: 5.0),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context,SelectType.VIDEO);
                    },
                    child: Text(
                      '从相册选择视频',
                      style: TextStyle(fontSize: 20.0,color: Colors.black54),
                    )),
              )
            ],
          );
        }).then<void>((SelectType value){
          print("value is : " + value.toString());
          switch(value){
            case SelectType.TEXT:
              break;
            case SelectType.SHOOT:
              break;
            case SelectType.PICTURE:
              MediaUtil.getAllImages(9).then((List<File> values){
                print('values is : ' + values.toString());
              });
              break;
            case SelectType.VIDEO:
              MediaUtil.getVideo().then((File value){
                print('value is : ' + value.toString());
              });
              break;
          }
    });
  }

  Future<String> request() async {
    Dio dio = new Dio();
    Response<String> response = await dio.get('https://www.baidu.com');
    return response.data;
  }

  Widget buildListTileLeading(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(getDate()),
          Text(new TimeOfDay.now().format(context)),
        ],
      ),
    );
  }

  //带图片的条目
  Widget buildListTileOfImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListTile(
        leading: buildListTileLeading(context),
        title: Text(
            'CircleAvatar, which shows an icon representing a person and is often used as the leading element of a ListTile.'),
        subtitle: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 1.0,
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(2.0),
          children: memorys.map((Memory memory) {
            print('count : ${count++}');
            return GestureDetector(
                onTap: () {
                  print('jiangliang');
                  pushFullImageScreenWidget();
                },
                child: Image.asset(
                  'image/places/india_chennai_flower_market.png',
                  fit: BoxFit.cover,
                ));
          }).toList(),
        ),
      ),
    );
  }

  int count = 0;
  List<Memory> memorys = <Memory>[
    Memory(),
    Memory(),
    Memory(),
    Memory(),
    Memory(),
    Memory(),
    Memory(),
    Memory(),
    Memory(),
  ];
  List<String> images = <String>[
    'image/places/india_chennai_flower_market.png',
    'image/places/india_chennai_highway.png',
    'image/places/india_chettinad_produce.png',
    'image/places/india_chettinad_silk_maker.png',
    'image/places/india_pondicherry_beach.png',
    'image/places/india_pondicherry_fisherman.png',
    'image/places/india_pondicherry_salt_farm.png',
    'image/places/india_tanjore_bronze_works.png',
    'image/places/india_tanjore_market_merchant.png',
  ];

  void pushFullImageScreenWidget() {
    final TransitionRoute<void> route = PageRouteBuilder<void>(pageBuilder:
        (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
      return ImageFullScreen(images: images);
    });
    Navigator.of(context).push(route);
  }

//  VideoPlayerController butterflyController;
  final Completer<Null> connectedCompleter = Completer<Null>();

  void pushFullVideoScreenWidget(String dataSource) {
    final TransitionRoute<void> route = PageRouteBuilder<void>(pageBuilder:
        (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
      return VideoFullScreen(
        dataSource: dataSource,
      );
    });
    Navigator.of(context).push(route);
  }

  Future<Null> initController(VideoPlayerController controller) async {
    controllers.add(controller);
    await controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  //语音条目
  Widget buildListTileOfVideo(BuildContext context) {
    VideoPlayerController controller =
        VideoPlayerController.asset('videos/butterfly.mp4');
    initController(controller);
    return ListTile(
        leading: buildListTileLeading(context),
        title: Text(
            'CircleAvatar, which shows an icon representing a person and is often used as the leading element of a ListTile.'),
        subtitle: GestureDetector(
            onTap: () {
              pushFullVideoScreenWidget('videos/butterfly.mp4');
            },
            child: Container(
              width: 200,
              height: 150,
              child: Hero(
                tag: controller,
                child: Stack(
                  children: <Widget>[
                    VideoPlayer(controller),
                    Center(child: Icon(Icons.play_circle_filled))
                  ],
                ),
              ),
            )));
  }

  //视频条目
  Widget buildListTileOfVoice(BuildContext context) {}

  //纯文字条目
  Widget buildListTileOfText(BuildContext context) {
    return ListTile(
      leading: buildListTileLeading(context),
      title: Text(
          'Material Components 库中的Card包含相关内容块，可以由大多数类型的widget构成，但通常与ListTile一起使用。Card有一个孩子， 但它可以是支持多个孩子的列，行，列表，网格或其他小部件。默认情况下，Card将其大小缩小为0像素。您可以使用SizedBox来限制Card的大小。'),
    );
  }

  String getDate() {
    DateTime date = DateTime.now();
    return "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
