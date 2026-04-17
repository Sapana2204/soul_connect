import 'package:flutter_soulconnect/model/stock_inward_model.dart';

class StockInwardRequestModel {
  int inwardId;
  int issueId;
  String inwardDate;
  int createdBy;
  int locationId;
  int fromLocationId;
  List<StockInwardDetails> details;

  StockInwardRequestModel({
    required this.inwardId,
    required this.issueId,
    required this.inwardDate,
    required this.createdBy,
    required this.locationId,
    required this.fromLocationId,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      "InwardId": inwardId,
      "IssueId": issueId,
      "InwardDate": inwardDate,
      "CreatedBy": createdBy,
      "LocationId": locationId,
      "FromLocationId": fromLocationId,
      "details": details.map((e) => e.toJson()).toList(),
    };
  }
}
