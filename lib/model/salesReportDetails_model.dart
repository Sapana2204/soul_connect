class SalesDetailsReportModel {
  String? salesBillNo;
  String? salesDate;
  String? customerName;
  int? rateTypeId;
  String? salesType;
  String? paymentTerm;
  String? itemName;
  String? batchNo;
  String? mfgDate;
  String? expDate;
  int? quantity;
  int? freeQuantity;
  int? rate;
  int? discAmt;
  int? schemeAmt;
  int? taxableAmt;
  int? totalTaxAmt;
  int? netAmt;
  int? itemId;
  String? rateType;

  SalesDetailsReportModel(
      {this.salesBillNo,
        this.salesDate,
        this.customerName,
        this.rateTypeId,
        this.salesType,
        this.paymentTerm,
        this.itemName,
        this.batchNo,
        this.mfgDate,
        this.expDate,
        this.quantity,
        this.freeQuantity,
        this.rate,
        this.discAmt,
        this.schemeAmt,
        this.taxableAmt,
        this.totalTaxAmt,
        this.netAmt,
        this.itemId,
        this.rateType});

  SalesDetailsReportModel.fromJson(Map<String, dynamic> json) {
    salesBillNo = json['SalesBillNo'];
    salesDate = json['SalesDate'];
    customerName = json['CustomerName'];
    rateTypeId = json['RateTypeId'];
    salesType = json['SalesType'];
    paymentTerm = json['PaymentTerm'];
    itemName = json['ItemName'];
    batchNo = json['BatchNo'];
    mfgDate = json['MfgDate'];
    expDate = json['ExpDate'];
    quantity = json['Quantity'];
    freeQuantity = json['FreeQuantity'];
    rate = json['Rate'];
    discAmt = json['DiscAmt'];
    schemeAmt = json['SchemeAmt'];
    taxableAmt = json['TaxableAmt'];
    totalTaxAmt = json['TotalTaxAmt'];
    netAmt = json['NetAmt'];
    itemId = json['ItemId'];
    rateType = json['RateType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesBillNo'] = this.salesBillNo;
    data['SalesDate'] = this.salesDate;
    data['CustomerName'] = this.customerName;
    data['RateTypeId'] = this.rateTypeId;
    data['SalesType'] = this.salesType;
    data['PaymentTerm'] = this.paymentTerm;
    data['ItemName'] = this.itemName;
    data['BatchNo'] = this.batchNo;
    data['MfgDate'] = this.mfgDate;
    data['ExpDate'] = this.expDate;
    data['Quantity'] = this.quantity;
    data['FreeQuantity'] = this.freeQuantity;
    data['Rate'] = this.rate;
    data['DiscAmt'] = this.discAmt;
    data['SchemeAmt'] = this.schemeAmt;
    data['TaxableAmt'] = this.taxableAmt;
    data['TotalTaxAmt'] = this.totalTaxAmt;
    data['NetAmt'] = this.netAmt;
    data['ItemId'] = this.itemId;
    data['RateType'] = this.rateType;
    return data;
  }
}
