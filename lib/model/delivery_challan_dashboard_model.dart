class DeliveryChallanDashboardModel {
  int? challanId;
  int? challanSeriesId;
  String? challanNo;
  String? challanDate;
  int? customerId;
  int? totalQty;
  String? byHand;
  String? vehicleDetails;
  int? firmId;
  int? locationId;
  int? preparedBy;
  int? checkedBy;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  String? narration;
  int? salesId;
  bool? isCancelled;
  String? customerName;
  String? contact;
  String? deliveryAddress;
  bool? isConvertedtoInvoice;
  List<Details>? details;

  DeliveryChallanDashboardModel(
      {this.challanId,
        this.challanSeriesId,
        this.challanNo,
        this.challanDate,
        this.customerId,
        this.totalQty,
        this.byHand,
        this.vehicleDetails,
        this.firmId,
        this.locationId,
        this.preparedBy,
        this.checkedBy,
        this.createdBy,
        this.createdOn,
        this.updatedBy,
        this.updatedOn,
        this.narration,
        this.salesId,
        this.isCancelled,
        this.customerName,
        this.contact,
        this.deliveryAddress,
        this.isConvertedtoInvoice,
        this.details});

  DeliveryChallanDashboardModel.fromJson(Map<String, dynamic> json) {
    challanId = json['ChallanId'];
    challanSeriesId = json['ChallanSeriesId'];
    challanNo = json['ChallanNo'];
    challanDate = json['ChallanDate'];
    customerId = json['CustomerId'];
    totalQty = json['TotalQty'];
    byHand = json['ByHand'];
    vehicleDetails = json['VehicleDetails'];
    firmId = json['FirmId'];
    locationId = json['LocationId'];
    preparedBy = json['PreparedBy'];
    checkedBy = json['CheckedBy'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    narration = json['Narration'];
    salesId = json['SalesId'];
    isCancelled = json['IsCancelled'];
    customerName = json['CustomerName'];
    contact = json['Contact'];
    deliveryAddress = json['DeliveryAddress'];
    isConvertedtoInvoice = json['IsConvertedtoInvoice'];
    if (json['Details'] != null) {
      details = <Details>[];
      json['Details'].forEach((v) {
        details!.add(new Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ChallanId'] = this.challanId;
    data['ChallanSeriesId'] = this.challanSeriesId;
    data['ChallanNo'] = this.challanNo;
    data['ChallanDate'] = this.challanDate;
    data['CustomerId'] = this.customerId;
    data['TotalQty'] = this.totalQty;
    data['ByHand'] = this.byHand;
    data['VehicleDetails'] = this.vehicleDetails;
    data['FirmId'] = this.firmId;
    data['LocationId'] = this.locationId;
    data['PreparedBy'] = this.preparedBy;
    data['CheckedBy'] = this.checkedBy;
    data['CreatedBy'] = this.createdBy;
    data['CreatedOn'] = this.createdOn;
    data['UpdatedBy'] = this.updatedBy;
    data['UpdatedOn'] = this.updatedOn;
    data['Narration'] = this.narration;
    data['SalesId'] = this.salesId;
    data['IsCancelled'] = this.isCancelled;
    data['CustomerName'] = this.customerName;
    data['Contact'] = this.contact;
    data['DeliveryAddress'] = this.deliveryAddress;
    data['IsConvertedtoInvoice'] = this.isConvertedtoInvoice;
    if (this.details != null) {
      data['Details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Details {
  int? challanDtlsId;
  int? challanId;
  int? itemId;
  int? unitId;
  int? quantity;
  String? barcode;
  String? batchNo;
  String? mfgDate;
  String? expDate;
  int? purchaseId;
  int? purchaseRate;
  int? pFLPurchaseRate;
  int? mRP;
  int? salesRate;
  int? salesRate1;
  int? salesRate2;
  int? firmId;
  int? locationId;
  String? itemName;
  String? unitName;

  Details(
      {this.challanDtlsId,
        this.challanId,
        this.itemId,
        this.unitId,
        this.quantity,
        this.barcode,
        this.batchNo,
        this.mfgDate,
        this.expDate,
        this.purchaseId,
        this.purchaseRate,
        this.pFLPurchaseRate,
        this.mRP,
        this.salesRate,
        this.salesRate1,
        this.salesRate2,
        this.firmId,
        this.locationId,
        this.itemName,
        this.unitName});

  Details.fromJson(Map<String, dynamic> json) {
    challanDtlsId = json['ChallanDtlsId'];
    challanId = json['ChallanId'];
    itemId = json['ItemId'];
    unitId = json['UnitId'];
    quantity = json['Quantity'];
    barcode = json['Barcode'];
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];
    purchaseId = json['PurchaseId'];
    purchaseRate = json['PurchaseRate'];
    pFLPurchaseRate = json['PFL_PurchaseRate'];
    mRP = json['MRP'];
    salesRate = json['SalesRate'];
    salesRate1 = json['SalesRate1'];
    salesRate2 = json['SalesRate2'];
    firmId = json['FirmId'];
    locationId = json['LocationId'];
    itemName = json['ItemName'];
    unitName = json['UnitName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ChallanDtlsId'] = this.challanDtlsId;
    data['ChallanId'] = this.challanId;
    data['ItemId'] = this.itemId;
    data['UnitId'] = this.unitId;
    data['Quantity'] = this.quantity;
    data['Barcode'] = this.barcode;
    data['BatchNo'] = this.batchNo;
    data['MfgDate'] = this.mfgDate;
    data['ExpDate'] = this.expDate;
    data['PurchaseId'] = this.purchaseId;
    data['PurchaseRate'] = this.purchaseRate;
    data['PFL_PurchaseRate'] = this.pFLPurchaseRate;
    data['MRP'] = this.mRP;
    data['SalesRate'] = this.salesRate;
    data['SalesRate1'] = this.salesRate1;
    data['SalesRate2'] = this.salesRate2;
    data['FirmId'] = this.firmId;
    data['LocationId'] = this.locationId;
    data['ItemName'] = this.itemName;
    data['UnitName'] = this.unitName;
    return data;
  }
}
