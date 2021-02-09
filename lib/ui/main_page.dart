import 'package:f_fridgehub/ui/fridge_page.dart';
import 'package:f_fridgehub/ui/recipe_page.dart';
import 'package:f_fridgehub/ui/recommend_page.dart';
import 'package:f_fridgehub/ui/setting_page.dart';
import 'package:f_fridgehub/ui/share_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatefulWidget {
  final User user;

  MainPage(this.user);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int index = 0;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RecommendPage(widget.user),
      FridgePage(widget.user),
      RecipePage(widget.user),
      SharePage(widget.user),
      SettingPage(widget.user)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: GestureDetector(
        onTap: () {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    },
    child: Scaffold(
          body: AnimatedSwitcher(
            child: _pages[index],
            duration: Duration(milliseconds: 200),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
            backgroundColor: Colors.white,
            fixedColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.ac_unit),
                label: '냉장고',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_fire_department),
                label: '레시피',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share),
                label: '공유',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '설정',
              ),
            ],
            onTap: (int value) {
              print('tapped : $value');
              setState(() {
                index = value;
              });
            },
          ),
        ),),
        onWillPop: _onBackPressed);
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("앱을 종료할까요?"),
            actions: <Widget>[
              FlatButton(
                child: Text("네"),
                onPressed: () => Navigator.pop(context, true),
              ),
              FlatButton(
                child: Text("아니요"),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ) ??
        false;
  }
}
