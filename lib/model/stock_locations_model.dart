class StockLocationsModel {
  int? locationId;
  String? locationName;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  String? misc1;
  String? misc2;
  String? misc3;
  String? misc4;
  String? misc5;
  int? firmId;
  String? firmName;

  StockLocationsModel(
      {this.locationId,
        this.locationName,
        this.createdBy,
        this.createdOn,
        this.updatedBy,
        this.updatedOn,
        this.misc1,
        this.misc2,
        this.misc3,
        this.misc4,
        this.misc5,
        this.firmId,
        this.firmName});

  StockLocationsModel.fromJson(Map<String, dynamic> json) {
    locationId = json['LocationId'];
    locationName = json['LocationName'];
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    misc1 = json['Misc1'];
    misc2 = json['Misc2'];
    misc3 = json['Misc3'];
    misc4 = json['Misc4'];
    misc5 = json['Misc5'];
    firmId = json['FirmId'];
    firmName = json['FirmName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LocationId'] = this.locationId;
    data['LocationName'] = this.locationName;
    data['CreatedBy'] = this.createdBy;
    data['CreatedOn'] = this.createdOn;
    data['UpdatedBy'] = this.updatedBy;
    data['UpdatedOn'] = this.updatedOn;
    data['Misc1'] = this.misc1;
    data['Misc2'] = this.misc2;
    data['Misc3'] = this.misc3;
    data['Misc4'] = this.misc4;
    data['Misc5'] = this.misc5;
    data['FirmId'] = this.firmId;
    data['FirmName'] = this.firmName;
    return data;
  }
}