import 'package:flutter/material.dart';
import 'package:memory/model/classification.dart';
import 'dart:io';
import 'package:memory/utils/media_util.dart';
import 'memory_list.dart';

enum DialogAction {
  cancel,
  confirm,
}

const double _kMinFlingVelocity = 800.0;
bool flag = false;

typedef BannerTapCallback = void Function(Classification classification);

typedef OnClickCallback = void Function(Classification classification);

class GridClassifyViewer extends StatefulWidget {
  const GridClassifyViewer({Key key, this.classification}) : super(key: key);
  final Classification classification;

  @override
  State<StatefulWidget> createState() => _GridClassifyViewerState();
}

class _GridClassifyViewerState extends State<GridClassifyViewer>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = _controller.drive(Tween<Offset>(
        begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: Image.asset(
            widget.classification.iconName,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class GridClassifyItem extends StatelessWidget {
  GridClassifyItem({
    Key key,
    @required this.classification,
    @required this.onBannerTap,
    @required this.onClickCallback,
  })  : assert(classification != null),
        assert(onBannerTap != null),
        super(key: key);

  final Classification classification;
  final BannerTapCallback onBannerTap;
  final OnClickCallback onClickCallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onBannerTap(classification);
      },
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          title: _GridTitleText(classification.title),
          trailing: !flag
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        onClickCallback(classification);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
        ),
        child: Hero(
          tag: classification.tag,
          child: classification.file != null
              ? Image.file(
                  classification.file,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  classification.iconName,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(text),
    );
  }
}

class GridClassify extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GridClassifyState();
}

final List<Classification> classifies = <Classification>[
  Classification(
      id: '10000',
      title: '孩子',
      iconName: 'image/places/india_chennai_flower_market.png'),
  Classification(
      id: '10001',
      title: '爱人',
      iconName: 'image/places/india_tanjore_bronze_works.png'),
  Classification(
      id: '10002',
      title: '父母',
      iconName: 'image/places/india_thanjavur_market.png'),
];

class GridClassifyState extends State<GridClassify> {
  String classifyName;
  static final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text('记忆永恒'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  flag = !flag;
                });
              })
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: SafeArea(
                  top: false,
                  bottom: false,
                  child: GridView.count(
                    crossAxisCount:
                        (orientation == Orientation.portrait ? 2 : 3),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    padding: const EdgeInsets.all(4.0),
                    childAspectRatio:
                        (orientation == Orientation.portrait) ? 1.0 : 1.3,
                    children:
                        classifies.map<Widget>((Classification classification) {
                      return GridClassifyItem(
                        classification: classification,
                        onBannerTap: (Classification classification) {
                          print('跳转至特定模块记忆列表界面');
                          Navigator.push(context, new MaterialPageRoute(builder: (context){
                            return new MemoryList(classification: classification,);
                          }));
                        },
                        onClickCallback: (Classification classification) {
                          showDeleteModuleDialog(classification);
                        },
                      );
                    }).toList(),
                  )))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.add),
          onPressed: () {
            print('添加新的记忆模块');
            showAddModuleDialog();
          }),
    );
  }

  void showDeleteModuleDialog(Classification classification) {
    showDialog<DialogAction>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('确定删除该分类？'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, DialogAction.cancel);
                },
                child: const Text('取消'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, DialogAction.confirm);
                },
                child: const Text('确定'),
              )
            ],
          );
        }).then<void>((DialogAction value) {
      if (value == DialogAction.confirm) {
        setState(() {
          classifies.remove(classification);
        });
      }
    });
  }

  void showAddModuleDialog<T>() {
    showDialog<T>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(
              child: Text('添加分类'),
            ),
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                alignment: Alignment.bottomLeft,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '分类名称',
                    filled: true,
                  ),
                  style: Theme.of(context).textTheme.headline,
                  onChanged: (String value) {
                    classifyName = value;
                  },
                ),
              ),
              GestureDetector(
                  onTap: () {
                    if (classifyName != null) {
                      _selectedImage();
                      Navigator.pop(context, classifyName);
                    } else {
                      //TODO:提醒用户分类名称不能为空
                      _globalKey.currentState.showSnackBar(
                          SnackBar(content: const Text('请输入分类名称')));
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'image/places/add.png',
                      width: 100,
                      height: 150,
                    ),
                  ))
            ],
          );
        }).then((T value) {
      setState(() {
        _imageFile.then((List<File> files) {
          for (File file in files) {
            Classification classification = Classification(
              title: '$value',
              file: file,
            );
            classifies.add(classification);
          }
        });
        classifyName = null;
        _imageFile = null;
      });
    });
  }

  Future<List<File>> _imageFile;

  /**
   * 打开系统相册
   */
  void _selectedImage() {
//    setState(() {
//      _imageFile = ImagePicker.pickImage(source: ImageSource.gallery);
//    });
    setState(() {
      _imageFile = MediaUtil.getAllImages(1);
    });
  }
}

void main() => runApp(MaterialApp(
      home: GridClassify(),
    ));
