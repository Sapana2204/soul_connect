class ProfitLossModel {
  List<ProfitLossStatement>? profitLossStatement;
  ProfitLossTotals? profitLossTotals;

  ProfitLossModel({this.profitLossStatement, this.profitLossTotals});

  ProfitLossModel.fromJson(Map<String, dynamic> json) {
    if (json['profitLossStatement'] != null) {
      profitLossStatement = <ProfitLossStatement>[];
      json['profitLossStatement'].forEach((v) {
        profitLossStatement!.add(ProfitLossStatement.fromJson(v));
      });
    }

    profitLossTotals = json['profitLossTotals'] != null
        ? ProfitLossTotals.fromJson(json['profitLossTotals'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (profitLossStatement != null) {
      data['profitLossStatement'] =
          profitLossStatement!.map((v) => v.toJson()).toList();
    }

    if (profitLossTotals != null) {
      data['profitLossTotals'] = profitLossTotals!.toJson();
    }

    return data;
  }
}

class ProfitLossStatement {
  String? salesBillNo;
  String? customerName;
  String? payType;

  double? totalQty;
  double? billAmt;
  double? margin;
  double? taxAmount;
  double? profitLoss;

  String? salesDate;
  List<Details>? details;

  ProfitLossStatement({
    this.salesBillNo,
    this.customerName,
    this.payType,
    this.totalQty,
    this.billAmt,
    this.margin,
    this.taxAmount,
    this.profitLoss,
    this.salesDate,
    this.details,
  });

  ProfitLossStatement.fromJson(Map<String, dynamic> json) {
    salesBillNo = json['SalesBillNo'];
    customerName = json['CustomerName'];
    payType = json['PayType'];

    totalQty = (json['TotalQty'] as num?)?.toDouble();
    billAmt = (json['BillAmt'] as num?)?.toDouble();
    margin = (json['Margin'] as num?)?.toDouble();
    taxAmount = (json['TaxAmount'] as num?)?.toDouble();
    profitLoss = (json['ProfitLoss'] as num?)?.toDouble();

    salesDate = json['SalesDate'];

    if (json['Details'] != null) {
      details = <Details>[];
      json['Details'].forEach((v) {
        details!.add(Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['SalesBillNo'] = salesBillNo;
    data['CustomerName'] = customerName;
    data['PayType'] = payType;

    data['TotalQty'] = totalQty;
    data['BillAmt'] = billAmt;
    data['Margin'] = margin;
    data['TaxAmount'] = taxAmount;
    data['ProfitLoss'] = profitLoss;

    data['SalesDate'] = salesDate;

    if (details != null) {
      data['Details'] = details!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Details {
  String? itemName;

  double? totalQty;
  double? billAmt;
  double? margin;
  double? taxAmount;
  double? profitLoss;

  Details({
    this.itemName,
    this.totalQty,
    this.billAmt,
    this.margin,
    this.taxAmount,
    this.profitLoss,
  });

  Details.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];

    totalQty = (json['TotalQty'] as num?)?.toDouble();
    billAmt = (json['BillAmt'] as num?)?.toDouble();
    margin = (json['Margin'] as num?)?.toDouble();
    taxAmount = (json['TaxAmount'] as num?)?.toDouble();
    profitLoss = (json['ProfitLoss'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['ItemName'] = itemName;
    data['TotalQty'] = totalQty;
    data['BillAmt'] = billAmt;
    data['Margin'] = margin;
    data['TaxAmount'] = taxAmount;
    data['ProfitLoss'] = profitLoss;

    return data;
  }
}

class ProfitLossTotals {
  double? totalQtyTotal;
  double? billAmtTotal;
  double? marginTotal;
  double? taxAmountTotal;
  double? profitLossTotal;

  ProfitLossTotals({
    this.totalQtyTotal,
    this.billAmtTotal,
    this.marginTotal,
    this.taxAmountTotal,
    this.profitLossTotal,
  });

  ProfitLossTotals.fromJson(Map<String, dynamic> json) {
    totalQtyTotal = (json['TotalQtyTotal'] as num?)?.toDouble();
    billAmtTotal = (json['BillAmtTotal'] as num?)?.toDouble();
    marginTotal = (json['MarginTotal'] as num?)?.toDouble();
    taxAmountTotal = (json['TaxAmountTotal'] as num?)?.toDouble();
    profitLossTotal = (json['ProfitLossTotal'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['TotalQtyTotal'] = totalQtyTotal;
    data['BillAmtTotal'] = billAmtTotal;
    data['MarginTotal'] = marginTotal;
    data['TaxAmountTotal'] = taxAmountTotal;
    data['ProfitLossTotal'] = profitLossTotal;

    return data;
  }
}
