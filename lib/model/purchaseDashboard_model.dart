import 'PurchaseInvoiceItem_model.dart';
import 'addPurchase_model.dart';

class PurchaseDashboardModel {
  int? purchaseId;
  int? ledgerId;
  int? purchaseSeriesId;
  String? purchaseDate;
  int? supplierId;
  String? supplierBillNo;
  double? totalQty;
  double? freeQty;
  double? subTotal;
  double? discAmt;
  double? taxableAmt;
  double? totalTaxAmt;
  double? invoiceChargesAmt;
  double? roundOff;
  double? grossBillDiscountAmt;
  double? grossBillDiscountPer;
  double? netAmt;
  double? paidAmt;
  double? balAmt;
  double? totalAmt;
  String? billPaidStatus;
  String? narration;
  String? byHand;
  String? vehicleDetails;
  int? isBillPaid;
  String? preparedByUser;
  String? createdByUser;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;
  int? userId;
  bool? isChallan;
  String? supplierChallanNo;
  String? challanDate;
  bool? isPurchased;
  bool? isWithoutGST;
  bool? isPurchaseReturned;
  String? misc1;
  String? misc2;
  String? misc3;
  String? misc4;
  String? misc5;
  int? locationId;
  String? purchasedOn;
  int? firmId;
  bool? isCancelled;
  String? supplierName;
  String? address;
  String? mobile;
  String? gSTIN;
  String? payMode;
  String? paymentTerm;
  List<PurchaseOtherCharges>? purchaseOtherCharges;
  List<Details>? details;

  PurchaseDashboardModel({
    this.purchaseId,
    this.ledgerId,
    this.purchaseSeriesId,
    this.purchaseDate,
    this.supplierId,
    this.supplierBillNo,
    this.totalQty,
    this.freeQty,
    this.subTotal,
    this.discAmt,
    this.taxableAmt,
    this.totalTaxAmt,
    this.invoiceChargesAmt,
    this.roundOff,
    this.grossBillDiscountAmt,
    this.grossBillDiscountPer,
    this.netAmt,
    this.paidAmt,
    this.balAmt,
    this.totalAmt,
    this.billPaidStatus,
    this.narration,
    this.byHand,
    this.vehicleDetails,
    this.isBillPaid,
    this.preparedByUser,
    this.createdByUser,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.userId,
    this.isChallan,
    this.supplierChallanNo,
    this.challanDate,
    this.isPurchased,
    this.isWithoutGST,
    this.isPurchaseReturned,
    this.misc1,
    this.misc2,
    this.misc3,
    this.misc4,
    this.misc5,
    this.locationId,
    this.purchasedOn,
    this.firmId,
    this.isCancelled,
    this.supplierName,
    this.address,
    this.mobile,
    this.gSTIN,
    this.payMode,
    this.paymentTerm,
    this.purchaseOtherCharges,
    this.details,
  });

