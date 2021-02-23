import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/model/fridge.dart';
import 'package:f_fridgehub/state/scrolldetector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

class FridgePage extends StatefulWidget {
  final User user;

  FridgePage(this.user);

  @override
  _FridgePageState createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  DBHelper dbHelper = new DBHelper();
  List<String> ingList = [];
  TextEditingController controller = TextEditingController();
  String text;
  String currentFridge;

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

  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    getFridge();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        Provider.of<ScrollDetector>(context, listen: false).visible(false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        Provider.of<ScrollDetector>(context, listen: false).visible(true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.orangeAccent,
        title: Row(
          children: [
            Text("냉장고 관리"),
            Spacer(),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.4)),
              width: 250,
              height: 40,
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: controller,
                  autofocus: false,
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontStyle: FontStyle.italic),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(15)),
                      hintText: "재료 추가하기",
                      fillColor: Colors.white70),
                ),
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
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/fridgeback.png'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: OrientationBuilder(builder: (context, orientation) {
            return StaggeredGridView.count(
              controller: _scrollController,
              crossAxisCount: orientation == Orientation.portrait ? 1 : 2,
              staggeredTiles: [
                StaggeredTile.count(1, 1),
                StaggeredTile.count(1, 1)
              ],
              mainAxisSpacing: 0,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Image(
                          image: AssetImage('images/ic_fr.png'),
                          height: 50,
                          width: 50,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '냉장고 관리',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        constraints: BoxConstraints(
                            minHeight: orientation == Orientation.portrait
                                ? size.height * 0.3
                                : size.height - 200),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.brown.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _buildIngGrid('ing_list')),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Image(
                          image: AssetImage('images/ic_bc.png'),
                          height: 50,
                          width: 50,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '장바구니 관리',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        clipBehavior: Clip.antiAlias,
                        constraints: BoxConstraints(
                            minHeight: orientation == Orientation.portrait
                                ? size.height * 0.3
                                : size.height - 200),
                        decoration: BoxDecoration(
                          color: Colors.brown.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _buildIngGrid('cart_list')),
                  ],
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildIngGrid(String category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('fridge')
            .doc(currentFridge)
            .collection(category)
            .snapshots(),
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            child: snapshot.hasData
                ? StaggeredGridView.countBuilder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 5,
                    itemCount: snapshot.data?.docs?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final fridge =
                          Fridge.fromSnapshot(snapshot.data?.docs[index]);
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
                        child: CircleAvatar(
                          backgroundImage: AssetImage('images/dish.png'),
                          backgroundColor: Colors.white,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                fridge.iName,
                                style: TextStyle(color: Colors.black),
                                maxLines: 1,
                              ),
                              AutoSizeText(
                                fridge.quantity,
                                maxLines: 1,
                              ),
                            ],
                          )),
                        ),
                      );
                    },
                    staggeredTileBuilder: (int index) =>
                        StaggeredTile.count(1, 1),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
            duration: Duration(milliseconds: 500),
          );
        },
      ),
    );
  }

  void getFridge() async {
    String temp = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.user.uid)
        .get()
        .then((value) => value.data()['current_fridge'].toString());
    setState(() {
      currentFridge = temp;
    });
  }
}
