class StockIssueForInwardModel {
  int? issueId;
  String? issueNumber;
  List<StockIssueForInwardDetails>? details;

  StockIssueForInwardModel({
    this.issueId,
    this.issueNumber,
    this.details,
  });

  StockIssueForInwardModel.fromJson(Map<String, dynamic> json) {
    issueId = json['IssueId'];
    issueNumber = json['issueNumber'];

    if (json['details'] != null) {
      details = <StockIssueForInwardDetails>[];
      json['details'].forEach((v) {
        details!.add(StockIssueForInwardDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['IssueId'] = issueId;
    data['issueNumber'] = issueNumber;

    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class StockIssueForInwardDetails {
  int? issueDetailsId;
  int? issueId;
  int? itemId;
  int? unitId;

  String? itemName;
  String? unitName;

  double? issueQuantity;
  double? inwardQuantity;

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

  StockIssueForInwardDetails({
    this.issueDetailsId,
    this.issueId,
    this.itemId,
    this.unitId,
    this.itemName,
    this.unitName,
    this.issueQuantity,
    this.inwardQuantity,
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
  });

  StockIssueForInwardDetails.fromJson(Map<String, dynamic> json) {
    issueDetailsId = json['IssueDetailsId'];
    issueId = json['IssueId'];
    itemId = json['ItemId'];
    unitId = json['UnitId'];

    itemName = json['ItemName'];
    unitName = json['UnitName'];

    issueQuantity = (json['IssueQuantity'] ?? 0).toDouble();
    inwardQuantity = (json['InwardQuantity'] ?? 0).toDouble();

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['IssueDetailsId'] = issueDetailsId;
    data['IssueId'] = issueId;
    data['ItemId'] = itemId;
    data['UnitId'] = unitId;

    data['ItemName'] = itemName;
    data['UnitName'] = unitName;

    data['IssueQuantity'] = issueQuantity;
    data['InwardQuantity'] = inwardQuantity;

    data['BatchNo'] = batchNo;
    data['MfgDate'] = mfgDate;
    data['ExpDate'] = expDate;
    data['Barcode'] = barcode;

    data['PurchaseRate'] = purchaseRate;
    data['PurchaseRateWithTax'] = purchaseRateWithTax;

    data['SalesRate'] = salesRate;
    data['SalesRate1'] = salesRate1;
    data['SalesRate2'] = salesRate2;

    data['MRP'] = mrp;
    data['PurchaseId'] = purchaseId;

    return data;
  }
}