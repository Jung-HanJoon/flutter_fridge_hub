import 'dart:ui';
import 'package:f_fridgehub/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final User user;

  SettingPage(this.user);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GoogleSignIn googleSignInAccount = GoogleSignIn();

  String versionDB = '0.1';
  String versionApp = '0.1';
  TextEditingController controllerJoin = new TextEditingController();
  List<String> groupList = [];
  List<Color> lightColorSet = [Color(0xbbACF0F2), Color(0x6667CC8E)];
  List<Color> darkColorSet = [Color(0xff252932), Color(0xff252525)];

  bool alarmSwitch = false;
  bool darkModeSwitch = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOptionalFlag();
  }

  void setOptionalFlag(String option, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(option, value);
  }

  void getOptionalFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      alarmSwitch = preferences.getBool('alarm') ?? false;
      darkModeSwitch = preferences.getBool('darkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(seconds: 1);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: Text("사용자 설정"),
          actions: [
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  signOutGoogle();
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                })
          ]),
      body: AnimatedContainer(
        duration: duration,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: darkModeSwitch ? darkColorSet : lightColorSet)),
        child: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(
              height: 24,
            ),
            Text(
              '참여중인 그룹',
              style: TextStyle(
                  fontSize: 30,
                  color: darkModeSwitch ? Colors.white : Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        ?.collection('user')
                        ?.doc(widget.user.uid)
                        ?.get()
                        ?.then((value) => value?.data()),
                    builder:
                        (BuildContext context, AsyncSnapshot<Map> snapshot) {
                      if ((snapshot?.data?.isEmpty ?? true) ||
                          (snapshot?.data == null)) {
                        return CircularProgressIndicator();
                      } else {
                        return Row(
                          children: [
                            if (snapshot?.data['group_list'] != null)
                              ...snapshot?.data['group_list']?.map((value) {
                                groupList.add(value['fridge']);
                                return GroupTile(
                                    activation:
                                        snapshot?.data['current_fridge'] ==
                                            value['fridge'],
                                    fridge: value['fridge'].toString(),
                                    user: widget.user);
                              })?.toList(),
                          ],
                        );
                      }
                    }),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 15),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.7)
                  ]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        '설정',
                        style: TextStyle(fontSize: 25),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('푸시 알람 받기'),
                        trailing: Switch(
                            value: alarmSwitch,
                            onChanged: (value) {
                              setOptionalFlag('alarm', value);
                              getOptionalFlag();
                            }),
                      ),
                      ListTile(
                        title: Text('다크모드 적용'),
                        trailing: Switch(
                            value: darkModeSwitch,
                            onChanged: (value) {
                              setOptionalFlag('darkMode', value);
                              getOptionalFlag();
                            }),
                      ),
                      ListTile(
                        title: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white)),
                            onPressed: () => showBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  TextEditingController controllerJoin =
                                      new TextEditingController();
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 5,
                                              color: Colors.grey[300],
                                              spreadRadius: 1,
                                              offset: Offset(1, 1))
                                        ]),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: TextField(
                                              decoration:
                                                  InputDecoration.collapsed(
                                                hintText: '공유 코드 삽입',
                                              ),
                                              controller: controllerJoin,
                                            )),
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.white)),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('fridge')
                                                  .doc(controllerJoin.text)
                                                  .get()
                                                  .then((value) {
                                                if (!value.exists ||
                                                    (groupList.any((element) =>
                                                        controllerJoin?.text ==
                                                        element))) {
                                                  return SnackBarAction(
                                                      label: '그룹을 찾을 수 없습니다.',
                                                      onPressed: () {});
                                                } else {
                                                  FirebaseFirestore.instance
                                                      .collection('user')
                                                      .doc(widget.user.uid)
                                                      .update({
                                                    'current_fridge':
                                                        controllerJoin.text
                                                            .toString(),
                                                    'group_list':
                                                        FieldValue.arrayUnion([
                                                      {
                                                        'fridge':
                                                            '${controllerJoin.text}'
                                                      }
                                                    ])
                                                  });
                                                }
                                              });
                                            },
                                            child: Text('참가하기'))
                                      ],
                                    ),
                                  );
                                }),
                            child: Text('그룹 참여하기')),
                      ),
                      ListTile(
                        title: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white)),
                            onPressed: () async {
                              String docId = await FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(widget.user.uid)
                                  .get()
                                  .then((value) => value
                                      .data()['current_fridge']
                                      .toString());
                              Clipboard.setData(new ClipboardData(text: docId));
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "공유코드: " + docId,
                                  ),
                                ),
                              );
                            },
                            child: Text('공유 코드 복사')),
                      ),
                      ListTile(
                        title: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white)),
                            onPressed: () {},
                            child: Text('건의하기')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('앱 버전 : $versionDB'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('DB 버전 : $versionApp'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('데이터 제공 : 농립축산식품부 공공데이터'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  void signOutGoogle() async {
    await googleSignInAccount.signOut();
    print("User Sign Out");
  }
}

class GroupTile extends StatefulWidget {
  final String fridge;
  final User user;
  final bool activation;

  const GroupTile({
    Key key,
    this.fridge,
    this.user,
    this.activation,
  }) : super(key: key);

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  String title;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTitle();
  }

  void getTitle() async {
    String temp = await FirebaseFirestore.instance
        .collection('fridge')
        .doc(this.widget.fridge)
        .get()
        .then((value) => value['title']);
    setState(() {
      title = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('그룹 변경'),
                    content: Text('$title 그룹으로 변경할까요?'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('user')
                                .doc(widget.user.uid)
                                .update({'current_fridge': widget.fridge}).then(
                                    (value) => Navigator.pop(context));
                          },
                          child: Text('예')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('아니오'))
                    ],
                  ));
        },
        onLongPress: () async {
          TextEditingController editTitleController =
              new TextEditingController();
          editTitleController.text = title;
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('그룹 이름 변경'),
                    content: TextField(
                      controller: editTitleController,
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('fridge')
                                .doc(widget.fridge)
                                .update({
                              'title': editTitleController.text
                            }).then((value) => Navigator.pop(context));
                          },
                          child: Text('예')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('아니오'))
                    ],
                  ));
        },
        child: Container(
          width: 150,
          height: 150,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (widget.activation ?? false)
                BoxShadow(
                    blurRadius: 0,
                    color: Colors.orangeAccent,
                    spreadRadius: 1,
                    offset: Offset(0, 0)),
            ],
            gradient: LinearGradient(colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.7)
            ]),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(widget.activation ? '활성화' : ''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
