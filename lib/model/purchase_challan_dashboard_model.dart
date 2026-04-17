class PurchaseChallanDashboardModel {
  int? purchaseId;
  int? purchaseSeriesId;
  String? purchaseDate;
  int? supplierId;
  String? supplierName;
  String? supplierBillNo;
  double? totalQty;
  double? freeQty;
  double? subTotal;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? invoiceChargesAmt;
  double? roundOff;
  double? grossBillDiscountPer;
  double? grossBillDiscountAmt;
  double? netAmt;
  double? paidAmt;
  double? balAmt;
  String? billPaidStatus;
  String? narration;
  String? byHand;
  String? vehicleDetails;
  bool? isBillPaid;
  int? preparedBy;
  bool? isChallan;
  String? supplierChallanNo;
  String? challanDate;
  bool? isPurchased;
  String? purchasedOn;
  bool? isWithoutGST;
  int? firmId;
  bool? isPurchaseReturned;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  int? locationId;

  List<PurchaseChallanDetailsModel>? details;

  PurchaseChallanDashboardModel({
    this.purchaseId,
    this.purchaseSeriesId,
    this.purchaseDate,
    this.supplierId,
    this.supplierName,
    this.supplierBillNo,
    this.totalQty,
    this.freeQty,
    this.subTotal,
    this.discAmt,
    this.taxableAmt,
    this.totalTaxAmt,
    this.invoiceChargesAmt,
    this.roundOff,
    this.grossBillDiscountPer,
    this.grossBillDiscountAmt,
    this.netAmt,
    this.paidAmt,
    this.balAmt,
    this.billPaidStatus,
    this.narration,
    this.byHand,
    this.vehicleDetails,
    this.isBillPaid,
    this.preparedBy,
    this.isChallan,
    this.supplierChallanNo,
    this.challanDate,
    this.isPurchased,
    this.purchasedOn,
    this.isWithoutGST,
    this.firmId,
    this.isPurchaseReturned,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.locationId,
    this.details,
  });

  PurchaseChallanDashboardModel.fromJson(Map<String, dynamic> json) {
    purchaseId = json['PurchaseId'];
    purchaseSeriesId = json['PurchaseSeriesId'];
    purchaseDate = json['PurchaseDate'];
    supplierId = json['SupplierId'];
    supplierName = json['SupplierName'];
    supplierBillNo = json['SupplierBillNo'];
    totalQty = (json['TotalQty'] ?? 0).toDouble();
    freeQty = (json['FreeQty'] ?? 0).toDouble();
    subTotal = (json['SubTotal'] ?? 0).toDouble();
    discAmt = (json['DiscAmt'] ?? 0).toDouble();
    taxableAmt = (json['TaxableAmt'] ?? 0).toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] ?? 0).toDouble();
    invoiceChargesAmt = (json['InvoiceChargesAmt'] ?? 0).toDouble();
    roundOff = (json['RoundOff'] ?? 0).toDouble();
    grossBillDiscountPer = (json['GrossBillDiscountPer'] ?? 0).toDouble();
    grossBillDiscountAmt = (json['GrossBillDiscountAmt'] ?? 0).toDouble();
    netAmt = (json['NetAmt'] ?? 0).toDouble();
    paidAmt = (json['PaidAmt'] ?? 0).toDouble();
    balAmt = (json['BalAmt'] ?? 0).toDouble();
    billPaidStatus = json['BillPaidStatus'];
    narration = json['Narration'];
    byHand = json['ByHand'];
    vehicleDetails = json['VehicleDetails'];
    isBillPaid = json['IsBillPaid'];
    preparedBy = json['PreparedBy'];
    isChallan = json['IsChallan'];
    supplierChallanNo = json['SupplierChallanNo'];
    challanDate = json['ChallanDate'];
    isPurchased = json['IsPurchased'];
    purchasedOn = json['PurchasedOn'];
    isWithoutGST = json['IsWithoutGST'];
    firmId = json['FirmId'];
    isPurchaseReturned = json['IsPurchaseReturned'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    locationId = json['LocationId'];

    if (json['Details'] != null) {
      details = <PurchaseChallanDetailsModel>[];
      json['Details'].forEach((v) {
        details!.add(PurchaseChallanDetailsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['PurchaseId'] = purchaseId;
    data['PurchaseSeriesId'] = purchaseSeriesId;
    data['PurchaseDate'] = purchaseDate;
    data['SupplierId'] = supplierId;
    data['SupplierName'] = supplierName;
    data['SupplierBillNo'] = supplierBillNo;
    data['TotalQty'] = totalQty;
    data['FreeQty'] = freeQty;
    data['SubTotal'] = subTotal;
    data['DiscAmt'] = discAmt;
    data['TaxableAmt'] = taxableAmt;
    data['TotalTaxAmt'] = totalTaxAmt;
    data['NetAmt'] = netAmt;
    data['LocationId'] = locationId;

    if (details != null) {
      data['Details'] = details!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class PurchaseChallanDetailsModel {
  int? purDtlsId;
  int? purchaseId;
  int? itemId;
  double? quantity;
  double? rate;
  double? itemTotal;
  double? netAmt;
  String? batchNo;
  String? expDate;
  String? itemName;
  String? unitName;
  double? mrp;
  double? purchaseRate;
  double? salesRate;

  PurchaseChallanDetailsModel({
    this.purDtlsId,
    this.purchaseId,
    this.itemId,
    this.quantity,
    this.rate,
    this.itemTotal,
    this.netAmt,
    this.batchNo,
    this.expDate,
    this.itemName,
    this.unitName,
    this.mrp,
    this.purchaseRate,
    this.salesRate,
  });

  PurchaseChallanDetailsModel.fromJson(Map<String, dynamic> json) {
    purDtlsId = json['PurDtlsId'];
    purchaseId = json['PurchaseId'];
    itemId = json['ItemId'];
    quantity = (json['Quantity'] ?? 0).toDouble();
    rate = (json['Rate'] ?? 0).toDouble();
    itemTotal = (json['ItemTotal'] ?? 0).toDouble();
    netAmt = (json['NetAmt'] ?? 0).toDouble();
    batchNo = json['BatchNo'];
    expDate = json['ExpDate'];
    itemName = json['ItemName'];
    unitName = json['UnitName'];
    mrp = (json['MRP'] ?? 0).toDouble();
    purchaseRate = (json['PurchaseRate'] ?? 0).toDouble();
    salesRate = (json['SalesRate'] ?? 0).toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['PurDtlsId'] = purDtlsId;
    data['PurchaseId'] = purchaseId;
    data['ItemId'] = itemId;
    data['Quantity'] = quantity;
    data['Rate'] = rate;
    data['ItemTotal'] = itemTotal;
    data['NetAmt'] = netAmt;
    data['BatchNo'] = batchNo;
    data['ExpDate'] = expDate;
    data['ItemName'] = itemName;
    data['UnitName'] = unitName;
    data['MRP'] = mrp;
    data['PurchaseRate'] = purchaseRate;
    data['SalesRate'] = salesRate;

    return data;
  }
}