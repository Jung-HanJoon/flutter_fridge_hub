import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/model/fridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FridgePage extends StatefulWidget {
  User user;

  FridgePage(this.user);

  @override
  _FridgePageState createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  DBHelper dbHelper = new DBHelper();
  List<String> ingList = [];
  TextEditingController controller = TextEditingController();
  String text;

  void _loadData() async {
    await dbHelper.getIngList().then((result) {
      if (result != null) {
        setState(() {
          ingList = result;
          print('db load succecs');
        });
      } else {
        setState(() {
          ingList = ['리스트', '호출', '실패'];
          print('db load fail');
        });
      }
    });
  }

  void addIng(String ings) {
    FirebaseFirestore.instance
        .collection('fridge')
        .doc(widget.user.uid)
        .collection('ing_list')
        .add({
      'iName': ings, //재료 이름
      'quantity': '', //양
    }).whenComplete(() => print('insert success'));
  }

  void addCart(String ings) {
    FirebaseFirestore.instance
        .collection('fridge')
        .doc(widget.user.uid)
        .collection('cart_list')
        .add({
      'iName': ings, //재료 이름
      'quantity': '', //양
    }).whenComplete(() => print('insert success'));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
        title: Text("냉장고 관리"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/fridgeback.png'), fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(children: <Widget>[
                Padding(

                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.white,
                    child: TypeAheadField(

                      textFieldConfiguration: TextFieldConfiguration(
                          controller: controller,
                          autofocus: false,
                          style: DefaultTextStyle.of(context)
                              .style
                              .copyWith(fontStyle: FontStyle.italic),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "재료 추가하기",
                              fillColor: Colors.white70
                          ),),
                      suggestionsCallback: (pattern) async {
                        return ingList.where(
                            (s) => s.toLowerCase().contains(pattern.toLowerCase()));
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: IconButton(
                            icon: Icon(Icons.shopping_cart),
                            onPressed: () => addCart(suggestion),
                          ),
                          title: Text(suggestion),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => addIng(suggestion),
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        controller.text = suggestion;
                      },
                    ),
                  ),
                ),
              ]),
              Row(
                children: [
                  Image(
                    image: AssetImage('images/ic_fr.png'),
                    height: 50,
                    width: 50,
                  ),
                  Text(
                    '냉장고 관리',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ],
              ),
              _buildIngGrid('ing_list'),
              Row(
                children: [
                  Image(
                    image: AssetImage('images/ic_bc.png'),
                    height: 50,
                    width: 50,
                  ),
                  Text(
                    '장바구니 관리',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  )
                ],
              ),

              _buildIngGrid('cart_list'),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildIngGrid(String category) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            height: (MediaQuery.of(context).size.height - 330) / 2,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('fridge')
                  .doc(widget.user.uid)
                  .collection(category)
                  .snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }else{
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 5,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final fridge =
                      Fridge.fromSnapshot(snapshot.data.docs[index]);
                      return InkWell(
                        onTap: () {
                          var dialtec = TextEditingController();
                          dialtec.text = fridge.quantity;
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("개수 수정"),
                                  content: TextField(
                                    controller: dialtec,
                                  ),
                                  actions: [
                                    MaterialButton(
                                        child: Text("수정"),
                                        onPressed: () {
                                          fridge.reference.update({
                                            'quantity': dialtec.text,
                                          });
                                          Navigator.pop(context);
                                        }),
                                  ],
                                );
                              });
                        },
                        onLongPress: () {
                          final snackBar = SnackBar(
                            content: Text('이 재료를 삭제하시겠습니까?'),
                            action: SnackBarAction(
                              label: '삭제',
                              onPressed: () {
                                fridge.reference.delete();
                              },
                            ),
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        },
                        child: Container(
                            child: CircleAvatar(
                              backgroundImage: AssetImage('images/dish.png'),
                              backgroundColor: Colors.white,
                              child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        fridge.iName,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Text(fridge.quantity),
                                    ],
                                  )),
                            )),
                      );
                    },
                    staggeredTileBuilder: (int index) =>
                        StaggeredTile.count(1, 1),
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 4.0,
                  );
                }
              },
            )),
      ),
    );
  }
}
