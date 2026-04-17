class InvoiceItem {
  final String productName;
  final int qty;
  final int freeQty;
  final double rate;
  final double subtotal;
  final double discountPerc;
  final double discountAmt;
  final double totalDisc;
  final double taxable;
  final double taxPerc;
  late final double taxAmt;
  final double totalAmt;
  final double purchaseRate;
  final double purchaseRateWithTax;
  final double mrp;
  final int stkPurchaseId;
  final int stock;
  final bool isNonGST;
  final int returnQty;

  // 🔹 Additional fields required for API
  final int itemId;
  final String itemName;
  final int unitId;
  final int firmId;
  final int locationId;
  final String mfgDate;

  // 🔹 Multiple tax components (for CGST / SGST / IGST)
  double taxPer1;
  double taxAmt1;
  double taxPer2;
  double taxAmt2;
  double taxPer3;
  double taxAmt3;
  double taxPer4;
  double taxAmt4;
  double taxPer5;
  double taxAmt5;

  final double netAmt;
  final int taxGroupId;

  InvoiceItem({
    required this.productName,
    required this.qty,
    required this.freeQty,
    required this.rate,
    required this.subtotal,
    required this.discountPerc,
    required this.discountAmt,
    required this.totalDisc,
    required this.taxable,
    required this.taxPerc,
    required this.taxAmt,
    required this.totalAmt,
    required this.purchaseRate,
    required this.purchaseRateWithTax,
    required this.mrp,
    required this.stkPurchaseId,
    required this.stock,
    required this.isNonGST,
    required this.returnQty,
    required this.itemId,
    required this.itemName,
    required this.unitId,
    required this.firmId,
    required this.locationId,
    required this.mfgDate,
    this.taxPer1 = 0.0,
    this.taxAmt1 = 0.0,
    this.taxPer2 = 0.0,
    this.taxAmt2 = 0.0,
    this.taxPer3 = 0.0,
    this.taxAmt3 = 0.0,
    this.taxPer4 = 0.0,
    this.taxAmt4 = 0.0,
    this.taxPer5 = 0.0,
    this.taxAmt5 = 0.0,
    required this.netAmt,
    required this.taxGroupId,
  });

  /// ✅ Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      "SalesId": 0,
      "ItemId": itemId,
      "ItemName": itemName,
      "UnitId": unitId,
      "Quantity": qty,
      "FreeQty": freeQty,
      "Rate": rate,
      "MfgDate": mfgDate,
      "ItemTotal": subtotal,
      "DiscPer": discountPerc,
      "DiscAmt": discountAmt,
      "TaxableAmt": taxable,
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
      "TotalTaxAmt": taxAmt1 + taxAmt2 + taxAmt3 + taxAmt4 + taxAmt5,
      "NetAmt": totalAmt,
      "TaxGroupId": taxGroupId,
      "FirmId": firmId,
      "LocationId": locationId,
      "Pax": 0,
      "Barcode": "",
    };
  }

  /// ✅ Safe JSON Parsing
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      productName: json['ItemName'] ?? '',
      qty: parseInt(json['Quantity']),
      freeQty: parseInt(json['FreeQty']),
      rate: parseDouble(json['Rate']),
      subtotal: parseDouble(json['ItemTotal']),
      discountPerc: parseDouble(json['DiscPer']),
      discountAmt: parseDouble(json['DiscAmt']),
      totalDisc: parseDouble(json['TotalDisc']),
      taxable: parseDouble(json['TaxableAmt']),
      taxPerc: parseDouble(json['TaxPerc'] ?? json['TaxPer']),
      taxAmt: parseDouble(json['TaxAmt'] ?? json['TotalTaxAmt']),
      totalAmt: parseDouble(json['NetAmt']),
      purchaseRate: parseDouble(json['PurchaseRate']),
      purchaseRateWithTax: parseDouble(json['PurchaseRateWithTax']),
      mrp: parseDouble(json['Mrp']),
      stkPurchaseId: parseInt(json['StkPurchaseId']),
      stock: parseInt(json['Stock']),
      isNonGST: json['IsNonGST'] == true || json['IsNonGST'] == 1,
      returnQty: parseInt(json['ReturnQty']),
      itemId: parseInt(json['ItemId']),
      itemName: json['ItemName'] ?? '',
      unitId: parseInt(json['UnitId']),
      firmId: parseInt(json['FirmId']),
      locationId: parseInt(json['LocationId']),
      mfgDate: json['MfgDate'] ?? '',
      taxPer1: parseDouble(json['TaxPer1']),
      taxAmt1: parseDouble(json['TaxAmt1']),
      taxPer2: parseDouble(json['TaxPer2']),
      taxAmt2: parseDouble(json['TaxAmt2']),
      taxPer3: parseDouble(json['TaxPer3']),
      taxAmt3: parseDouble(json['TaxAmt3']),
      taxPer4: parseDouble(json['TaxPer4']),
      taxAmt4: parseDouble(json['TaxAmt4']),
      taxPer5: parseDouble(json['TaxPer5']),
      taxAmt5: parseDouble(json['TaxAmt5']),
      netAmt: parseDouble(json['NetAmt']),
      taxGroupId: parseInt(json['TaxGroupId']),
    );
  }
}

/// ✅ Safe converters for all numeric fields
int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString().split('.')[0]) ?? 0;
}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

