class StockInwardModel {
  int? inwardId;
  int? issueId;
  String? inwardDate;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  bool? isCancelled;
  int? locationId;
  int? fromLocationId;
  List<StockInwardDetails>? details;

  StockInwardModel({
    this.inwardId,
    this.issueId,
    this.inwardDate,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isCancelled,
    this.locationId,
    this.fromLocationId,
    this.details,
  });

  factory StockInwardModel.fromJson(Map<String, dynamic> json) {
    return StockInwardModel(
      inwardId: json['InwardId'],
      issueId: json['IssueId'],
      inwardDate: json['InwardDate'],
      createdBy: json['CreatedBy'],
      createdOn: json['CreatedOn'],
      updatedBy: json['UpdatedBy'],
      updatedOn: json['UpdatedOn'],
      isCancelled: json['IsCancelled'],
      locationId: json['LocationId'],
      fromLocationId: json['FromLocationId'],
      details: json['details'] != null
          ? List<StockInwardDetails>.from(
          json['details'].map((x) => StockInwardDetails.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InwardId': inwardId,
      'IssueId': issueId,
      'InwardDate': inwardDate,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'UpdatedBy': updatedBy,
      'UpdatedOn': updatedOn,
      'IsCancelled': isCancelled,
      'LocationId': locationId,
      'FromLocationId': fromLocationId,
      'details': details?.map((d) => d.toJson()).toList(),
    };
  }
}

class StockInwardDetails {
  int? issueId;
  int? itemId;
  int? unitId;
  double? issueQuantity;
  double? inwardQuantity;
  String? excessShortageReason;
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
  int? locationId;
  int? fromLocationId;

  StockInwardDetails({
    this.issueId,
    this.itemId,
    this.unitId,
    this.issueQuantity,
    this.inwardQuantity,
    this.excessShortageReason,
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
    this.locationId,
    this.fromLocationId,
  });

  factory StockInwardDetails.fromJson(Map<String, dynamic> json) {
    return StockInwardDetails(
      issueId: json['IssueId'],
      itemId: json['ItemId'],
      unitId: json['UnitId'],
      issueQuantity: (json['IssueQuantity'] ?? 0).toDouble(),
      inwardQuantity: (json['InwardQuantity'] ?? 0).toDouble(),
      excessShortageReason: json['ExcessShortageReason'],
      rate: (json['Rate'] ?? 0).toDouble(),
      batchNo: json['BatchNo'],
      mfgDate: json['MfgDate'],
      expDate: json['ExpDate'],
      barcode: json['Barcode'],
      purchaseRate: (json['PurchaseRate'] ?? 0).toDouble(),
      purchaseRateWithTax: json['PurchaseRateWithTax'] == null
          ? null
          : (json['PurchaseRateWithTax']).toDouble(),
      cashSalesRate: (json['CashSalesRate'] ?? 0).toDouble(),
      outletSalesRate: (json['OutletSalesRate'] ?? 0).toDouble(),
      creditSalesRate: (json['CreditSalesRate'] ?? 0).toDouble(),
      mrp: (json['MRP'] ?? 0).toDouble(),
      purchaseId: json['PurchaseId'],
      locationId: json['LocationId'],
      fromLocationId: json['FromLocationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IssueId': issueId,
      'ItemId': itemId,
      'UnitId': unitId,
      'IssueQuantity': issueQuantity,
      'InwardQuantity': inwardQuantity,
      'ExcessShortageReason': excessShortageReason,
      'Rate': rate,
      'BatchNo': batchNo,
      'MfgDate': mfgDate,
      'ExpDate': expDate,
      'Barcode': barcode,
      'PurchaseRate': purchaseRate,
      'PurchaseRateWithTax': purchaseRateWithTax,
      'CashSalesRate': cashSalesRate,
      'OutletSalesRate': outletSalesRate,
      'CreditSalesRate': creditSalesRate,
      'MRP': mrp,
      'PurchaseId': purchaseId,
      'LocationId': locationId,
      'FromLocationId': fromLocationId,
    };
  }
}