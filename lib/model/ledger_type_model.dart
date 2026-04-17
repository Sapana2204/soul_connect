class LedgerTypeModel {
int? ledgerId;
String? ledgerName;
int? groupID;
String? groupName;
String? contact;
String? gSTIN;
String? pAN;
double? openingBalance;
String? drCrType;
String? openingAsOn;
String? description;
bool? status;
String? ledgerType;
int? custSuppBankID;
String? address;
double? creditLimit;
String? email;
int? gSTStateCode;
int? createdBy;
int? updatedBy;
String? misc1;
String? misc2;
String? misc3;
String? misc4;
String? misc5;
bool? isFreightPostageAcc;

LedgerTypeModel(
{this.ledgerId,
this.ledgerName,
this.groupID,
this.groupName,
this.contact,
this.gSTIN,
this.pAN,
this.openingBalance,
this.drCrType,
this.openingAsOn,
this.description,
this.status,
this.ledgerType,
this.custSuppBankID,
this.address,
this.creditLimit,
this.email,
this.gSTStateCode,
this.createdBy,
this.updatedBy,
this.misc1,
this.misc2,
this.misc3,
this.misc4,
this.misc5,
this.isFreightPostageAcc});

LedgerTypeModel.fromJson(Map<String, dynamic> json) {
ledgerId = json['LedgerId'];
ledgerName = json['LedgerName'];
groupID = json['GroupID'];
groupName = json['GroupName'];
contact = json['Contact'];
gSTIN = json['GSTIN'];
pAN = json['PAN'];
openingBalance = json['OpeningBalance'];
drCrType = json['DrCrType'];
openingAsOn = json['OpeningAsOn'];
description = json['Description'];
status = json['Status'];
ledgerType = json['LedgerType'];
custSuppBankID = json['CustSuppBankID'];
address = json['Address'];
creditLimit = json['CreditLimit'];
email = json['Email'];
gSTStateCode = json['GSTStateCode'];
createdBy = json['CreatedBy'];
updatedBy = json['UpdatedBy'];
misc1 = json['Misc1'];
misc2 = json['Misc2'];
misc3 = json['Misc3'];
misc4 = json['Misc4'];
misc5 = json['Misc5'];
isFreightPostageAcc = json['IsFreightPostageAcc'];
}

Map<String, dynamic> toJson() {
final Map<String, dynamic> data = new Map<String, dynamic>();
data['LedgerId'] = this.ledgerId;
data['LedgerName'] = this.ledgerName;
data['GroupID'] = this.groupID;
data['GroupName'] = this.groupName;
data['Contact'] = this.contact;
data['GSTIN'] = this.gSTIN;
data['PAN'] = this.pAN;
data['OpeningBalance'] = this.openingBalance;
data['DrCrType'] = this.drCrType;
data['OpeningAsOn'] = this.openingAsOn;
data['Description'] = this.description;
data['Status'] = this.status;
data['LedgerType'] = this.ledgerType;
data['CustSuppBankID'] = this.custSuppBankID;
data['Address'] = this.address;
data['CreditLimit'] = this.creditLimit;
data['Email'] = this.email;
data['GSTStateCode'] = this.gSTStateCode;
data['CreatedBy'] = this.createdBy;
data['UpdatedBy'] = this.updatedBy;
data['Misc1'] = this.misc1;
data['Misc2'] = this.misc2;
data['Misc3'] = this.misc3;
data['Misc4'] = this.misc4;
data['Misc5'] = this.misc5;
data['IsFreightPostageAcc'] = this.isFreightPostageAcc;
return data;
}
}