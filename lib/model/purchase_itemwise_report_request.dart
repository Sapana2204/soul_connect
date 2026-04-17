class PurchaseItemwiseReportRequest {
  final String fromDate;
  final String toDate;
  final int? userId;
  final int? supplierId;
  final String? billType;
  final String? rateType;
  final String? paymentTerm;
  final String? salesType;
  final String? cropType;
  final int? locationId;
  final int? itemId;

  PurchaseItemwiseReportRequest({
    required this.fromDate,
    required this.toDate,
    this.userId,
    this.supplierId,
    this.billType,
    this.rateType,
    this.paymentTerm,
    this.salesType,
    this.cropType,
    this.locationId,
    this.itemId,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'fromDate': fromDate,
      'toDate': toDate,
    };

    if (userId != null) params['userId'] = userId.toString();
    if (supplierId != null) params['supplierId'] = supplierId.toString();
    if (billType != null) params['billType'] = billType!;
    if (rateType != null) params['rateType'] = rateType!;
    if (paymentTerm != null) params['paymentTerm'] = paymentTerm!;
    if (salesType != null) params['salesType'] = salesType!;
    if (cropType != null) params['cropType'] = cropType!;
    if (locationId != null) params['locationId'] = locationId.toString();
    if (itemId != null) params['itemId'] = itemId.toString();

    return params;
  }
}