class ExpiringItemModel {
  String? itemName;
  String? batchNo;
  String? expDate;
  double? opening;
  double? purchase;
  double? inward;
  double? sales;
  double? salesReturn;
  double? purchaseReturn;
  double? issue;
  double? expired;
  double? damage;
  double? purchaseRate;
  double? purchaseTaxRate;
  double? closing;
  String? hsnCode;
  String? barcode;
  int? purchaseId;
  int? itemId;
  int? unitId;

  ExpiringItemModel({
    this.itemName,
    this.batchNo,
    this.expDate,
    this.opening,
    this.purchase,
    this.inward,
    this.sales,
    this.salesReturn,
    this.purchaseReturn,
    this.issue,
    this.expired,
    this.damage,
    this.purchaseRate,
    this.purchaseTaxRate,
    this.closing,
    this.hsnCode,
    this.barcode,
    this.purchaseId,
    this.itemId,
    this.unitId,
  });

  ExpiringItemModel.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    batchNo = json['BatchNo'];
    expDate = json['ExpDate'];
    opening = (json['Opening'] ?? 0).toDouble();
    purchase = (json['Purchase'] ?? 0).toDouble();
    inward = (json['Inward'] ?? 0).toDouble();
    sales = (json['Sales'] ?? 0).toDouble();
    salesReturn = (json['SalesReturn'] ?? 0).toDouble();
    purchaseReturn = (json['PurchaseReturn'] ?? 0).toDouble();
    issue = (json['Issue'] ?? 0).toDouble();
    expired = (json['Expired'] ?? 0).toDouble();
    damage = (json['Damage'] ?? 0).toDouble();
    purchaseRate = (json['PurchaseRate'] ?? 0).toDouble();
    purchaseTaxRate = (json['PurchaseTaxRate'] ?? 0).toDouble();
    closing = (json['Closing'] ?? 0).toDouble();
    hsnCode = json['HSNCode'];
    barcode = json['Barcode'];
    purchaseId = json['PurchaseId'];
    itemId = json['ItemId'];
    unitId = json['UnitId'];
  }
}