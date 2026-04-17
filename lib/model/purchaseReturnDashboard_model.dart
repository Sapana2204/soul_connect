class PurchaseReturnDashboardModel {
  int? returnId;
  String? returnDate;
  int? supplierId;

  double? totalQty;
  double? freeQty;

  double? subTotal;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? invoiceChargesAmt;
  double? roundOff;
  double? netAmt;

  String? narration;
  String? locationName;
  String? byHand;
  int? firmId;
  int? locationId;
  int? purchaseId;

  bool? isCancelled;
  int? preparedBy;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;

  String? supplierName;
  List<Details>? details;
  List<OtherCharges>? otherCharges;

  PurchaseReturnDashboardModel.fromJson(Map<String, dynamic> json) {
    returnId = json['ReturnId'];
    returnDate = json['ReturnDate'];
    supplierId = json['SupplierId'];

    totalQty = (json['TotalQty'] as num?)?.toDouble();
    freeQty = (json['FreeQty'] as num?)?.toDouble();
    subTotal = (json['SubTotal'] as num?)?.toDouble();
    discAmt = (json['DiscAmt'] as num?)?.toDouble();
    taxableAmt = (json['TaxableAmt'] as num?)?.toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] as num?)?.toDouble();
    invoiceChargesAmt = (json['InvoiceChargesAmt'] as num?)?.toDouble();
    roundOff = (json['RoundOff'] as num?)?.toDouble();
    netAmt = (json['NetAmt'] as num?)?.toDouble();
    locationName = json['LocationName'];
    narration = json['Narration'];
    byHand = json['ByHand'];
    firmId = json['FirmId'];
    locationId = json['LocationId'];
    purchaseId = json['PurchaseId'];

    isCancelled = json['IsCancelled'];
    preparedBy = json['PreparedBy'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];

    supplierName = json['SupplierName'];

    details = json['Details'] != null
        ? (json['Details'] as List)
        .map((e) => Details.fromJson(e))
        .toList()
        : [];

    otherCharges = json['OtherCharges'] != null
        ? (json['OtherCharges'] as List)
        .map((e) => OtherCharges.fromJson(e))
        .toList()
        : [];
  }

  /// ✅ TO JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['ReturnId'] = returnId;
    data['ReturnDate'] = returnDate;
    data['SupplierId'] = supplierId;

    data['TotalQty'] = totalQty;
    data['FreeQty'] = freeQty;
    data['LocationName'] = locationName;
    data['SubTotal'] = subTotal;
    data['DiscAmt'] = discAmt;
    data['TaxableAmt'] = taxableAmt;
    data['TotalTaxAmt'] = totalTaxAmt;
    data['InvoiceChargesAmt'] = invoiceChargesAmt;
    data['RoundOff'] = roundOff;
    data['NetAmt'] = netAmt;

    data['Narration'] = narration;
    data['ByHand'] = byHand;
    data['FirmId'] = firmId;
    data['LocationId'] = locationId;
    data['PurchaseId'] = purchaseId;

    data['IsCancelled'] = isCancelled;
    data['PreparedBy'] = preparedBy;
    data['CreatedBy'] = createdBy;
    data['CreatedOn'] = createdOn;
    data['UpdatedBy'] = updatedBy;
    data['UpdatedOn'] = updatedOn;

    data['SupplierName'] = supplierName;

    data['Details'] = details != null
        ? details!.map((e) => e.toJson()).toList()
        : [];

    data['OtherCharges'] = otherCharges != null
        ? otherCharges!.map((e) => e.toJson()).toList()
        : [];

    return data;
  }
}

class Details {
  int? returnDetailsId;
  int? returnId;
  int? itemId;
  int? unitId;


  double? quantity;
  double? freeQuantity;
  double? rate;
  double? itemTotal;
  double? discPer;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? netAmt;

  String? batchNo;
  String? expDate;

  double? marginPer;
  double? salesRate;
  double? mRP;
  int? pax;

  double? taxPer1;
  double? taxAmt1;
  double? taxPer2;
  double? taxAmt2;
  double? taxPer3;
  double? taxAmt3;
  double? taxPer4;
  double? taxAmt4;
  double? taxPer5;
  double? taxAmt5;

  double? salesRate1;
  double? salesRate2;

  int? stkPurchaseId;
  bool? isWithoutGST;
  double? actRetQty;
  int? locationId;

