class SalesReturnItemDetailsModel {
  final int customerId;
  final int firmId;
  final int locationId;
  final int itemId;
  final int unitId;

  final double quantity;

  final String barcode;
  final String batchNo;
  final String mfgDate;
  final String expDate;

  final int stkPurchaseId;

  final double purchaseRate;
  final double pflPurchaseRate;
  final double pflSalesRate;

  final double salesRate1;
  final double salesRate2;

  final String itemName;
  final String unitName;

  final double mrp;

  final double taxPer1;
  final double taxAmt1;
  final double taxPer2;
  final double taxAmt2;
  final double taxPer3;
  final double taxAmt3;
  final double taxPer4;
  final double taxAmt4;
  final double taxPer5;
  final double taxAmt5;

  final double rate;

  final int taxGroupId;
  final double taxPer;

  final String taxIncludeExclude;

  SalesReturnItemDetailsModel({
    required this.customerId,
    required this.firmId,
    required this.locationId,
    required this.itemId,
    required this.unitId,
    required this.quantity,
    required this.barcode,
    required this.batchNo,
    required this.mfgDate,
    required this.expDate,
    required this.stkPurchaseId,
    required this.purchaseRate,
    required this.pflPurchaseRate,
    required this.pflSalesRate,
    required this.salesRate1,
    required this.salesRate2,
    required this.itemName,
    required this.unitName,
    required this.mrp,
    required this.taxPer1,
    required this.taxAmt1,
    required this.taxPer2,
    required this.taxAmt2,
    required this.taxPer3,
    required this.taxAmt3,
    required this.taxPer4,
    required this.taxAmt4,
    required this.taxPer5,
    required this.taxAmt5,
    required this.rate,
    required this.taxGroupId,
    required this.taxPer,
    required this.taxIncludeExclude,
  });

  factory SalesReturnItemDetailsModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnItemDetailsModel(
      customerId: json["CustomerId"] ?? 0,
      firmId: json["FirmId"] ?? 0,
      locationId: json["LocationId"] ?? 0,
      itemId: json["ItemId"] ?? 0,
      unitId: json["UnitId"] ?? 0,
      quantity: (json["Quantity"] ?? 0).toDouble(),

      barcode: json["Barcode"] ?? "",
      batchNo: json["BatchNo"] ?? "",
      mfgDate: json["MfgDate"] ?? "",
      expDate: json["ExpDate"] ?? "",

      stkPurchaseId: json["StkPurchaseId"] ?? 0,

      purchaseRate: (json["PurchaseRate"] ?? 0).toDouble(),
      pflPurchaseRate: (json["PFL_PurchaseRate"] ?? 0).toDouble(),
      pflSalesRate: (json["PFL_SalesRate"] ?? 0).toDouble(),

      salesRate1: (json["SalesRate1"] ?? 0).toDouble(),
      salesRate2: (json["SalesRate2"] ?? 0).toDouble(),

      itemName: json["ItemName"] ?? "",
      unitName: json["UnitName"] ?? "",

      mrp: (json["MRP"] ?? 0).toDouble(),

      taxPer1: (json["TaxPer1"] ?? 0).toDouble(),
      taxAmt1: (json["TaxAmt1"] ?? 0).toDouble(),
      taxPer2: (json["TaxPer2"] ?? 0).toDouble(),
      taxAmt2: (json["TaxAmt2"] ?? 0).toDouble(),
      taxPer3: (json["TaxPer3"] ?? 0).toDouble(),
      taxAmt3: (json["TaxAmt3"] ?? 0).toDouble(),
      taxPer4: (json["TaxPer4"] ?? 0).toDouble(),
      taxAmt4: (json["TaxAmt4"] ?? 0).toDouble(),
      taxPer5: (json["TaxPer5"] ?? 0).toDouble(),
      taxAmt5: (json["TaxAmt5"] ?? 0).toDouble(),

      rate: (json["Rate"] ?? 0).toDouble(),

      taxGroupId: json["TaxGroupId"] ?? 0,
      taxPer: (json["TaxPer"] ?? 0).toDouble(),

      taxIncludeExclude: json["TaxIncludeExclude"] ?? "",
    );
  }
}