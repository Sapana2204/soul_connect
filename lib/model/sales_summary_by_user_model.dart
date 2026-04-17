class SalesSummaryModel {
  String? salesBillNo;
  String? salesDate;
  String? customerName;
  int? customerId;
  String? rateType;
  String? salesType;
  String? paymentTerm;
  double? subTotal;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? otherCharges;
  double? billTotal;
  double? roundOff;
  double? netAmt;

  SalesSummaryModel({
    this.salesBillNo,
    this.salesDate,
    this.customerName,
    this.customerId,
    this.rateType,
    this.salesType,
    this.paymentTerm,
    this.subTotal,
    this.discAmt,
    this.taxableAmt,
    this.totalTaxAmt,
    this.otherCharges,
    this.billTotal,
    this.roundOff,
    this.netAmt,
  });

  SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    salesBillNo = json['SalesBillNo'];
    salesDate = json['SalesDate'];
    customerName = json['CustomerName'];
    customerId = json['CustomerId'];
    rateType = json['RateType'];
    salesType = json['SalesType'];
    paymentTerm = json['PaymentTerm'];
    subTotal = (json['SubTotal'] ?? 0).toDouble();
    discAmt = (json['DiscAmt'] ?? 0).toDouble();
    taxableAmt = (json['TaxableAmt'] ?? 0).toDouble();
    totalTaxAmt = (json['TotalTaxAmt'] ?? 0).toDouble();
    otherCharges = (json['OtherCharges'] ?? 0).toDouble();
    billTotal = (json['BillTotal'] ?? 0).toDouble();
    roundOff = (json['RoundOff'] ?? 0).toDouble();
    netAmt = (json['NetAmt'] ?? 0).toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['SalesBillNo'] = salesBillNo;
    data['SalesDate'] = salesDate;
    data['CustomerName'] = customerName;
    data['CustomerId'] = customerId;
    data['RateType'] = rateType;
    data['SalesType'] = salesType;
    data['PaymentTerm'] = paymentTerm;
    data['SubTotal'] = subTotal;
    data['DiscAmt'] = discAmt;
    data['TaxableAmt'] = taxableAmt;
    data['TotalTaxAmt'] = totalTaxAmt;
    data['OtherCharges'] = otherCharges;
    data['BillTotal'] = billTotal;
    data['RoundOff'] = roundOff;
    data['NetAmt'] = netAmt;
    return data;
  }
}