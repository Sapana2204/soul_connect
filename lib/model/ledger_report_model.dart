class LedgerReportModel {
  String? vchDate;
  String? vchNo;
  String? narration;
  String? voucherType;
  double? debit;     // ✅ changed
  double? credit;    // ✅ changed
  int? vchID;
  int? vchTypeId;
  int? ledgerId;
  String? drCrType;
  String? refBillId;
  String? currentClosing;
  String? misc5;

  LedgerReportModel(
      {this.vchDate,
        this.vchNo,
        this.narration,
        this.voucherType,
        this.debit,
        this.credit,
        this.vchID,
        this.vchTypeId,
        this.ledgerId,
        this.drCrType,
        this.refBillId,
        this.currentClosing,
        this.misc5});

  LedgerReportModel.fromJson(Map<String, dynamic> json) {
    vchDate = json['VchDate'];
    vchNo = json['VchNo'];
    narration = json['Narration'];
    voucherType = json['VoucherType'];
    debit = (json['Debit'] as num?)?.toDouble();   // ✅ SAFE
    credit = (json['Credit'] as num?)?.toDouble(); // ✅ SAFE
    vchID = json['VchID'];
    vchTypeId = json['VchTypeId'];
    ledgerId = json['LedgerId'];
    drCrType = json['DrCrType'];
    refBillId = json['RefBillId'];
    currentClosing = json['CurrentClosing'];
    misc5 = json['Misc5'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['VchDate'] = this.vchDate;
    data['VchNo'] = this.vchNo;
    data['Narration'] = this.narration;
    data['VoucherType'] = this.voucherType;
    data['Debit'] = this.debit;
    data['Credit'] = this.credit;
    data['VchID'] = this.vchID;
    data['VchTypeId'] = this.vchTypeId;
    data['LedgerId'] = this.ledgerId;
    data['DrCrType'] = this.drCrType;
    data['RefBillId'] = this.refBillId;
    data['CurrentClosing'] = this.currentClosing;
    data['Misc5'] = this.misc5;
    return data;
  }
}
