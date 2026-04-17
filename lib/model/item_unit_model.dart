class ItemUnitModel {
  final int itemId;
  final int unitId;
  final String unitName;

  ItemUnitModel({
    required this.itemId,
    required this.unitId,
    required this.unitName,
  });

  factory ItemUnitModel.fromJson(Map<String, dynamic> json) {
    return ItemUnitModel(
      itemId: json['ItemId'],
      unitId: json['UnitId'],
      unitName: json['UnitName'],
    );
  }
}
