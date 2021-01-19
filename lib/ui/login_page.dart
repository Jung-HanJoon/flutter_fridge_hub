import 'package:f_fridgehub/functions/db_helper.dart';
import 'package:f_fridgehub/ui/main_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  DBHelper dbHelper;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/login_background.png'),
              fit: BoxFit.cover
            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 15, 8, 100),
                      child: Align(
                        alignment: Alignment.centerLeft,
                          child: Text('''냉장고를\n부탁해''', style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold),)),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: SignInButton(
                        Buttons.Google,
                        onPressed: (){
                          _handleSignIn().then((user) {
                            Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context)=> MainPage(user)));
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      );
  }

  Future<User> _handleSignIn() async{
    GoogleSignInAccount account = await _googleSignIn.signIn();
    GoogleSignInAuthentication googldAuth = await account.authentication;
    AuthCredential credential = GoogleAuthProvider.credential( idToken: googldAuth.idToken, accessToken: googldAuth.accessToken);
    var authResult = await _auth.signInWithCredential(credential);
    User user = authResult.user;

    return user;
  }
}