import 'add_sale_model.dart';

class SalesDashboardModel {
  int? salesID;
  String? salesBillNo;
  int? salesSeriesId;
  String? salesDate;
  int? customerId;
  double? totalQty;
  double? itemTotal;
  int? locationId;
  int? userID;
  String? billType;
  String? rateType;
  String? salesType;
  String? paymentTerm;
  String? cropType;
  double? freeQty;
  double? subTotal;
  double? discPer;
  double? discAmt;
  double? totalDiscAmt;
  double? totalAmt;
  double? freight;
  double? taxableAmt;
  double? totalTaxAmt;
  double? totalTaxableAmt;
  double? invoiceChargesAmt;
  double? billTotal;
  double? roundOff;
  double? netBillTotal;
  double? netAmt;
  double? netBillAmt;
  String? narration;
  String? byHand;
  String? vehicleDetails;
  bool? isBillReceived;
  int? bankLedgerId;
  bool? isChallanInvoice;
  bool? isQuotationInvoice;
  bool? isWalkinCustomer;
  String? customerName;
  String? address;
  int? age;
  double? cashPaidAmount;
  double? bankPaidAmount;
  String? modeOfBankPayment;
  double? customerOutstanding;
  bool? isSalesReturned;
  String? misc1;
  String? misc2;
  String? misc3;
  String? misc4;
  String? misc5;
  int? preparedBy;
  int? checkedBy;
  int? createdBy;
  int? updatedBy;
  String? phoneNumber;
  // Null? salesDetails;
  // Null? salesOtherCharges;
  List<SalesDetail>? salesDetails;
  List<SalesOtherCharge>? salesOtherCharges;

  SalesDashboardModel(
      {this.salesID,
        this.salesBillNo,
        this.salesSeriesId,
        this.salesDate,
        this.customerId,
        this.totalQty,
        this.itemTotal,
        this.locationId,
        this.userID,
        this.billType,
        this.rateType,
        this.salesType,
        this.paymentTerm,
        this.cropType,
        this.freeQty,
        this.subTotal,
        this.discPer,
        this.discAmt,
        this.totalDiscAmt,
        this.totalAmt,
        this.freight,
        this.taxableAmt,
        this.totalTaxAmt,
        this.totalTaxableAmt,
        this.invoiceChargesAmt,
        this.billTotal,
        this.roundOff,
        this.netBillTotal,
        this.netAmt,
        this.netBillAmt,
        this.narration,
        this.byHand,
        this.vehicleDetails,
        this.isBillReceived,
        this.bankLedgerId,
        this.isChallanInvoice,
        this.isQuotationInvoice,
        this.isWalkinCustomer,
        this.customerName,
        this.address,
        this.age,
        this.cashPaidAmount,
        this.bankPaidAmount,
        this.modeOfBankPayment,
        this.customerOutstanding,
        this.isSalesReturned,
        this.misc1,
        this.misc2,
        this.misc3,
        this.misc4,
        this.misc5,
        this.preparedBy,
        this.checkedBy,
        this.createdBy,
        this.updatedBy,
        this.phoneNumber,
        this.salesDetails,
        this.salesOtherCharges});

