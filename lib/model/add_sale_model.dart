class AddSaleModel {
  int salesID;
  String salesBillNo;
  String salesDate;
  int customerId;
  double totalQty;
  double itemTotal;
  int locationId;
  int userID;
  String billType;
  String rateType;
  String taxIncludeExclude;
  String salesType;
  String paymentTerm;
  String cropType;
  double freeQty;
  double subTotal;
  double discPer;
  double discAmt;
  double totalDiscAmt;
  double totalAmt;
  double freight;
  double taxableAmt;
  double totalTaxAmt;
  double totalTaxableAmt;
  double invoiceChargesAmt;
  double billTotal;
  double roundOff;
  double netBillTotal;
  double netAmt;
  double netBillAmt;
  String narration;
  String byHand;
  String vehicleDetails;
  bool isBillReceived;
  int bankLedgerId;
  bool isChallanInvoice;
  bool isQuotationInvoice;
  bool isWalkinCustomer;
  String customerName;
  String address;
  int age;
  double cashPaidAmount;
  double bankPaidAmount;
  String modeOfBankPayment;
  double customerOutstanding;
  bool isSalesReturned;
  String misc1;
  String misc2;
  String misc3;
  String misc4;
  String misc5;
  int preparedBy;
  int checkedBy;
  int createdBy;
  int updatedBy;
  String phoneNumber;
  List<SalesDetail> salesDetails;
  List<SalesOtherCharge> salesOtherCharges;

  AddSaleModel({
    required this.salesID,
    required this.salesBillNo,
    required this.salesDate,
    required this.customerId,
    required this.totalQty,
    required this.itemTotal,
    required this.locationId,
    required this.userID,
    required this.billType,
    required this.rateType,
    required this.taxIncludeExclude,
    required this.salesType,
    required this.paymentTerm,
    required this.cropType,
    required this.freeQty,
    required this.subTotal,
    required this.discPer,
    required this.discAmt,
    required this.totalDiscAmt,
    required this.totalAmt,
    required this.freight,
    required this.taxableAmt,
    required this.totalTaxAmt,
    required this.totalTaxableAmt,
    required this.invoiceChargesAmt,
    required this.billTotal,
    required this.roundOff,
    required this.netBillTotal,
    required this.netAmt,
    required this.netBillAmt,
    required this.narration,
    required this.byHand,
    required this.vehicleDetails,
    required this.isBillReceived,
    required this.bankLedgerId,
    required this.isChallanInvoice,
    required this.isQuotationInvoice,
    required this.isWalkinCustomer,
    required this.customerName,
    required this.address,
    required this.age,
    required this.cashPaidAmount,
    required this.bankPaidAmount,
    required this.modeOfBankPayment,
    required this.customerOutstanding,
    required this.isSalesReturned,
    required this.misc1,
    required this.misc2,
    required this.misc3,
    required this.misc4,
    required this.misc5,
    required this.preparedBy,
    required this.checkedBy,
    required this.createdBy,
    required this.updatedBy,
    required this.phoneNumber,
    required this.salesDetails,
    required this.salesOtherCharges,
  });

  Map<String, dynamic> toJson() => {
    "SalesID": salesID,
    "SalesBillNo": salesBillNo,
    "SalesDate": salesDate,
    "CustomerId": customerId,
    "TotalQty": totalQty,
    "ItemTotal": itemTotal,
    "LocationId": locationId,
    "UserID": userID,
    "BillType": billType,
    "RateType": rateType,
    "TaxIncludeExclude": taxIncludeExclude,
    "SalesType": salesType,
    "PaymentTerm": paymentTerm,
    "CropType": cropType,
    "FreeQty": freeQty,
    "SubTotal": subTotal,
    "DiscPer": discPer,
    "DiscAmt": discAmt,
    "TotalDiscAmt": totalDiscAmt,
    "TotalAmt": totalAmt,
    "Freight": freight,
    "TaxableAmt": taxableAmt,
    "TotalTaxAmt": totalTaxAmt,
    "TotalTaxableAmt": totalTaxableAmt,
    "InvoiceChargesAmt": invoiceChargesAmt,
    "BillTotal": billTotal,
    "RoundOff": roundOff,
    "NetBillTotal": netBillTotal,
    "NetAmt": netAmt,
    "NetBillAmt": netBillAmt,
    "Narration": narration,
    "ByHand": byHand,
    "VehicleDetails": vehicleDetails,
    "IsBillReceived": isBillReceived,
    "BankLedgerId": bankLedgerId,
    "IsChallanInvoice": isChallanInvoice,
    "IsQuotationInvoice": isQuotationInvoice,
    "IsWalkinCustomer": isWalkinCustomer,
    "CustomerName": customerName,
    "Address": address,
    "Age": age,
    "CashPaidAmount": cashPaidAmount,
    "BankPaidAmount": bankPaidAmount,
    "ModeOfBankPayment": modeOfBankPayment,
    "CustomerOutstanding": customerOutstanding,
    "IsSalesReturned": isSalesReturned,
    "Misc1": misc1,
    "Misc2": misc2,
    "Misc3": misc3,
    "Misc4": misc4,
    "Misc5": misc5,
    "PreparedBy": preparedBy,
    "CheckedBy": checkedBy,
    "CreatedBy": createdBy,
    "UpdatedBy": updatedBy,
    "PhoneNumber": phoneNumber,
    "Details": salesDetails.map((x) => x.toJson()).toList(),
    "OtherCharges":
    salesOtherCharges.map((x) => x.toJson()).toList(),
  };
}

