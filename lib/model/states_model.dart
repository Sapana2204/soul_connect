class StatesModel {
  int? gSTStateCode;
  String? stateName;

  StatesModel({this.gSTStateCode, this.stateName});

  StatesModel.fromJson(Map<String, dynamic> json) {
    gSTStateCode = json['GSTStateCode'];
    stateName = json['StateName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['GSTStateCode'] = this.gSTStateCode;
    data['StateName'] = this.stateName;
    return data;
  }
}