import 'package:f_fridgehub/ui/login_page.dart';
import 'package:f_fridgehub/ui/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final FirebaseAuth mAuth = FirebaseAuth.instance;
  bool tutorial = true;

  void setOptionalFlag(String option, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(option, value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOptionalFlag();
  }

  void getOptionalFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      tutorial = preferences.getBool('tutorial') ?? true;
    });
    print('튜토리얼 확인 : ' + tutorial.toString());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (mAuth.currentUser != null) {
          return MainPage(mAuth.currentUser);
        } else if (tutorial) {
          return TutorialPage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var d = Duration(seconds: 3);
    Future.delayed(d, () {
      Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  RootPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              }),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: ThemeData.dark().primaryColor,
          image: DecorationImage(image: AssetImage('images/splash.png'), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 60),
              child: Text(
          '냉장고\n허브',
          style: TextStyle(fontSize: 70, color: Colors.white),
        ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '베타버전 v0.1',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final List<Widget> cardList = [
    TutorialCard(
      title: '최적의 레시피 추천',
      image: 'images/splash.png',
      content:
          '냉장고 안의 재료를 활용하는 최적의 레시피를 추천해 드립니다.\n농림수산식품부에서 제공하는 우리나라의 식재료를 활용하는 레시피로 구성되어 있습니다.',
    ),
    TutorialCard(
      title: '냉장고 재료 관리',
      image: 'images/splash.png',
      content:
          '냉장고 안에 재료들을 관리하며 메모 할 수 있습니다. 구매해야할 재료를 장바구니에 담아 손쉽게 가족들과 공유할 수 있습니다.\n가족과 함께 식재료를 효과적으로 관리 해보세요!',
    ),
    TutorialCard(
      title: '가족과 함께 공유',
      image: 'images/splash.png',
      content: '가족과 함께 오늘의 저녁메뉴를 골라보세요!\n식탁과 함께하는 시간을 기록하고 새로운 요리를 도전해보세요!',
    ),
    TutorialCard(
        title: '레시피 제공',
        image: 'images/splash.png',
        content:
            '원하는 요리를 검색하거나 추천받은 요리의 정보를 확인하고 바로 조리해보세요! \n 부족한 재료를 쉽게 확인하고 장바구니에 추가할 수 있어요!'),
    TutorialCard(
      title: '다양한 그룹 참여',
      image: 'images/splash.png',
      content:
          '자취방과 집을 오가며 여러 그룹에 참여할 수 있어요.\n냉장고 허브와 함께 가족과 즐거운 식사와 추억을 만들어보세요!',
    ),
  ];

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: Colors.orangeAccent,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                '기능 살펴보기',
                style: TextStyle(fontSize: 35),
              ),
              SizedBox(
                height: 20,
              ),
              CarouselSlider(
                // carouselController: (index){
                //   setState(() {
                //     _current = index;
                //   });
                // },
                items: cardList,
                options: CarouselOptions(
                  enableInfiniteScroll: false,
                  aspectRatio: (size.width / (size.height - 200)),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 100,
                  height: 50,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (int index = 0; index < cardList.length; index++)
                    AnimatedContainer(
                      margin: EdgeInsets.only(right: 4),
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:
                              index == _current ? Colors.blue : Colors.white),
                      width: index == _current ? 20 : 10,
                      height: 10,
                    )
                ]),
                _current == cardList.length - 1
                    ? TextButton(
                        onPressed: () async {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          preferences.setBool('tutorial', false);
                          print('튜토리얼 결과 : ' +
                              preferences.getBool('tutorial').toString());
                          return Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (route) => false);
                        },
                        child: SizedBox(
                            width: 100,
                            child: Text(
                              '시작하기',
                              style: TextStyle(color: Colors.white),
                            )))
                    : SizedBox(
                        width: 100,
                      ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialCard extends StatelessWidget {
  final String image;
  final String title;
  final String content;

  const TutorialCard({
    Key key,
    this.image,
    this.title,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                title,
                style: TextStyle(fontSize: 35),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Image.asset(image),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(content),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
