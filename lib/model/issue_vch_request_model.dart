class IssueVchRequestModel {
  int? fromLocationId;
  int? toLocationId;
  int? userId;
  String? issueDate;
  int issueId;
  List<StockIssueDetailsRequest>? stockIssueDetailsRequests;

  IssueVchRequestModel({
    this.fromLocationId,
    this.toLocationId,
    this.userId,
    this.issueDate,
    this.issueId = 0,
    this.stockIssueDetailsRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      "FromLocationId": fromLocationId,
      "ToLocationId": toLocationId,
      "UserId": userId,
      "IssueDate": issueDate,
      "IssueId": issueId,
      "StockIssueDetailsRequests":
      stockIssueDetailsRequests?.map((e) => e.toJson()).toList(),
    };
  }
}

class StockIssueDetailsRequest {
  int issueId;
  int? itemId;
  int? unitId;
  double? quantity;
  double? rate;
  String? batchNo;
  String? mfgDate;
  String? expDate;
  String? barcode;
  double? purchaseRate;
  double? purchaseRateWithTax;
  double? cashSalesRate;
  double? outletSalesRate;
  double? creditSalesRate;
  double? mrp;
  int? purchaseId;
  int? fromLocationId;
  int? toLocationId;

  StockIssueDetailsRequest({
    this.issueId = 0,
    this.itemId,
    this.unitId,
    this.quantity,
    this.rate,
    this.batchNo,
    this.mfgDate,
    this.expDate,
    this.barcode,
    this.purchaseRate,
    this.purchaseRateWithTax,
    this.cashSalesRate,
    this.outletSalesRate,
    this.creditSalesRate,
    this.mrp,
    this.purchaseId,
    this.fromLocationId,
    this.toLocationId,
  });

  Map<String, dynamic> toJson() {
    return {
      "IssueId": issueId,
      "ItemId": itemId,
      "UnitId": unitId,
      "Quantity": quantity,
      "Rate": rate,
      "BatchNo": batchNo,
      "MfgDate": mfgDate,
      "ExpDate": expDate,
      "Barcode": barcode,
      "PurchaseRate": purchaseRate,
      "PurchaseRateWithTax": purchaseRateWithTax,
      "CashSalesRate": cashSalesRate,
      "OutletSalesRate": outletSalesRate,
      "CreditSalesRate": creditSalesRate,
      "MRP": mrp,
      "PurchaseId": purchaseId,
      "FromLocationId": fromLocationId,
      "ToLocationId": toLocationId,
    };
  }
}