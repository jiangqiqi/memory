import 'package:flutter/material.dart';

//class ImageFullScreen extends StatefulWidget {
//  const ImageFullScreen({this.images});
//
//  final List<String> images;
//
//  @override
//  State<StatefulWidget> createState() => _ImageFullScreenState();
//}

class ImageFullScreen extends StatelessWidget {
  const ImageFullScreen({this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    return Scaffold(
      backgroundColor: Colors.black54,
      body: DefaultTabController(
        length: images.length,
        child: Container(
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              TabBarView(
                children: images.map<Widget>((String image) {
                  return Center(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          image,
                          fit: BoxFit.cover,
                        )),
                  );
                }).toList(),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: TabPageSelector(
                  controller: controller,
                  selectedColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
//  @override
//  Widget build(BuildContext context) {
//    final TabController controller = DefaultTabController.of(context);
//    return Scaffold(
//      body: Text('Jiangliang'),
//    );
//  }
}
