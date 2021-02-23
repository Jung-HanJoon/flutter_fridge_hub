import 'package:f_fridgehub/state/scrolldetector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomNavigationBars extends StatefulWidget {
  @override
  _CustomBottomNavigationBarsState createState() =>
      _CustomBottomNavigationBarsState();
}

class _CustomBottomNavigationBarsState
    extends State<CustomBottomNavigationBars> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      height: Provider.of<ScrollDetector>(context, listen: false).isScrolled
          ? 56.0
          : 0.0,
      child: Wrap(
        children: <Widget>[
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex:
                Provider.of<ScrollDetector>(context, listen: false).index,
            // backgroundColor: Colors.white,
            // fixedColor: Colors.orange,
            // unselectedItemColor: Colors.grey,
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
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.share),
              //   label: '공유',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '설정',
              ),
            ],
            onTap: (int value) {
              Provider.of<ScrollDetector>(context, listen: false)
                  .setIndex(value);
            },
          ),
        ],
      ),
    );
  }
}
