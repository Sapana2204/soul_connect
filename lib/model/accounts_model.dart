class AccountsModel {
  final int? voucherId;
  final int vchTypeId;
  final String? vchDate;
  final String userId;
  final int createdBy;
  final int updatedBy;

  AccountsModel({
    this.voucherId,
    required this.vchTypeId,
    this.vchDate,
    required this.userId,
    required this.createdBy,
    required this.updatedBy,
  });

  /// Convert Model -> JSON
  Map<String, dynamic> toJson() {
    return {
      "VoucherId": voucherId,
      "VchTypeId": vchTypeId,
      "VchDate": vchDate,
      "UserId": userId,
      "CreatedBy": createdBy,
      "UpdatedBy": updatedBy,
    };
  }

  /// Optional: JSON -> Model (useful later)
  factory AccountsModel.fromJson(Map<String, dynamic> json) {
    return AccountsModel(
      voucherId: json["VoucherId"],
      vchTypeId: json["VchTypeId"],
      vchDate: json["VchDate"],
      userId: json["UserId"],
      createdBy: json["CreatedBy"],
      updatedBy: json["UpdatedBy"],
    );
  }
}