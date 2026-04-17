class PurchaseInvoiceItem {
  final double qty;
  final double free;
  final double rate;
  final double rateWithGST;
  final double discountPerc;
  final double taxPerc;
  final double? taxRate;
  final double itemTotal;
  final double discountAmt;
  final double taxableAmt;
  final double netAmt;
  final int unitId;
  final int? itemId;
  final String? productName;
  final String? batch;
  final String? expiry;
  final String? barcode;
  final int cash;
  final int credit;
  final int mrp;
  final int outlet;
  final String? hsn;
  final String? mfgDate; // Corrected
  final double schemePerc;
  final double taxAmt;
  final double schemeAmt;
  final int? taxGroupId;
  final bool taxable;
  final double totalTaxAmt;
  final int? purDtlsId;
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
  final double originalDiscountAmt;
  final double originalItemTotal;

  PurchaseInvoiceItem({
    required this.unitId,
    this.itemId,
    this.productName,
    this.batch,
    this.expiry,
    this.barcode,
    required this.qty,
    required this.free,
    required this.rate,
    required this.rateWithGST,
    required this.discountPerc,
    required this.taxPerc,
    this.taxRate,
    required this.itemTotal,
    required this.discountAmt,
    required this.taxableAmt,
    required this.netAmt,
    required this.cash,
    required this.credit,
    required this.mrp,
    required this.outlet,
    this.hsn,
    this.mfgDate,
    required this.schemePerc,
    required this.taxAmt,
    required this.schemeAmt,
    this.taxGroupId,
    required this.taxable,
    required this.totalTaxAmt,
    this.purDtlsId,
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
    required this.originalDiscountAmt,
    required this.originalItemTotal,
  });

  /// Safe double parser
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safe int parser
  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// ✅ fromJson
  factory PurchaseInvoiceItem.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceItem(
      unitId: parseInt(json['UnitId']),
      itemId: parseInt(json['ItemId']),
      productName: json['ItemName'] ?? json['ProductName'],
      batch: json['Batch'] ?? json['BatchNo'] ?? "",
      expiry: json['ExpDate'] ?? json['Expiry'],
      barcode: json['Barcode'] ?? '',
      qty: parseDouble(json['Quantity'] ?? json['Qty']),
      free: parseDouble(json['FreeQuantity'] ?? json['Free']),
      rate: parseDouble(json['Rate']),
      rateWithGST: parseDouble(json['RateWithGST']),
      discountPerc: parseDouble(json['DiscPer'] ?? json['DiscountPerc']),
      taxPerc: parseDouble(json['TaxPer'] ?? json['TotalTaxPer']),
      taxRate: parseDouble(json['TaxRate']),
      itemTotal: parseDouble(json['ItemTotal']),
      discountAmt: parseDouble(json['DiscAmt'] ?? json['DiscountAmt']),
      taxableAmt: parseDouble(json['TaxableAmt']),
      netAmt: parseDouble(json['NetAmt']),
      cash: parseInt(json['CashRateMargin']),
      credit: parseInt(json['CreditRateMargin']),
      mrp: parseInt(json['MRP'] ?? json['Mrp']),
      outlet: parseInt(json['OutletRateMargin']),
      hsn: json['HSNCode'] ?? json['Hsn'],
      mfgDate: json['MfgDate'] is String ? json['MfgDate'] : null,
      schemePerc: parseDouble(json['SchemePer'] ?? json['SchemePerc']),
      taxAmt: parseDouble(json['TotalTaxAmt'] ?? json['TaxAmt']),
      schemeAmt: parseDouble(json['SchemeAmt']),
      taxGroupId: parseInt(json['TaxGroupId']),
      taxable: json['IsWithoutGST'] == true ? false : true,
      totalTaxAmt: parseDouble(json['TotalTaxAmt']),
      purDtlsId: parseInt(json['PurDtlsId']),
      taxPer1: parseInt(json['TaxPer1']),
      taxAmt1: parseInt(json['TaxAmt1']),
      taxPer2: parseInt(json['TaxPer2']),
      taxAmt2: parseInt(json['TaxAmt2']),
      taxPer3: parseInt(json['TaxPer3']),
      taxAmt3: parseInt(json['TaxAmt3']),
      taxPer4: parseInt(json['TaxPer4']),
      taxAmt4: parseInt(json['TaxAmt4']),
      taxPer5: parseInt(json['TaxPer5']),
      taxAmt5: parseInt(json['TaxAmt5']),
      originalDiscountAmt:
      parseDouble(json['DiscAmt'] ?? json['DiscountAmt']),
      originalItemTotal:
      parseDouble(json['ItemTotal']),

    );
  }

  /// ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'UnitId': unitId,
      'ItemId': itemId,
      'ProductName': productName,
      'Batch': batch,
      'Expiry': expiry,
      'Barcode': barcode,
      'Quantity': qty,
      'Free': free,
      'Rate': rate,
      'RateWithGST': rateWithGST,
      'DiscPer': discountPerc,
      'TaxPerc': taxPerc,
      'TaxRate': taxRate,
      'ItemTotal': itemTotal,
      'DiscAmt': discountAmt,
      'TaxableAmt': taxableAmt,
      'NetAmt': netAmt,
      'CashRateMargin': cash,
      'CreditRateMargin': credit,
      'MRP': mrp,
      'OutletRateMargin': outlet,
      'Hsn': hsn,
      'MfgDate': mfgDate,
      'SchemePerc': schemePerc,
      'TaxAmt': taxAmt,
      'SchemeAmt': schemeAmt,
      'TaxGroupId': taxGroupId,
      'IsWithoutGST': !taxable,
      'TotalTaxAmt': totalTaxAmt,
      'PurDtlsId': purDtlsId,
      'TaxPer1': taxPer1,
      'TaxAmt1': taxAmt1,
      'TaxPer2': taxPer2,
      'TaxAmt2': taxAmt2,
      'TaxPer3': taxPer3,
      'TaxAmt3': taxAmt3,
      'TaxPer4': taxPer4,
      'TaxAmt4': taxAmt4,
      'TaxPer5': taxPer5,
      'TaxAmt5': taxAmt5,
    };
  }
}
