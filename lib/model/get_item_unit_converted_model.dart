class GetItemUnitConvertedModel {
  int? itemId;
  String? itemName;
  int? unitId;
  String? unitName;

  GetItemUnitConvertedModel(
      {this.itemId, this.itemName, this.unitId, this.unitName});

  GetItemUnitConvertedModel.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    itemName = json['ItemName'];
    unitId = json['UnitId'];
    unitName = json['UnitName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ItemId'] = this.itemId;
    data['ItemName'] = this.itemName;
    data['UnitId'] = this.unitId;
    data['UnitName'] = this.unitName;
    return data;
  }
}
