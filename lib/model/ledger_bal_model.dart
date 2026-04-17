class LedgerBalModel {
  int? ledgerId;
  String? balanceAsOn;
  String? balanceType;
  double? balance;

  LedgerBalModel(
      {this.ledgerId, this.balanceAsOn, this.balanceType, this.balance});

  LedgerBalModel.fromJson(Map<String, dynamic> json) {
    ledgerId = json['LedgerId'];
    balanceAsOn = json['BalanceAsOn'];
    balanceType = json['BalanceType'];
    balance = json['Balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LedgerId'] = this.ledgerId;
    data['BalanceAsOn'] = this.balanceAsOn;
    data['BalanceType'] = this.balanceType;
    data['Balance'] = this.balance;
    return data;
  }
}