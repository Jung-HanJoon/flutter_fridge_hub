import 'package:f_fridgehub/costum_widget/border_text.dart';
import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/model/base.dart';
import 'package:f_fridgehub/model/comment.dart';
import 'package:f_fridgehub/model/ing.dart';
import 'package:f_fridgehub/model/recipe.dart';
import 'package:f_fridgehub/model/recommend.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RecipePage extends StatefulWidget {
  final User user;
  final String search;

  RecipePage(this.user, {this.search});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  DBHelper dbHelper = new DBHelper();
  List<String> recipeList = [];
  TextEditingController controller = TextEditingController();
  Base base;
  List<Ing> ing;
  List<Recipe> recipe;
  List<String> fridge = [];
  String search;
  List favorList = [];

  String currentFridge;

  void _loadData() async {
    await dbHelper.getRecipeList().then((result) {
      if (result != null) {
        setState(() {
          recipeList = result;
          print('db load succecs');
        });
      } else {
        setState(() {
          recipeList = ['요리 정보를 찾을 수 없어요!'];
          print('db load fail');
        });
      }
    });
  }

  @override
  void initState() {
    _loadData();
    getFridge();
    super.initState();
    search = widget.search;
    getFavor();
  }

  @override
  Widget build(BuildContext context) {
    if (search != null) {
      recipe = null;
      ing = null;
      dbHelper.getBaseRecipe(search).then((value) {
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
      search = null;
    }
    return Scaffold(
        backgroundColor: Colors.grey[300],
        resizeToAvoidBottomPadding: false,
        // appBar: AppBar(title: Text('레시피'),),
        body: base == null
            ? Column(children: [
                SizedBox(
                  height: 25,
                ),
                Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: controller,
                          // autofocus: controller.text.isNotEmpty ? false : true,
                          onTap: () {
                            controller.text = '';
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
                        search = null;
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
                Expanded(
                  flex: 1,
                  child: Center(
                      child: Text(
                    '요리를 검색해 보세요',
                    style: TextStyle(fontSize: 25),
                  )),
                ),
                _buildFavor(),
              ])
            : SingleChildScrollView(
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
                            // autofocus: controller.text.isNotEmpty ? false : true,
                            onTap: () {
                              controller.text = '';
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                filled: true,
                                hintStyle:
                                    new TextStyle(color: Colors.grey[800]),
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
                          search = null;
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
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      thickness: 2,
                    ),
                  ),
                  CommentAddWidget(widget.user, base.foodID),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      thickness: 2,
                    ),
                  ),
                  _buildFavor(),
                ]),
              ));
  }

  Widget _buildBase() {
    if (base == null) {
      return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Center(
              child: Text(
            '요리를 검색해 보세요',
            style: TextStyle(fontSize: 25),
          )));
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
                                    fontSize: 30, color: Colors.orange[400]),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            snapshot.data.intro,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        padding: EdgeInsets.zero,
                        child: Center(
                            child: InkWell(
                          onTap: () {
                            setFavor();
                          },
                          child: Icon(
                            favorList.any((element) =>
                                    element.toString() == base.foodID)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 30,
                          ),
                        )),
                      ),
                    )
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
    List<Map<String, dynamic>> cartList = [];
    if (ing != null) {
      List<Ing> mainIng = [];
      List<Ing> subIng = [];
      List<Ing> sub2Ing = [];
      for (int i = 0; i < ing.length; i++) {
        switch (ing[i].iCat) {
          case '주재료':
            mainIng.add(ing[i]);
            break;
          case '부재료':
            subIng.add(ing[i]);
            break;
          case '양념':
            sub2Ing.add(ing[i]);
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
                    BoxShadow(
                      color: Colors.grey[500],
                      offset: Offset(4.0, 4.0),
                      blurRadius: 15.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4.0, -4.0),
                      blurRadius: 15.0,
                      spreadRadius: 1.0,
                    )
                  ],
                  color: Colors.grey[300]),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                      title: Text(
                        '재료',
                        style: TextStyle(fontSize: 25),
                      ),
                      children: [
                        if (mainIng.isNotEmpty)
                          Column(
                            children: [
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '주재료',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                height: 3,
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white),
                              ),
                              ...mainIng.map((e) {
                                TextStyle tstyle =
                                    new TextStyle(color: Colors.black);
                                if (fridge.contains(e.iName)) {
                                  tstyle = TextStyle(color: Colors.blue);
                                } else {
                                  cartList.add(Map<String, dynamic>()
                                    ..addAll({
                                      'iName': e.iName,
                                      'quantity': e.quantity
                                    }));
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
                              }).toList()
                            ],
                          ),
                        if (subIng.isNotEmpty)
                          Column(
                            children: [
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('부재료',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: 3,
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white),
                              ),
                              ...subIng.map((e) {
                                TextStyle tstyle =
                                    new TextStyle(color: Colors.black);
                                if (fridge.contains(e.iName)) {
                                  tstyle = TextStyle(color: Colors.blue);
                                } else {
                                  cartList.add(Map<String, dynamic>()
                                    ..addAll({
                                      'iName': e.iName,
                                      'quantity': e.quantity
                                    }));
                                }
                                return ListTile(
                                  leading: Text(e.iName, style: tstyle),
                                  trailing: Text(e.quantity, style: tstyle),
                                );
                              }).toList(),
                            ],
                          ),
                        if (sub2Ing.isNotEmpty)
                          Column(
                            children: [
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('양념',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                height: 3,
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white),
                              ),
                              ...sub2Ing.map((e) {
                                TextStyle tstyle =
                                    new TextStyle(color: Colors.black);
                                if (fridge.contains(e.iName)) {
                                  tstyle = TextStyle(color: Colors.blue);
                                } else {
                                  cartList.add(Map<String, dynamic>()
                                    ..addAll({
                                      'iName': e.iName,
                                      'quantity': e.quantity
                                    }));
                                }
                                return ListTile(
                                  leading: Text(e.iName, style: tstyle),
                                  trailing: Text(e.quantity, style: tstyle),
                                );
                              }).toList()
                            ],
                          ),
                        (mainIng.isNotEmpty ||
                                subIng.isNotEmpty ||
                                sub2Ing.isNotEmpty)
                            ? ElevatedButton(
                                onPressed: () {
                                  addCart(cartList);
                                },
                                child: Center(child: Text('장바구니 추가')),
                              )
                            : Text('재료 정보가 없는 레시피입니다.')
                      ])),
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
            leading: Text(
              e.pOrder.toString(),
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            title: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[500],
                      offset: Offset(4.0, 4.0),
                      blurRadius: 15.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4.0, -4.0),
                      blurRadius: 15.0,
                      spreadRadius: 1.0,
                    )
                  ],
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.process,
                      style: TextStyle(),
                    ),
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

  void addCart(List<Map<String, dynamic>> ings) {
    ings.forEach((element) {
      FirebaseFirestore.instance
          .collection('fridge')
          .doc(currentFridge)
          .collection('cart_list')
          .add(element);
    });
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

    var result = await FirebaseFirestore.instance
        .collection('fridge')
        .doc(currentFridge)
        .collection('ing_list')
        .get();
    setState(() {
      fridge = result.docs.map((e) => e['iName'].toString()).toList();
    });
  }

  void getFavor() async {
    List<dynamic> temp = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.user.uid)
        .get()
        .then((value) => value['favorite']);
    setState(() {
      favorList = temp;
    });
  }

  void setFavor() async {
    favorList.any((element) => element == base.foodID)
        ? FirebaseFirestore.instance
            .collection('user')
            .doc(widget.user.uid)
            .update({
            'favorite': FieldValue.arrayRemove([base.foodID])
          }).whenComplete(() => getFavor())
        : FirebaseFirestore.instance
            .collection('user')
            .doc(widget.user.uid)
            .update({
            'favorite': FieldValue.arrayUnion([base.foodID])
          }).whenComplete(() => getFavor());
  }

  _buildFavor() {
    return FutureBuilder(
      future: dbHelper.getFavorList(favorList),
      builder: (BuildContext context, AsyncSnapshot<List<Recommend>> snapshot) {
        return AnimatedSwitcher(
          child: snapshot?.data?.length != 0
              ? Column(
                  children: [
                    Text(
                      '스크랩한 레시피',
                      style: TextStyle(fontSize: 30),
                    ),
                    CarouselSlider(
                        options: CarouselOptions(
                          enableInfiniteScroll: false,
                          aspectRatio: 4 / 3,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {},
                        ),
                        items: snapshot?.data?.map((e) {
                          return Builder(
                            builder: (context) {
                              return _buildTile(e);
                            },
                          );
                        })?.toList()),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    HintBox(text: '마음에 드는 레시피를\n스크랩 해보세요!'),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
          duration: Duration(milliseconds: 300),
        );
      },
    );
  }

  Widget _buildTile(Recommend recommend) {
    return GestureDetector(
      onTap: () {
        setState(() {
          search = recommend.fName;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Stack(alignment: Alignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                // alignment: AlignmentDirectional.bottomCenter,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      recommend.fImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          //라인 색상을 전환할 때 사용
                          colors: <Color>[Color(0x00ffffff), Colors.white],
                          stops: [0.0, 0.9], //시작과 끝을 설정
                          begin: FractionalOffset(0.7, 0.0),
                          end: FractionalOffset(1.5, 0.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.all(8.0), child: Container()),
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
                          Padding(
                              padding: EdgeInsets.all(8.0), child: Container()),
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
                          Padding(
                              padding: EdgeInsets.all(8.0), child: Container()),
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
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            BorderText(
                              size: 30,
                              textColor: Colors.orange[400],
                              borderColor: Colors.black,
                              text: recommend.fName,
                            ),
                            AutoSizeText(
                              '"${recommend.intro}"',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.center,
                              maxLines: 2,
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
        ]),
      ),
    );
  }
}

class CommentAddWidget extends StatelessWidget {
  final User user;
  final String foodId;
  final controller = TextEditingController();

  CommentAddWidget(this.user, this.foodId);

  Future<bool> checkDoc(foodId) async {
    return await FirebaseFirestore.instance
        .collection('recipe')
        .doc(foodId)
        .get()
        .then((value) => value.exists
            ? true
            : value.reference.set({'comment': []}).then((value) => true));
  }

  @override
  Widget build(BuildContext context) {
    String name;
    String photoUrl;
    for (var profile in user.providerData) {
      name = profile.displayName;
      photoUrl = profile.photoURL;
    }
    return Column(
      children: [
        FutureBuilder(
            future: checkDoc(foodId),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data ?? false) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('recipe')
                      ?.doc(foodId)
                      ?.snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData &&
                        ((snapshot?.data['comment']?.length ?? 0) > 0)) {
                      return Column(children: [
                        ...snapshot?.data['comment']
                            ?.map((value) => CommentWidget(
                                Comment.fromMap(value), foodId, user))
                            ?.toList()
                      ]);
                    } else {
                      return HintBox(
                          text: '아직 레시피에 대한 평가가 없네요!\n요리에 도전하고 첫 소감을 작성해보세요!');
                    }
                  },
                );
              } else {
                return HintBox(
                    text: '아직 레시피에 대한 평가가 없네요!\n요리에 도전하고 첫 소감을 작성해보세요!');
              }
            }),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      photoUrl,
                      width: 70,
                      height: 70,
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          LimitedBox(
                              maxWidth: MediaQuery.of(context).size.width,
                              child: TextField(
                                autofocus: false,
                                maxLines: 2,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                    hintText: '댓글 입력',
                                    border: InputBorder.none),
                                controller: controller,
                              )),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  int now =
                                      DateTime.now().millisecondsSinceEpoch;
                                  if (controller.text.isNotEmpty ||
                                      controller.text != '')
                                    FirebaseFirestore.instance
                                        .collection('recipe')
                                        .doc(foodId)
                                        .get()
                                        .then((value) => value.exists
                                            ? value.reference.update({
                                                'comment':
                                                    FieldValue.arrayUnion([
                                                  {
                                                    'user': user.uid,
                                                    'name': name,
                                                    'photoUrl': photoUrl,
                                                    'date': now,
                                                    'content': controller.text
                                                        .toString()
                                                  }
                                                ])
                                              })
                                            : value.reference.set({
                                                'comment':
                                                    FieldValue.arrayUnion([
                                                  {
                                                    'user': user.uid,
                                                    'name': name,
                                                    'photoUrl': photoUrl,
                                                    'date': now,
                                                    'content': controller.text
                                                        .toString()
                                                  }
                                                ])
                                              }));
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HintBox extends StatelessWidget {
  final String text;

  const HintBox({
    Key key,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[400], borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.wb_incandescent_outlined,
                size: 50,
              ),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    text,
                    style: TextStyle(fontSize: 25, color: Colors.grey[850]),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  final Comment _comment;
  final String foodId;
  final User user;

  CommentWidget(this._comment, this.foodId, this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                _comment.photoUrl,
                width: 70,
                height: 70,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _comment.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(_comment.date,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _comment.user == user.uid
                                  ? IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        return showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("댓글을 삭제할까요?"),
                                                actions: <Widget>[
                                                  FlatButton(
                                                      child: Text("네"),
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'recipe')
                                                            .doc(foodId)
                                                            .update({
                                                          'comment': FieldValue
                                                              .arrayRemove([
                                                            {
                                                              'user':
                                                                  _comment.user,
                                                              'name':
                                                                  _comment.name,
                                                              'photoUrl':
                                                                  _comment
                                                                      .photoUrl,
                                                              'date': _comment
                                                                  .dateInt,
                                                              'content': _comment
                                                                  .content
                                                                  .toString()
                                                            }
                                                          ])
                                                        }).then((value) =>
                                                                Navigator.pop(
                                                                    context));
                                                      }),
                                                  FlatButton(
                                                    child: Text("아니요"),
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;
                                      })
                                  : Container()
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        _comment.content,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
