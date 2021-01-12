class Ing{
  int foodId;
  int iId;
  String iName;
  String quantity;
  int irdnt_ty_code;
  String iCat;

  Ing(this.foodId,
      this.iId,
      this.iName,
      this.quantity,
      this.irdnt_ty_code,
      this.iCat);



  @override
  String toString() {
    return 'foodId = $foodId, iId = $iId, iName = $iName, quantity = $quantity, irdnt_ty_code = $irdnt_ty_code, iCat = $iCat';
  }
}