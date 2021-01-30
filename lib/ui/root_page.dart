import 'package:f_fridgehub/ui/login_page.dart';
import 'package:f_fridgehub/ui/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class RootPage extends StatelessWidget {
  final FirebaseAuth mAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
      return StreamBuilder<User>(
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(mAuth.currentUser!=null){
            return MainPage(mAuth.currentUser);
          }else{
            return LoginPage();
          }
        },
      );
    }
  }
