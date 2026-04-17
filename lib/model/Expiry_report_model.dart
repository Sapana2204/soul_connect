class ExpiryReportModel {
  final String? itemName;
  final String? batchNo;
  final DateTime? expDate;
  final double? opening;
  final double? purchase;
  final double? inward;
  final double? sales;
  final double? salesReturn;
  final double? purchaseReturn;
  final double? issue;
  final double? expired;
  final double? damage;
  final double? closing;
  final double? purchaseRate;
  final double? purchaseTaxRate;
  final double? cashSalesRate;
  final double? creditSalesRate;
  final double? outletSalesRate;
  final double? mrp;
  final double? purchaseValuation;
  final double? salesValuation;
  final double? profitValue;
  final String? hsnCode;
  final String? barcode;
  final int? purchaseId;
  final int? itemId;
  final int? unitId;

  ExpiryReportModel({
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
    this.closing,
    this.purchaseRate,
    this.purchaseTaxRate,
    this.cashSalesRate,
    this.creditSalesRate,
    this.outletSalesRate,
    this.mrp,
    this.purchaseValuation,
    this.salesValuation,
    this.profitValue,
    this.hsnCode,
    this.barcode,
    this.purchaseId,
    this.itemId,
    this.unitId,
  });

  factory ExpiryReportModel.fromJson(Map<String, dynamic> json) {
    return ExpiryReportModel(
      itemName: json['ItemName'],
      batchNo: json['BatchNo'],
      expDate: json['ExpDate'] != null
          ? DateTime.parse(json['ExpDate'])
          : null,

      opening: (json['Opening'] ?? 0).toDouble(),
      purchase: (json['Purchase'] ?? 0).toDouble(),
      inward: (json['Inward'] ?? 0).toDouble(),
      sales: (json['Sales'] ?? 0).toDouble(),
      salesReturn: (json['SalesReturn'] ?? 0).toDouble(),
      purchaseReturn: (json['PurchaseReturn'] ?? 0).toDouble(),
      issue: (json['Issue'] ?? 0).toDouble(),
      expired: (json['Expired'] ?? 0).toDouble(),
      damage: (json['Damage'] ?? 0).toDouble(),
      closing: (json['Closing'] ?? 0).toDouble(),

      purchaseRate: (json['PurchaseRate'] ?? 0).toDouble(),
      purchaseTaxRate: (json['PurchaseTaxRate'] ?? 0).toDouble(),
      cashSalesRate: (json['CashSalesRate'] ?? 0).toDouble(),
      creditSalesRate: (json['CreditSalesRate'] ?? 0).toDouble(),
      outletSalesRate: (json['OutletSalesRate'] ?? 0).toDouble(),

      mrp: (json['MRP'] ?? 0).toDouble(),
      purchaseValuation: (json['PurchaseValuation'] ?? 0).toDouble(),
      salesValuation: (json['SalesValuation'] ?? 0).toDouble(),
      profitValue: (json['ProfitValue'] ?? 0).toDouble(),

      hsnCode: json['HSNCode']?.toString(),
      barcode: json['Barcode']?.toString(),

      purchaseId: json['PurchaseId'],
      itemId: json['ItemId'],
      unitId: json['UnitId'],
    );
  }
}