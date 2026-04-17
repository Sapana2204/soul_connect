class RateTypesModel {
  int? rateTypeId;
  String? rateType;
  String? rateTypeDisplay;

  RateTypesModel({this.rateTypeId, this.rateType, this.rateTypeDisplay});

  RateTypesModel.fromJson(Map<String, dynamic> json) {
    rateTypeId = json['RateTypeId'];
    rateType = json['RateType'];
    rateTypeDisplay = json['RateTypeDisplay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RateTypeId'] = this.rateTypeId;
    data['RateType'] = this.rateType;
    data['RateTypeDisplay'] = this.rateTypeDisplay;
    return data;
  }
}