class StockReportModel {
  String? itemName, batchNo, expDate, hsnCode, barcode;

  int? itemId, purchaseId, unitId;

  double? opening,
      purchase,
      sales,
      salesReturn,
      purchaseReturn,
      issue,
      expired,
      damage,
      inward,
      closing;

  double? purchaseRate,
      purchaseTaxRate,
      cashSalesRate,
      creditSalesRate,
      outletSalesRate,
      mrp;

  double? purchaseValuation,
      salesValuation,
      profitValue;

  StockReportModel({
    this.itemName,
    this.batchNo,
    this.expDate,
    this.hsnCode,
    this.barcode,
    this.itemId,
    this.purchaseId,
    this.unitId,
    this.opening,
    this.purchase,
    this.sales,
    this.salesReturn,
    this.purchaseReturn,
    this.issue,
    this.expired,
    this.damage,
    this.inward,
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
  });

  StockReportModel.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    batchNo = json['BatchNo'] ?? '-';
    expDate = json['ExpDate']?.toString().split('T')[0] ?? '-';

    itemId = json['ItemId'];
    purchaseId = json['PurchaseId'];
    unitId = json['UnitId'];

    opening = double.tryParse(json['Opening']?.toString() ?? '0') ?? 0.0;
    purchase = double.tryParse(json['Purchase']?.toString() ?? '0') ?? 0.0;
    sales = double.tryParse(json['Sales']?.toString() ?? '0') ?? 0.0;

    salesReturn = double.tryParse(json['SalesReturn']?.toString() ?? '0') ?? 0.0;
    purchaseReturn = double.tryParse(json['PurchaseReturn']?.toString() ?? '0') ?? 0.0;

    issue = double.tryParse(json['Issue']?.toString() ?? '0') ?? 0.0;
    expired = double.tryParse(json['Expired']?.toString() ?? '0') ?? 0.0;
    damage = double.tryParse(json['Damage']?.toString() ?? '0') ?? 0.0;

    inward = double.tryParse(json['Inward']?.toString() ?? '0') ?? 0.0;

    closing = double.tryParse(json['Closing']?.toString() ?? '0') ?? 0.0;

    purchaseRate =
        double.tryParse(json['PurchaseRate']?.toString() ?? '0') ?? 0.0;

    purchaseTaxRate =
        double.tryParse(json['PurchaseTaxRate']?.toString() ?? '0') ?? 0.0;

    cashSalesRate =
        double.tryParse(json['CashSalesRate']?.toString() ?? '0') ?? 0.0;

    creditSalesRate =
        double.tryParse(json['CreditSalesRate']?.toString() ?? '0') ?? 0.0;

    outletSalesRate =
        double.tryParse(json['OutletSalesRate']?.toString() ?? '0') ?? 0.0;

    mrp = double.tryParse(json['MRP']?.toString() ?? '0') ?? 0.0;

    purchaseValuation =
        double.tryParse(json['PurchaseValuation']?.toString() ?? '0') ?? 0.0;

    salesValuation =
        double.tryParse(json['SalesValuation']?.toString() ?? '0') ?? 0.0;

    profitValue =
        double.tryParse(json['ProfitValue']?.toString() ?? '0') ?? 0.0;

    hsnCode = json['HSNCode'];
    barcode = json['Barcode'];
  }

  Map<String, dynamic> toJson() {
    return {
      "ItemName": itemName,
      "BatchNo": batchNo,
      "ExpDate": expDate,
      "Opening": opening,
      "Purchase": purchase,
      "Sales": sales,
      "SalesReturn": salesReturn,
      "PurchaseReturn": purchaseReturn,
      "Issue": issue,
      "Expired": expired,
      "Damage": damage,
      "Inward": inward,
      "Closing": closing,
      "PurchaseRate": purchaseRate,
      "PurchaseTaxRate": purchaseTaxRate,
      "MRP": mrp,
      "PurchaseValuation": purchaseValuation,
      "SalesValuation": salesValuation,
      "ProfitValue": profitValue,
      "HSNCode": hsnCode,
    };
  }
}