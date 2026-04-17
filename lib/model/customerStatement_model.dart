class CustomerStatementModel {
  int? salesId;
  String? salesType;
  int? customerId;
  String? salesBillNo;
  String? salesDate;
  String? customerName;

  double? totalQty;   // 🔥 changed to double
  double? netAmt;     // 🔥 changed to double

  String? payMode;    // 🔥 don't use Null?
  dynamic details;    // 🔥 use dynamic

  CustomerStatementModel({
    this.salesId,
    this.salesType,
    this.customerId,
    this.salesBillNo,
    this.salesDate,
    this.customerName,
    this.totalQty,
    this.netAmt,
    this.payMode,
    this.details,
  });

  CustomerStatementModel.fromJson(Map<String, dynamic> json) {
    salesId = json['SalesId'];
    salesType = json['SalesType'];
    customerId = json['CustomerId'];
    salesBillNo = json['SalesBillNo'];
    salesDate = json['SalesDate'];
    customerName = json['CustomerName'];

    // ✅ SAFE numeric parsing
    totalQty = (json['TotalQty'] as num?)?.toDouble();
    netAmt   = (json['NetAmt'] as num?)?.toDouble();

    payMode = json['PayMode'];
    details = json['Details'];
  }

  Map<String, dynamic> toJson() {
    return {
      'SalesId': salesId,
      'SalesType': salesType,
      'CustomerId': customerId,
      'SalesBillNo': salesBillNo,
      'SalesDate': salesDate,
      'CustomerName': customerName,
      'TotalQty': totalQty,
      'NetAmt': netAmt,
      'PayMode': payMode,
      'Details': details,
    };
  }
}