class DayBookSummaryReportModel {
  String? payMode;
  double? debit;   // ✅ FIX
  double? credit;  // ✅ FIX

  DayBookSummaryReportModel({this.payMode, this.debit, this.credit});

  DayBookSummaryReportModel.fromJson(Map<String, dynamic> json) {
    payMode = json['PayMode'];

    debit  = (json['Debit'] ?? 0).toDouble();   // ✅ SAFE
    credit = (json['Credit'] ?? 0).toDouble();  // ✅ SAFE
  }

  Map<String, dynamic> toJson() {
    return {
      'PayMode': payMode,
      'Debit': debit,
      'Credit': credit,
    };
  }
}