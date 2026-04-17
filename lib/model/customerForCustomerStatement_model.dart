class CustomerForCustomerStatementModel {
  int? partyId;
  String? partyName;
  String? partyType;
  String? address;
  String? contactPerson;
  String? phone;
  String? mobile;
  String? email;
  bool? isActive;
  String? notes;
  String? gSTIN;
  String? pAN;
  String? dealerCode;
  int? gSTStateCode;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  int? ledgerId;
  double? creditLimit;
  double? opening;
  String? drCrType;
  String? aadharNumber;
  String? partyTypeName;
  bool? isDisplayNarration;
  bool? isDisplayItemDescription;

  CustomerForCustomerStatementModel(
      {this.partyId,
        this.partyName,
        this.partyType,
        this.address,
        this.contactPerson,
        this.phone,
        this.mobile,
        this.email,
        this.isActive,
        this.notes,
        this.gSTIN,
        this.pAN,
        this.dealerCode,
        this.gSTStateCode,
        this.createdBy,
        this.createdOn,
        this.updatedBy,
        this.updatedOn,
        this.ledgerId,
        this.creditLimit,
        this.opening,
        this.drCrType,
        this.aadharNumber,
        this.partyTypeName,
        this.isDisplayNarration,
        this.isDisplayItemDescription});

  CustomerForCustomerStatementModel.fromJson(Map<String, dynamic> json) {
    partyId = json['PartyId'];
    partyName = json['PartyName'];
    partyType = json['PartyType'];
    address = json['Address'];
    contactPerson = json['ContactPerson'];
    phone = json['Phone'];
    mobile = json['Mobile'];
    email = json['Email'];
    isActive = json['IsActive'];
    notes = json['Notes'];
    gSTIN = json['GSTIN'];
    pAN = json['PAN'];
    dealerCode = json['DealerCode'];
    gSTStateCode = json['GSTStateCode'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    ledgerId = json['LedgerId'];
    creditLimit = (json['CreditLimit'] ?? 0).toDouble();
    opening = (json['Opening'] ?? 0).toDouble();
    drCrType = json['DrCrType'];
    aadharNumber = json['AadharNumber'];
    partyTypeName = json['PartyTypeName'];
    isDisplayNarration = json['IsDisplayNarration'];
    isDisplayItemDescription = json['IsDisplayItemDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PartyId'] = this.partyId;
    data['PartyName'] = this.partyName;
    data['PartyType'] = this.partyType;
    data['Address'] = this.address;
    data['ContactPerson'] = this.contactPerson;
    data['Phone'] = this.phone;
    data['Mobile'] = this.mobile;
    data['Email'] = this.email;
    data['IsActive'] = this.isActive;
    data['Notes'] = this.notes;
    data['GSTIN'] = this.gSTIN;
    data['PAN'] = this.pAN;
    data['DealerCode'] = this.dealerCode;
    data['GSTStateCode'] = this.gSTStateCode;
    data['CreatedBy'] = this.createdBy;
    data['CreatedOn'] = this.createdOn;
    data['UpdatedBy'] = this.updatedBy;
    data['UpdatedOn'] = this.updatedOn;
    data['LedgerId'] = this.ledgerId;
    data['CreditLimit'] = this.creditLimit;
    data['Opening'] = this.opening;
    data['DrCrType'] = this.drCrType;
    data['AadharNumber'] = this.aadharNumber;
    data['PartyTypeName'] = this.partyTypeName;
    data['IsDisplayNarration'] = this.isDisplayNarration;
    data['IsDisplayItemDescription'] = this.isDisplayItemDescription;
    return data;
  }
}
