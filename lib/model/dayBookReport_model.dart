class DayBookReportModel {
  int? vchId;
  String? vchDate;
  String? vchTime;
  String? transaction;
  String? payMode; // ✅ FIX (was Null?)
  String? vchNo;
  String? party;
  double? amount;  // ✅ FIX
  double? debit;   // ✅ FIX
  double? credit;  // ✅ FIX

  DayBookReportModel(
      {this.vchId,
        this.vchDate,
        this.vchTime,
        this.transaction,
        this.payMode,
        this.vchNo,
        this.party,
        this.amount,
        this.debit,
        this.credit});

  DayBookReportModel.fromJson(Map<String, dynamic> json) {
    vchId = json['VchId'];
    vchDate = json['VchDate'];
    vchTime = json['VchTime'];
    transaction = json['Transaction'];
    payMode = json['PayMode'];
    vchNo = json['VchNo'];
    party = json['Party'];
    amount = (json['Amount'] ?? 0).toDouble();  // ✅ SAFE
    debit  = (json['Debit'] ?? 0).toDouble();   // ✅ SAFE
    credit = (json['Credit'] ?? 0).toDouble();  // ✅ SAFE
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['VchId'] = this.vchId;
    data['VchDate'] = this.vchDate;
    data['VchTime'] = this.vchTime;
    data['Transaction'] = this.transaction;
    data['PayMode'] = this.payMode;
    data['VchNo'] = this.vchNo;
    data['Party'] = this.party;
    data['Amount'] = this.amount;
    data['Debit'] = this.debit;
    data['Credit'] = this.credit;
    return data;
  }
}
