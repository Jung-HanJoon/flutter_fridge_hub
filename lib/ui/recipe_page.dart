import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/main.dart';
import 'package:f_fridgehub/model/base.dart';
import 'package:f_fridgehub/model/ing.dart';
import 'package:f_fridgehub/model/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipePage extends StatefulWidget {
  User user;
  RecipePage(this.user);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
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
          title: Text("레시피"),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(children: <Widget>[
            Column(children: <Widget>[
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                    controller: controller,
                    autofocus: true,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontStyle: FontStyle.italic),
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
                  return recipeList.where(
                      (s) => s.toLowerCase().contains(pattern.toLowerCase()));
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
                },
              )
            ]),
            _buildBase(),
            _buildIng(),
            _buildRecipe(),
          ])),
        ));
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
            return Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Image.network(
                    snapshot.data.fImg,
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
                        colors: <Color>[Color(0x00736AB7), Colors.blueGrey],
                        stops: [0.0, 0.9], //시작과 끝을 설정
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(0.0, 0.9),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      snapshot.data.intro,
                      style: TextStyle(color: Colors.lime, fontSize: 17),
                    ),
                  ),
                ]);
          } else {
            return Container();
          }
        },
      );
    }
  }

  Widget _buildIng() {
    if (ing != null) {
      String maining = '';
      String subing = '';
      String sub2ing = '';
      for (int i = 0; i < ing.length; i++) {
        switch (ing[i].iCat) {
          case '주재료':
            maining += ing[i].iName + ing[i].quantity;
            if (i != ing.length - 1) maining += ', ';
            break;
          case '부재료':
            subing += ing[i].iName + ing[i].quantity;
            if (i != ing.length - 1) subing += ', ';
            break;
          case '양념':
            sub2ing += ing[i].iName + ing[i].quantity;
            if (i != ing.length - 1) sub2ing += ', ';
            break;
        }
      }

      return Column(
        children: [
          if (maining != '')
            ListTile(leading: Text('주재료'), title: Text(maining)),
          if (subing != '') ListTile(leading: Text('부재료'), title: Text(subing)),
          if (sub2ing != '')
            ListTile(leading: Text('양념'), title: Text(sub2ing)),
        ],
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.process),
                  if (a != '')
                    CachedNetworkImage(
                      imageUrl: a,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                ],
              ),
              leading: Text(e.pOrder.toString()));
        }).toList(),
      );
    } else {
      return Container();
    }
  }
}
