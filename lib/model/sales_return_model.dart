class SalesReturnModel {
  int? returnId;
  String? returnDate;
  int? customerId;
  String? customerName;
  String? mobile;
  double? totalQty;
  double? freeQty;
  double? subTotal;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? netAmt;
  String? payMode;
  List<SalesReturnDetail>? details;

  SalesReturnModel({
    this.returnId,
    this.returnDate,
    this.customerId,
    this.customerName,
    this.mobile,
    this.totalQty,
    this.freeQty,
    this.subTotal,
    this.discAmt,
    this.taxableAmt,
    this.totalTaxAmt,
    this.netAmt,
    this.payMode,
    this.details,
  });

  factory SalesReturnModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnModel(
      returnId: json['ReturnId'],
      returnDate: json['ReturnDate'],
      customerId: json['CustomerId'],
      customerName: json['CustomerName'],
      mobile: json['Mobile'],
      totalQty: (json['TotalQty'] as num?)?.toDouble(),
      freeQty: (json['FreeQty'] as num?)?.toDouble(),
      subTotal: (json['SubTotal'] as num?)?.toDouble(),
      discAmt: (json['DiscAmt'] as num?)?.toDouble(),
      taxableAmt: (json['TaxableAmt'] as num?)?.toDouble(),
      totalTaxAmt: (json['TotalTaxAmt'] as num?)?.toDouble(),
      netAmt: (json['NetAmt'] as num?)?.toDouble(),
      payMode: json['PayMode'],
      details: json['Details'] != null
          ? (json['Details'] as List)
          .map((v) => SalesReturnDetail.fromJson(v))
          .toList()
          : [],
    );
  }
}

class SalesReturnDetail {
  int? itemId;
  String? itemName;
  String? batchNo;
  String? expDate;
  double? quantity;
  double? freeQuantity;
  double? rate;
  double? itemTotal;
  double? discPer;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? netAmt;
  double? totalTaxPer;
  String? hsnCode;

  SalesReturnDetail.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    itemName = json['ItemName'];
    batchNo = json['BatchNo'];
    expDate = json['ExpDate'];
    quantity = (json['Quantity'] as num?)?.toDouble();
    freeQuantity = (json['FreeQuantity'] as num?)?.toDouble();
    rate = (json['Rate'] as num?)?.toDouble();
    itemTotal = (json['ItemTotal'] as num?)?.toDouble();
    discPer = (json['DiscPer'] as num?)?.toDouble();
    discAmt = (json['DiscAmt'] as num?)?.toDouble();
    taxableAmt = (json['TaxableAmt'] as num?)?.toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] as num?)?.toDouble();
    netAmt = (json['NetAmt'] as num?)?.toDouble();
    totalTaxPer = (json['TotalTaxPer'] as num?)?.toDouble();
    hsnCode = json['HSNCode'];
  }
}