class SalesDetail {
  int itemId;
  int unitId;
  String itemName;
  String barcode;
  double quantity;
  double rate;
  double freeQuantity;
  double itemTotal;
  String discPer;
  double discAmt;
  double totalDiscount;
  double taxableAmt;
  double taxPer;
  double taxPer1;
  double taxAmt1;
  double taxPer2;
  double taxAmt2;
  String taxPer3;
  String taxAmt3;
  String taxPer4;
  String taxAmt4;
  String taxPer5;
  String taxAmt5;
  int taxGroupId;
  double purchaseRate;
  double purchaseRateWithTax;
  // double cashSalesRate;
  // double creditSalesRate;
  // double outletSalesRate;
  double mrp;
  int stkPurchaseId;
  double totalTaxAmt;
  double netAmt;
  // double pflPurchaseRate;
  String usedAs;
  bool isWithoutGST;
  String returnQty;
  String action;

  SalesDetail({
    required this.itemId,
    required this.unitId,
    required this.itemName,
    required this.barcode,
    required this.quantity,
    required this.rate,
    required this.freeQuantity,
    required this.itemTotal,
    required this.discPer,
    required this.discAmt,
    required this.totalDiscount,
    required this.taxableAmt,
    required this.taxPer,
    required this.taxPer1,
    required this.taxAmt1,
    required this.taxPer2,
    required this.taxAmt2,
    required this.taxPer3,
    required this.taxAmt3,
    required this.taxPer4,
    required this.taxAmt4,
    required this.taxPer5,
    required this.taxAmt5,
    required this.taxGroupId,
    required this.purchaseRate,
    required this.purchaseRateWithTax,
    // required this.cashSalesRate,
    // required this.creditSalesRate,
    // required this.outletSalesRate,
    required this.mrp,
    required this.stkPurchaseId,
    required this.totalTaxAmt,
    required this.netAmt,
    // required this.pflPurchaseRate,
    required this.usedAs,
    required this.isWithoutGST,
    required this.returnQty,
    required this.action,
  });

