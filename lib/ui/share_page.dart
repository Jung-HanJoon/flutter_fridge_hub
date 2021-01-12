import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SharePage extends StatefulWidget {
  User user;
  SharePage(this.user);
  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
          BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/banner.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Text("공유 공간"),
      ),
      body: _buildTimeLine(),

    );
  }

  Widget _buildTimeLine() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('fridge')
          .doc(widget.user.uid)
          .collection('timeline')
          .snapshots(),
      builder: (context, snapshot) {
        if(snapshot.data.docs.isEmpty){
          return Center(
            child: Text('타임라인은 공사중입니다')
            //CircularProgressIndicator(),
          );
        }else{
          List<Widget> a;
    for(int i = 0 ; i< snapshot.data.docs.length ;i++){
      if(i==0){
        a.add(TimelineTile(
          isFirst: true,
          alignment: TimelineAlign.manual,
          lineXY: 0.3,
          startChild: Container(
            child: Text('2021. 01. 12'),
            // color: Colors.amberAccent,
          ),
          endChild: Container(
            child: Center(child: Text('회원가입')),
            constraints: const BoxConstraints(
              minHeight: 120,
            ),
            // color: Colors.lightGreenAccent,
          ),
        ));
      }else{
        a.add(TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.3,
          startChild: Container(
            child: Text('날짜'),
            // color: Colors.amberAccent,
          ),
          endChild: Container(
            child: Center(child: Text('내용')),
            constraints: const BoxConstraints(
              minHeight: 120,
            ),
            // color: Colors.lightGreenAccent,
          ),
        ));
      }
    }
          return Column(
            children:snapshot.data.docs.map((e)=> TimelineTile(
              isFirst: true,
              alignment: TimelineAlign.manual,
              lineXY: 0.3,
              startChild: Container(
                child: Text('2021. 01. 10'),
                // color: Colors.amberAccent,
              ),
              endChild: Container(
                child: Center(child: Text('회원가입')),
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                // color: Colors.lightGreenAccent,
              ),
            )).toList(),
          );
        }
      },
    );
  }
}
