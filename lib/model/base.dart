class Base {
  String foodID;
  String fName;
  String intro;
  String fdCat;
  String time;
  String difficult;
  String fImg;

  Base.fromMap(Map<String, dynamic> map)
      : assert(map['FoodID'] != null),
        assert(map['FName'] != null),
        assert(map['Intro'] != null),
        assert(map['Fdcat'] != null),
        assert(map['time'] != null),
        assert(map['difficult'] != null),
        assert(map['Fimg'] != null),
        foodID = map['FoodID'],
        fName = map['FName'],
        intro = map['Intro'],
        fdCat = map['Fdcat'],
        time = map['time'],
        difficult = map['difficult'],
        fImg = map['Fimg'];

  Base(
      {this.foodID,
      this.fName,
      this.intro,
      this.fdCat,
      this.time,
      this.difficult,
      this.fImg});
}
