class DeliveryChallanItem {
  int? itemId;
  String? itemName;
  int? unitId;
  String? unitName;
  double qty;

  String? barcode;
  String? batchNo;
  DateTime? mfgDate;
  DateTime? expDate;

  int? purchaseId;
  double? purchaseRate;
  double? pflPurchaseRate;
  double? salesRate;
  double? salesRate1;
  double? salesRate2;
  double? mrp;

  DeliveryChallanItem({
    this.itemId,
    this.itemName,
    this.unitId,
    this.unitName,
    required this.qty,
    this.barcode,
    this.batchNo,
    this.mfgDate,
    this.expDate,
    this.purchaseId,
    this.purchaseRate,
    this.pflPurchaseRate,
    this.salesRate,
    this.salesRate1,
    this.salesRate2,
    this.mrp,
  });

  /// ✅ API → UI
  factory DeliveryChallanItem.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanItem(
      itemId: json['ItemId'],
      itemName: json['ItemName'],
      unitId: json['UnitId'],
      unitName: json['UnitName'],
      qty: (json['Qty'] ?? 0).toDouble(),
      barcode: json['Barcode'],
      batchNo: json['BatchNo'],
      mfgDate:
      json['MfgDate'] != null ? DateTime.parse(json['MfgDate']) : null,
      expDate:
      json['ExpDate'] != null ? DateTime.parse(json['ExpDate']) : null,
      purchaseId: json['PurchaseId'],
      purchaseRate:
      json['PurchaseRate'] != null
          ? (json['PurchaseRate'] as num).toDouble()
          : null,
      pflPurchaseRate:
      json['PflPurchaseRate'] != null
          ? (json['PflPurchaseRate'] as num).toDouble()
          : null,
      salesRate:
      json['SalesRate'] != null
          ? (json['SalesRate'] as num).toDouble()
          : null,
      salesRate1:
      json['SalesRate1'] != null
          ? (json['SalesRate1'] as num).toDouble()
          : null,
      salesRate2:
      json['SalesRate2'] != null
          ? (json['SalesRate2'] as num).toDouble()
          : null,
      mrp:
      json['MRP'] != null
          ? (json['MRP'] as num).toDouble()
          : null,
    );
  }

  /// ✅ UI → API
  Map<String, dynamic> toJson() {
    return {
      "ItemId": itemId,
      "ItemName": itemName,
      "UnitId": unitId,
      "UnitName": unitName,
      "Qty": qty,
      "Barcode": barcode,
      "BatchNo": batchNo,
      "MfgDate": mfgDate?.toIso8601String(),
      "ExpDate": expDate?.toIso8601String(),
      "PurchaseId": purchaseId,
      "PurchaseRate": purchaseRate,
      "PflPurchaseRate": pflPurchaseRate,
      "SalesRate": salesRate,
      "SalesRate1": salesRate1,
      "SalesRate2": salesRate2,
      "MRP": mrp,
    };
  }
}
