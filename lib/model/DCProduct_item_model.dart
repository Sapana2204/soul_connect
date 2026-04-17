class DCProductItem {
  // ✅ Previous fields (UNCHANGED)

  final String barcode;
  final String productName;
  final double qty;
  final String unit;
  final int unitId;       // 🔥 actual UnitId for API
  final String batch;

  // ➕ New fields added
  int? challanId;
  int? itemId;
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
  int? firmId;
  int? locationId;
  int? salesId;

  DCProductItem({
    // previous required fields
    required this.barcode,
    required this.productName,
    required this.qty,
    required this.unit,
    required this.unitId,
    required this.batch,
    // new optional fields
    this.challanId,
    this.itemId,
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
    this.firmId,
    this.locationId,
    this.salesId
  });
}
