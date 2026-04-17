class ItemRateModel {
  Rate? rate;

  ItemRateModel({this.rate});

  ItemRateModel.fromJson(Map<String, dynamic> json) {
    rate = json['Rate'] != null ? new Rate.fromJson(json['Rate']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rate != null) {
      data['Rate'] = this.rate!.toJson();
    }
    return data;
  }
}

class Rate {
  double? rate;
  bool? baseRateApplied;

  Rate({this.rate, this.baseRateApplied});

  Rate.fromJson(Map<String, dynamic> json) {
    rate = json['Rate'];
    baseRateApplied = json['BaseRateApplied'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Rate'] = this.rate;
    data['BaseRateApplied'] = this.baseRateApplied;
    return data;
  }
}