import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/ui/login_page.dart';
import 'package:f_fridgehub/ui/root_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '냉장고 허브',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Youth',
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      home: SplashScreen(),
    );
  }
}