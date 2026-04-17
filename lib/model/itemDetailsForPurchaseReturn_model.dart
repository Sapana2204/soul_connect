class ItemDetailsForPurchaseReturnModel {
  int? itemId;
  int? unitId;
  String? unitName;
  String? itemName;
  String? barcode;
  String? hSNCode;
  String? batchNo;
  String? mfgDate;
  String? expDate;
  String? taxIncludeExclude;

  int? purchaseId;

  double? purchaseRate;
  double? pFLPurchaseRate;
  double? purchaseTaxRate;

  double? salesRate;
  double? salesRate1;
  double? salesRate2;

  double? mRP;
  double? stockQuantity;

  int? taxGroupId;
  int? locationId;

  double? taxPer;
  double? discPer;

  double? taxPer1;
  double? taxAmt1;

  double? taxPer2;
  double? taxAmt2;

  double? taxPer3;
  double? taxAmt3;

  double? taxPer4;
  double? taxAmt4;

  double? taxPer5;
  double? taxAmt5;

  ItemDetailsForPurchaseReturnModel({
    this.itemId,
    this.unitId,
    this.unitName,
    this.itemName,
    this.barcode,
    this.hSNCode,
    this.batchNo,
    this.mfgDate,
    this.expDate,
    this.purchaseId,
    this.purchaseRate,
    this.pFLPurchaseRate,
    this.purchaseTaxRate,
    this.salesRate,
    this.salesRate1,
    this.salesRate2,
    this.mRP,
    this.stockQuantity,
    this.taxGroupId,
    this.locationId,
    this.taxPer,
    this.discPer,
    this.taxPer1,
    this.taxAmt1,
    this.taxPer2,
    this.taxAmt2,
    this.taxPer3,
    this.taxAmt3,
    this.taxPer4,
    this.taxAmt4,
    this.taxPer5,
    this.taxAmt5,
    this.taxIncludeExclude,
  });

  ItemDetailsForPurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    unitId = json['UnitId'];
    unitName = json['UnitName'];
    itemName = json['ItemName'];
    barcode = json['Barcode'];
    hSNCode = json['HSNCode']?.toString();
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];

    purchaseId = json['PurchaseId'];

    purchaseRate = (json['LastPurchaseRate'] as num?)?.toDouble();
    pFLPurchaseRate = (json['PFL_PurchaseRate'] as num?)?.toDouble();
    purchaseTaxRate = (json['PurchaseTaxRate'] as num?)?.toDouble();

    salesRate = (json['SalesRate'] as num?)?.toDouble();
    salesRate1 = (json['SalesRate1'] as num?)?.toDouble();
    salesRate2 = (json['SalesRate2'] as num?)?.toDouble();

    mRP = (json['MRP'] as num?)?.toDouble();
    stockQuantity = (json['StockQuantity'] as num?)?.toDouble();

    taxGroupId = json['TaxGroupId'];
    locationId = json['LocationId'];

    taxPer = (json['TaxPer'] as num?)?.toDouble();
    discPer = (json['DiscPer'] as num?)?.toDouble();

    taxPer1 = (json['TaxPer1'] as num?)?.toDouble();
    taxAmt1 = (json['TaxAmt1'] as num?)?.toDouble();

    taxPer2 = (json['TaxPer2'] as num?)?.toDouble();
    taxAmt2 = (json['TaxAmt2'] as num?)?.toDouble();

    taxPer3 = (json['TaxPer3'] as num?)?.toDouble();
    taxAmt3 = (json['TaxAmt3'] as num?)?.toDouble();

    taxPer4 = (json['TaxPer4'] as num?)?.toDouble();
    taxAmt4 = (json['TaxAmt4'] as num?)?.toDouble();

    taxPer5 = (json['TaxPer5'] as num?)?.toDouble();
    taxAmt5 = (json['TaxAmt5'] as num?)?.toDouble();
    taxIncludeExclude = json['TaxIncludeExclude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['ItemId'] = itemId;
    data['UnitId'] = unitId;
    data['UnitName'] = unitName;
    data['ItemName'] = itemName;
    data['Barcode'] = barcode;
    data['HSNCode'] = hSNCode;
    data['BatchNo'] = batchNo;
    data['MfgDate'] = mfgDate;
    data['ExpDate'] = expDate;

    data['PurchaseId'] = purchaseId;

    data['PurchaseRate'] = purchaseRate;
    data['PFL_PurchaseRate'] = pFLPurchaseRate;
    data['PurchaseTaxRate'] = purchaseTaxRate;

    data['SalesRate'] = salesRate;
    data['SalesRate1'] = salesRate1;
    data['SalesRate2'] = salesRate2;

    data['MRP'] = mRP;
    data['StockQuantity'] = stockQuantity;

    data['TaxGroupId'] = taxGroupId;
    data['LocationId'] = locationId;

    data['TaxPer'] = taxPer;
    data['DiscPer'] = discPer;

    data['TaxPer1'] = taxPer1;
    data['TaxAmt1'] = taxAmt1;

    data['TaxPer2'] = taxPer2;
    data['TaxAmt2'] = taxAmt2;

    data['TaxPer3'] = taxPer3;
    data['TaxAmt3'] = taxAmt3;

    data['TaxPer4'] = taxPer4;
    data['TaxAmt4'] = taxAmt4;

    data['TaxPer5'] = taxPer5;
    data['TaxAmt5'] = taxAmt5;
    data['TaxIncludeExclude'] = taxIncludeExclude;

    return data;
  }
}
