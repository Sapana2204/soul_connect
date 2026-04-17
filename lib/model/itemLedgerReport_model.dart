class ItemLedgerReportModel {
  int? id;
  String? transDate;
  String? narration;
  String? partyName;
  String? partyAddress;
  String? billNo;
  double? inward;
  double? issue;
  double? balance;

  ItemLedgerReportModel({
    this.id,
    this.transDate,
    this.narration,
    this.partyName,
    this.partyAddress,
    this.billNo,
    this.inward,
    this.issue,
    this.balance,
  });

  ItemLedgerReportModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    transDate = json['TransDate'];
    narration = json['Narration'];
    partyName = json['PartyName'];
    partyAddress = json['PartyAddress'];
    billNo = json['BillNo'];

    inward = (json['Inward'] as num?)?.toDouble();
    issue = (json['Issue'] as num?)?.toDouble();
    balance = (json['Balance'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      "Id": id,
      "Date": transDate, // ✅ for ReportCard
      "Narration": narration,
      "PartyName": partyName,
      "Address": partyAddress, // ✅ for ReportCard
      "BillNo": billNo,
      "Inward": inward,
      "Issue": issue,
      "Balance": balance,
    };
  }
}
