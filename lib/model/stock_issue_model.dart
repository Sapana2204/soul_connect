class StockIssueModel {
  int? issueId;
  String? issueDate;
  String? issueNo;
  int? fromLocationId;
  int? toLocationId;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  bool? isCancelled;
  String? issueFromLocation;
  String? issueToLocation;
  String? createdByUserName;
  List<IssueDetails>? details;

  StockIssueModel({
    this.issueId,
    this.issueDate,
    this.issueNo,
    this.fromLocationId,
    this.toLocationId,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isCancelled,
    this.issueFromLocation,
    this.issueToLocation,
    this.createdByUserName,
    this.details,
  });

  StockIssueModel.fromJson(Map<String, dynamic> json) {
    issueId = json['IssueId'];
    issueDate = json['IssueDate'];
    issueNo = json['IssueNo'];
    fromLocationId = json['FromLocationId'];
    toLocationId = json['ToLocationId'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    isCancelled = json['IsCancelled'];
    issueFromLocation = json['IssueFromLocation'];
    issueToLocation = json['IssueToLocation'];
    createdByUserName = json['CreatedByUserName'];

    if (json['Details'] != null) {
      details = [];
      json['Details'].forEach((v) {
        details!.add(IssueDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "IssueId": issueId,
      "IssueDate": issueDate,
      "IssueNo": issueNo,
      "FromLocationId": fromLocationId,
      "ToLocationId": toLocationId,
      "CreatedBy": createdBy,
      "CreatedOn": createdOn,
      "UpdatedBy": updatedBy,
      "UpdatedOn": updatedOn,
      "IsCancelled": isCancelled,
      "IssueFromLocation": issueFromLocation,
      "IssueToLocation": issueToLocation,
      "CreatedByUserName": createdByUserName,
      "Details": details?.map((e) => e.toJson()).toList(),
    };
  }
}

class IssueDetails {
  int? issueDetailsId;
  int? issueId;
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
  double? salesRate;
  double? salesRate1;
  double? salesRate2;
  double? mrp;
  int? purchaseId;
  int? fromLocationId;
  int? toLocationId;
  String? itemName;
  String? unitName;

  IssueDetails({
    this.issueDetailsId,
    this.issueId,
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
    this.salesRate,
    this.salesRate1,
    this.salesRate2,
    this.mrp,
    this.purchaseId,
    this.fromLocationId,
    this.toLocationId,
    this.itemName,
    this.unitName,
  });

  IssueDetails.fromJson(Map<String, dynamic> json) {
    issueDetailsId = json['IssueDetailsId'];
    issueId = json['IssueId'];
    itemId = json['ItemId'];
    unitId = json['UnitId'];
    quantity = (json['Quantity'] ?? 0).toDouble();
    rate = (json['Rate'] ?? 0).toDouble();
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];
    barcode = json['Barcode'];
    purchaseRate = (json['PurchaseRate'] ?? 0).toDouble();
    purchaseRateWithTax = (json['PurchaseRateWithTax'] ?? 0).toDouble();
    salesRate = (json['SalesRate'] ?? 0).toDouble();
    salesRate1 = (json['SalesRate1'] ?? 0).toDouble();
    salesRate2 = (json['SalesRate2'] ?? 0).toDouble();
    mrp = (json['MRP'] ?? 0).toDouble();
    purchaseId = json['PurchaseId'];
    fromLocationId = json['FromLocationId'];
    toLocationId = json['ToLocationId'];
    itemName = json['ItemName'];
    unitName = json['UnitName'];
  }

  Map<String, dynamic> toJson() {
    return {
      "IssueDetailsId": issueDetailsId,
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
      "SalesRate": salesRate,
      "SalesRate1": salesRate1,
      "SalesRate2": salesRate2,
      "MRP": mrp,
      "PurchaseId": purchaseId,
      "FromLocationId": fromLocationId,
      "ToLocationId": toLocationId,
      "ItemName": itemName,
      "UnitName": unitName,
    };
  }
}