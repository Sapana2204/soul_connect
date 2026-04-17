class StockItemsForPurchaseReturnModel {
  int? itemId;
  String? itemName;
  String? itemCode;
  int? manfId;
  int? suppId;
  int? cateId;
  String? hSNCode;
  int? minLevel;
  int? maxLevel;
  int? reorderLevel;
  String? shelf;
  int? unitId;
  bool? isActive;

  double? lastPurchaseRate;
  int? taxGroupId;

  String? schedule;
  String? productType;
  String? packing;
  double? packingSize;

  String? contents;
  String? usedAs;
  String? itemCategory;
  String? itemCompany;
  bool? isItemShowsInStock;
  bool? isHardwareItem;
  int? createdBy;
  String? createdOn;
  int? updatedBy;
  String? updatedOn;

  dynamic lastPurchaseRateValue;
  dynamic lastPurchaseTaxRate;
  dynamic lastCashSales;
  dynamic lastCreditSales;
  dynamic lastOutletSales;
  dynamic lastMRP;
  dynamic lastPurchaseDate;
  dynamic lastPurchaseQty;

  double? cashRateMargin;
  double? creditRateMargin;
  double? outletRateMargin;

  String? displayName;
  bool? isGatePass;
  bool? isCombiItem;
  int? combiId;
  String? manufacture;
  String? manufacturer;
  String? unitName;
  String? taxGroupName;
  String? taxGroupDtls;

  double? taxPer;
  int? purchaseId;
  double? rate;
  String? batchNo;

  StockItemsForPurchaseReturnModel({
    this.itemId,
    this.itemName,
    this.itemCode,
    this.manfId,
    this.suppId,
    this.cateId,
    this.hSNCode,
    this.minLevel,
    this.maxLevel,
    this.reorderLevel,
    this.shelf,
    this.unitId,
    this.isActive,
    this.lastPurchaseRate,
    this.taxGroupId,
    this.schedule,
    this.productType,
    this.packing,
    this.packingSize,
    this.contents,
    this.usedAs,
    this.itemCategory,
    this.itemCompany,
    this.isItemShowsInStock,
    this.isHardwareItem,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.lastPurchaseRateValue,
    this.lastPurchaseTaxRate,
    this.lastCashSales,
    this.lastCreditSales,
    this.lastOutletSales,
    this.lastMRP,
    this.lastPurchaseDate,
    this.lastPurchaseQty,
    this.cashRateMargin,
    this.creditRateMargin,
    this.outletRateMargin,
    this.displayName,
    this.isGatePass,
    this.isCombiItem,
    this.combiId,
    this.manufacture,
    this.manufacturer,
    this.unitName,
    this.taxGroupName,
    this.taxGroupDtls,
    this.taxPer,
    this.purchaseId,
    this.rate,
    this.batchNo,
  });

  StockItemsForPurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    itemId = (json['ItemId'] as num?)?.toInt();
    itemName = json['ItemName'];
    itemCode = json['ItemCode'];
    manfId = (json['ManfId'] as num?)?.toInt();
    suppId = (json['SuppId'] as num?)?.toInt();
    cateId = (json['CateId'] as num?)?.toInt();
    hSNCode = json['HSNCode'];
    minLevel = (json['MinLevel'] as num?)?.toInt();
    maxLevel = (json['MaxLevel'] as num?)?.toInt();
    reorderLevel = (json['ReorderLevel'] as num?)?.toInt();
    shelf = json['Shelf'];
    unitId = (json['UnitId'] as num?)?.toInt();
    isActive = json['IsActive'];

    lastPurchaseRate = (json['LastPurchaseRate'] as num?)?.toDouble();
    taxGroupId = (json['TaxGroupId'] as num?)?.toInt();

    schedule = json['Schedule'];
    productType = json['ProductType'];
    packing = json['Packing'];
    packingSize = (json['PackingSize'] as num?)?.toDouble();

    contents = json['Contents'];
    usedAs = json['UsedAs'];
    itemCategory = json['ItemCategory'];
    itemCompany = json['ItemCompany'];
    isItemShowsInStock = json['IsItemShowsInStock'];
    isHardwareItem = json['IsHardwareItem'];
    createdBy = (json['CreatedBy'] as num?)?.toInt();
    createdOn = json['CreatedOn'];
    updatedBy = (json['UpdatedBy'] as num?)?.toInt();
    updatedOn = json['UpdatedOn'];

    lastPurchaseRateValue = json['LastPurchaseRateValue'];
    lastPurchaseTaxRate = json['LastPurchaseTaxRate'];
    lastCashSales = json['LastCashSales'];
    lastCreditSales = json['LastCreditSales'];
    lastOutletSales = json['LastOutletSales'];
    lastMRP = json['LastMRP'];
    lastPurchaseDate = json['LastPurchaseDate'];
    lastPurchaseQty = json['LastPurchaseQty'];

    cashRateMargin = (json['CashRateMargin'] as num?)?.toDouble();
    creditRateMargin = (json['CreditRateMargin'] as num?)?.toDouble();
    outletRateMargin = (json['OutletRateMargin'] as num?)?.toDouble();

    displayName = json['DisplayName'];
    isGatePass = json['IsGatePass'];
    isCombiItem = json['IsCombiItem'];
    combiId = (json['CombiId'] as num?)?.toInt();
    manufacture = json['Manufacture'];
    manufacturer = json['Manufacturer'];
    unitName = json['UnitName'];
    taxGroupName = json['TaxGroupName'];
    taxGroupDtls = json['TaxGroupDtls'];

    taxPer = (json['TaxPer'] as num?)?.toDouble();
    purchaseId = (json['PurchaseId'] as num?)?.toInt();
    rate = (json['Rate'] as num?)?.toDouble();
    batchNo = json['BatchNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['ItemId'] = itemId;
    data['ItemName'] = itemName;
    data['ItemCode'] = itemCode;
    data['ManfId'] = manfId;
    data['SuppId'] = suppId;
    data['CateId'] = cateId;
    data['HSNCode'] = hSNCode;
    data['MinLevel'] = minLevel;
    data['MaxLevel'] = maxLevel;
    data['ReorderLevel'] = reorderLevel;
    data['Shelf'] = shelf;
    data['UnitId'] = unitId;
    data['IsActive'] = isActive;
    data['LastPurchaseRate'] = lastPurchaseRate;
    data['TaxGroupId'] = taxGroupId;
    data['Schedule'] = schedule;
    data['ProductType'] = productType;
    data['Packing'] = packing;
    data['PackingSize'] = packingSize;
    data['Contents'] = contents;
    data['UsedAs'] = usedAs;
    data['ItemCategory'] = itemCategory;
    data['ItemCompany'] = itemCompany;
    data['IsItemShowsInStock'] = isItemShowsInStock;
    data['IsHardwareItem'] = isHardwareItem;
    data['CreatedBy'] = createdBy;
    data['CreatedOn'] = createdOn;
    data['UpdatedBy'] = updatedBy;
    data['UpdatedOn'] = updatedOn;
    data['LastPurchaseRateValue'] = lastPurchaseRateValue;
    data['LastPurchaseTaxRate'] = lastPurchaseTaxRate;
    data['LastCashSales'] = lastCashSales;
    data['LastCreditSales'] = lastCreditSales;
    data['LastOutletSales'] = lastOutletSales;
    data['LastMRP'] = lastMRP;
    data['LastPurchaseDate'] = lastPurchaseDate;
    data['LastPurchaseQty'] = lastPurchaseQty;
    data['CashRateMargin'] = cashRateMargin;
    data['CreditRateMargin'] = creditRateMargin;
    data['OutletRateMargin'] = outletRateMargin;
    data['DisplayName'] = displayName;
    data['IsGatePass'] = isGatePass;
    data['IsCombiItem'] = isCombiItem;
    data['CombiId'] = combiId;
    data['Manufacture'] = manufacture;
    data['Manufacturer'] = manufacturer;
    data['UnitName'] = unitName;
    data['TaxGroupName'] = taxGroupName;
    data['TaxGroupDtls'] = taxGroupDtls;
    data['TaxPer'] = taxPer;
    data['PurchaseId'] = purchaseId;
    data['Rate'] = rate;
    data['BatchNo'] = batchNo;
    return data;
  }
}
