class AddVouchersModel {
  int? locationId;
  int? debitLedgerId;
  int? creditLedgerId;
  int? voucherId;
  int? vchTypeId;
  int? vchSeriesId;
  String? vchNo;
  int? firmId;
  String? vchDate;
  double? vchAmt;
  String? vchNarration;
  String? debitLedgerName;
  String? creditLedgerName;
  String? refBillId;
  String? voucherAt;
  String? receiptNo;
  String? chequeNo;
  String? payMode;
  String? payType;
  String? chequeDate;
  String? bankName;
  String? chequeNarration;
  int? userId;
  String? misc1;
  String? misc2;
  String? misc3;
  String? misc4;
  String? misc5;
  int? createdBy;
  int? updatedBy;

  AddVouchersModel(
      {this.locationId,
        this.debitLedgerId,
        this.creditLedgerId,
        this.voucherId,
        this.vchTypeId,
        this.vchSeriesId,
        this.vchNo,
        this.firmId,
        this.vchDate,
        this.vchAmt,
        this.vchNarration,
        this.debitLedgerName,
        this.creditLedgerName,
        this.refBillId,
        this.voucherAt,
        this.receiptNo,
        this.chequeNo,
        this.payMode,
        this.payType,
        this.chequeDate,
        this.bankName,
        this.chequeNarration,
        this.userId,
        this.misc1,
        this.misc2,
        this.misc3,
        this.misc4,
        this.misc5,
        this.createdBy,
        this.updatedBy});

  AddVouchersModel.fromJson(Map<String, dynamic> json) {
    locationId = json['LocationId'];
    debitLedgerId = json['DebitLedgerId'];
    creditLedgerId = json['CreditLedgerId'];
    voucherId = json['VoucherId'];
    vchTypeId = json['VchTypeId'];
    vchSeriesId = json['VchSeriesId'];
    vchNo = json['VchNo'];
    firmId = json['FirmId'];
    vchDate = json['VchDate'];
    vchAmt = json['VchAmt'];
    vchNarration = json['VchNarration'];
    debitLedgerName = json['DebitLedgerName'];
    creditLedgerName = json['CreditLedgerName'];
    refBillId = json['RefBillId'];
    voucherAt = json['VoucherAt'];
    receiptNo = json['ReceiptNo'];
    chequeNo = json['ChequeNo'];
    payMode = json['PayMode'];
    payType = json['PayType'];
    chequeDate = json['ChequeDate'];
    bankName = json['BankName'];
    chequeNarration = json['ChequeNarration'];
    userId = json['UserId'];
    misc1 = json['Misc1'];
    misc2 = json['Misc2'];
    misc3 = json['Misc3'];
    misc4 = json['Misc4'];
    misc5 = json['Misc5'];
    createdBy = json['CreatedBy'];
    updatedBy = json['UpdatedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LocationId'] = this.locationId;
    data['DebitLedgerId'] = this.debitLedgerId;
    data['CreditLedgerId'] = this.creditLedgerId;
    data['VoucherId'] = this.voucherId;
    data['VchTypeId'] = this.vchTypeId;
    data['VchSeriesId'] = this.vchSeriesId;
    data['VchNo'] = this.vchNo;
    data['FirmId'] = this.firmId;
    data['VchDate'] = this.vchDate;
    data['VchAmt'] = this.vchAmt;
    data['VchNarration'] = this.vchNarration;
    data['DebitLedgerName'] = this.debitLedgerName;
    data['CreditLedgerName'] = this.creditLedgerName;
    data['RefBillId'] = this.refBillId;
    data['VoucherAt'] = this.voucherAt;
    data['ReceiptNo'] = this.receiptNo;
    data['ChequeNo'] = this.chequeNo;
    data['PayMode'] = this.payMode;
    data['PayType'] = this.payType;
    data['ChequeDate'] = this.chequeDate;
    data['BankName'] = this.bankName;
    data['ChequeNarration'] = this.chequeNarration;
    data['UserId'] = this.userId;
    data['Misc1'] = this.misc1;
    data['Misc2'] = this.misc2;
    data['Misc3'] = this.misc3;
    data['Misc4'] = this.misc4;
    data['Misc5'] = this.misc5;
    data['CreatedBy'] = this.createdBy;
    data['UpdatedBy'] = this.updatedBy;
    return data;
  }
}