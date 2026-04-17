class PartyModel {
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
  String? misc1;
  String? misc2;
  String? misc3;
  String? misc4;
  String? misc5;
  double? creditLimit;
  double? opening;
  String? drCrType;
  String? partyTypeName;

  PartyModel(
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
        this.misc1,
        this.misc2,
        this.misc3,
        this.misc4,
        this.misc5,
        this.creditLimit,
        this.opening,
        this.drCrType,
        this.partyTypeName});

  PartyModel.fromJson(Map<String, dynamic> json) {
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
    misc1 = json['Misc1'];
    misc2 = json['Misc2'];
    misc3 = json['Misc3'];
    misc4 = json['Misc4'];
    misc5 = json['Misc5'];
    creditLimit = json['CreditLimit'];
    opening = json['Opening'];
    drCrType = json['DrCrType'];
    partyTypeName = json['PartyTypeName'];
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
    data['Misc1'] = this.misc1;
    data['Misc2'] = this.misc2;
    data['Misc3'] = this.misc3;
    data['Misc4'] = this.misc4;
    data['Misc5'] = this.misc5;
    data['CreditLimit'] = this.creditLimit;
    data['Opening'] = this.opening;
    data['DrCrType'] = this.drCrType;
    data['PartyTypeName'] = this.partyTypeName;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PartyModel &&
        other.partyId == partyId;
  }

  @override
  int get hashCode => partyId.hashCode;
}