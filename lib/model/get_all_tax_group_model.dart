class TaxGroupPercentageModel {
  final int taxGroupId;
  final int taxId;
  final String taxName;
  final double taxPer;
  final String misc1;

  TaxGroupPercentageModel({
    required this.taxGroupId,
    required this.taxId,
    required this.taxName,
    required this.taxPer,
    required this.misc1,
  });

  factory TaxGroupPercentageModel.fromJson(Map<String, dynamic> json) {
    return TaxGroupPercentageModel(
      taxGroupId: json['TaxGroupId'] ?? 0,
      taxId: json['TaxId'] ?? 0,
      taxName: json['TaxName'] ?? '',
      taxPer: (json['TaxPer'] ?? 0).toDouble(),
      misc1: json['Misc1'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TaxGroupId': taxGroupId,
      'TaxId': taxId,
      'TaxName': taxName,
      'TaxPer': taxPer,
      'Misc1': misc1,
    };
  }
}
