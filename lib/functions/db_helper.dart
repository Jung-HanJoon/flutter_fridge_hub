import 'dart:io';
import 'package:f_fridgehub/model/base.dart';
import 'package:f_fridgehub/model/ing.dart';
import 'package:f_fridgehub/model/recipe.dart';
import 'package:f_fridgehub/model/recommend.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBHelper {

  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if(_database != null) {
      return _database;
    }else {
      _database = await initDB();
      return _database;
    }
  }

  Future initDB() async{
    final dbPath = await getDatabasesPath();//디폴트 db 저장 path를 찾음(and/ios 알아서)
    final path  = join(dbPath, "cook.db");//경로 합치기

    final exist = await databaseExists(path);//db가 저장되어있는지 확인

    if(exist){
      print('db already exsits');
    }else{//db가 없다면 assets으로부터 복사함
      print('creating a copy from assets');

      try{
        await Directory(dirname(path)).create(recursive: true);
      }catch(_){}

      ByteData data = await rootBundle.load(join("assets", "cook.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);

      print("db copied");
    }

    return await openDatabase('cook.db');
  }

  //Read RecipeList
  Future<List<String>> getRecipeList() async {
    final db = await database;
    var result = await db.rawQuery('SELECT FName FROM BASE');

    // print the results
    return result.isNotEmpty ? result.map((e) => e['FName'].toString()).toList() : Null;
  }

  Future<Base> getBaseRecipe(String fname) async {
    final db = await database;
    var result = await db.rawQuery('SELECT * FROM BASE WHERE FName = ?', [fname]);

    List<Base> base = result.map((e) => Base(foodID: e['FoodID'], fName: e['FName'], intro: e['Intro'], fdCat: e['Fdcat'], time: e['time'], difficult: e['difficult'], fImg: e['Fimg'])).toList();

    return result.isNotEmpty ? base[0] : Null;
  }

  Future<List<Ing>> getIng(String foodid) async {
    final db = await database;
    List<Map<String, dynamic>> result1 = await db.rawQuery("SELECT * FROM ING WHERE FoodId = ?",[foodid]);

    //List<Map<String, dynamic>> result = await db.query('ING', where: 'FoodId', whereArgs: [foodid]);
    List<Ing> ing = result1.map((e) =>
      Ing(e['FoodId'], e['Iid'], e['IName'], e['Quantity'], e['irdnt_ty_code'], e['ICat'])
    ).toList();

    return ing;
  }

  Future<List<Recipe>> getRecipe(String foodid) async {
    final db = await database;
    List<Map<String, dynamic>> result2 = await db.rawQuery('SELECT * FROM RECIPE WHERE FoodId = ? order By POrder asc', [foodid]);

    //List<Map<String, dynamic>> result = await db.query('RECIPE', where: 'FoodId', whereArgs: [foodid], orderBy: 'POrder');
    List<Recipe> recipe = result2.map((e) => Recipe(pId: e['Pid'], foodId: e['FoodId'], pOrder: e['POrder'], process: e['Process'], pImg: e['Pimg'], tip: e['Tip'])).toList();
    return recipe;
  }


  Future<List<String>> getIngList() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery("SELECT distinct IName FROM ING");

    //List<Map<String, dynamic>> result = await db.query('ING', where: 'FoodId', whereArgs: [foodid]);
    List<String> ing = result.map((e) =>e['IName'].toString()).toList();

    return ing;
  }

  Future<List<Recommend>> getRecommendList(List<String> ing) async {
    final db = await database;
    String a='(';
    // print("'$ing, '");
    // ing.map((e) => a+="'$e'"+'');

    for(int i=0; i<ing.length;i++){
      a += "'${ing[i]}'";
      if(i==ing.length-1)break;
      a += ', ';
    }
    a +=')';

    print(ing);
    print(a);
    List<Map<String, dynamic>> result = await db.rawQuery("SELECT Fimg, Intro, FName, difficult, time, Fdcat FROM BASE WHERE FoodID IN(SELECT FoodId FROM ING WHERE IName IN $a GROUP BY FoodId order by count(FoodId) desc Limit 5)");
    //List<Map<String, dynamic>> result = await db.query('ING', where: 'FoodId', whereArgs: [foodid]);
    print('result = $result');
    List<Recommend> recommended = result.map((e) =>Recommend(e['FName'], e['Intro'], e['Fimg'], e['difficult'], e['time'], e['Fdcat'])).toList();
    return recommended;
  }


  //
  // getRecipe(String fname) async {
  //   final db = await database;
  //   var res = await db.rawQuery('SELECT * FROM BASE WHERE FName = ?', [fname]);
  //   return res.isNotEmpty ? res.asMap( ).toList() : Null;
  // }
  //
  // //Read All
  // Future<List<Dog>> getAllDogs() async {
  //   final db = await database;
  //   var res = await db.rawQuery('SELECT * FROM $TableName');
  //   List<Dog> list = res.isNotEmpty ? res.map((c) => Dog(id:c['id'], name:c['name'])).toList() : [];
  //
  //   return list;
  // }
  //
  // //Delete
  // deleteDog(int id) async {
  //   final db = await database;
  //   var res = db.rawDelete('DELETE FROM $TableName WHERE id = ?', [id]);
  //   return res;
  // }
  //
  // //Delete All
  // deleteAllDogs() async {
  //   final db = await database;
  //   db.rawDelete('DELETE FROM $TableName');
  // }

}