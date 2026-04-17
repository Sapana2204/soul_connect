class ExpiryModel {
  int? expiryId;
  String? expiryDate;
  int? locationId;
  int? createdby;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  bool? isCancelled;
  int? firmId;
  String? createdByName;
  List<ExpiryDetailsModel>? details;

  ExpiryModel({
    this.expiryId,
    this.expiryDate,
    this.locationId,
    this.createdby,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.isCancelled,
    this.firmId,
    this.createdByName,
    this.details,
  });

  ExpiryModel.fromJson(Map<String, dynamic> json) {
    expiryId = json['ExpiryId'];
    expiryDate = json['ExpiryDate'];
    locationId = json['LocationId'];
    createdby = json['Createdby'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    isCancelled = json['IsCancelled'];
    firmId = json['FirmId'];
    createdByName = json['CreatedByName'];

    if (json['Details'] != null) {
      details = <ExpiryDetailsModel>[];
      json['Details'].forEach((v) {
        details!.add(ExpiryDetailsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['ExpiryId'] = expiryId;
    data['ExpiryDate'] = expiryDate;
    data['LocationId'] = locationId;
    data['Createdby'] = createdby;
    data['CreatedOn'] = createdOn;
    data['UpdatedBy'] = updatedBy;
    data['UpdatedOn'] = updatedOn;
    data['IsCancelled'] = isCancelled;
    data['FirmId'] = firmId;
    data['CreatedByName'] = createdByName;

    if (details != null) {
      data['Details'] = details!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class ExpiryDetailsModel {
  int? expiryDetailsId;
  int? expiryId;
  String? barcode;
  int? itemId;
  int? unitId;
  double? quantity;
  String? batchNo;
  String? mfgDate;
  String? expDate;
  double? mrp;
  double? purchaseRate;
  double? purchaseRateWithTax;
  double? salesRate;
  double? salesRate1;
  double? salesRate2;
  int? purchaseId;
  int? firmId;
  int? locationId;
  String? itemName;
  String? unitName;

  ExpiryDetailsModel({
    this.expiryDetailsId,
    this.expiryId,
    this.barcode,
    this.itemId,
    this.unitId,
    this.quantity,
    this.batchNo,
    this.mfgDate,
    this.expDate,
    this.mrp,
    this.purchaseRate,
    this.purchaseRateWithTax,
    this.salesRate,
    this.salesRate1,
    this.salesRate2,
    this.purchaseId,
    this.firmId,
    this.locationId,
    this.itemName,
    this.unitName,
  });

  ExpiryDetailsModel.fromJson(Map<String, dynamic> json) {
    expiryDetailsId = json['ExpiryId'];
    expiryId = json['ExpiryId'];
    barcode = json['Barcode'];
    itemId = json['ItemId'];
    unitId = json['UnitId'];
    quantity = (json['Quantity'] ?? 0).toDouble();
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];
    mrp = (json['MRP'] ?? 0).toDouble();
    purchaseRate = (json['PurchaseRate'] ?? 0).toDouble();
    purchaseRateWithTax = (json['PurchaseRateWithTax'] ?? 0).toDouble();
    salesRate = (json['SalesRate'] ?? 0).toDouble();
    salesRate1 = (json['SalesRate1'] ?? 0).toDouble();
    salesRate2 = (json['SalesRate2'] ?? 0).toDouble();
    purchaseId = json['PurchaseId'];
    firmId = json['FirmId'];
    locationId = json['LocationId'];
    itemName = json['ItemName'];
    unitName = json['UnitName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['ExpiryDetailsId'] = expiryDetailsId;
    data['ExpiryId'] = expiryId;
    data['Barcode'] = barcode;
    data['ItemId'] = itemId;
    data['UnitId'] = unitId;
    data['Quantity'] = quantity;
    data['BatchNo'] = batchNo;
    data['MfgDate'] = mfgDate;
    data['ExpDate'] = expDate;
    data['MRP'] = mrp;
    data['PurchaseRate'] = purchaseRate;
    data['PurchaseRateWithTax'] = purchaseRateWithTax;
    data['SalesRate'] = salesRate;
    data['SalesRate1'] = salesRate1;
    data['SalesRate2'] = salesRate2;
    data['PurchaseId'] = purchaseId;
    data['FirmId'] = firmId;
    data['LocationId'] = locationId;
    data['ItemName'] = itemName;
    data['UnitName'] = unitName;
    return data;
  }
}