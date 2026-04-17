class BillTypesModel {
  int? billTypeId;
  String? billType;
  String? prefix;
  bool? includeFinancialYear;
  String? salesQuotation;

  BillTypesModel(
      {this.billTypeId,
        this.billType,
        this.prefix,
        this.includeFinancialYear,
        this.salesQuotation});

  BillTypesModel.fromJson(Map<String, dynamic> json) {
    billTypeId = json['BillTypeId'];
    billType = json['BillType'];
    prefix = json['Prefix'];
    includeFinancialYear = json['IncludeFinancialYear'];
    salesQuotation = json['SalesQuotation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BillTypeId'] = this.billTypeId;
    data['BillType'] = this.billType;
    data['Prefix'] = this.prefix;
    data['IncludeFinancialYear'] = this.includeFinancialYear;
    data['SalesQuotation'] = this.salesQuotation;
    return data;
  }
}