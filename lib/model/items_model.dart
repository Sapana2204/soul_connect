class ItemsModel {
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
  double? lASTPURCHASERATE;
  double? lASTCASHSALES;
  double? lASTCREDITSALES;
  double? lASTOUTLETSALES;
  double? lASTMRP;
  String? lASTPURCHASEDATE;
  double? lASTPURCHASEQTY;
  double? cashRateMargin;
  double? creditRateMargin;
  double? outletRateMargin;
  String? displayName;
  bool? isGatePass;
  String? unitName;
  String? taxGroupName;
  String? taxGroupDtls;
  String? taxPer;
  double? baseRate;
  String? barcode;

  ItemsModel({
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
    this.lASTPURCHASERATE,
    this.lASTCASHSALES,
    this.lASTCREDITSALES,
    this.lASTOUTLETSALES,
    this.lASTMRP,
    this.lASTPURCHASEDATE,
    this.lASTPURCHASEQTY,
    this.cashRateMargin,
    this.creditRateMargin,
    this.outletRateMargin,
    this.displayName,
    this.isGatePass,
    this.unitName,
    this.taxGroupName,
    this.taxGroupDtls,
    this.taxPer,
    this.baseRate,
    this.barcode,
  });

  ItemsModel.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    itemName = json['ItemName'];
    itemCode = json['ItemCode'];
    manfId = json['ManfId'];
    suppId = json['SuppId'];
    cateId = json['CateId'];
    hSNCode = json['HSNCode'];
    minLevel = json['MinLevel'];
    maxLevel = json['MaxLevel'];
    reorderLevel = json['ReorderLevel'];
    shelf = json['Shelf'];
    unitId = json['UnitId'];
    isActive = json['IsActive'];
    lastPurchaseRate = (json['LastPurchaseRate'] as num?)?.toDouble();
    taxGroupId = json['TaxGroupId'];
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
    createdBy = json['CreatedBy'];
    createdOn = json['CreatedOn'];
    updatedBy = json['UpdatedBy'];
    updatedOn = json['UpdatedOn'];
    lASTPURCHASERATE = (json['LAST_PURCHASERATE'] as num?)?.toDouble();
    lASTCASHSALES = (json['LAST_CASHSALES'] as num?)?.toDouble();
    lASTCREDITSALES = (json['LAST_CREDITSALES'] as num?)?.toDouble();
    lASTOUTLETSALES = (json['LAST_OUTLETSALES'] as num?)?.toDouble();
    lASTMRP = (json['LAST_MRP'] as num?)?.toDouble();
    lASTPURCHASEDATE = json['LAST_PURCHASEDATE'];
    lASTPURCHASEQTY = (json['LAST_PURCHASEQTY'] as num?)?.toDouble();
    cashRateMargin = (json['CashRateMargin'] as num?)?.toDouble();
    creditRateMargin = (json['CreditRateMargin'] as num?)?.toDouble();
    outletRateMargin = (json['OutletRateMargin'] as num?)?.toDouble();
    displayName = json['DisplayName'];
    isGatePass = json['IsGatePass'];
    unitName = json['UnitName'];
    taxGroupName = json['TaxGroupName'];
    taxGroupDtls = json['TaxGroupDtls'];
    taxPer = json['TaxPer'];
    baseRate = (json['BaseRate'] as num?)?.toDouble();
    barcode = (json['BarCode'] );
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
    data['LAST_PURCHASERATE'] = lASTPURCHASERATE;
    data['LAST_CASHSALES'] = lASTCASHSALES;
    data['LAST_CREDITSALES'] = lASTCREDITSALES;
    data['LAST_OUTLETSALES'] = lASTOUTLETSALES;
    data['LAST_MRP'] = lASTMRP;
    data['LAST_PURCHASEDATE'] = lASTPURCHASEDATE;
    data['LAST_PURCHASEQTY'] = lASTPURCHASEQTY;
    data['CashRateMargin'] = cashRateMargin;
    data['CreditRateMargin'] = creditRateMargin;
    data['OutletRateMargin'] = outletRateMargin;
    data['DisplayName'] = displayName;
    data['IsGatePass'] = isGatePass;
    data['UnitName'] = unitName;
    data['TaxGroupName'] = taxGroupName;
    data['TaxGroupDtls'] = taxGroupDtls;
    data['TaxPer'] = taxPer;
    data['BaseRate'] = baseRate;
    data['BarCode'] = barcode;
    return data;
  }
}
