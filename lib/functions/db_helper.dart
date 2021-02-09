import 'dart:io';
import 'package:f_fridgehub/model/base.dart';
import 'package:f_fridgehub/model/ing.dart';
import 'package:f_fridgehub/model/recipe.dart';
import 'package:f_fridgehub/model/recommend.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper _db = DBHelper._();

  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDB();
      return _database;
    }
  }

  Future initDB() async {
    final dbPath = await getDatabasesPath(); //디폴트 db 저장 path를 찾음(and/ios 알아서)
    final path = join(dbPath, "cook.db"); //경로 합치기

    final exist = await databaseExists(path); //db가 저장되어있는지 확인

    if (exist) {
      print('db already exsits');
    } else {
      //db가 없다면 assets으로부터 복사함
      print('creating a copy from assets');

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "cook.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);

      print("db copied");
    }

    return await openDatabase('cook.db');
  }

  Future<List<String>> getRecipeList() async {
    final db = await database;
    var result = await db.rawQuery('SELECT FName FROM BASE');

    return result.isNotEmpty
        ? result.map((e) => e['FName'].toString()).toList()
        : Null;
  }

  Future<Base> getBaseRecipe(String fname) async {
    final db = await database;
    var result =
        await db.rawQuery('SELECT * FROM BASE WHERE FName = ?', [fname]);

    List<Base> base = result
        .map((e) => Base(
            foodID: e['FoodID'],
            fName: e['FName'],
            intro: e['Intro'],
            fdCat: e['Fdcat'],
            time: e['time'],
            difficult: e['difficult'],
            fImg: e['Fimg']))
        .toList();

    return result.isNotEmpty ? base[0] : Null;
  }

  Future<List<Ing>> getIng(String foodid) async {
    final db = await database;
    List<Map<String, dynamic>> result1 =
        await db.rawQuery("SELECT * FROM ING WHERE FoodId = ?", [foodid]);

    List<Ing> ing = result1
        .map((e) => Ing(e['FoodId'], e['Iid'], e['IName'], e['Quantity'],
            e['irdnt_ty_code'], e['ICat']))
        .toList();

    return ing;
  }

  Future<List<Recipe>> getRecipe(String foodid) async {
    final db = await database;
    List<Map<String, dynamic>> result2 = await db.rawQuery(
        'SELECT * FROM RECIPE WHERE FoodId = ? order By POrder asc', [foodid]);

    List<Recipe> recipe = result2
        .map((e) => Recipe(
            pId: e['Pid'],
            foodId: e['FoodId'],
            pOrder: e['POrder'],
            process: e['Process'],
            pImg: e['Pimg'],
            tip: e['Tip']))
        .toList();
    return recipe;
  }

  Future<List<String>> getIngList() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery("SELECT distinct IName FROM ING");
    List<String> ing = result.map((e) => e['IName'].toString()).toList();

    return ing;
  }

  Future<List<Recommend>> getRecommendList1(
      List<String> ing, bool isChecked) async {
    final db = await database;
    String a = '(';

    for (int i = 0; i < ing.length; i++) {
      a += "'${ing[i]}'";
      if (i == ing.length - 1) break;
      a += ', ';
    }
    a += ')';
    List<String> subQuery = ['', ''];
    if (isChecked) {
      subQuery = ["WHERE ICat is NOT '양념'", "AND ICat is NOT '양념'"];
    }

    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT BASE.FName, BASE.Intro, BASE.Fimg, BASE.difficult, BASE.time, BASE.Fdcat, b.FoodId, b.가진재료수 , a.필요개수 FROM (SELECT FoodId, count(FoodId) as '필요개수' FROM ING ${subQuery[0]} GROUP BY FoodId)as a, (SELECT FoodId, count(FoodId) as '가진재료수'FROM ING WHERE IName IN $a ${subQuery[1]} GROUP BY FoodId) as b, BASE WHERE a.FoodId=b.FoodId AND b.FoodId = BASE.FoodID AND a.FoodId = Base.FoodID GROUP BY BASE.FoodID ORDER BY b.'가진재료수' DESC LIMIT 10");
    List<Recommend> recommended = result
        .map((e) => Recommend(
            fName: e['FName'],
            intro: e['Intro'],
            fImg: e['Fimg'],
            difficult: e['difficult'],
            time: e['time'],
            cat: e['Fdcat'],
            need: e['필요개수'].toString(),
            ready: e['가진재료수'].toString()))
        .toList();
    return recommended;
  }

  Future<List<Recommend>> getRecommendList2(
      List<String> ing, bool isChecked) async {
    final db = await database;
    String a = '(';

    for (int i = 0; i < ing.length; i++) {
      a += "'${ing[i]}'";
      if (i == ing.length - 1) break;
      a += ', ';
    }
    a += ')';

    List<String> subQuery = ['', ''];
    if (isChecked) {
      subQuery = ["WHERE ICat is NOT '양념'", "AND ICat is NOT '양념'"];
    }

    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT BASE.FName, BASE.Intro, BASE.Fimg, BASE.difficult, BASE.time, BASE.Fdcat, b.FoodId, b.가진재료수 , a.필요개수 FROM (SELECT FoodId, count(FoodId) as '필요개수' FROM ING ${subQuery[0]} GROUP BY FoodId)as a,(SELECT FoodId, count(FoodId) as '가진재료수'FROM ING WHERE IName IN $a ${subQuery[1]} GROUP BY FoodId) as b, BASE WHERE a.FoodId=b.FoodId AND b.FoodId = BASE.FoodID AND a.FoodId = Base.FoodID GROUP BY BASE.FoodID ORDER BY CAST(b.'가진재료수' AS FLOAT)/CAST(a.'필요개수' AS FLOAT) DESC LIMIT 10");
    List<Recommend> recommended2 = result
        .map((e) => Recommend(
            fName: e['FName'],
            intro: e['Intro'],
            fImg: e['Fimg'],
            difficult: e['difficult'],
            time: e['time'],
            cat: e['Fdcat'],
            need: e['필요개수'].toString(),
            ready: e['가진재료수'].toString()))
        .toList();
    return recommended2;
  }

  Future<List<Recommend>> getFavorList(
      List ing) async {
    final db = await database;
    String a = '(';

    for (int i = 0; i < ing.length; i++) {
      a += "'${ing[i]}'";
      if (i == ing.length - 1) break;
      a += ', ';
    }
    a += ')';


    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT FName, Intro, Fimg, difficult, time, Fdcat FROM BASE WHERE BASE.FoodID IN $a");
    List<Recommend> recommended = result
        .map((e) => Recommend(
        fName: e['FName'],
        intro: e['Intro'],
        fImg: e['Fimg'],
        difficult: e['difficult'],
        time: e['time'],
        cat: e['Fdcat']))
        .toList();
    return recommended;
  }
}
