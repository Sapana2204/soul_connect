class AddSaleReturnModel {
  int returnId;
  String returnDate;
  int customerId;
  String customerName;
  String address;
  String mobile;
  String payMode;

  double totalQty;
  double freeQty;
  double subTotal;
  double discAmt;
  double taxableAmt;
  double totalTaxAmt;
  double invoiceChargesAmt;
  double roundOff;
  double netAmt;

  String narration;
  String byHand;
  int locationId;
  int salesId;

  int createdBy;
  String createdOn;
  int userId;

  bool isCreditNoteCreated;
  int creditNoteVchId;
  bool isVoucher;
  bool isCreditNote;

  List<SalesReturnDetail> details;
  List<SalesReturnOtherCharge> otherCharges;

  AddSaleReturnModel({
    required this.returnId,
    required this.returnDate,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.mobile,
    required this.payMode,
    required this.totalQty,
    required this.freeQty,
    required this.subTotal,
    required this.discAmt,
    required this.taxableAmt,
    required this.totalTaxAmt,
    required this.invoiceChargesAmt,
    required this.roundOff,
    required this.netAmt,
    required this.narration,
    required this.byHand,
    required this.locationId,
    required this.salesId,
    required this.createdBy,
    required this.createdOn,
    required this.userId,
    required this.isCreditNoteCreated,
    required this.creditNoteVchId,
    required this.isVoucher,
    required this.isCreditNote,
    required this.details,
    required this.otherCharges,
  });

  Map<String, dynamic> toJson() {
    return {
      "ReturnId": returnId,
      "ReturnDate": returnDate,
      "CustomerId": customerId,
      "CustomerName": customerName,
      "Address": address,
      "Mobile": mobile,
      "PayMode": payMode,
      "TotalQty": totalQty,
      "FreeQty": freeQty,
      "SubTotal": subTotal,
      "DiscAmt": discAmt,
      "TaxableAmt": taxableAmt,
      "TotalTaxAmt": totalTaxAmt,
      "InvoiceChargesAmt": invoiceChargesAmt,
      "RoundOff": roundOff,
      "NetAmt": netAmt,
      "Narration": narration,
      "ByHand": byHand,
      "LocationId": locationId,
      "SalesId": salesId,
      "CreatedBy": createdBy,
      "CreatedOn": createdOn,
      "UserID": userId,
      "IsCreditNoteCreated": isCreditNoteCreated,
      "CreditNoteVchId": creditNoteVchId,
      "IsVoucher": isVoucher,
      "IsCreditNote": isCreditNote,
      "Details": details.map((e) => e.toJson()).toList(),
      "OtherCharges": otherCharges.map((e) => e.toJson()).toList(),
    };
  }
}

class SalesReturnDetail {
  int itemId;
  int unitId;
  double quantity;
  double freeQuantity;
  double rate;
  double itemTotal;
  double discPer;
  double discAmt;
  double taxableAmt;
  double totalTaxAmt;
  double netAmt;

  double taxPer1;
  double taxAmt1;
  double taxPer2;
  double taxAmt2;
  double taxPer3;
  double taxAmt3;

  bool isWithoutGST;
  double actRetQty;
  int locationId;

  double purchaseRate;
  double pflPurchaseRate;

  SalesReturnDetail({
    required this.itemId,
    required this.unitId,
    required this.quantity,
    required this.freeQuantity,
    required this.rate,
    required this.itemTotal,
    required this.discPer,
    required this.discAmt,
    required this.taxableAmt,
    required this.totalTaxAmt,
    required this.netAmt,
    required this.taxPer1,
    required this.taxAmt1,
    required this.taxPer2,
    required this.taxAmt2,
    required this.taxPer3,
    required this.taxAmt3,
    required this.isWithoutGST,
    required this.actRetQty,
    required this.locationId,
    required this.purchaseRate,
    required this.pflPurchaseRate,
  });

  Map<String, dynamic> toJson() {
    return {
      "ItemId": itemId,
      "UnitId": unitId,
      "Quantity": quantity,
      "FreeQuantity": freeQuantity,
      "Rate": rate,
      "ItemTotal": itemTotal,
      "DiscPer": discPer,
      "DiscAmt": discAmt,
      "TaxableAmt": taxableAmt,
      "TotalTaxAmt": totalTaxAmt,
      "NetAmt": netAmt,
      "TaxPer1": taxPer1,
      "TaxAmt1": taxAmt1,
      "TaxPer2": taxPer2,
      "TaxAmt2": taxAmt2,
      "IsWithoutGST": isWithoutGST,
      "ActRetQty": actRetQty,
      "LocationId": locationId,
      "PurchaseRate": purchaseRate,
      "PFL_PurchaseRate": pflPurchaseRate,
    };
  }
}

class SalesReturnOtherCharge {
  int ledgerId;
  double amount;
  String ledgerName;

  SalesReturnOtherCharge({
    required this.ledgerId,
    required this.amount,
    required this.ledgerName,
  });

  factory SalesReturnOtherCharge.fromJson(Map<String, dynamic> json) {
    return SalesReturnOtherCharge(
      ledgerId: json['LedgerId'],
      amount: (json['Amount'] as num).toDouble(),
      ledgerName: json['LedgerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "LedgerId": ledgerId,
      "Amount": amount,
      "LedgerName": ledgerName,
    };
  }
}
