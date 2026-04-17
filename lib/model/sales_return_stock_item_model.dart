class SalesReturnStockItemModel {
  final int itemId;
  final String itemName;
  final String unitName;
  final double taxPer;
  final String taxGroupName;
  final String itemCompany;
  final String itemCategory;
  final String productType;

  SalesReturnStockItemModel({
    required this.itemId,
    required this.itemName,
    required this.unitName,
    required this.taxPer,
    required this.taxGroupName,
    required this.itemCompany,
    required this.itemCategory,
    required this.productType,
  });

  factory SalesReturnStockItemModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnStockItemModel(
      itemId: json['ItemId'] ?? 0,
      itemName: json['ItemName'] ?? '',
      unitName: json['UnitName'] ?? '',
      taxPer: (json['TaxPer'] ?? 0).toDouble(),
      taxGroupName: json['TaxGroupName'] ?? '',
      itemCompany: json['ItemCompany'] ?? '',
      itemCategory: json['ItemCategory'] ?? '',
      productType: json['ProductType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemId': itemId,
      'ItemName': itemName,
      'UnitName': unitName,
      'TaxPer': taxPer,
      'TaxGroupName': taxGroupName,
      'ItemCompany': itemCompany,
      'ItemCategory': itemCategory,
      'ProductType': productType,
    };
  }

  @override
  String toString() {
    return 'StockItem('
        'id: $itemId, '
        'name: $itemName, '
        'unit: $unitName, '
        'tax: $taxPer, '
        'company: $itemCompany, '
        'category: $itemCategory'
        ')';
  }
}
