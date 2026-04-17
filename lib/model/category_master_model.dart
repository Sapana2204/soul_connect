class CategoryMasterModel {
  int? CateId;
  String? CateName;
  String? CateShortName;
  bool? IsHardware;

  CategoryMasterModel(
      {this.CateId, this.CateName, this.CateShortName, this.IsHardware});

  CategoryMasterModel.fromJson(Map<String, dynamic> json) {
    CateId = json['CateId'];
    CateName = json['CateName'];
    CateShortName = json['CateShortName'];
    IsHardware = json['IsHardware'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CateId'] = this.CateId;
    data['CateName'] = this.CateName;
    data['CateShortName'] = this.CateShortName;
    data['IsHardware'] = this.IsHardware;
    return data;
  }
}