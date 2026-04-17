class PurchaseReturnModel {
  int? returnId;
  String? returnDate;
  int? supplierId;
  int? totalQty;
  int? freeQty;
  int? subTotal;
  int? discAmt;
  int? taxableAmt;
  int? totalTaxAmt;
  int? invoiceChargesAmt;
  int? roundOff;
  int? netAmt;
  String? taxIncludeExclude;
  String? narration;
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
  int? userID;
  List<Details>? details;
  List<OtherCharges>? otherCharges;

  PurchaseReturnModel(
      {this.returnId,
        this.returnDate,
        this.supplierId,
        this.totalQty,
        this.freeQty,
        this.subTotal,
        this.discAmt,
        this.taxableAmt,
        this.totalTaxAmt,
        this.invoiceChargesAmt,
        this.roundOff,
        this.netAmt,
        this.taxIncludeExclude,
        this.narration,
        this.byHand,
        this.firmId,
        this.locationId,
        this.purchaseId,
        this.isCancelled,
        this.preparedBy,
        this.createdBy,
        this.createdOn,
        this.updatedBy,
        this.updatedOn,
        this.userID,
        this.details,
        this.otherCharges});

  PurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    returnId = json['ReturnId'];
    returnDate = json['ReturnDate'];
    supplierId = json['SupplierId'];
    totalQty = json['TotalQty'];
    freeQty = json['FreeQty'];
    subTotal = json['SubTotal'];
    discAmt = json['DiscAmt'];
    taxableAmt = json['TaxableAmt'];
    totalTaxAmt = json['TotalTaxAmt'];
    invoiceChargesAmt = json['InvoiceChargesAmt'];
    roundOff = json['RoundOff'];
    netAmt = json['NetAmt'];
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
    userID = json['UserID'];
    if (json['Details'] != null) {
      details = <Details>[];
      json['Details'].forEach((v) {
        details!.add(new Details.fromJson(v));
      });
    }
    if (json['OtherCharges'] != null) {
      otherCharges = <OtherCharges>[];
      json['OtherCharges'].forEach((v) {
        otherCharges!.add(new OtherCharges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReturnId'] = this.returnId;
    data['ReturnDate'] = this.returnDate;
    data['SupplierId'] = this.supplierId;
    data['TotalQty'] = this.totalQty;
    data['FreeQty'] = this.freeQty;
    data['SubTotal'] = this.subTotal;
    data['DiscAmt'] = this.discAmt;
    data['TaxableAmt'] = this.taxableAmt;
    data['TotalTaxAmt'] = this.totalTaxAmt;
    data['InvoiceChargesAmt'] = this.invoiceChargesAmt;
    data['RoundOff'] = this.roundOff;
    data['NetAmt'] = this.netAmt;
    data['TaxIncludeExclude'] = this.taxIncludeExclude;
    data['Narration'] = this.narration;
    data['ByHand'] = this.byHand;
    data['FirmId'] = this.firmId;
    data['LocationId'] = this.locationId;
    data['PurchaseId'] = this.purchaseId;
    data['IsCancelled'] = this.isCancelled;
    data['PreparedBy'] = this.preparedBy;
    data['CreatedBy'] = this.createdBy;
    data['CreatedOn'] = this.createdOn;
    data['UpdatedBy'] = this.updatedBy;
    data['UpdatedOn'] = this.updatedOn;
    data['UserID'] = this.userID;
    if (this.details != null) {
      data['PurchaseReturnDetails'] =
          this.details!.map((v) => v.toJson()).toList();
    }
    if (this.otherCharges != null) {
      data['OtherCharges'] = this.otherCharges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Details {
  int? itemId;
  int? unitId;
  int? quantity;
  int? freeQuantity;
  int? rate;
  int? purchaseRateWithTax;
  int? itemTotal;
  int? discPer;
  int? discAmt;
  int? taxableAmt;
  int? totalTaxAmt;
  int? netAmt;
  String? batchNo;
  String? mfgDate;
  String? expDate;
  int? marginPer;
  int? salesRate;
  int? mRP;
  int? pax;
  int? taxPer1;
  int? taxAmt1;
  int? taxPer2;
  int? taxAmt2;
  int? taxPer3;
  int? taxAmt3;
  int? taxPer4;
  int? taxAmt4;
  int? taxPer5;
  int? taxAmt5;
  int? salesRate1;
  int? salesRate2;
  int? stkPurchaseId;
  bool? isWithoutGST;
  int? actRetQty;
  int? firmId;
  int? locationId;
  String? barcode;

  Details(
      {this.itemId,
        this.unitId,
        this.quantity,
        this.freeQuantity,
        this.rate,
        this.purchaseRateWithTax,
        this.itemTotal,
        this.discPer,
        this.discAmt,
        this.taxableAmt,
        this.totalTaxAmt,
        this.netAmt,
        this.batchNo,
        this.mfgDate,
        this.expDate,
        this.marginPer,
        this.salesRate,
        this.mRP,
        this.pax,
        this.taxPer1,
        this.taxAmt1,
        this.taxPer2,
        this.taxAmt2,
        this.taxPer3,
        this.taxAmt3,
        this.taxPer4,
        this.taxAmt4,
        this.taxPer5,
        this.taxAmt5,
        this.salesRate1,
        this.salesRate2,
        this.stkPurchaseId,
        this.isWithoutGST,
        this.actRetQty,
        this.firmId,
        this.locationId,
        this.barcode});

  Details.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    unitId = json['UnitId'];
    quantity = json['Quantity'];
    freeQuantity = json['FreeQuantity'];
    rate = json['Rate'];
    purchaseRateWithTax = json['PurchaseRateWithTax'];
    itemTotal = json['ItemTotal'];
    discPer = json['DiscPer'];
    discAmt = json['DiscAmt'];
    taxableAmt = json['TaxableAmt'];
    totalTaxAmt = json['TotalTaxAmt'];
    netAmt = json['NetAmt'];
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];
    marginPer = json['MarginPer'];
    salesRate = json['SalesRate'];
    mRP = json['MRP'];
    pax = json['Pax'];
    taxPer1 = json['TaxPer1'];
    taxAmt1 = json['TaxAmt1'];
    taxPer2 = json['TaxPer2'];
    taxAmt2 = json['TaxAmt2'];
    taxPer3 = json['TaxPer3'];
    taxAmt3 = json['TaxAmt3'];
    taxPer4 = json['TaxPer4'];
    taxAmt4 = json['TaxAmt4'];
    taxPer5 = json['TaxPer5'];
    taxAmt5 = json['TaxAmt5'];
    salesRate1 = json['SalesRate1'];
    salesRate2 = json['SalesRate2'];
    stkPurchaseId = json['StkPurchaseId'];
    isWithoutGST = json['IsWithoutGST'];
    actRetQty = json['ActRetQty'];
    firmId = json['FirmId'];
    locationId = json['LocationId'];
    barcode = json['Barcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ItemId'] = this.itemId;
    data['UnitId'] = this.unitId;
    data['Quantity'] = this.quantity;
    data['FreeQuantity'] = this.freeQuantity;
    data['Rate'] = this.rate;
    data['PurchaseRateWithTax'] = this.purchaseRateWithTax;
    data['ItemTotal'] = this.itemTotal;
    data['DiscPer'] = this.discPer;
    data['DiscAmt'] = this.discAmt;
    data['TaxableAmt'] = this.taxableAmt;
    data['TotalTaxAmt'] = this.totalTaxAmt;
    data['NetAmt'] = this.netAmt;
    data['BatchNo'] = this.batchNo;
    data['MfgDate'] = this.mfgDate;
    data['ExpDate'] = this.expDate;
    data['MarginPer'] = this.marginPer;
    data['SalesRate'] = this.salesRate;
    data['MRP'] = this.mRP;
    data['Pax'] = this.pax;
    data['TaxPer1'] = this.taxPer1;
    data['TaxAmt1'] = this.taxAmt1;
    data['TaxPer2'] = this.taxPer2;
    data['TaxAmt2'] = this.taxAmt2;
    data['TaxPer3'] = this.taxPer3;
    data['TaxAmt3'] = this.taxAmt3;
    data['TaxPer4'] = this.taxPer4;
    data['TaxAmt4'] = this.taxAmt4;
    data['TaxPer5'] = this.taxPer5;
    data['TaxAmt5'] = this.taxAmt5;
    data['SalesRate1'] = this.salesRate1;
    data['SalesRate2'] = this.salesRate2;
    data['StkPurchaseId'] = this.stkPurchaseId;
    data['IsWithoutGST'] = this.isWithoutGST;
    data['ActRetQty'] = this.actRetQty;
    data['FirmId'] = this.firmId;
    data['LocationId'] = this.locationId;
    data['Barcode'] = this.barcode;
    return data;
  }
}

class OtherCharges {
  int? ledgerId;
  int? amount;

  OtherCharges({this.ledgerId, this.amount});

  OtherCharges.fromJson(Map<String, dynamic> json) {
    ledgerId = json['LedgerId'];
    amount = json['Amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LedgerId'] = this.ledgerId;
    data['Amount'] = this.amount;
    return data;
  }
}