  factory PurchaseDashboardModel.fromJson(Map<String, dynamic> json) {
    return PurchaseDashboardModel(
      purchaseId: json['PurchaseId'],
      ledgerId: json['LedgerId'],
      purchaseSeriesId: json['PurchaseSeriesId'],
      purchaseDate: json['PurchaseDate'],
      supplierId: json['SupplierId'],
      supplierBillNo: json['SupplierBillNo'],

      totalQty: (json['TotalQty'] as num?)?.toDouble(),
      freeQty: (json['FreeQty'] as num?)?.toDouble(),
      subTotal: (json['SubTotal'] as num?)?.toDouble(),
      discAmt: (json['DiscAmt'] as num?)?.toDouble(),
      taxableAmt: (json['TaxableAmt'] as num?)?.toDouble(),
      totalTaxAmt: (json['TotalTaxAmt'] as num?)?.toDouble(),
      invoiceChargesAmt: (json['InvoiceChargesAmt'] as num?)?.toDouble(),
      roundOff: (json['RoundOff'] as num?)?.toDouble(),
      grossBillDiscountAmt: (json['GrossBillDiscountAmt'] as num?)?.toDouble(),
      grossBillDiscountPer: (json['GrossBillDiscountPer'] as num?)?.toDouble(),
      netAmt: (json['NetAmt'] as num?)?.toDouble(),
      paidAmt: (json['PaidAmt'] as num?)?.toDouble(),
      balAmt: (json['BalAmt'] as num?)?.toDouble(),
      totalAmt: (json['TotalAmt'] as num?)?.toDouble(),

      billPaidStatus: json['BillPaidStatus'],
      narration: json['Narration'],
      byHand: json['ByHand'],
      vehicleDetails: json['VehicleDetails'],
      isBillPaid: json['IsBillPaid'],
      preparedByUser: json['PreparedByUser'],
      createdByUser: json['CreatedByUser'],
      createdBy: json['CreatedBy'],
      createdOn: json['CreatedOn'],
      updatedBy: json['UpdatedBy'],
      updatedOn: json['UpdatedOn'],
      userId: json['UserId'],
      isChallan: json['IsChallan'],
      supplierChallanNo: json['SupplierChallanNo'],
      challanDate: json['ChallanDate'],
      isPurchased: json['IsPurchased'],
      isWithoutGST: json['IsWithoutGST'],
      isPurchaseReturned: json['IsPurchaseReturned'],
      misc1: json['Misc1'],
      misc2: json['Misc2'],
      misc3: json['Misc3'],
      misc4: json['Misc4'],
      misc5: json['Misc5'],
      locationId: json['LocationId'],
      purchasedOn: json['PurchasedOn'],
      firmId: json['FirmId'],
      isCancelled: json['IsCancelled'],
      supplierName: json['SupplierName'],
      address: json['Address'],
      mobile: json['Mobile'],
      gSTIN: json['GSTIN'],
      payMode: json['PayMode'],
      paymentTerm: json['PaymentTerm'],

      purchaseOtherCharges: json['PurchaseOtherCharges'] != null
          ? (json['PurchaseOtherCharges'] as List)
          .map((e) => PurchaseOtherCharges.fromJson(e))
          .toList()
          : [],

      details: json['Details'] != null
          ? (json['Details'] as List)
          .map((e) => Details.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PurchaseId': purchaseId,
      'PurchaseSeriesId': purchaseSeriesId,
      'PurchaseDate': purchaseDate,
      'SupplierId': supplierId,
      'SupplierBillNo': supplierBillNo,
      'TotalQty': totalQty,
      'FreeQty': freeQty,
      'SubTotal': subTotal,
      'DiscAmt': discAmt,
      'TaxableAmt': taxableAmt,
      'TotalTaxAmt': totalTaxAmt,
      'InvoiceChargesAmt': invoiceChargesAmt,
      'RoundOff': roundOff,
      'GrossBillDiscountAmt': grossBillDiscountAmt,
      'GrossBillDiscountPer': grossBillDiscountPer,
      'NetAmt': netAmt,
      'PaidAmt': paidAmt,
      'BalAmt': balAmt,
      'BillPaidStatus': billPaidStatus,
      'Narration': narration,
      'ByHand': byHand,
      'VehicleDetails': vehicleDetails,
      'IsBillPaid': isBillPaid,
      'PreparedByUser': preparedByUser,
      'CreatedByUser': createdByUser,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'UpdatedBy': updatedBy,
      'UpdatedOn': updatedOn,
      'UserId': userId,
      'IsChallan': isChallan,
      'SupplierChallanNo': supplierChallanNo,
      'ChallanDate': challanDate,
      'IsPurchased': isPurchased,
      'IsWithoutGST': isWithoutGST,
      'IsPurchaseReturned': isPurchaseReturned,
      'Misc1': misc1,
      'Misc2': misc2,
      'Misc3': misc3,
      'Misc4': misc4,
      'Misc5': misc5,
      'LocationId': locationId,
      'PurchasedOn': purchasedOn,
      'FirmId': firmId,
      'IsCancelled': isCancelled,
      'SupplierName': supplierName,
      'Address': address,
      'Mobile': mobile,
      'GSTIN': gSTIN,
      'PayMode': payMode,
      'PaymentTerm': paymentTerm,
      'PurchaseOtherCharges': purchaseOtherCharges,
      'Details': details,
    };
  }
}
