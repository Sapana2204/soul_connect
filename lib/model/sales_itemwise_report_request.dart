class SalesItemwiseReportRequest {
  final String fromDate;
  final String toDate;
  final int userId;
  final int? customerId;
  final String? billType;
  final String? rateType;
  final String? paymentTerm;
  final String? salesType;
  final String? cropType;
  final int? locationId;
  final int? itemId;

  SalesItemwiseReportRequest({
    required this.fromDate,
    required this.toDate,
    required this.userId,
    this.customerId,
    this.billType,
    this.rateType,
    this.paymentTerm,
    this.salesType,
    this.cropType,
    this.locationId,
    this.itemId,
  });

  /// Convert to query parameters (for GET API)
  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'fromDate': fromDate,
      'toDate': toDate,
      'userId': userId.toString(),
    };

    if (customerId != null) params['customerId'] = customerId.toString();
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