  Map<String, dynamic> toJson() => {
    "ItemId": itemId,
    "UnitId": unitId,
    "ItemName": itemName,
    "Barcode": barcode,
    "Quantity": quantity,
    "Rate": rate,
    "FreeQuantity": freeQuantity,
    "ItemTotal": itemTotal,
    "DiscPer": discPer,
    "DiscAmt": discAmt,
    "TotalDiscount": totalDiscount,
    "TaxableAmt": taxableAmt,
    "TaxPer": taxPer,
    "TaxPer1": taxPer1,
    "TaxAmt1": taxAmt1,
    "TaxPer2": taxPer2,
    "TaxAmt2": taxAmt2,
    "TaxPer3": taxPer3,
    "TaxAmt3": taxAmt3,
    "TaxPer4": taxPer4,
    "TaxAmt4": taxAmt4,
    "TaxPer5": taxPer5,
    "TaxAmt5": taxAmt5,
    "TaxGroupId": taxGroupId,
    "PurchaseRate": purchaseRate,
    "PurchaseRateWithTax": purchaseRateWithTax,
    // "CashSalesRate": cashSalesRate,
    // "CreditSalesRate": creditSalesRate,
    // "OutletSalesRate": outletSalesRate,
    "MRP": mrp,
    "StkPurchaseId": stkPurchaseId,
    "TotalTaxAmt": totalTaxAmt,
    "NetAmt": netAmt,
    // "PFL_PurchaseRate": pflPurchaseRate,
    "UsedAs": usedAs,
    "IsWithoutGST": isWithoutGST,
    "ReturnQty": returnQty,
    "Action": action,
  };

