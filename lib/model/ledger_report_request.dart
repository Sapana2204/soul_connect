class LedgerReportRequest {
  final String fromDate;
  final String toDate;
  final int ledgerId;


  LedgerReportRequest({
    required this.fromDate,
    required this.toDate,
    required this.ledgerId,

  });

  /// Convert to query parameters (for GET API)
  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'fromDate': fromDate,
      'toDate': toDate,
      'ledgerId': ledgerId.toString(),
    };



    return params;
  }
}
