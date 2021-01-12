import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/model/recommend.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendPage extends StatefulWidget {
  User user;

  RecommendPage(this.user);

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  DBHelper dbHelper = new DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/banner.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Text("추천 레시피"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        child: _buildBody(),
      ),
    );
  }



  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('fridge')
          .doc(widget.user.uid)
          .collection('ing_list')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data.docs.isEmpty) {
          return Image(
            image: AssetImage('images/img_empty3.png'),
            fit: BoxFit.fill,
          );
        } else {
          return _buildList(context, snapshot.data.docs);
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<String> ingList =
        snapshot.map((e) => e.data()['iName'].toString()).toList();
    print(ingList);
    return FutureBuilder(
      future: dbHelper.getRecommendList(ingList),
      builder: (BuildContext context, AsyncSnapshot<List<Recommend>> snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data.map((e) => _buildTile(e)).toList(),
          );
        } else {
          return Image(
            image: AssetImage('images/img_empty3.png'),
            fit: BoxFit.fill,
          );
        }
      },
    );
  }
  Widget _buildTile(Recommend recommend) {
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Image.network(
            recommend.fImg,
            width: MediaQuery.of(context).size.width,
            height: 300,
            fit: BoxFit.cover,
          ),
          Container(
            margin: EdgeInsets.only(top: 190.0),
            height: 110.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                //라인 색상을 전환할 때 사용
                colors: <Color>[Color(0x00736AB7), Colors.brown[400]],
                stops: [0.0, 0.9], //시작과 끝을 설정
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(0.0, 0.9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('"${recommend.intro}"'
              ,
              style: TextStyle(color: Colors.white, fontSize: 18),textAlign: TextAlign.center,
            ),
          ),

        ],
      ),
    );
  }
}
