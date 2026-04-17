class Strings {
  // Standard Strings //

  static String get dateString => DateTime.now().toString().substring(0, 10);
  static const String exit = 'Exit';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String started = 'Get Started';
  static const String inputContactHint = 'Contact Number';
  static const String searchBarHint = 'Search here...';
  static const String noData = 'No data available';
  // DashBoard //

  static const String dashboardAppBar = 'Welcome User!';
  static const String dashboardSalesCardTitle = 'Sales';
  static const String dashboardPurchaseCardTitle = 'Purchase';
  static const String dashboardCash = 'Cash';
  static const String dashboardCredit = 'Credit';
  static const String dashboardBank = 'Bank';
  static const String dashboardStockCardH = 'Total Stock : ';
  static const String dashboardTab1 = 'Customers';
  static const String dashboardTab2 = 'Suppliers';
  static const String dashboardPartyHeading1 = 'Name';
  static const String dashboardPartyHeading2 = 'Outstanding';
  static const String dashboardPartyHeading3 = 'Contact';

  static const String dashboardPartyTotal = 'Total Outstanding : ';
  static const String dashboardProductHeading1 = 'Product Expiry';
  static const String dashboardProductHeading2 = 'Total Items : ';
  static const String dashboardProductHeading3 = 'Items Expiring Soon';
  static const String dashboardProductRow1 = 'Product';
  static const String dashboardProductRow2 = 'HSN';
  static const String dashboardProductRow3 = 'Batch';
  static const String dashboardProductRow4 = 'Expiry';

  // Sales Dashboard //

  static const String salesAppBar = 'Sales Dashboard';

  static const String stockLocHeading = 'Welcome to Sales';
  static const String stockLocSubHeading = 'Select Stock Location';
  static const String stockLocation = 'Stock Location';
  static const String stockLocSubHead2 =
      'Choose your working location to continue with the sales invoice.';
  static const String stickLocSubHead3 =
      'This will be used for inventory tracking.';
  static const String stickLocSnackText = 'Please select a stock location.';
  static const String existItemSnack = 'Item already exists in invoice.';
  static const String salesInvoiceAppbar1 = 'Edit Sales (Invoice)';
  static const String salesInvoiceAppbar2 = 'Sales (Invoice)';
  static const String salesReturnAppbar1 = 'Sales Return';
  static const String addReturn = 'Add Return';
  static const String salesInvoiceSearch = 'Customer Name';
  static const String salesInvoiceProductBar = 'Select Product';
  static const String salesInvoiceSnackText = 'Please add at least one product';
  static const String selectBillDetailsSnack = "Please select bill details";
  static const String selectProductStockLine = 'Available Stock';
  static const String stock = 'Stock';
  static const String selectProductNoStock = 'No stock available';
  static const String selectProductSearchText = 'Search product...';
  static const String selectCustomerHeading = 'Select Customer';
  static const String selectCustomerHand = 'By Hand';
  static const String selectCustomerSnackText = 'Please select a customer';
  static const String selectBillDetails = "Select Bill Details";
  static const String outstanding = "Outstanding:";
  static const String creditLimit = "Credit Limit";
  static const String noSelectedProduct = "No selected product to display";
  static const String totalQty = "Total Qty";
  static const String qty = "Qty";
  static const String freeQty = "Free Qty";
  static const String subTotal = "SubTotal";
  static const String tax = "Tax";
  static const String totalDisc = "Total Disc";
  static const String discAmt = "Disc Amt";
  static const String discPercent = "Disc (%)";
  static const String taxPerc = "Tax (%)";
  static const String taxableAmt = "Taxable Amt";
  static const String taxAmt = "Tax Amt";
  static const String totalAmt = "Total Amt";
  static const String freight = "Freight";
  static const String grossTotal = "Gross Total";
  static const String netTotal = "Net Total";
  static const String roundOff = "Round Off";
  static const String netBillAmount = "Net Bill Amount";
  static const String billDetails = "Bill details";
  static const String billType = "Bill Type";
  static const String rateType = "Rate Type";
  static const String payMode = "Pay Mode";
  static const String taxType = "Tax Type";
  static const String rate = "Rate";
  static const String purchaseRate = "Purchase Rate";
  static const String confirmDelete = "Confirm Delete";

  // Sales Invoice Messages
  static const String partyFetchError = "Failed to fetch party list";
  static const String rateTypeFetchError = "Failed to fetch rate types";
  static const String billTypeFetchError = "Failed to fetch bill types";
  static const String ledgerBalanceFetchError = "Failed to fetch ledger balance";
  static const String taxGroupFetchError = "Failed to fetch tax group percentage";
  static const String rateCantZero = "Rate cannot be 0";
  static const String qtyCantZero = "Quantity cannot be empty or 0";

  // Purchase Dashboard //
  static const String purchaseAppBar = 'Purchase Dashboard';
  static const String purchaseSearchHint = 'Search by supplier or ID...';
  static const String purchaseInvoiceBar3 = 'Update Purchase Inward';
  static const String purchaseInvoiceBar4 = 'Purchase Inward';
  static const String purchaseInvoiceSelectSupplierText =
      'Tap to select supplier';
  static const String purchaseInvoiceSnackText1 =
      'Please select a supplier first';
  static const String purchaseInvoiceSnackText2 =
      'Unable to fetch ledger balance';

  // Delivery Challan Dashboard //
  static const String deliveryChallanAppBar = 'Delivery Challans';

// Purchase Messages //

  static const String purchaseSelectSupplierError =
      'Please select supplier';

  static const String purchaseAddProductError =
      'Please add at least one product';

  static const String purchaseSaveSuccess =
      'Purchase saved successfully';



  static const String purchaseSaveFailed =
      'Failed to save purchase';


  // Home Screen

  static const String appName = 'SoulConnect';
  static const String companyName = 'Soulsoft Infotech PVT. LTD.';

  static const String navPurchase = 'Purchase';
  static const String navPayment = 'Payment';
  static const String navReceipt = 'Receipt';
  static const String navSales = 'Sales';
  static const String navDashboard = 'Dashboard';

  static const String createPurchase = '+ New Purchase';
  static const String createSales = '+ New Sales';
  static const String createPayment = '+ Create Payment';
  static const String createReceipt = '+ Create Receipt';

  // Purchase Inward Screen //

  static const String purchaseSupplierChanged =
      'Supplier changed. Products cleared';

  static const String purchaseOutstandingBalance =
      'Outstanding Balance';

  static const String purchaseSelectSupplier = 'Select Supplier';

  static const String purchaseSelectProduct = 'Select Product';

  static const String purchaseNoProductsSelected =
      'No products selected';

  static const String purchaseInvoiceSummary =
      'Invoice Summary';

  static const String purchaseItemTotal = 'Item Total';

  static const String purchaseNetBill = 'Net Bill';

  static const String purchaseFinalPurchase = 'Net Bill Amt';

  static const String purchaseFinalPurchaseAmount =
      'Final Purchase Amount';

  static const String purchaseProductBatchExists =
      'This product batch is already added';

  static const String purchaseExpiredProduct =
      'Cannot add expired products';

  static const String purchaseExpiredProductMessage =
      "Cannot add expired products.\nExpiry date ({date}) is before today's date.";

  // Product Detail Dialog //

  static const String batchNo = 'Batch No';
  static const String expiry = 'Expiry';
  static const String quantity = 'Quantity';
  static const String mrp = 'MRP';
  static const String hsn = 'HSN';
  static const String schemePercent = 'Scheme (%)';
  static const String schemeAmt = 'Scheme Amt';
  static const String taxPercent = 'Tax (%)';
  static const String totalTaxAmtLabel = 'Total Tax Amt';
  static const String netAmount = 'Net Amount';

  // Purchase Supplier Popup //

  static const String supplierDetails = 'Supplier Details';
  static const String selectLocation = 'Select Location';
  static const String selectSupplier = 'Select Supplier';
  static const String next = 'Next';
  static const String paymentTerm = 'Payment Term';
  static const String enterPaymentTerm = 'Enter Payment Term (1-30 days)';
  static const String unknown = 'Unknown';

// Tax Types
  static const String taxExclusive = 'Exclusive';
  static const String taxInclusive = 'Inclusive';
  static const String taxNoTax = 'No Tax';

// Pay Modes
  static const String payModeCash = 'Cash';
  static const String payModeCredit = 'Credit';

  // Purchase Item Details Popup //

  static const String itemDetails = 'Item Details *';
  static const String batch = 'Batch';
  static const String expiryLabel = 'Expiry';
  static const String gstLabel = 'GST (%)';
  static const String qtyShort = 'Qty';
  static const String freeShort = 'Free';
  static const String rateLabel = 'Rate';
  static const String withGst = 'With GST';
  static const String taxable = 'Taxable';
  static const String schemeDiscount = 'Free, Scheme & Discount';
  static const String scheme = 'Scheme';
  static const String discount = 'Discount';
  static const String percentSymbol = '(%):';
  static const String amountShort = 'Amt';
  static const String totalShort = 'Total';
  static const String totalLabel = 'Total';
  static const String setBarcode = 'Set Barcode';
  static const String barcode = 'Barcode';
  static const String salesRate = 'Sales Rate';
  static const String addItem = 'Add Item';
  static const String outlet = 'Outlet';
  static const String validationMsgforAddItem =
      "Cash, Credit and Outlet rates must be less than or equal to MRP";

// Snackbars / Validations


  static String creditRateValidationMsg(double credit, double actualRate) =>
      "Credit Rate (₹$credit) must be greater than Actual Rate (₹$actualRate).";

  static String creditLimitExceededMsg(double limit) =>
      "Outstanding amount exceeds credit limit of ₹ $limit. Please adjust the sale amount.";

  // Purchase Select Product Popup
  static const String selectProductTitle = "Select Product";
  static const String chooseProductAndBatch = "Choose product & batch";
  static const String selectProductHint = "Select Product";
  static const String searchProductHint = "Search product...";

  static const String availableBatches = "Available Batches";
  static const String noProductSelected = "No product selected";
  static const String noBatch = "No Batch";
  static const String select = "Select";

  static const String createNewBatch = "Create New Batch";
  static const String pleaseSelectProductFirst = "Please select a product first";

  //Login
  static const String loginSuccess = 'Login Successful!';
  static const String unauthorizedUser = 'Unauthorized User';
  static const String networkError = 'Network Error';

  //Reports
  static const String stockReport = 'Stock Report';

// Outstanding Report
  static const String outstandingReportTitle = "Outstanding Report";
  static const String supplier = "Supplier";
  static const String customer = "Customer";
  static const String supplierOutstanding = "Supplier Outstanding";
  static const String customerOutstanding = "Customer Outstanding";

  static const String noRecordsFound = "No Records Found";
  static const String date = "Date";
  static const String contact = "Contact";

  static const String savePdfReport = "Save PDF Report";
  static const String printReport = "Print Report";

  static const String noDataToExport = "No data available to export";

  static const String totalRecords = "Total Records";

  static const String messageDear = "Dear";
  static const String messageReminder = "This is a reminder that your outstanding balance of";
  static const String messagePending = "is pending.";
  static const String messageArrangePayment = "Kindly arrange payment at the earliest.";
  static const String messageRegards = "Regards";
  // Login Screen
  static const String welcome = "Hello !";
  static const String loginSubtitle =
      "Log In with Your username and passcode.";

  static const String customerId = "Customer ID";
  static const String username = "Username";
  static const String password = "Password";

  static const String enterCustomerId = "Enter Customer ID";
  static const String enterUsername = "Enter Username";
  static const String enterPassword = "Enter Password";

  static const String signIn = "SIGN IN";

  static const String copyright =
      "Copyright © 2025 SoulSoft Infotech\nAll rights reserved";

  // 🔹 Freight & Postage Dialog
  static const String freightPostageTitle = "Freight & Postage Charges";

  static const String selectLedger = "Select Ledger";
  static const String ledger = "Ledger";

  static const String chargeAmount = "Charge Amount (₹)";
  static const String addCharge = "Add Charge";

  static const String noChargesAdded = "No charges added yet";

  static const String chargeLabel = "Charge";

  static const String close = "Close";
  static const String apply = "Apply";

  //Payment Voucher
  static const String addPaymentVoucher = "Add Payment Voucher";
  static const String editPaymentVoucher = "Edit Payment Voucher";
  static const String add = "Add";
  static const String update = "Update";
  static const String paidTo = "Paid To *";
  static const String paidBy = "Paid By *";
  static const String payModeLabel = "Pay Mode *";
  static const String payTypeLabel = "Pay Type *";
  static const String amount = "Amount";
  static const String narration = "Narration";
  static const String chequeNo = "Cheque No";
  static const String chequeDate = "Cheque Date";
  static const String bankName = "Bank Name";
  static const String fillRequiredFields =
      "Please fill all required fields";
  static const String cash = "CASH";
  static const String bank = "BANK";
  static const String card = "Card";
  static const String upi = "UPI";
  static const String netBanking = "Net Banking";
  static const String cheque = "CHEQUE";
  static const String dateLabel = "Date";

  // Receipt Voucher
  static const String addReceiptVoucher = "Add Receipt Voucher";
  static const String editReceiptVoucher = "Edit Receipt Voucher";
  static const String receivedFrom = "Received From *";
  static const String receivedBy = "Received By *";

  static const String selectDateRange = "Select Date / Range";
  static const String pickStartDate = "Pick Start Date";
  static const String pickEndDateOptional = "Pick End Date (Optional)";
  static const String viewAmountDetails = "View Amount Details";

  static const String purchaseReturnStatement = "Purchase Return Statement";
  static const String noDataToPrint = "No data available to print";
  static const String dateRange = "Date Range";
  static const String fromDate = "From Date";
  static const String toDate = "To Date";
  static const String location = "Location";
  static const String generatedOn = "Generated on";
  static const String billNo = "Bill No";
  static const String freeQtyLabel = "Free Qty";
  static const String subtotalLabel = "Subtotal";
  static const String taxableAmtLabel = "Taxable Amt";
  static const String taxAmtLabel = "Tax Amt";
  static const String postage = "Postage";
  static const String disc = "Disc";
  static const String netAmt = "Net Amt";
  static const String returnId = "Return ID";

  static const String purchaseReturnItemwise = "Purchase Return - Itemwise";
  static const String purchaseReturnItemwiseReport =
      "Purchase Return Itemwise Report";
  static const String error = "Error";

//Reports
  static const String salesSummarystmt = "Sales Summary Statement";
  static const String salesStmt = "Sales Summary";
  static const String salesReportItemWise = "Sales Report (Item Wise)";

  //Vouchers
  static const String inwardStock = "+ Inward Stock";

  //purchase challan
  static const String purchaseChallan = 'Purchase challan';
  static const String newPurchaseChallan = 'New Purchase challan';
  static const String purchaseChallanDashboard = 'Purchase challan Dashboard';
  static const String purchaseChallanSaveSuccess = 'Purchase Challan saved successfully';
  static const String purchaseChallanSaveFailed = 'Failed to save purchase challan';
  static const String purchaseInvoiceBar1 = 'Update Purchase Challan';
  static const String purchaseInvoiceBar2 = 'Purchase Challan';
}


