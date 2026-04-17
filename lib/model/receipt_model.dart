class ReceiptModel {
  int? vchId;
  String? vchNo;
  DateTime? vchDate;
  double? vchAmt;
  String? vchNarration;
  String? payMode;
  String? ledgerName;

  ReceiptModel({
    this.vchId,
    this.vchNo,
    this.vchDate,
    this.vchAmt,
    this.vchNarration,
    this.payMode,
    this.ledgerName,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      vchId: json['VchId'],
      vchNo: json['VchNo'],
      vchDate: DateTime.tryParse(json['VchDate'] ?? ""),
      vchAmt: (json['VchAmt'] ?? 0).toDouble(),
      vchNarration: json['VchNarration'],
      payMode: json['PayMode'],
      ledgerName: json['LedgerName'],
    );
  }
}