  Details.fromJson(Map<String, dynamic> json) {
    returnDetailsId = json['ReturnDetailsId'];
    returnId = json['ReturnId'];
    itemId = json['ItemId'];
    unitId = json['UnitId'];

    quantity = (json['Quantity'] as num?)?.toDouble();
    freeQuantity = (json['FreeQuantity'] as num?)?.toDouble();
    rate = (json['Rate'] as num?)?.toDouble();
    itemTotal = (json['ItemTotal'] as num?)?.toDouble();
    discPer = (json['DiscPer'] as num?)?.toDouble();
    discAmt = (json['DiscAmt'] as num?)?.toDouble();
    taxableAmt = (json['TaxableAmt'] as num?)?.toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] as num?)?.toDouble();
    netAmt = (json['NetAmt'] as num?)?.toDouble();

    batchNo = json['BatchNo'];
    expDate = json['ExpDate'];

    marginPer = (json['MarginPer'] as num?)?.toDouble();
    salesRate = (json['SalesRate'] as num?)?.toDouble();
    mRP = (json['MRP'] as num?)?.toDouble();
    pax = json['Pax'];

    taxPer1 = (json['TaxPer1'] as num?)?.toDouble();
    taxAmt1 = (json['TaxAmt1'] as num?)?.toDouble();
    taxPer2 = (json['TaxPer2'] as num?)?.toDouble();
    taxAmt2 = (json['TaxAmt2'] as num?)?.toDouble();
    taxPer3 = (json['TaxPer3'] as num?)?.toDouble();
    taxAmt3 = (json['TaxAmt3'] as num?)?.toDouble();
    taxPer4 = (json['TaxPer4'] as num?)?.toDouble();
    taxAmt4 = (json['TaxAmt4'] as num?)?.toDouble();
    taxPer5 = (json['TaxPer5'] as num?)?.toDouble();
    taxAmt5 = (json['TaxAmt5'] as num?)?.toDouble();

    salesRate1 = (json['SalesRate1'] as num?)?.toDouble();
    salesRate2 = (json['SalesRate2'] as num?)?.toDouble();

    stkPurchaseId = json['StkPurchaseId'];
    isWithoutGST = json['IsWithoutGST'];
    actRetQty = (json['ActRetQty'] as num?)?.toDouble();
    locationId = json['LocationId'];
  }

  /// ✅ TO JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['ReturnDetailsId'] = returnDetailsId;
    data['ReturnId'] = returnId;
    data['ItemId'] = itemId;
    data['UnitId'] = unitId;

    data['Quantity'] = quantity;
    data['FreeQuantity'] = freeQuantity;
    data['Rate'] = rate;
    data['ItemTotal'] = itemTotal;
    data['DiscPer'] = discPer;
    data['DiscAmt'] = discAmt;
    data['TaxableAmt'] = taxableAmt;
    data['TotalTaxAmt'] = totalTaxAmt;
    data['NetAmt'] = netAmt;

    data['BatchNo'] = batchNo;
    data['ExpDate'] = expDate;

    data['MarginPer'] = marginPer;
    data['SalesRate'] = salesRate;
    data['MRP'] = mRP;
    data['Pax'] = pax;

    data['TaxPer1'] = taxPer1;
    data['TaxAmt1'] = taxAmt1;
    data['TaxPer2'] = taxPer2;
    data['TaxAmt2'] = taxAmt2;
    data['TaxPer3'] = taxPer3;
    data['TaxAmt3'] = taxAmt3;
    data['TaxPer4'] = taxPer4;
    data['TaxAmt4'] = taxAmt4;
    data['TaxPer5'] = taxPer5;
    data['TaxAmt5'] = taxAmt5;

    data['SalesRate1'] = salesRate1;
    data['SalesRate2'] = salesRate2;

    data['StkPurchaseId'] = stkPurchaseId;
    data['IsWithoutGST'] = isWithoutGST;
    data['ActRetQty'] = actRetQty;
    data['LocationId'] = locationId;

    return data;
  }
}

class OtherCharges {
  int? returnChargeId;
  int? returnId;
  int? ledgerId;
  double? amount;

  OtherCharges({this.returnChargeId, this.returnId, this.ledgerId, this.amount});

  OtherCharges.fromJson(Map<String, dynamic> json) {
    returnChargeId = json['ReturnChargeId'];
    returnId = json['ReturnId'];
    ledgerId = json['LedgerId'];
    amount = (json['Amount'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['ReturnChargeId'] = returnChargeId;
    data['ReturnId'] = returnId;
    data['LedgerId'] = ledgerId;
    data['Amount'] = amount;
    return data;
  }
}
