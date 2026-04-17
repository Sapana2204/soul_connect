class ItemSalesDetailsModel {
  String? itemName;
  String? hSNCode;
  String? batchNo;
  String? barcode;
  String? expDate;
  String? mfgDate;
  double? purchaseRate;
  double? purchaseTaxRate;
  double? mRP;
  double? cashSalesRate;
  double? salesRate;
  double? creditSalesRate;
  double? outletSalesRate;
  double? stockQuantity;
  int? itemId;
  int? unitId;
  int? purchaseId;
  int? salesId;
  int? taxGroupId;
  double? taxPer;

  ItemSalesDetailsModel({
    this.itemName,
    this.hSNCode,
    this.batchNo,
    this.barcode,
    this.expDate,
    this.mfgDate,
    this.purchaseRate,
    this.purchaseTaxRate,
    this.mRP,
    this.cashSalesRate,
    this.creditSalesRate,
    this.outletSalesRate,
    this.salesRate,
    this.stockQuantity,
    this.itemId,
    this.unitId,
    this.purchaseId,
    this.taxGroupId,
    this.taxPer,
    this.salesId
  });

  ItemSalesDetailsModel.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    hSNCode = json['HSNCode'];
    batchNo = json['BatchNo'];
    barcode = json['Barcode'];
    expDate = json['ExpDate'];
    mfgDate = json['MfgDate'];
    purchaseRate = (json['PurchaseRate'] as num?)?.toDouble();
    salesRate = (json['SalesRate'] as num?)?.toDouble();
    purchaseTaxRate = (json['PurchaseTaxRate'] as num?)?.toDouble();
    mRP = (json['MRP'] as num?)?.toDouble();
    cashSalesRate = (json['CashSalesRate'] as num?)?.toDouble();
    creditSalesRate = (json['CreditSalesRate'] as num?)?.toDouble();
    outletSalesRate = (json['OutletSalesRate'] as num?)?.toDouble();
    stockQuantity = (json['StockQuantity'] as num?)?.toDouble();
    itemId = json['ItemId'];
    salesId = json['SalesId'];
    unitId = json['UnitId'];
    purchaseId = json['PurchaseId'];
    taxGroupId = json['TaxGroupId'];
    taxPer = (json['TaxPer'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemName'] = itemName;
    data['HSNCode'] = hSNCode;
    data['BatchNo'] = batchNo;
    data['Barcode'] = barcode;
    data['ExpDate'] = expDate;
    data['MfgDate'] = mfgDate;
    data['PurchaseRate'] = purchaseRate;
    data['PurchaseTaxRate'] = purchaseTaxRate;
    data['MRP'] = mRP;
    data['CashSalesRate'] = cashSalesRate;
    data['CreditSalesRate'] = creditSalesRate;
    data['OutletSalesRate'] = outletSalesRate;
    data['StockQuantity'] = stockQuantity;
    data['ItemId'] = itemId;
    data['salesId'] = salesId;
    data['UnitId'] = unitId;
    data['PurchaseId'] = purchaseId;
    data['TaxGroupId'] = taxGroupId;
    data['TaxPer'] = taxPer;
    return data;
  }
}
