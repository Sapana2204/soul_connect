class AddPurchaseModel {
  int? purchaseId;
  int? purchaseSeriesId;
  String? purchaseDate;
  int? supplierId;
  String? supplierBillNo;
  double? totalQty;
  double? freeQty;
  double? subTotal;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? roundOff;
  double? netAmt;
  int? invoiceChargesAmt;
  int? grossBillDiscountAmt;
  double? grossBillDiscountPer;
  int? paidAmt;
  int? balAmt;
  String? billPaidStatus;
  String? narration;
  String? byHand;
  String? vehicleDetails;
  int? isBillPaid;
  String? preparedByUser;
  String? createdByUser;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  int? userId;
  bool? isChallan;
  String? supplierChallanNo;
  String? challanDate;
  bool? isPurchased;
  bool? isWithoutGST;
  bool? isPurchaseReturned;
  String? misc1;
  String? misc2;
  String? misc3;
  String? misc4;
  String? misc5;
  int? locationId;
  String? purchasedOn;
  int? firmId;
  bool? isCancelled;
  String? supplierName;
  String? address;
  String? mobile;
  String? gSTIN;
  String? payMode;
  String? paymentTerm;
  List<PurchaseOtherCharges>? purchaseOtherCharges;
  List<Details>? details;
  String? taxIncludeExclude;

  AddPurchaseModel(
      {this.purchaseId,
        this.purchaseSeriesId,
        this.purchaseDate,
        this.supplierId,
        this.supplierBillNo,
        this.totalQty,
        this.freeQty,
        this.subTotal,
        this.discAmt,
        this.taxableAmt,
        this.totalTaxAmt,
        this.invoiceChargesAmt,
        this.roundOff,
        this.grossBillDiscountAmt,
        this.grossBillDiscountPer,
        this.netAmt,
        this.paidAmt,
        this.balAmt,
        this.billPaidStatus,
        this.narration,
        this.byHand,
        this.vehicleDetails,
        this.isBillPaid,
        this.preparedByUser,
        this.createdByUser,
        this.createdBy,
        this.createdOn,
        this.updatedBy,
        this.updatedOn,
        this.userId,
        this.isChallan,
        this.supplierChallanNo,
        this.challanDate,
        this.isPurchased,
        this.isWithoutGST,
        this.isPurchaseReturned,
        this.misc1,
        this.misc2,
        this.misc3,
        this.misc4,
        this.misc5,
        this.locationId,
        this.purchasedOn,
        this.firmId,
        this.isCancelled,
        this.supplierName,
        this.address,
        this.mobile,
        this.gSTIN,
        this.payMode,
        this.paymentTerm,
        this.purchaseOtherCharges,
        this.taxIncludeExclude,
        this.details});

  AddPurchaseModel.fromJson(Map<String, dynamic> json) {
    purchaseId = json['PurchaseId'];
    purchaseSeriesId = json['PurchaseSeriesId'];
    purchaseDate = json['PurchaseDate'];
    supplierId = json['SupplierId'];
    supplierBillNo = json['SupplierBillNo'];
    totalQty = json['TotalQty'];
    freeQty = json['FreeQty'];
    subTotal = json['SubTotal'];
    discAmt = json['DiscAmt'];
    taxableAmt = json['TaxableAmt'];
    totalTaxAmt = json['TotalTaxAmt'];
    invoiceChargesAmt = json['InvoiceChargesAmt'];
    roundOff = json['RoundOff'];
    grossBillDiscountAmt = json['GrossBillDiscountAmt'];
    grossBillDiscountPer = json['GrossBillDiscountPer'];
    netAmt = json['NetAmt'];
    paidAmt = json['PaidAmt'];
    balAmt = json['BalAmt'];
    billPaidStatus = json['BillPaidStatus'];
    narration = json['Narration'];
    byHand = json['ByHand'];
    vehicleDetails = json['VehicleDetails'];
    isBillPaid = json['IsBillPaid'];
    preparedByUser = json['PreparedByUser'];
    createdByUser = json['CreatedByUser'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    userId = json['UserId'];
    isChallan = json['IsChallan'];
    supplierChallanNo = json['SupplierChallanNo'];
    challanDate = json['ChallanDate'];
    isPurchased = json['IsPurchased'];
    isWithoutGST = json['IsWithoutGST'];
    isPurchaseReturned = json['IsPurchaseReturned'];
    misc1 = json['Misc1'];
    misc2 = json['Misc2'];
    misc3 = json['Misc3'];
    misc4 = json['Misc4'];
    misc5 = json['Misc5'];
    locationId = json['LocationId'];
    purchasedOn = json['PurchasedOn'];
    firmId = json['FirmId'];
    isCancelled = json['IsCancelled'];
    supplierName = json['SupplierName'];
    address = json['Address'];
    mobile = json['Mobile'];
    gSTIN = json['GSTIN'];
    payMode = json['PayMode'];
    taxIncludeExclude = json['TaxIncludeExclude'];
    paymentTerm = json['PaymentTerm'];
    if (json['PurchaseOtherCharges'] != null) {
      purchaseOtherCharges = <PurchaseOtherCharges>[];
      json['PurchaseOtherCharges'].forEach((v) {
        purchaseOtherCharges!.add(new PurchaseOtherCharges.fromJson(v));
      });
    }
    if (json['Details'] != null) {
      details = <Details>[];
      json['Details'].forEach((v) {
        details!.add(new Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PurchaseId'] = this.purchaseId;
    data['PurchaseSeriesId'] = this.purchaseSeriesId;
    data['PurchaseDate'] = this.purchaseDate;
    data['SupplierId'] = this.supplierId;
    data['SupplierBillNo'] = this.supplierBillNo;
    data['TotalQty'] = this.totalQty;
    data['FreeQty'] = this.freeQty;
    data['SubTotal'] = this.subTotal;
    data['DiscAmt'] = this.discAmt;
    data['TaxableAmt'] = this.taxableAmt;
    data['TotalTaxAmt'] = this.totalTaxAmt;
    data['InvoiceChargesAmt'] = this.invoiceChargesAmt;
    data['RoundOff'] = this.roundOff;
    data['GrossBillDiscountAmt'] = this.grossBillDiscountAmt;
    data['GrossBillDiscountPer'] = this.grossBillDiscountPer;
    data['NetAmt'] = this.netAmt;
    data['PaidAmt'] = this.paidAmt;
    data['BalAmt'] = this.balAmt;
    data['BillPaidStatus'] = this.billPaidStatus;
    data['Narration'] = this.narration;
    data['ByHand'] = this.byHand;
    data['VehicleDetails'] = this.vehicleDetails;
    data['IsBillPaid'] = this.isBillPaid;
    data['PreparedByUser'] = this.preparedByUser;
    data['CreatedByUser'] = this.createdByUser;
    data['CreatedBy'] = this.createdBy;
    data['CreatedOn'] = this.createdOn;
    data['UpdatedBy'] = this.updatedBy;
    data['UpdatedOn'] = this.updatedOn;
    data['UserId'] = this.userId;
    data['IsChallan'] = this.isChallan;
    data['SupplierChallanNo'] = this.supplierChallanNo;
    data['ChallanDate'] = this.challanDate;
    data['IsPurchased'] = this.isPurchased;
    data['IsWithoutGST'] = this.isWithoutGST;
    data['IsPurchaseReturned'] = this.isPurchaseReturned;
    data['Misc1'] = this.misc1;
    data['Misc2'] = this.misc2;
    data['Misc3'] = this.misc3;
    data['Misc4'] = this.misc4;
    data['Misc5'] = this.misc5;
    data['LocationId'] = this.locationId;
    data['PurchasedOn'] = this.purchasedOn;
    data['FirmId'] = this.firmId;
    data['IsCancelled'] = this.isCancelled;
    data['SupplierName'] = this.supplierName;
    data['Address'] = this.address;
    data['Mobile'] = this.mobile;
    data['GSTIN'] = this.gSTIN;
    data['PayMode'] = this.payMode;
    data['PaymentTerm'] = this.paymentTerm;
    data['TaxIncludeExclude'] = this.taxIncludeExclude;
    if (this.purchaseOtherCharges != null) {
      data['PurchaseOtherCharges'] =
          this.purchaseOtherCharges!.map((v) => v.toJson()).toList();
    }
    if (this.details != null) {
      data['Details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseOtherCharges {
  int? purchaseInvChargeId;
  int? ledgerId;
  int? purchaseId;
  double? amount;
  String? ledgerName;

  PurchaseOtherCharges(
      {this.purchaseInvChargeId,
        this.ledgerId,
        this.purchaseId,
        this.amount,
        this.ledgerName});

  PurchaseOtherCharges.fromJson(Map<String, dynamic> json) {
    purchaseInvChargeId = json['PurchaseInvChargeId'];
    ledgerId = json['LedgerId'];
    purchaseId = json['PurchaseId'];
    amount = json['Amount'];
    ledgerName = json['LedgerName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PurchaseInvChargeId'] = this.purchaseInvChargeId;
    data['LedgerId'] = this.ledgerId;
    data['PurchaseId'] = this.purchaseId;
    data['Amount'] = this.amount;
    data['LedgerName'] = this.ledgerName;
    return data;
  }
}

class Details {
  int? purDtlsId;
  int? purchaseId;
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
  String? mfgDate;
  String? expDate;
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
  double? schemePer;
  double? schemeAmt;
  String? barcode;
  double? mRP;
  double? purchaseRate;
  double? salesRate;
  double? salesRate1;
  double? salesRate2;
  double? cashRateMargin;
  double? creditRateMargin;
  double? outletRateMargin;
  bool? isWithoutGST;
  double? returnQty;
  String? hSNCode;
  int? taxGroupId;
  int? firmId;
  int? locationId;
  String? itemName;
  String? unitName;
  double? totalTaxPer;

  Details({
    this.purDtlsId,
    this.purchaseId,
    this.itemId,
    this.unitId,
    this.quantity,
    this.freeQuantity,
    this.rate,
    this.itemTotal,
    this.discPer,
    this.discAmt,
    this.taxableAmt,
    this.totalTaxAmt,
    this.netAmt,
    this.batchNo,
    this.mfgDate,
    this.expDate,
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
    this.schemePer,
    this.schemeAmt,
    this.barcode,
    this.mRP,
    this.purchaseRate,
    this.salesRate,
    this.salesRate1,
    this.salesRate2,
    this.cashRateMargin,
    this.creditRateMargin,
    this.outletRateMargin,
    this.isWithoutGST,
    this.returnQty,
    this.hSNCode,
    this.taxGroupId,
    this.firmId,
    this.locationId,
    this.itemName,
    this.unitName,
    this.totalTaxPer,
  });

  Details.fromJson(Map<String, dynamic> json) {
    purDtlsId = json['PurDtlsId'];
    purchaseId = json['PurchaseId'];
    itemId = json['ItemId'];
    unitId = json['UnitId'];
    quantity = (json['Quantity'] ?? 0).toDouble();
    freeQuantity = (json['FreeQuantity'] ?? 0).toDouble();
    rate = (json['Rate'] ?? 0).toDouble();
    itemTotal = (json['ItemTotal'] ?? 0).toDouble();
    discPer = (json['DiscPer'] ?? 0).toDouble();
    discAmt = (json['DiscAmt'] ?? 0).toDouble();
    taxableAmt = (json['TaxableAmt'] ?? 0).toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] ?? 0).toDouble();
    netAmt = (json['NetAmt'] ?? 0).toDouble();
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];
    taxPer1 = (json['TaxPer1'] ?? 0).toDouble();
    taxAmt1 = (json['TaxAmt1'] ?? 0).toDouble();
    taxPer2 = (json['TaxPer2'] ?? 0).toDouble();
    taxAmt2 = (json['TaxAmt2'] ?? 0).toDouble();
    taxPer3 = (json['TaxPer3'] ?? 0).toDouble();
    taxAmt3 = (json['TaxAmt3'] ?? 0).toDouble();
    taxPer4 = (json['TaxPer4'] ?? 0).toDouble();
    taxAmt4 = (json['TaxAmt4'] ?? 0).toDouble();
    taxPer5 = (json['TaxPer5'] ?? 0).toDouble();
    taxAmt5 = (json['TaxAmt5'] ?? 0).toDouble();
    schemePer = (json['SchemePer'] ?? 0).toDouble();
    schemeAmt = (json['SchemeAmt'] ?? 0).toDouble();
    barcode = json['Barcode'];
    mRP = (json['MRP'] ?? 0).toDouble();
    purchaseRate = (json['PurchaseRate'] ?? 0).toDouble();
    salesRate = (json['SalesRate'] ?? 0).toDouble();
    salesRate1 = (json['SalesRate1'] ?? 0).toDouble();
    salesRate2 = (json['SalesRate2'] ?? 0).toDouble();
    cashRateMargin = (json['CashRateMargin'] ?? 0).toDouble();
    creditRateMargin = (json['CreditRateMargin'] ?? 0).toDouble();
    outletRateMargin = (json['OutletRateMargin'] ?? 0).toDouble();
    isWithoutGST = json['IsWithoutGST'];
    returnQty = (json['ReturnQty'] ?? 0).toDouble();
    hSNCode = json['HSNCode'];
    taxGroupId = json['TaxGroupId'];
    firmId = json['FirmId'];
    locationId = json['LocationId'];
    itemName = json['ItemName'];
    unitName = json['UnitName'];
    totalTaxPer = (json['TotalTaxPer'] ?? 0).toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['PurDtlsId'] = purDtlsId;
    data['PurchaseId'] = purchaseId;
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
    data['MfgDate'] = mfgDate;
    data['ExpDate'] = expDate;
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
    data['SchemePer'] = schemePer;
    data['SchemeAmt'] = schemeAmt;
    data['Barcode'] = barcode;
    data['MRP'] = mRP;
    data['PurchaseRate'] = purchaseRate;
    data['SalesRate'] = salesRate;
    data['SalesRate1'] = salesRate1;
    data['SalesRate2'] = salesRate2;
    data['CashRateMargin'] = cashRateMargin;
    data['CreditRateMargin'] = creditRateMargin;
    data['OutletRateMargin'] = outletRateMargin;
    data['IsWithoutGST'] = isWithoutGST;
    data['ReturnQty'] = returnQty;
    data['HSNCode'] = hSNCode;
    data['TaxGroupId'] = taxGroupId;
    data['FirmId'] = firmId;
    data['LocationId'] = locationId;
    data['ItemName'] = itemName;
    data['UnitName'] = unitName;
    data['TotalTaxPer'] = totalTaxPer;
    return data;
  }
}

