import 'dart:io';
class Classification{

  Classification({this.id,this.iconName,this.title,this.file});
  final String id;
  final String iconName;
  final String title;
  final File file;
  String get tag => title;

}