  factory SalesDetail.fromJson(Map<String, dynamic> json) {
    return SalesDetail(
      itemId: json['ItemId'] ?? 0,
      unitId: json['UnitId'] ?? 0,
      itemName: json['ItemName'] ?? '',
      barcode: json['Barcode'] ?? '',
      quantity: (json['Quantity'] ?? 0).toDouble(),
      rate: (json['Rate'] ?? 0).toDouble(),
      freeQuantity: (json['FreeQuantity'] ?? 0).toDouble(),
      itemTotal: (json['ItemTotal'] ?? 0).toDouble(),
      discPer: json['DiscPer']?.toString() ?? '0',
      discAmt: (json['DiscAmt'] ?? 0).toDouble(),
      totalDiscount: (json['TotalDiscount'] ?? 0).toDouble(),
      taxableAmt: (json['TaxableAmt'] ?? 0).toDouble(),
      taxPer: (json['TaxPer'] ?? 0).toDouble(),
      taxPer1: (json['TaxPer1'] ?? 0).toDouble(),
      taxAmt1: (json['TaxAmt1'] is String)
          ? double.tryParse(json['TaxAmt1']) ?? 0
          : (json['TaxAmt1'] ?? 0).toDouble(),
      taxPer2: (json['TaxPer2'] ?? 0).toDouble(),
      taxAmt2: (json['TaxAmt2'] is String)
          ? double.tryParse(json['TaxAmt2']) ?? 0
          : (json['TaxAmt2'] ?? 0).toDouble(),
      taxPer3: json['TaxPer3']?.toString() ?? '0.00',
      taxAmt3: json['TaxAmt3']?.toString() ?? '0.00',
      taxPer4: json['TaxPer4']?.toString() ?? '0.00',
      taxAmt4: json['TaxAmt4']?.toString() ?? '0.00',
      taxPer5: json['TaxPer5']?.toString() ?? '0.00',
      taxAmt5: json['TaxAmt5']?.toString() ?? '0.00',
      taxGroupId: json['TaxGroupId'] ?? 0,
      purchaseRate: (json['PurchaseRate'] ?? 0).toDouble(),
      purchaseRateWithTax: (json['PurchaseRateWithTax'] ?? 0).toDouble(),
      // cashSalesRate: (json['CashSalesRate'] ?? 0).toDouble(),
      // creditSalesRate: (json['CreditSalesRate'] ?? 0).toDouble(),
      // outletSalesRate: (json['OutletSalesRate'] ?? 0).toDouble(),
      mrp: (json['MRP'] ?? 0).toDouble(),
      stkPurchaseId: json['StkPurchaseId'] ?? 0,
      totalTaxAmt: (json['TotalTaxAmt'] ?? 0).toDouble(),
      netAmt: (json['NetAmt'] ?? 0).toDouble(),
      // pflPurchaseRate: (json['PFL_PurchaseRate'] ?? 0).toDouble(),
      usedAs: json['UsedAs'] ?? 'N/A',
      isWithoutGST: json['IsWithoutGST'] ?? false,
      returnQty: json['ReturnQty']?.toString() ?? '0',
      action: json['Action'] ?? '',
    );
  }

}
// class SalesDetail {
//   int itemId;
//   int unitId;
//   String itemName;
//   double quantity;
//   double rate;
//   double itemTotal;
//   double discPer;
//   double discAmt;
//   double totalDiscount;
//   double taxableAmt;
//   double taxPer;
//   double taxPer1;
//   double taxAmt1;
//   double taxPer2;
//   double taxAmt2;
//   double totalTaxAmt;
//   double netAmt;
//
//   SalesDetail({
//     required this.itemId,
//     required this.unitId,
//     required this.itemName,
//     required this.quantity,
//     required this.rate,
//     required this.itemTotal,
//     required this.discPer,
//     required this.discAmt,
//     required this.totalDiscount,
//     required this.taxableAmt,
//     required this.taxPer,
//     required this.taxPer1,
//     required this.taxAmt1,
//     required this.taxPer2,
//     required this.taxAmt2,
//     required this.totalTaxAmt,
//     required this.netAmt,
//   });
//
//   factory SalesDetail.fromJson(Map<String, dynamic> json) {
//     return SalesDetail(
//       itemId: json['ItemId'],
//       unitId: json['UnitId'],
//       itemName: json['ItemName'] ?? '',
//       quantity: (json['Quantity'] ?? 0).toDouble(),
//       rate: (json['Rate'] ?? 0).toDouble(),
//       itemTotal: (json['ItemTotal'] ?? 0).toDouble(),
//       discPer: (json['DiscPer'] ?? 0).toDouble(),
//       discAmt: (json['DiscAmt'] ?? 0).toDouble(),
//       totalDiscount: (json['TotalDiscount'] ?? 0).toDouble(),
//       taxableAmt: (json['TaxableAmt'] ?? 0).toDouble(),
//       taxPer: (json['TaxPer'] ?? 0).toDouble(),
//       taxPer1: (json['TaxPer1'] ?? 0).toDouble(),
//       taxAmt1: double.tryParse(json['TaxAmt1'].toString()) ?? 0,
//       taxPer2: (json['TaxPer2'] ?? 0).toDouble(),
//       taxAmt2: double.tryParse(json['TaxAmt2'].toString()) ?? 0,
//       totalTaxAmt: (json['TotalTaxAmt'] ?? 0).toDouble(),
//       netAmt: (json['NetAmt'] ?? 0).toDouble(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "ItemId": itemId,
//     "UnitId": unitId,
//     "ItemName": itemName,
//     "Quantity": quantity,
//     "Rate": rate,
//     "ItemTotal": itemTotal,
//     "DiscPer": discPer,
//     "DiscAmt": discAmt,
//     "TotalDiscount": totalDiscount,
//     "TaxableAmt": taxableAmt,
//     "TaxPer": taxPer,
//     "TaxPer1": taxPer1,
//     "TaxAmt1": taxAmt1,
//     "TaxPer2": taxPer2,
//     "TaxAmt2": taxAmt2,
//     "TotalTaxAmt": totalTaxAmt,
//     "NetAmt": netAmt,
//   };
// }



class SalesOtherCharge {
  int ledgerId;
  double amount;
  String ledgerName;

  SalesOtherCharge({
    required this.ledgerId,
    required this.amount,
    required this.ledgerName,
  });

  factory SalesOtherCharge.fromJson(Map<String, dynamic> json) {
    return SalesOtherCharge(
      ledgerId: json['LedgerId'],
      amount: (json['Amount'] as num).toDouble(),
      ledgerName: json['LedgerName'],
    );
  }

  Map<String, dynamic> toJson() => {
    "LedgerId": ledgerId,
    "Amount": amount,
    "LedgerName": ledgerName,
  };
}
