import 'package:intl/intl.dart';

class Comment{
  String date;
  String name;
  String photoUrl;
  String user;
  String content;
  int dateInt;

  Comment.fromMap(Map<String, dynamic> map)
      : assert(map['date'] != null),
        assert(map['name'] != null),
        assert(map['photoUrl'] != null),
        assert(map['user'] != null),
        assert(map['content'] != null),
        this.date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(map['date'])),
        this.dateInt=map['date'],
        this.name = map['name'],
        this.photoUrl = map['photoUrl'],
        this.user = map['user'],
        this.content = map['content'];

  Comment({this.date, this.name, this.photoUrl, this.user, this.content});

// Comment({this.content, this.date, this.name, this.photoUrl, this.user});

  // Comment(Map<String, dynamic> map){
  //   this.date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(map['date']));
  //   this.name = map['name'];
  //   this.photoUrl = map['photoUrl'];
  //   this.user = map['user'];
  //   this.content = map['content'];
  // }
}