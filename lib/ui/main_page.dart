import 'package:f_fridgehub/costum_widget/bottom_navigationbar.dart';
import 'package:f_fridgehub/state/scrolldetector.dart';
import 'package:f_fridgehub/ui/fridge_page.dart';
import 'package:f_fridgehub/ui/recipe_page.dart';
import 'package:f_fridgehub/ui/recommend_page.dart';
import 'package:f_fridgehub/ui/setting_page.dart';
import 'package:f_fridgehub/ui/share_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final User user;

  MainPage(this.user);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  List<Widget> _pages;
  bool darkModeSwitch = false;

  @override
  void initState() {
    super.initState();
    getOptionalFlag();
    _pages = [
      RecommendPage(widget.user),
      FridgePage(widget.user),
      RecipePage(widget.user),
      // SharePage(widget.user),
      SettingPage(widget.user)
    ];
  }

  void getOptionalFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      darkModeSwitch = preferences.getBool('darkMode') ?? false;
    });
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
                child: _pages[Provider.of<ScrollDetector>(context).index],
                duration: Duration(milliseconds: 200),
              ),
              bottomNavigationBar: CustomBottomNavigationBars()),
        ),
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
