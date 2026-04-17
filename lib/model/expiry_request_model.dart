import 'package:flutter_soulconnect/model/get_expiry_model.dart';

class ExpiryRequestModel {
  int expiryId;
  String expiryDate;
  int firmId;
  int locationId;
  int createdBy;
  String createdOn;
  int updatedBy;
  String updatedOn;
  bool isCancelled;
  int userId;
  List<ExpiryDetailsModel> details;

  ExpiryRequestModel({
    required this.expiryId,
    required this.expiryDate,
    required this.firmId,
    required this.locationId,
    required this.createdBy,
    required this.createdOn,
    required this.updatedBy,
    required this.updatedOn,
    required this.isCancelled,
    required this.userId,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      "ExpiryId": expiryId,
      "ExpiryDate": expiryDate,
      "FirmId": firmId,
      "LocationId": locationId,
      "CreatedBy": createdBy,
      "CreatedOn": createdOn,
      "UpdatedBy": updatedBy,
      "UpdatedOn": updatedOn,
      "IsCancelled": isCancelled,
      "UserId": userId,
      "Details": details,
    };
  }
}