  SalesDashboardModel.fromJson(Map<String, dynamic> json) {
    salesID = json['SalesID'];
    salesBillNo = json['SalesBillNo'];
    salesSeriesId = json['SalesSeriesId'];
    salesDate = json['SalesDate'];
    customerId = json['CustomerId'];
    totalQty = _toDouble(json['TotalQty']);
    itemTotal = json['ItemTotal'];
    locationId = json['LocationId'];
    userID = json['UserID'];
    billType = json['BillType'];
    rateType = json['RateType'];
    salesType = json['SalesType'];
    paymentTerm = json['PaymentTerm'];
    cropType = json['CropType'];
    freeQty = _toDouble(json['FreeQty']);
    subTotal = _toDouble(json['SubTotal']);
    discPer = _toDouble(json['DiscPer']);
    discAmt = _toDouble(json['DiscAmt']);
    totalDiscAmt = _toDouble(json['TotalDiscAmt']);
    totalAmt = _toDouble(json['TotalAmt']);
    freight = _toDouble(json['Freight']);
    taxableAmt = _toDouble(json['TaxableAmt']);
    totalTaxAmt = _toDouble(json['TotalTaxAmt']);
    totalTaxableAmt = _toDouble(json['TotalTaxableAmt']);
    invoiceChargesAmt = _toDouble(json['InvoiceChargesAmt']);
    billTotal = _toDouble(json['BillTotal']);
    roundOff = _toDouble(json['RoundOff']);
    netBillTotal = _toDouble(json['NetBillTotal']);
    netAmt = _toDouble(json['NetAmt']);
    netBillAmt = _toDouble(json['NetBillAmt']);
    narration = json['Narration'];
    byHand = json['ByHand'];
    vehicleDetails = json['VehicleDetails'];
    isBillReceived = json['IsBillReceived'];
    bankLedgerId = json['BankLedgerId'];
    isChallanInvoice = json['IsChallanInvoice'];
    isQuotationInvoice = json['IsQuotationInvoice'];
    isWalkinCustomer = json['IsWalkinCustomer'];
    customerName = json['CustomerName'];
    address = json['Address'];
    age = json['Age'];
    cashPaidAmount = _toDouble(json['CashPaidAmount']);
    bankPaidAmount = _toDouble(json['BankPaidAmount']);
    modeOfBankPayment = json['ModeOfBankPayment'];
    customerOutstanding = _toDouble(json['CustomerOutstanding']);
    isSalesReturned = json['IsSalesReturned'];
    misc1 = json['Misc1'];
    misc2 = json['Misc2'];
    misc3 = json['Misc3'];
    misc4 = json['Misc4'];
    misc5 = json['Misc5'];
    preparedBy = json['PreparedBy'];
    checkedBy = json['CheckedBy'];
    createdBy = json['CreatedBy'];
    updatedBy = json['UpdatedBy'];
    phoneNumber = json['PhoneNumber'];
    // salesDetails = json['SalesDetails'];
    // salesOtherCharges = json['SalesOtherCharges'];
    // Correctly map SalesDetails JSON array to List<SalesDetail>
    if (json['SalesDetails'] != null) {
      salesDetails = List<SalesDetail>.from(
          json['SalesDetails'].map((x) => SalesDetail.fromJson(x))
      );
    } else {
      salesDetails = [];
    }

    // Correctly map SalesOtherCharges JSON array to List<SalesOtherCharge>
    if (json['SalesOtherCharges'] != null) {
      salesOtherCharges = List<SalesOtherCharge>.from(
          json['SalesOtherCharges'].map((x) => SalesOtherCharge.fromJson(x))
      );
    } else {
      salesOtherCharges = [];
    }
  }
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesID'] = this.salesID;
    data['SalesBillNo'] = this.salesBillNo;
    data['SalesSeriesId'] = this.salesSeriesId;
    data['SalesDate'] = this.salesDate;
    data['CustomerId'] = this.customerId;
    data['TotalQty'] = this.totalQty;
    data['ItemTotal'] = this.itemTotal;
    data['LocationId'] = this.locationId;
    data['UserID'] = this.userID;
    data['BillType'] = this.billType;
    data['RateType'] = this.rateType;
    data['SalesType'] = this.salesType;
    data['PaymentTerm'] = this.paymentTerm;
    data['CropType'] = this.cropType;
    data['FreeQty'] = this.freeQty;
    data['SubTotal'] = this.subTotal;
    data['DiscPer'] = this.discPer;
    data['DiscAmt'] = this.discAmt;
    data['TotalDiscAmt'] = this.totalDiscAmt;
    data['TotalAmt'] = this.totalAmt;
    data['Freight'] = this.freight;
    data['TaxableAmt'] = this.taxableAmt;
    data['TotalTaxAmt'] = this.totalTaxAmt;
    data['TotalTaxableAmt'] = this.totalTaxableAmt;
    data['InvoiceChargesAmt'] = this.invoiceChargesAmt;
    data['BillTotal'] = this.billTotal;
    data['RoundOff'] = this.roundOff;
    data['NetBillTotal'] = this.netBillTotal;
    data['NetAmt'] = this.netAmt;
    data['NetBillAmt'] = this.netBillAmt;
    data['Narration'] = this.narration;
    data['ByHand'] = this.byHand;
    data['VehicleDetails'] = this.vehicleDetails;
    data['IsBillReceived'] = this.isBillReceived;
    data['BankLedgerId'] = this.bankLedgerId;
    data['IsChallanInvoice'] = this.isChallanInvoice;
    data['IsQuotationInvoice'] = this.isQuotationInvoice;
    data['IsWalkinCustomer'] = this.isWalkinCustomer;
    data['CustomerName'] = this.customerName;
    data['Address'] = this.address;
    data['Age'] = this.age;
    data['CashPaidAmount'] = this.cashPaidAmount;
    data['BankPaidAmount'] = this.bankPaidAmount;
    data['ModeOfBankPayment'] = this.modeOfBankPayment;
    data['CustomerOutstanding'] = this.customerOutstanding;
    data['IsSalesReturned'] = this.isSalesReturned;
    data['Misc1'] = this.misc1;
    data['Misc2'] = this.misc2;
    data['Misc3'] = this.misc3;
    data['Misc4'] = this.misc4;
    data['Misc5'] = this.misc5;
    data['PreparedBy'] = this.preparedBy;
    data['CheckedBy'] = this.checkedBy;
    data['CreatedBy'] = this.createdBy;
    data['UpdatedBy'] = this.updatedBy;
    data['PhoneNumber'] = this.phoneNumber;
    data['SalesDetails'] = this.salesDetails;
    data['SalesOtherCharges'] = this.salesOtherCharges;
    return data;
  }
}