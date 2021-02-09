import 'dart:async';

import 'package:f_fridgehub/costum_widget/border_text.dart';
import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/model/recommend.dart';
import 'package:f_fridgehub/ui/recipe_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendPage extends StatefulWidget {
  final User user;

  RecommendPage(this.user);

  @override
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  DBHelper dbHelper = new DBHelper();
  String dropdownValue = '재료 보유율';
  Size size;
  bool isChecked = false;
  String currentFridge;
  bool isLoading = true;

  void startTimer() {
    Timer.periodic(const Duration(seconds: 3), (t) {
      t.cancel(); //stops the timer
      if(mounted)
      setState(() {
        isLoading = false; //set loading to false
      });
    });
  }


  @override
  void initState() {
    super.initState();
    getfridge();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          "추천 레시피",
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isChecked = !isChecked;
                    });
                  },
                  child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(100)),
                      child: Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: isChecked
                                      ? Colors.white
                                      : Colors.transparent),
                              color:
                                  isChecked ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(100)))),
                ),
              ),
              Text(
                '양념 제외',
                style: TextStyle(
                    color: isChecked ? Colors.white : Colors.grey[600]),
              ),
              SizedBox(
                width: 10,
              ),
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: <String>['최대 소비', '재료 보유율']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('fridge')
          .doc(currentFridge)
          .collection('ing_list')
          .snapshots(),
      builder: (context, snapshot) {
        if ((snapshot.data == null) || (snapshot.data.docs.isEmpty ?? true)) {
          return isLoading ? Center(child: CircularProgressIndicator()) : Image(image: AssetImage('images/img_empty3.png'),fit: BoxFit.cover,);
        } else {
          return _buildList(context, snapshot.data.docs);
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<String> ingList =
        snapshot.map((e) => e.data()['iName'].toString()).toList();
    return FutureBuilder(
      future: dropdownValue == '재료 보유율'
          ? dbHelper.getRecommendList2(ingList, isChecked)
          : dbHelper.getRecommendList1(ingList, isChecked),
      builder: (BuildContext context, AsyncSnapshot<List<Recommend>> snapshot) {
        return AnimatedSwitcher(
          child: snapshot.hasData ? Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) =>
        _buildTile(snapshot.data[index])),
        ) : CircularProgressIndicator()
              ,
          duration: Duration(milliseconds: 300),
        );
      },
    );
  }

  Widget _buildTile(Recommend recommend) {
    return GestureDetector(
      onTap: () => Navigator.push(context, _createRoute(recommend.fName)),
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
                  width: size.width,
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
                      color: Colors.white.withOpacity(0.6)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text('재료 : ${recommend.ready} / ${recommend.need}'),
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
                    children: [
                      Padding(padding: EdgeInsets.all(8.0), child: Container()),
                      BorderText(
                        text: '구분',
                        size: 20,
                        borderColor: Colors.white,
                        textColor: Colors.grey[800],
                      ),
                      BorderText(
                        text: recommend.cat,
                        size: 35,
                        borderColor: Colors.black,
                        textColor: Colors.white,
                      ),
                      Padding(padding: EdgeInsets.all(8.0), child: Container()),
                      BorderText(
                        text: '난이도',
                        size: 20,
                        borderColor: Colors.white,
                        textColor: Colors.grey[800],
                      ),
                      BorderText(
                        text: recommend.difficult,
                        size: 35,
                        borderColor: Colors.black,
                        textColor: Colors.white,
                      ),
                      Padding(padding: EdgeInsets.all(8.0), child: Container()),
                      BorderText(
                        text: '조리시간',
                        size: 20,
                        borderColor: Colors.white,
                        textColor: Colors.grey[800],
                      ),
                      BorderText(
                        text: recommend.time,
                        size: 35,
                        borderColor: Colors.black,
                        textColor: Colors.white,
                      ),
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
                                  fontSize: 30, color: Colors.orange[400]),
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

  Route _createRoute(String fName) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => RecipePage(
        widget.user,
        search: fName,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  void getfridge() async{
    String temp = await FirebaseFirestore.instance.collection('user').doc(widget.user.uid).get().then((value) => value.data()['current_fridge'].toString());
    setState(() {
      currentFridge = temp;
    });
}
}
