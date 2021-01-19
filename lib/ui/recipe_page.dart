import 'dart:math';

import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/main.dart';
import 'package:f_fridgehub/model/base.dart';
import 'package:f_fridgehub/model/ing.dart';
import 'package:f_fridgehub/model/recipe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipePage extends StatefulWidget {
  User user;
  String search;

  RecipePage(this.user, {this.search});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  DBHelper dbHelper = new DBHelper();
  List<String> recipeList = [];
  TextEditingController controller = TextEditingController();
  Base base = Base();
  List<Ing> ing;
  List<Recipe> recipe;
  List<String> fridge = [];

  void _loadData() async {
    await dbHelper.getRecipeList().then((result) {
      if (result != null) {
        setState(() {
          recipeList = result;
          print('db load succecs');
        });
      } else {
        setState(() {
          recipeList = ['리스트', '호출', '실패', 'ㅜㅜ'];
          print('db load fail');
        });
      }
    });
  }

  @override
  void initState() {
    _loadData();
    getfromfridge();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.search != null) {
      recipe = null;
      ing = null;
      dbHelper.getBaseRecipe(widget.search).then((value) {
        base = value;
        Future.wait([
          dbHelper.getIng(value.foodID),
          dbHelper.getRecipe(value.foodID)
        ]).then((value) => setState(() {
              ing = value[0];
              recipe = value[1];
            }));
      });
      controller.text = widget.search;
      widget.search = null;
    }
    return Scaffold(
      backgroundColor: Colors.grey[300],
        resizeToAvoidBottomPadding: false,
        // appBar: AppBar(title: Text('레시피'),),
        body: Stack(children: [
          SingleChildScrollView(
            child: Column(children: <Widget>[
              SizedBox(
                height: 25,
              ),
              Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                        controller: controller,
                        autofocus: controller.text.isNotEmpty ? false : true,
                        onTap: (){
                          controller.text='';
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            hintStyle: new TextStyle(color: Colors.grey[800]),
                            hintText: "레시피 검색",
                            fillColor: Colors.white70)),
                    suggestionsCallback: (pattern) async {
                      return recipeList.where((s) =>
                          s.toLowerCase().contains(pattern.toLowerCase()));
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: Icon(Icons.shopping_cart),
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      recipe = null;
                      ing = null;
                      widget.search = null;
                      dbHelper.getBaseRecipe(suggestion).then((value) {
                        base = value;
                        Future.wait([
                          dbHelper.getIng(value.foodID),
                          dbHelper.getRecipe(value.foodID)
                        ]).then((value) => setState(() {
                              ing = value[0];
                              recipe = value[1];
                            }));
                      });
                      controller.text = suggestion;
                    },
                  ),
                )
              ]),
              _buildBase(),
              SizedBox(
                height: 10,
              ),
              _buildIng(),
              SizedBox(
                height: 10,
              ),
              _buildRecipe(),
            ]),
          ),
        ]));
  }

  Widget _buildBase() {
    if (base == null) {
      return Center(
        child: Text('레시피를 검색하세요'),
      );
    } else {
      return FutureBuilder(
        future: dbHelper.getBaseRecipe(base.fName),
        builder: (BuildContext context, AsyncSnapshot<Base> snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35)),
              child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Hero(
                      tag: snapshot.data.fImg.toString(),
                      child: Image.network(
                        snapshot.data.fImg,
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 190.0),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: <Widget>[
                              Text(
                                snapshot.data.fName,
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
                                snapshot.data.fName,
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.orange[400]),
                              ),
                            ],
                          ),
                          SizedBox(height: 8,),
                          Text(
                            snapshot.data.intro,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ]),
            );
          } else {
            return Container();
          }
        },
      );
    }
  }

  Widget _buildIng() {
    List<Map<String, dynamic>> cartlist=[];
    if (ing != null) {
      List<Ing> mainings = [];
      List<Ing> subings = [];
      List<Ing> sub2ings = [];
      for (int i = 0; i < ing.length; i++) {
        switch (ing[i].iCat) {
          case '주재료':
            mainings.add(ing[i]);
            break;
          case '부재료':
            subings.add(ing[i]);
            break;
          case '양념':
            sub2ings.add(ing[i]);
            break;
        }
      }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
              BoxShadow( color: Colors.grey[500], offset: Offset(4.0, 4.0), blurRadius: 15.0, spreadRadius: 1.0, ), BoxShadow( color: Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0,)
                  ],
                  color: Colors.grey[300]),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                    title: Text(
                      '재료',
                      style: TextStyle(fontSize: 25),
                    ),
                    children: []
                      ..add(Column(
                        children: [
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('주재료', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            height: 3,
                            width: MediaQuery.of(context).size.width - 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                          ),
                        ],
                      ))
                      ..addAll(
                        mainings.map((e) {
                          TextStyle tstyle = new TextStyle(color: Colors.black);
                          if (fridge.contains(e.iName)) {
                            tstyle = TextStyle(color: Colors.blue);
                          }else{
                            cartlist.add(Map<String, dynamic>()..addAll({'iName':e.iName, 'quantity':e.quantity}));
                          }
                          return ListTile(
                            leading: Text(
                              e.iName,
                              style: tstyle,
                            ),
                            trailing: Text(
                              e.quantity,
                              style: tstyle,
                            ),
                          );
                        }),
                      )
                      ..add(Column(
                        children: [
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('부재료', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            height: 3,
                            width: MediaQuery.of(context).size.width - 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                          ),
                        ],
                      ))
                      ..addAll(
                        subings.map((e) {
                          TextStyle tstyle = new TextStyle(color: Colors.black);
                          if (fridge.contains(e.iName)) {
                            tstyle = TextStyle(color: Colors.blue);
                          }else{
                            cartlist.add(Map<String, dynamic>()..addAll({'iName':e.iName, 'quantity':e.quantity}));
                          }
                          return ListTile(
                            leading: Text(e.iName, style: tstyle),
                            trailing: Text(e.quantity, style: tstyle),
                          );
                        }).toList(),
                      )
                      ..add(Column(
                        children: [
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('양념', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            height: 3,
                            width: MediaQuery.of(context).size.width - 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                          ),
                        ],
                      ))
                      ..addAll(
                        sub2ings.map((e) {
                          TextStyle tstyle = new TextStyle(color: Colors.black);
                          if (fridge.contains(e.iName)) {
                            tstyle = TextStyle(color: Colors.blue);
                          }else{
                            cartlist.add(Map<String, dynamic>()..addAll({'iName':e.iName, 'quantity':e.quantity}));
                          }
                          return ListTile(
                            leading: Text(e.iName, style: tstyle),
                            trailing: Text(e.quantity, style: tstyle),
                          );
                        }).toList(),
                      )..add(
                        ElevatedButton(onPressed: (){
                          addCart(cartlist);
                        }, child: Center(child: Text('장바구니 추가')),
                        )
                      )
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Container(),
      );
    }
  }

  Widget _buildRecipe() {
    if (recipe != null) {
      return Column(
        children: recipe.map((e) {
          String a;
          if (e.pImg == null) {
            a = '';
          } else {
            a = e.pImg;
          }
          return ListTile(
            leading: Text(e.pOrder.toString(), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
            title: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow( color: Colors.grey[500], offset: Offset(4.0, 4.0), blurRadius: 15.0, spreadRadius: 1.0, ), BoxShadow( color: Colors.white, offset: Offset(-4.0, -4.0), blurRadius: 15.0, spreadRadius: 1.0,)

                  ],
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.process, style: TextStyle(),),
                    SizedBox(
                      height: 8,
                    ),
                    if (a != '')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: a,
                          placeholder: (context, url) =>
                              CupertinoActivityIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }

  void getfromfridge() async {
    var result = await FirebaseFirestore.instance
        .collection('fridge')
        .doc(widget.user.uid)
        .collection('ing_list')
        .get();
    setState(() {
      fridge = result.docs.map((e) => e['iName'].toString()).toList();
    });
    print(fridge);
  }


  void addCart(List<Map<String, dynamic>> ings) {
    ings.forEach((element) {
      FirebaseFirestore.instance
          .collection('fridge')
          .doc(widget.user.uid)
          .collection('cart_list')
          .add(element).catchError((onError)=>print(onError));
    });
  }
}
