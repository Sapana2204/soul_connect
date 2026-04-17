import 'delivery_challan_item_model.dart';

class DeliveryChallanModel {
  int challanId;
  int customerId;
  int locationId;

  String challanNo;
  DateTime challanDate;
  String customerName;

  String? contact;
  String? deliveryAddress;
  String? vehicleNo;
  String? byHand;

  double totalQty;
  List<DeliveryChallanItem>? details;

  DeliveryChallanModel({
    required this.challanId,
    required this.customerId,
    required this.locationId,
    required this.challanNo,
    required this.challanDate,
    required this.customerName,
    required this.totalQty,
    this.contact,
    this.deliveryAddress,
    this.vehicleNo,
    this.byHand,
    this.details,
  });

  /// ✅ REQUIRED because repository uses it
  factory DeliveryChallanModel.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanModel(
      challanId: json['ChallanId'] ?? 0,
      customerId: json['CustomerId'] ?? 0,
      locationId: json['LocationId'] ?? 0,
      challanNo: json['ChallanNo'] ?? '',
      challanDate: DateTime.parse(json['ChallanDate']),
      customerName: json['CustomerName'] ?? '',
      totalQty: (json['TotalQty'] as num?)?.toDouble() ?? 0.0,
      contact: json['Contact'],
      deliveryAddress: json['DeliveryAddress'],
      vehicleNo: json['VehicleDetails'],
      byHand: json['ByHand'],
      details: json['Details'] != null
          ? (json['Details'] as List)
          .map((e) => DeliveryChallanItem.fromJson(e))
          .toList()
          : null,
    );
  }

  /// ✅ Needed for ADD / UPDATE
  Map<String, dynamic> toJson() {
    return {
      "ChallanId": challanId,
      "CustomerId": customerId,
      "LocationId": locationId,
      "ChallanNo": challanNo,
      "ChallanDate": challanDate.toIso8601String(),
      "CustomerName": customerName,
      "TotalQty": totalQty,
      "Contact": contact,
      "DeliveryAddress": deliveryAddress,
      "VehicleDetails": vehicleNo,
      "ByHand": byHand,
      "Details": details?.map((e) => e.toJson()).toList(),
    };
  }
}
