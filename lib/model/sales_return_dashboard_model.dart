import 'add_sale_model.dart';

class SalesReturnDashboardModel {
  int? returnId;
  String? returnDate;
  double? totalQty;
  double? freeQty;
  int? customerId;
  String? payMode;
  double? subTotal;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? invoiceChargesAmt;
  double? roundOff;
  double? netAmt;
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
  String? address;
  String? mobile;
  String? gSTIN;
  bool? isCreditNoteCreated;
  int? vchId;
  String? customerName;
  List<Details>? details;
  List<SalesOtherCharge>? otherCharges;

  SalesReturnDashboardModel.fromJson(Map<String, dynamic> json) {
    returnId = json['ReturnId'];
    returnDate = json['ReturnDate'];
    totalQty = (json['TotalQty'] as num?)?.toDouble();
    freeQty = (json['FreeQty'] as num?)?.toDouble();
    customerId = json['CustomerId'];
    payMode = json['PayMode'];
    subTotal = (json['SubTotal'] as num?)?.toDouble();
    discAmt = (json['DiscAmt'] as num?)?.toDouble();
    taxableAmt = (json['TaxableAmt'] as num?)?.toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] as num?)?.toDouble();
    invoiceChargesAmt = (json['InvoiceChargesAmt'] as num?)?.toDouble();
    roundOff = (json['RoundOff'] as num?)?.toDouble();
    netAmt = (json['NetAmt'] as num?)?.toDouble();
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
    address = json['Address'];
    mobile = json['Mobile'];
    gSTIN = json['GSTIN'];
    isCreditNoteCreated = json['IsCreditNoteCreated'];
    vchId = json['VchId'];
    customerName = json['CustomerName'];

    details = (json['Details'] as List?)
        ?.map((e) => Details.fromJson(e))
        .toList();

    otherCharges = (json['OtherCharges'] as List?)
        ?.map((e) => SalesOtherCharge.fromJson(e))
        .toList() ?? [];
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
  String? mfgDate;
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
  int? actRetQty;
  int? firmId;
  int? locationId;

  String? itemName;
  String? hSNCode;
  String? unitName;
  int? taxGroupId;
  int? totalTaxPer;
  String? barcode;

  double? purchaseRate;
  double? pFLPurchaseRate;

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
    mfgDate = json['MfgDate'];
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
    actRetQty = json['ActRetQty'];
    firmId = json['FirmId'];
    locationId = json['LocationId'];

    itemName = json['ItemName'];
    hSNCode = json['HSNCode'];
    unitName = json['UnitName'];
    taxGroupId = json['TaxGroupId'];
    totalTaxPer = json['TotalTaxPer'];
    barcode = json['Barcode'];

    purchaseRate = (json['PurchaseRate'] as num?)?.toDouble();
    pFLPurchaseRate = (json['PFL_PurchaseRate'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      "ReturnDetailsId": returnDetailsId,
      "ReturnId": returnId,
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
      "BatchNo": batchNo,
      "MfgDate": mfgDate,
      "ExpDate": expDate,
      "MarginPer": marginPer,
      "SalesRate": salesRate,
      "MRP": mRP,
      "Pax": pax,
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
      "SalesRate1": salesRate1,
      "SalesRate2": salesRate2,
      "StkPurchaseId": stkPurchaseId,
      "IsWithoutGST": isWithoutGST,
      "ActRetQty": actRetQty,
      "FirmId": firmId,
      "LocationId": locationId,
      "ItemName": itemName,
      "HSNCode": hSNCode,
      "UnitName": unitName,
      "TaxGroupId": taxGroupId,
      "TotalTaxPer": totalTaxPer,
      "Barcode": barcode,
      "PurchaseRate": purchaseRate,
      "PFL_PurchaseRate": pFLPurchaseRate,
    };
  }

}
