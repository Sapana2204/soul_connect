class PurchaseReportDetailsModel {
  int? purchaseId;
  String? purchaseDate;
  String? supplierBillNo;
  String? supplierName;
  String? itemName;
  String? batchNo;
  String? mfgDate;
  String? expDate;

  double? quantity;
  double? freeQuantity;

  String? unitName;

  double? rate;
  double? itemTotal;
  double? discAmt;
  double? schemeAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? netAmt;

  double? mRP;
  double? rateWithTax;
  double? cashSalesRate;
  double? creditSalesRate;
  double? outletSalesRate;

  int? itemId;

  PurchaseReportDetailsModel({
    this.purchaseId,
    this.purchaseDate,
    this.supplierBillNo,
    this.supplierName,
    this.itemName,
    this.batchNo,
    this.mfgDate,
    this.expDate,
    this.quantity,
    this.freeQuantity,
    this.unitName,
    this.rate,
    this.itemTotal,
    this.discAmt,
    this.schemeAmt,
    this.taxableAmt,
    this.totalTaxAmt,
    this.netAmt,
    this.mRP,
    this.rateWithTax,
    this.cashSalesRate,
    this.creditSalesRate,
    this.outletSalesRate,
    this.itemId,
  });

  PurchaseReportDetailsModel.fromJson(Map<String, dynamic> json) {
    purchaseId = json['PurchaseId'];
    purchaseDate = json['PurchaseDate'];
    supplierBillNo = json['SupplierBillNo'];
    supplierName = json['SupplierName'];
    itemName = json['ItemName'];
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];

    quantity = (json['Quantity'] as num?)?.toDouble();
    freeQuantity = (json['FreeQuantity'] as num?)?.toDouble();

    unitName = json['UnitName'];

    rate = (json['Rate'] as num?)?.toDouble();
    itemTotal = (json['ItemTotal'] as num?)?.toDouble();
    discAmt = (json['DiscAmt'] as num?)?.toDouble();
    schemeAmt = (json['SchemeAmt'] as num?)?.toDouble();
    taxableAmt = (json['TaxableAmt'] as num?)?.toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] as num?)?.toDouble();
    netAmt = (json['NetAmt'] as num?)?.toDouble();

    mRP = (json['MRP'] as num?)?.toDouble();
    rateWithTax = (json['RateWithTax'] as num?)?.toDouble();
    cashSalesRate = (json['CashSalesRate'] as num?)?.toDouble();
    creditSalesRate = (json['CreditSalesRate'] as num?)?.toDouble();
    outletSalesRate = (json['OutletSalesRate'] as num?)?.toDouble();

    itemId = json['ItemId'];
  }
}
