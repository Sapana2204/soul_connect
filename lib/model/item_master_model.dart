class ItemMasterModel {
  int? itemId;
  String? itemName;
  String? createdOn;
  String? itemCode;
  int? manfId;
  int? suppId;
  int? cateId;
  String? hsnCode;
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
  double? packingSize;
  String? packing;
  String? contents;
  String? usedAs;
  String? itemCategory;
  String? itemCompany;
  bool? isItemShowsInStock;
  bool? isHardwareItem;
  int? createdBy;

  double? lastPurchaseRateAlt;
  double? lastCashSales;
  double? lastCreditSales;
  double? lastOutletSales;
  double? lastMrp;
  String? lastPurchaseDate;
  double? lastPurchaseQty;

  double? cashRateMargin;
  double? creditRateMargin;
  double? outletRateMargin;

  String? displayName;
  bool? isGatePass;
  String? unitName;
  String? taxGroupName;
  String? taxPercent;

  int? isCgst;
  int? isIgst;
  int? isSgst;

  ItemMasterModel({
    this.itemId,
    this.itemName,
    this.createdOn,
    this.itemCode,
    this.manfId,
    this.suppId,
    this.cateId,
    this.hsnCode,
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
    this.packingSize,
    this.packing,
    this.contents,
    this.usedAs,
    this.itemCategory,
    this.itemCompany,
    this.isItemShowsInStock,
    this.isHardwareItem,
    this.createdBy,
    this.lastPurchaseRateAlt,
    this.lastCashSales,
    this.lastCreditSales,
    this.lastOutletSales,
    this.lastMrp,
    this.lastPurchaseDate,
    this.lastPurchaseQty,
    this.cashRateMargin,
    this.creditRateMargin,
    this.outletRateMargin,
    this.displayName,
    this.isGatePass,
    this.unitName,
    this.taxGroupName,
    this.taxPercent,
    this.isCgst,
    this.isIgst,
    this.isSgst,
  });

  /// 🔥 Helper to safely convert int/double → double
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    return (value as num).toDouble();
  }

  ItemMasterModel.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    itemName = json['ItemName'];
    createdOn = json['CreatedOn'];
    itemCode = json['ItemCode'];
    manfId = json['ManfId'];
    suppId = json['SuppId'];
    cateId = json['CateId'];
    hsnCode = json['HSNCode'];
    minLevel = json['MinLevel'];
    maxLevel = json['MaxLevel'];
    reorderLevel = json['ReorderLevel'];
    shelf = json['Shelf'];
    unitId = json['UnitId'];
    isActive = json['IsActive'];
    taxGroupId = json['TaxGroupId'];
    schedule = json['Schedule'];
    productType = json['ProductType'];
    packing = json['Packing'];
    contents = json['Contents'];
    usedAs = json['UsedAs'];
    itemCategory = json['ItemCategory'];
    itemCompany = json['ItemCompany'];
    isItemShowsInStock = json['IsItemShowsInStock'];
    isHardwareItem = json['IsHardwareItem'];
    createdBy = json['CreatedBy'];

    /// ✅ Safe double conversions
    lastPurchaseRate = _toDouble(json['LastPurchaseRate']);
    packingSize = _toDouble(json['PackingSize']);

    lastPurchaseRateAlt = _toDouble(json['LAST_PURCHASERATE']);
    lastCashSales = _toDouble(json['LAST_CASHSALES']);
    lastCreditSales = _toDouble(json['LAST_CREDITSALES']);
    lastOutletSales = _toDouble(json['LAST_OUTLETSALES']);
    lastMrp = _toDouble(json['LAST_MRP']);
    lastPurchaseQty = _toDouble(json['LAST_PURCHASEQTY']);

    cashRateMargin = _toDouble(json['CashRateMargin']);
    creditRateMargin = _toDouble(json['CreditRateMargin']);
    outletRateMargin = _toDouble(json['OutletRateMargin']);

    /// Other fields
    lastPurchaseDate = json['LAST_PURCHASEDATE'];
    displayName = json['DisplayName'];
    isGatePass = json['IsGatePass'];
    unitName = json['UnitName'];
    taxGroupName = json['TaxGroupName'];

    /// ⚠️ Fix: correct key from API
    taxPercent = json['TaxPer']?.toString();

    isCgst = json['IsCGST'];
    isIgst = json['IsIGST'];
    isSgst = json['IsSGST'];
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemId': itemId,
      'ItemName': itemName,
      'CreatedOn': createdOn,
      'ItemCode': itemCode,
      'ManfId': manfId,
      'SuppId': suppId,
      'CateId': cateId,
      'HSNCode': hsnCode,
      'MinLevel': minLevel,
      'MaxLevel': maxLevel,
      'ReorderLevel': reorderLevel,
      'Shelf': shelf,
      'UnitId': unitId,
      'IsActive': isActive,
      'LastPurchaseRate': lastPurchaseRate,
      'TaxGroupId': taxGroupId,
      'Schedule': schedule,
      'ProductType': productType,
      'PackingSize': packingSize,
      'Packing': packing,
      'Contents': contents,
      'UsedAs': usedAs,
      'ItemCategory': itemCategory,
      'ItemCompany': itemCompany,
      'IsItemShowsInStock': isItemShowsInStock,
      'IsHardwareItem': isHardwareItem,
      'CreatedBy': createdBy,
      'LAST_PURCHASERATE': lastPurchaseRateAlt,
      'LAST_CASHSALES': lastCashSales,
      'LAST_CREDITSALES': lastCreditSales,
      'LAST_OUTLETSALES': lastOutletSales,
      'LAST_MRP': lastMrp,
      'LAST_PURCHASEDATE': lastPurchaseDate,
      'LAST_PURCHASEQTY': lastPurchaseQty,
      'CashRateMargin': cashRateMargin,
      'CreditRateMargin': creditRateMargin,
      'OutletRateMargin': outletRateMargin,
      'DisplayName': displayName,
      'IsGatePass': isGatePass,
      'UnitName': unitName,
      'TaxGroupName': taxGroupName,
      'TaxPercent': taxPercent,
      'IsCGST': isCgst,
      'IsIGST': isIgst,
      'IsSGST': isSgst,
    };
  }
}