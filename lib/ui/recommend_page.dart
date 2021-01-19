import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/model/recommend.dart';
import 'package:f_fridgehub/ui/recipe_page.dart';
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
  String dropdownValue = '재료 적중률';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          "추천 레시피",
          // style: TextStyle(color: Colors.black),
        ),
        actions: [
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['최대 소비', '재료 적중률', '주재료 우선']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 30,),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     children: [
            //       Text('추천', style: TextStyle(fontSize: 35, color: Colors.deepPurple, fontWeight: FontWeight.bold),),
            //       Text('레시피', style: TextStyle(fontSize: 35, color: Colors.deepOrange, fontWeight: FontWeight.bold),),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 10,),
            _buildBody(),
          ],
        ),
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
      future: dbHelper.getRecommendList3(ingList),
      builder: (BuildContext context, AsyncSnapshot<List<Recommend>> snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(
              children: snapshot.data.map((e) => _buildTile(e)).toList(),
            ),
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
    return GestureDetector(
      onTap: ()=> Navigator.push(context, _createRoute(recommend.fName)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Hero(
                tag: recommend.fImg.toString(),
                child: Image.network(
                  recommend.fImg,
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.6)
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('재료 : ${recommend.ready} / ${recommend.need}'),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.only(right: 10),
                  height: 300.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      //라인 색상을 전환할 때 사용
                      colors: <Color>[Color(0x00ffffff), Colors.white],
                      stops: [0.0, 0.9], //시작과 끝을 설정
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(1.5, 0.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(8.0), child: Container()),
                      Stack(
                        children: <Widget>[
                          Text(
                            '구분',
                            style: TextStyle(
                              fontSize: 20,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.white,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            '구분',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          Text(
                            recommend.cat,
                            style: TextStyle(
                              fontSize: 35,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            recommend.cat,
                            style: TextStyle(
                                fontSize: 35,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      // Text(
                      //   recommend.cat,
                      //   style: TextStyle(fontSize: 35),
                      // ),
                      Padding(padding: EdgeInsets.all(8.0), child: Container()),
                      Stack(
                        children: <Widget>[
                          Text(
                            '난이도',
                            style: TextStyle(
                              fontSize: 20,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.white,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            '난이도',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          Text(
                            recommend.difficult,
                            style: TextStyle(
                              fontSize: 35,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            recommend.difficult,
                            style: TextStyle(
                                fontSize: 35,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      // Text(
                      //   recommend.difficult,
                      //   style: TextStyle(fontSize: 35),
                      // ),
                      Padding(padding: EdgeInsets.all(8.0), child: Container()),
                      Stack(
                        children: <Widget>[
                          Text(
                            '조리시간',
                            style: TextStyle(
                              fontSize: 20,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.white,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            '조리시간',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          Text(
                            recommend.time,
                            style: TextStyle(
                              fontSize: 35,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          // Solid text as fill.
                          Text(
                            recommend.time,
                            style: TextStyle(
                                fontSize: 35,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      // Text(
                      //   '조리시간',
                      //   style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                      // ),

                      // Text(
                      //   recommend.time,
                      //   style: TextStyle(fontSize: 35),
                      // ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: <Widget>[
                            Text(
                              recommend.fName,
                              style: TextStyle(
                                fontSize: 30,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                              ),
                            ),
                            // Solid text as fill.
                            Text(
                              recommend.fName,
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.orange[400]),
                              ),
                          ],
                        ),
                        Text(
                          '"${recommend.intro}"',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  height: 110.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      //라인 색상을 전환할 때 사용
                      colors: <Color>[Color(0x00777777), Colors.black],
                      stops: [0.0, 0.9], //시작과 끝을 설정
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(0.0, 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Route _createRoute(String fname) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => RecipePage(widget.user, search: fname,),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
