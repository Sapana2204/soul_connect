class AppUrls {
  static const baseUrl = "https://prodapi.soulconnecterp.com/api";
  //static const baseUrl = "https://devapi.soulconnecterp.com/api";
  static const loginEndPoint = "$baseUrl/user/SignIn";
  static const getCategoryMasterUrl = "$baseUrl/category";
  static const getItemMasterUrl = "$baseUrl/item";
  static const getExtraChargeMasterUrl = "$baseUrl/invoicecharge";
  static const getCropMasterUrl = "$baseUrl/crop";
  static const getPartyUrl = "$baseUrl/party/C";
  static const getRateTypeUrl = "$baseUrl/sales/get_ratetypes";
  static const getBillTypeUrl = "$baseUrl/sales/get_billtypes/Sales";
  static const getItemsByProductTypeUrl =
      "$baseUrl/item/GetItemsByProductType/{stockDate}";
  static const getItemSalesDetailsUrl = "$baseUrl/item/GetItemSalesDetails";
  static const getStockLocationsByUserUrl =
      "$baseUrl/stock/GetStockLocationsByUser";
  static const getStkLocationsUrl = "$baseUrl/stock/StockLocations";
  static const getLedgerBalanceUrl = "$baseUrl/accledger/balance";
  static const getLedgerTypeUrl = "$baseUrl/accledger?ledgerType=B";
  static const getFreightPostageLedgerUrl =
      "$baseUrl/accledger?IsFreightPostageAcc=true";
  static const getPurchaseById = "$baseUrl/purchase";

  // static const getSalesDashboardUrl = "$baseUrl/sales/get_sales_by_date/{fromDate}/{toDate}/{userId}";
  static String getSalesDashboardUrl(
      String fromDate, String toDate, int userId) {
    return "$baseUrl/sales/get_sales_by_date/$fromDate/$toDate/$userId";
  }

  // static String getSalesById(int id) {
  //   return "$baseUrl/sales/get_salesById/$id";
  // }

  static const String getSalesById = "$baseUrl/sales/get_salesById";
  static const String getSalesByFilter = "$baseUrl/sales/get_phSalesByFilter";
  static const String getSalesReturnById =
      "$baseUrl/salesreturn/getSalesReturns?returnId=";

  static const String addSaleUrl = "$baseUrl/sales/add_sale";
  static const String updateSaleUrl = "$baseUrl/sales/update_sale";
  static const String deleteSaleUrl = "$baseUrl/sales/{salesId}";
  static const String deleteSalesReturnUrl = "$baseUrl/salesreturn/{id}";

  static const String getStatesUrl = "$baseUrl/party/states";
  static const String addPartyUrl = "$baseUrl/party";
  static const String salesInvoicePrintUrl =
      "$baseUrl/report/phsalesinvoiceheaderprint";
  static const String getAllTaxGroupPercentageUrl =
      "${baseUrl}/tax/api/tax/get_All_TaxGroup_Percentage";
  static const getPurchaseItemDetailsUrl =
      "$baseUrl/item/GetItemPurchaseDetails";
  static const deletePurchase = "$baseUrl/purchase/{id}";
  static const addPurchase = "$baseUrl/purchase";
  static const getPurchasePartyUrl = "$baseUrl/party/S";
  static const getItemsUrl = "$baseUrl/item";
  static const getAccLedgersByGroupId = "$baseUrl/accledger";
  static const addVouchersUrl = "$baseUrl/accountvoucher/add_voucher";
  static const getVouchersUrl = "$baseUrl/accountvoucher/get_allvouchers";
  static const updateVouchersUrl = "$baseUrl/accountvoucher/update_voucher";
  static const deleteVouchersUrl =
      "$baseUrl/accountvoucher/delete_voucher/{id}";
  static const updatePurchase = "$baseUrl/purchase/UpdatePurchase";
  static const getPurchaseChallan = "$baseUrl/purchase/get_PhPurchaseChallans";

// static const getCashAccountByGroupIdUrl = "$baseUrl/accledger/?GroupId=11";
  // static const getBankAccountsByGroupIdUrl = "$baseUrl/accledger/?GroupId=7";

  //Aditya
  static String getDashboardUrl(String date) {
    return "$baseUrl/Dashboard/summary?summaryDate=$date";
  }

  static String getSalesSummaryUrl(String fromDate, String toDate) {
    return "$baseUrl/report/phsalessummaryreport?fromDate=$fromDate&toDate=$toDate&userId=1";
  }

  static String getPurchaseUrl(String fromDate, String toDate) {
    return "$baseUrl/report/phpurchasesummaryreport?fromDate=$fromDate&toDate=$toDate&userId=1";
  }

  static String getProductExpiryUrl(String fromDate, String toDate) {
    return "$baseUrl/Dashboard/expiring?StockFromDate=$fromDate&StockToDate=$toDate&PageName=dashboard";
  }

  static String getPurchaseReturn(String returnFromDate, String returnToDate) {
    return "$baseUrl/purchasereturn/getPhPurchaseReturn?ReturnFromDate=$returnFromDate&ReturnToDate=$returnToDate";
  }

  static String getSalesReturn(String returnFromDate, String returnToDate) {
    return "$baseUrl/salesreturn/getSalesReturns?returnFromDate=$returnFromDate&returnToDate=$returnToDate";
  }

  static String getOutstandingReport(String date, int groupId) {
    return "$baseUrl/report/sundrydebtorscreditorsbalance?balanceDate=$date&groupId=$groupId";
  }

  static String getstockReportUrl(String fromDate, String toDate) {
    return "$baseUrl/report/stockstatement/$fromDate/$toDate";
  }

  static String getOpeningClosingBalance({
    required int ledgerId,
    required String balanceAsOn,
    required String balanceType,
  }) {
    return "$baseUrl/accledger/balance/$ledgerId/$balanceAsOn"
        "?balanceType=$balanceType";
  }

  static String getLedgerType(String ledgerType) =>
      "$baseUrl/accledger?ledgerType=$ledgerType";

  static const getPurchaseDashboardUrl =
      "$baseUrl/purchase/GetAllPurchases/{fromDate}/{toDate}";

  static const getAllPhPurchasesFilter =
      "$baseUrl/purchase/getAllPhPurchasesFilter";

  static const getDeliveryChallanDashboardUrl =
      "$baseUrl/DeliveryChallan/getDeliveryChallan";

  static const getItemUnitConvertedUrl = "$baseUrl/item/GetItemUnitConverted";
  static const addDeliveryChallan =
      "$baseUrl/DeliveryChallan/addDeliveryChallan";
  static const updateDeliveryChallan =
      "$baseUrl/DeliveryChallan/updateDeliveryChallan";
  static const deleteDeliveryChallan =
      "$baseUrl/DeliveryChallan/deleteDeliveryChallan/{challanId}/{id}";
  static const getDeliveryChallanById =
      "$baseUrl/DeliveryChallan/getDeliveryChallan";
  static const getPurchaseReturnById =
      "$baseUrl/purchasereturns/getPhPurchaseReturnByReturnId";
  static const getStockItemsForPurchaseReturn =
      "$baseUrl/purchasereturns/getStockPhItemsForPurchaseReturn";
  static const getItemDetailsForPurchaseReturn =
      "$baseUrl/purchaseReturn/getPurchaseReturnItemDetails";
  static const addPurchaseReturn = "$baseUrl/purchasereturn/addPurchaseReturn";
  static const updatePurchaseReturn =
      "$baseUrl/purchasereturns/updatePhPurchaseReturn";
  static const deletePurchaseReturn = "$baseUrl/purchasereturns/{id}";
  static const profitLossReport = "$baseUrl/report/ProfitLossStatementGrouped";
  static const itemLedgerReport = "$baseUrl/report/itemledger";
  static const phPurchaseDetailsReport =
      "$baseUrl/report/phpurchasedetailsreport";
  static const phSalesDetailsReport = "$baseUrl/report/phsalesdetailreport";
  static const customerForCustomerStatement = "$baseUrl/party";
  static const customerStatementSummary =
      "$baseUrl/report/phcustomerstatementsummary";
  static String getStockPhItemsForSalesReturn({
    required String stockDate,
    required String locationId,
    required int customerId,
  }) {
    return '$baseUrl/salesreturn/getStockPhItemsForSalesReturn'
        '?stockDate=$stockDate'
        '&locationId=$locationId'
        '&customerId=$customerId';
  }

  /// ADD SALES RETURN
  static String addSalesReturn = "$baseUrl/salesreturn/addSalesReturn";

  static String getItemDetailsForSalesReturn({
    int? itemId,
    required int locationId,
    required int customerId,
  }) {
    return "$baseUrl/salesreturn/getItemDetailsForSalesReturn"
        "?itemId=$itemId"
        "&locationId=$locationId"
        "&customerId=$customerId";
  }

  static const String updateSaleReturnUrl =
      "$baseUrl/salesreturn/updateSalesReturn";

  //Stock vouchers
  static const String getStockIssue = "$baseUrl/stockissue/GetStockIssue";
  static const String addStockIssue = "$baseUrl/stockissue/AddStockIssue";
  static const String updateStockIssue = "$baseUrl/stockissue/UpdateStockIssue";
  static const String deleteStockIssue = "$baseUrl/stockissue/DeleteStockIssue";
  static const String getStockInward = "$baseUrl/stock/GetStockInwards";
  static const String getIssueVoucher = "$baseUrl/stock/GetStockInwards";
  static const String getStockIssueForInward =
      "$baseUrl/stock/GetStockIssueForInward";
  static const String addStockInward = "$baseUrl/stock/AddStockInward";
  static const String deleteStockInward = "$baseUrl/stock/DeleteStockInward";
  static const String getExpiryVoucher = "$baseUrl/PhExpiry/getExpiry";
  static const String deleteExpiryVoucher = "$baseUrl/PhExpiry/deleteExpiry";
  static const String getExpiringDashboard = "$baseUrl/Dashboard/expiring";
  static const String addExpiryVoucher = "$baseUrl/PhExpiry/addExpiry";
  static const String updateExpiryVch = "$baseUrl/PhExpiry/updateExpiry";

  //Purchase Challans
  static const String getPurchaseChallans =
      "$baseUrl/purchase/get_PhPurchaseChallans?fromDate={fromDate}&toDate={toDate}";
  static const String getReceiptReport = "$baseUrl/accountvoucher/get_receipts";

  static const String getRateTypesUrl = "$baseUrl/sales/get_ratetypes";
}
