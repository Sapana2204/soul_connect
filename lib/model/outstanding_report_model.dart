class OutstandingModel {
  String? ledgerName;
  double? closing;
  String? drCr;
  int? ledgerId;
  String? contact;
  String? address;

  OutstandingModel({
    this.ledgerName,
    this.closing,
    this.drCr,
    this.ledgerId,
    this.contact,
    this.address,
  });

  OutstandingModel.fromJson(Map<String, dynamic> json) {
    ledgerName = json['LedgerName'];
    closing = double.tryParse(json['Closing'].toString()) ?? 0.0;
    drCr = json['DRCR'];
    ledgerId = json['LedgerId'];
    contact = json['Contact'];
    address = json['Address'];
  }

  Map<String, dynamic> toJson() {
    return {
      "LedgerName": ledgerName,
      "Closing": closing,
      "DRCR": drCr,
      "Contact": contact,
      "Address": address,
    };
  }
}