class PurchaseItemDetailsModel {
  String? batchNo;
  String? expDate;
  double? rate;
  double? rateWithTax;
  double? cashSalesRate;
  double? creditSalesRate;
  double? outletSalesRate;
  double? mRP;
  String? purchaseDate;
  int? purDtlsId;
  int? purchaseId;
  int? itemId;
  int? unitId;
  String? itemName;
  String? hSNCode;
  int? taxGroupId;
  double? taxPer;

  PurchaseItemDetailsModel({
    this.batchNo,
    this.expDate,
    this.rate,
    this.rateWithTax,
    this.cashSalesRate,
    this.creditSalesRate,
    this.outletSalesRate,
    this.mRP,
    this.purchaseDate,
    this.purDtlsId,
    this.purchaseId,
    this.itemId,
    this.unitId,
    this.itemName,
    this.hSNCode,
    this.taxGroupId,
    this.taxPer,
  });

  PurchaseItemDetailsModel.fromJson(Map<String, dynamic> json) {
    batchNo = json['BatchNo'];
    expDate = json['ExpDate'];
    rate = (json['Rate'] ?? 0).toDouble();
    rateWithTax = (json['RateWithTax'] ?? 0).toDouble();
    cashSalesRate = (json['CashSalesRate'] ?? 0).toDouble();
    creditSalesRate = (json['CreditSalesRate'] ?? 0).toDouble();
    outletSalesRate = (json['OutletSalesRate'] ?? 0).toDouble();
    mRP = (json['MRP'] ?? 0).toDouble();
    purchaseDate = json['PurchaseDate'];
    purDtlsId = (json['PurDtlsId'] ?? 0).toInt();
    purchaseId = (json['PurchaseId'] ?? 0).toInt();
    itemId = (json['ItemId'] ?? 0).toInt();
    unitId = (json['UnitId'] ?? 0).toInt();
    itemName = json['ItemName'];
    hSNCode = json['HSNCode'];
    taxGroupId = (json['TaxGroupId'] ?? 0).toInt();
    taxPer = (json['TaxPer'] ?? 0).toDouble();
  }


  Map<String, dynamic> toJson() {
    return {
      'BatchNo': batchNo,
      'ExpDate': expDate,
      'Rate': rate,
      'RateWithTax': rateWithTax,
      'CashSalesRate': cashSalesRate,
      'CreditSalesRate': creditSalesRate,
      'OutletSalesRate': outletSalesRate,
      'MRP': mRP,
      'PurchaseDate': purchaseDate,
      'PurDtlsId': purDtlsId,
      'PurchaseId': purchaseId,
      'ItemId': itemId,
      'UnitId': unitId,
      'ItemName': itemName,
      'HSNCode': hSNCode,
      'TaxGroupId': taxGroupId,
      'TaxPer': taxPer,
    };
  }
}
