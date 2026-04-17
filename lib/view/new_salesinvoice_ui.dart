import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/add_sale_model.dart';
import '../model/invoice_item_model.dart';
import '../model/items_by_product_type.dart';
import '../model/item_unit_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/routes/routes_names.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/sales_invoice_viewmodel.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import '../viewmodel/add_sale_view_model.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewmodel/ledger_type_viewmodel.dart';
import '../model/sales_dashboard_model.dart';
import '../viewmodel/sales_dashboard_viewmodel.dart';
import 'homeScreen.dart';

class NewSalesInvoiceUI extends StatefulWidget {
  const NewSalesInvoiceUI({super.key});

  @override
  State<NewSalesInvoiceUI> createState() => _NewSalesInvoiceUIState();
}

class _NewSalesInvoiceUIState extends State<NewSalesInvoiceUI> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isEdit = false;
  int? _editSaleId;

  // ─── Customer & Bill Details (Page 1) ───
  final TextEditingController customerController = TextEditingController();
  final TextEditingController byHandController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  String? selectedCustomer;
  String? customerAddress;
  int? selectedCustomerId;
  double? selectedCreditLimit;
  double? selectedOutstanding;

  String? selectedLocationId;
  String? selectedBillType;
  String? selectedRateType;
  String? selectedPayMode = 'Cash';
  String? selectedTaxType = 'Exclusive';
  final List<String> payModes = ['Cash', 'Credit'];
  final List<String> taxTypes = ['Exclusive', 'Inclusive', 'No Tax'];

  final TextEditingController locationSearchCtrl = TextEditingController();
  final TextEditingController rateTypeSearchCtrl = TextEditingController();

  // ─── Products (Page 2) ───
  final List<InvoiceItem> items = [];

  // Product selection state
  final TextEditingController productSearchCtrl = TextEditingController();
  final FocusNode _productFocusNode = FocusNode();
  ItemsByProductTypeModel? _selectedProductItem;
  String? _selectedProductName;
  ItemUnitModel? _selectedUnitModel;
  double _availableStock = 0;

  final _qtyCtrl = TextEditingController(text: "1");
  final _freeQtyCtrl = TextEditingController(text: "0");
  final _rateCtrl = TextEditingController();
  final _baseRateCtrl = TextEditingController();
  final _subtotalCtrl = TextEditingController();
  final _discPerCtrl = TextEditingController(text: "0");
  final _discAmtCtrl = TextEditingController();
  final _totalDiscCtrl = TextEditingController();
  final _taxableCtrl = TextEditingController();
  final _taxPerCtrl = TextEditingController();
  final _taxAmtCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();

  // ─── Bill Totals (Page 3) ───
  double totalQty = 0;
  double freeQty = 0;
  double itemTotal = 0;
  double totalDiscAmt = 0;
  double taxableAmt = 0;
  double taxAmt = 0;
  double totalAmt = 0;
  double netBillTotal = 0;
  double netBillAmt = 0;
  double freightValue = 0;
  double billTaxRate = 0.0;
  List<Map<String, dynamic>> freightCharges = [];
  List<SalesOtherCharge> salesOtherCharges = [];

  // ─── Freight In-Row state ───
  String? selectedFreightLedger;
  int? selectedFreightLedgerId;
  final TextEditingController freightChargeCtrl = TextEditingController();

  final TextEditingController discountController = TextEditingController();
  final TextEditingController roundOffController = TextEditingController();

  // ─── Payment (Page 3) ───
  final TextEditingController cashAmountController = TextEditingController();
  final TextEditingController bankAmountController = TextEditingController();
  String? selectedBankMode;
  String? selectedBankAccount;
  final List<String> bankModes = ["UPI", "Net Banking", "Card"];
  bool _isUpdatingPayment = false;

  DateTime salesDate = DateTime.now();
  String? selectedPaymentTerm;

  @override
  void initState() {
    super.initState();

    roundOffController.addListener(_recalculateTotals);
    roundOffController.addListener(_onDiscountChanged);
    discountController.addListener(_onDiscountChanged);

    cashAmountController.addListener(_onCashChanged);
    bankAmountController.addListener(_onBankChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final salesVM = Provider.of<SalesInvoiceViewmodel>(context, listen: false);
    final itemVM =
        Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);
    final ledgerVM = Provider.of<LedgerTypeViewmodel>(context, listen: false);

    // Fetch rate types first (lightweight, not user-specific) before firing heavier calls
    print("[RateType] UI: Calling getRateTypeApi()...");
    await salesVM.getRateTypeApi();
    print(
        "[RateType] UI: getRateTypeApi() completed. rateTypeList.length = ${salesVM.rateTypeList.length}");
    for (var rt in salesVM.rateTypeList) {
      print("[RateType] UI: -> id=${rt.rateTypeId}, rateType='${rt.rateType}'");
    }

    if (mounted &&
        salesVM.rateTypeList.isNotEmpty &&
        selectedRateType == null) {
      setState(() {
        selectedRateType = salesVM.rateTypeList.first.rateType;
      });
      print("[RateType] UI: selectedRateType set to '$selectedRateType'");
    } else {
      print(
          "[RateType] UI: NOT setting selectedRateType. mounted=$mounted, listEmpty=${salesVM.rateTypeList.isEmpty}, selectedRateType=$selectedRateType");
    }

    // Fire remaining calls (some are user-specific and heavier)
    ledgerVM.loadFreightPostageLedger();
    salesVM.getPartyApi();
    salesVM.fetchTaxGroupPercentage();
    itemVM.getStockLocationsByUserApi();
    salesVM.getBillTypeApi();

    _loadSavedLocation();

    if (mounted) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final isEdit = args['isEdit'] ?? false;
        final saleData = args['saleData'] as SalesDashboardModel?;
        final rateTypeArg = args['rateType'];

        if (isEdit && saleData != null) {
          setState(() {
            _isEdit = true;
            _editSaleId = saleData.salesID;
            if (rateTypeArg != null && rateTypeArg != '-') {
              selectedRateType = rateTypeArg;
            }
          });
          _fetchSaleDetailsById(_editSaleId ?? 0);
        }
      }
    }
  }

  void _fetchSaleDetailsById(int saleId) async {
    final dashboardVM =
        Provider.of<SalesDashboardViewModel>(context, listen: false);
    if (saleId == 0) return;

    final saleDetail = await dashboardVM.getSalesById(saleId);

    if (saleDetail != null && mounted) {
      setState(() {
        customerController.text = saleDetail.customerName ?? "";
        selectedCustomer = saleDetail.customerName;
        selectedCustomerId = saleDetail.customerId ?? 0;
        customerAddress = saleDetail.address ?? "-";
        byHandController.text = saleDetail.byHand ?? "-";
        contactController.text = saleDetail.phoneNumber ?? "-";

        selectedCreditLimit =
            (saleDetail.customerOutstanding ?? 0.0).toDouble();
        selectedOutstanding = saleDetail.totalAmt;

        selectedRateType = saleDetail.rateType ?? "-";
        selectedPayMode = saleDetail.salesType ?? "-";
        selectedBillType = saleDetail.billType ?? "-";

        items.clear();
        if (saleDetail.salesDetails != null &&
            saleDetail.salesDetails!.isNotEmpty) {
          items.clear();

          for (var detail in saleDetail.salesDetails!) {
            if (detail is SalesDetail) {
              items.add(InvoiceItem.fromJson(detail.toJson()));
            } else if (detail is Map<String, dynamic>) {
              items.add(InvoiceItem.fromJson(detail.toJson()));
            }
          }
        }
      });
    }
  }

  void _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocation = prefs.getString("selected_location");
    final savedBillType = prefs.getString("selected_bill_type");

    if (savedLocation != null) {
      setState(() {
        selectedLocationId = savedLocation;
        selectedBillType = savedBillType;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    customerController.dispose();
    byHandController.dispose();
    contactController.dispose();
    _qtyCtrl.dispose();
    _freeQtyCtrl.dispose();
    _rateCtrl.dispose();
    _baseRateCtrl.dispose();
    _subtotalCtrl.dispose();
    _discPerCtrl.dispose();
    _discAmtCtrl.dispose();
    _totalDiscCtrl.dispose();
    _taxableCtrl.dispose();
    _taxPerCtrl.dispose();
    _taxAmtCtrl.dispose();
    _totalCtrl.dispose();
    discountController.dispose();
    roundOffController.dispose();
    cashAmountController.dispose();
    bankAmountController.dispose();
    freightChargeCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════
  //  CALCULATION LOGIC (same as original)
  // ═══════════════════════════════════════════════════

  void _calculateProduct({String? activeField}) {
    double r2(double v) => double.parse(v.toStringAsFixed(2));

    final qty = double.tryParse(_qtyCtrl.text) ?? 1;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    double gst = double.tryParse(_taxPerCtrl.text) ?? 0;

    String tType = "E";
    if (selectedTaxType?.toLowerCase() == "inclusive") tType = "I";
    if (selectedTaxType?.toLowerCase() == "no tax") tType = "N";

    double baseRate = rate;
    if (tType == "I" && gst > 0) {
      baseRate = r2(rate * 100 / (100 + gst));
    }

    double subTotal = r2(baseRate * qty);

    double discPer = double.tryParse(_discPerCtrl.text) ?? 0;
    double discAmtPerItem = double.tryParse(_discAmtCtrl.text) ?? 0;

    if (activeField == "discper") {
      discAmtPerItem = r2((baseRate * discPer) / 100);
      _discAmtCtrl.text = discAmtPerItem.toStringAsFixed(2);
    } else if (activeField == "discAmt") {
      discPer = baseRate > 0 ? r2((discAmtPerItem / baseRate) * 100) : 0;
      _discPerCtrl.text = discPer.toStringAsFixed(2);
    } else {
      discAmtPerItem = r2((baseRate * discPer) / 100);
      _discAmtCtrl.text = discAmtPerItem.toStringAsFixed(2);
    }

    double totalDisc = r2(discAmtPerItem * qty);
    double taxable = r2(subTotal - totalDisc);

    double taxAmtVal = 0;
    double total = 0;

    if (tType == "E") {
      taxAmtVal = r2((taxable * gst) / 100);
      total = r2(taxable + taxAmtVal);
    } else if (tType == "I") {
      total = r2(rate * qty);
      taxAmtVal = r2(total - taxable);
      _baseRateCtrl.text = baseRate.toStringAsFixed(2);
    } else {
      taxAmtVal = 0;
      total = taxable;
    }

    setState(() {
      _subtotalCtrl.text = subTotal.toStringAsFixed(2);
      _totalDiscCtrl.text = totalDisc.toStringAsFixed(2);
      _taxableCtrl.text = taxable.toStringAsFixed(2);
      _taxAmtCtrl.text = taxAmtVal.toStringAsFixed(2);
      _totalCtrl.text = total.toStringAsFixed(2);
    });
  }

  void _recalculateTotals() {
    totalQty = 0;
    freeQty = 0;
    itemTotal = 0;
    totalDiscAmt = 0;
    taxableAmt = 0;
    taxAmt = 0;
    totalAmt = 0;

    for (var item in items) {
      totalQty += item.qty;
      freeQty += item.freeQty;
      itemTotal += item.subtotal;
      totalDiscAmt += item.totalDisc;
      taxableAmt += item.taxable;
      taxAmt += item.taxAmt;
      totalAmt += item.totalAmt;
    }

    if (taxableAmt > 0) {
      billTaxRate = taxAmt / taxableAmt;
    } else {
      billTaxRate = 0;
    }

    netBillTotal = totalAmt + freightValue;

    double roundOffValue = double.tryParse(roundOffController.text) ?? 0.0;
    netBillAmt = netBillTotal + roundOffValue;

    setState(() {});
  }

  void _onDiscountChanged() {
    double discountPercent = double.tryParse(discountController.text) ?? 0.0;

    double billDiscountAmt = (itemTotal * discountPercent) / 100;

    double newTaxableAmt = itemTotal - billDiscountAmt;
    if (newTaxableAmt < 0) newTaxableAmt = 0;

    double newTaxAmt = newTaxableAmt * billTaxRate;
    double newTotalAmt = newTaxableAmt + newTaxAmt;
    double newNetBillTotal = newTotalAmt + freightValue;

    double roundOffValue = double.tryParse(roundOffController.text) ?? 0.0;

    setState(() {
      totalDiscAmt = billDiscountAmt;
      taxableAmt = newTaxableAmt;
      taxAmt = newTaxAmt;
      totalAmt = newTotalAmt;
      netBillTotal = newNetBillTotal;
      netBillAmt = newNetBillTotal + roundOffValue;
    });
  }

  // ─── Payment sync ───
  void _onCashChanged() {
    if (_isUpdatingPayment) return;
    _isUpdatingPayment = true;
    final cashValue = double.tryParse(cashAmountController.text) ?? 0;
    final remaining = (netBillAmt - cashValue).clamp(0, netBillAmt);
    bankAmountController.text = remaining.toStringAsFixed(0);
    _isUpdatingPayment = false;
    setState(() {});
  }

  void _onBankChanged() {
    if (_isUpdatingPayment) return;
    _isUpdatingPayment = true;
    final bankValue = double.tryParse(bankAmountController.text) ?? 0;
    final remaining = (netBillAmt - bankValue).clamp(0, netBillAmt);
    cashAmountController.text = remaining.toStringAsFixed(0);
    _isUpdatingPayment = false;
    setState(() {});
  }

  // ─── Product helpers ───
  int _i(TextEditingController c, {int def = 0}) => int.tryParse(c.text) ?? def;
  double _d(TextEditingController c, {double def = 0.0}) =>
      double.tryParse(c.text) ?? def;

  int _resolveRateTypeId(ItemViewmodel vm) {
    final match = vm.rateTypes.firstWhere(
      (e) =>
          e.rateType?.toUpperCase() == (selectedRateType ?? "").toUpperCase(),
      orElse: () => vm.rateTypes.first,
    );
    return match.rateTypeId ?? 1;
  }

  Future<void> _onProductSelected(ItemsByProductTypeModel item) async {
    setState(() {
      _selectedProductItem = item;
      _selectedProductName = item.itemName;
      _availableStock = 0;
    });

    final unitVM = context.read<ItemViewmodel>();
    await unitVM.getItemUnits(item.itemId ?? 0);

    if (unitVM.unitList.isNotEmpty) {
      unitVM.setSelectedUnit(unitVM.unitList.first);
      _selectedUnitModel = unitVM.selectedUnit;
    }

    // Fetch stock quantity for this item
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final locationId = selectedLocationId ?? "0";
    final stockDetails = await unitVM.getItemSalesDetailsApi(
      item.itemId ?? 0,
      date,
      locationId,
    );
    double totalStock = 0;
    for (var detail in stockDetails) {
      totalStock += detail.stockQuantity ?? 0;
    }
    _availableStock = totalStock;

    _qtyCtrl.text = "1";
    _freeQtyCtrl.text = "0";
    _rateCtrl.text = (item.baseRate ?? 0).toString();
    _taxPerCtrl.text = (item.taxPer ?? 0).toString();

    await _loadItemRate();
    _calculateProduct();
  }

  Future<void> _loadItemRate() async {
    if (_selectedProductItem == null || _selectedUnitModel == null) return;

    final vm = Provider.of<ItemViewmodel>(context, listen: false);
    final rateOn = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final rateTypeId = _resolveRateTypeId(vm);

    await vm.getItemRate(
      itemId: _selectedProductItem!.itemId!,
      rateOn: rateOn,
      rateTypeId: rateTypeId,
      customerId: null,
      unitId: _selectedUnitModel!.unitId,
    );

    final rateData = vm.itemRate;
    if (rateData?.rate?.rate == null) return;

    setState(() {
      _rateCtrl.text = rateData!.rate!.rate!.toDouble().toStringAsFixed(2);
    });

    _calculateProduct();
  }

  void _addProductToList() {
    if (_selectedProductItem == null || _qtyCtrl.text.isEmpty) return;

    final enteredQty = _i(_qtyCtrl, def: 1);
    final enteredFreeQty = _i(_freeQtyCtrl);
    final totalRequired = enteredQty + enteredFreeQty;

    // Stock quantity validation
    if (_availableStock > 0 && totalRequired > _availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade700,
          content: Text(
            "Warning: Required qty ($totalRequired) exceeds available stock (${_availableStock.toStringAsFixed(0)})",
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    final invoiceItem = InvoiceItem(
      productName: _selectedProductName!,
      itemName: _selectedProductName!,
      qty: enteredQty,
      freeQty: enteredFreeQty,
      rate: _d(_rateCtrl),
      subtotal: _d(_subtotalCtrl),
      discountPerc: _d(_discPerCtrl),
      discountAmt: _d(_discAmtCtrl),
      totalDisc: _d(_totalDiscCtrl),
      taxable: _d(_taxableCtrl),
      taxPerc: _d(_taxPerCtrl),
      taxAmt: _d(_taxAmtCtrl),
      totalAmt: _d(_totalCtrl),
      netAmt: _d(_totalCtrl),
      itemId: _selectedProductItem!.itemId!,
      unitId: _selectedProductItem!.unitId ?? 0,
      taxGroupId: 0,
      stock: _availableStock.toInt(),
      purchaseRate: _selectedProductItem!.lastPurchaseRate ?? 0,
      mrp: _selectedProductItem!.lASTMRP ?? 0,
      stkPurchaseId: 0,
      firmId: 0,
      locationId: int.tryParse(selectedLocationId ?? "0") ?? 0,
      isNonGST: (_selectedProductItem!.taxPer ?? "0") != "0",
      mfgDate: "",
      purchaseRateWithTax: 0,
      returnQty: 0,
    );

    // Free qty stock check
    if (_availableStock > 0 && invoiceItem.freeQty > _availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Text(
            "Free quantity (${invoiceItem.freeQty}) cannot exceed available stock (${_availableStock.toStringAsFixed(0)}).",
          ),
        ),
      );
      return;
    }

    // Duplicate check
    final exists = items.any((item) => item.itemId == invoiceItem.itemId);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(Strings.existItemSnack),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() {
      items.add(invoiceItem);
      _recalculateTotals();
      // Reset product form
      _selectedProductItem = null;
      _selectedProductName = null;
      productSearchCtrl.clear();
      _qtyCtrl.text = "1";
      _freeQtyCtrl.text = "0";
      _rateCtrl.clear();
      _baseRateCtrl.clear();
      _subtotalCtrl.clear();
      _discPerCtrl.text = "0";
      _discAmtCtrl.clear();
      _totalDiscCtrl.clear();
      _taxableCtrl.clear();
      _taxPerCtrl.clear();
      _taxAmtCtrl.clear();
      _totalCtrl.clear();
    });
  }

  // ═══════════════════════════════════════════════════
  //  VALIDATION
  // ═══════════════════════════════════════════════════

  bool _validatePage1() {
    if (selectedCustomer == null || selectedCustomer!.isEmpty) {
      _showValidation("Please select a customer");
      return false;
    }
    if (selectedLocationId == null || selectedLocationId == "-") {
      _showValidation("Please select a stock location");
      return false;
    }
    if (selectedRateType == null) {
      _showValidation("Please select a rate type");
      return false;
    }
    return true;
  }

  bool _validatePage2() {
    if (items.isEmpty) {
      _showValidation("Please add at least one product");
      return false;
    }
    return true;
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Text(message),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  SAVE / API CALLS (same logic as original)
  // ═══════════════════════════════════════════════════

  void logLong(String tag, String text) {
    const int chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      log('${tag}_part${(i / chunkSize).floor()}: ${text.substring(i, end)}');
    }
  }

  Future<void> _saveInvoice() async {
    // ✅ CUSTOMER VALIDATION
    if (customerController.text.trim().isEmpty ||
        (selectedCustomerId ?? 0) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Text(Strings.selectCustomerSnackText),
        ),
      );
      return;
    }

    // ✅ PRODUCT VALIDATION
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: const Text(Strings.salesInvoiceSnackText),
        ),
      );
      return;
    }

    // ✅ BILL TYPE VALIDATION
    /* if (selectedBillType == null || selectedBillType == "-") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: const Text(Strings.selectBillDetailsSnack),
        ),
      );
      return;
    } */

    double discountPercent = double.tryParse(discountController.text) ?? 0.0;
    double roundOffValue = double.tryParse(roundOffController.text) ?? 0.0;
    double discountAmt = (itemTotal * discountPercent) / 100;
    double finalAmt = netBillTotal + roundOffValue;

    String taxTypeCode = "N";
    if (selectedTaxType?.toLowerCase() == "inclusive") {
      taxTypeCode = "I";
    } else if (selectedTaxType?.toLowerCase() == "exclusive") {
      taxTypeCode = "E";
    }

    if (selectedPayMode?.trim().toLowerCase() == "credit") {
      await _addSaleAPIDirect(taxTypeCode, discountPercent, discountAmt);
    } else {
      // For cash payment, use the inline payment section on page 3
      await _addSaleAPIWithPayment(
          taxTypeCode, discountPercent, discountAmt, finalAmt);
    }
  }

  Future<void> _addSaleAPIDirect(
      String taxTypeCode, double discountPercent, double discountAmt) async {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = int.tryParse(loginVM.userId ?? '0') ?? 0;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final viewModel = Provider.of<AddSaleViewModel>(context, listen: false);

      List<SalesDetail> salesDetails = _buildSalesDetails();
      List<SalesOtherCharge> otherCharges = _buildOtherCharges();

      double roundOffValue = double.tryParse(roundOffController.text) ?? 0.0;

      final addSale = AddSaleModel(
        salesID: 0,
        salesBillNo: "",
        salesDate: DateFormat('yyyy-MM-dd').format(salesDate),
        customerId: selectedCustomerId ?? 0,
        totalQty: totalQty,
        itemTotal: itemTotal,
        locationId: int.tryParse(selectedLocationId!) ?? 0,
        userID: userId,
        billType: selectedBillType ?? "",
        rateType: selectedRateType ?? "",
        taxIncludeExclude: taxTypeCode,
        salesType: selectedPayMode ?? "",
        paymentTerm: selectedPaymentTerm.toString(),
        cropType: "",
        freeQty: freeQty,
        subTotal: itemTotal,
        discPer: discountPercent,
        discAmt: discountAmt,
        totalDiscAmt: totalDiscAmt,
        totalAmt: totalAmt,
        freight: freightValue,
        taxableAmt: taxableAmt,
        totalTaxAmt: taxAmt,
        totalTaxableAmt: taxableAmt,
        invoiceChargesAmt: freightValue,
        billTotal: totalAmt + freightValue,
        roundOff: roundOffValue,
        netBillTotal: netBillTotal,
        netAmt: netBillAmt,
        netBillAmt: netBillAmt,
        narration: "",
        byHand: byHandController.text,
        vehicleDetails: "",
        isBillReceived: true,
        bankLedgerId: 0,
        isChallanInvoice: false,
        isQuotationInvoice: false,
        isWalkinCustomer: false,
        customerName: customerController.text,
        address: customerAddress ?? "",
        age: 0,
        cashPaidAmount: 0,
        bankPaidAmount: 0,
        modeOfBankPayment: "",
        customerOutstanding: 0,
        isSalesReturned: false,
        misc1: "",
        misc2: "",
        misc3: "",
        misc4: "",
        misc5: "",
        preparedBy: 0,
        checkedBy: 0,
        createdBy: 1,
        updatedBy: 1,
        phoneNumber: contactController.text,
        salesDetails: salesDetails,
        salesOtherCharges: otherCharges,
      );

      final requestBody = addSale.toJson();
      debugPrint("=========== ADD PURCHASE REQUEST ===========");
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
      debugPrint("============================================");
      logLong('Request Body', jsonEncode(requestBody));

      final salesId = await viewModel.addSale(context, requestBody);
      final salesVM =
          Provider.of<SalesInvoiceViewmodel>(context, listen: false);
      salesVM.clearBillDetails();
      salesVM.clearCustomerDetails();
      Navigator.pop(context); // hide loader

      if (salesId != null && salesId > 0) {
        Fluttertoast.showToast(
          msg: "Sale added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(initialIndex: 0),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Something went wrong: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> _addSaleAPIWithPayment(String taxTypeCode,
      double discountPercent, double discountAmt, double finalAmt) async {
    final double cashAmount = double.tryParse(cashAmountController.text) ?? 0.0;
    final double bankAmount = double.tryParse(bankAmountController.text) ?? 0.0;

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = int.tryParse(loginVM.userId ?? '0') ?? 0;

    if (bankAmount > 0) {
      if (selectedBankMode == null || selectedBankMode!.isEmpty) {
        _showValidation("Please select a bank payment mode.");
        return;
      }
      /* if (selectedBankAccount == null) {
        _showValidation("Please select a bank account.");
        return;
      } */
    }

    final ledgerVM = Provider.of<LedgerTypeViewmodel>(context, listen: false);
    int selectedBankLedgerId = 0;
    if (selectedBankAccount != null && ledgerVM.bankAccounts.isNotEmpty) {
      final matchedLedger = ledgerVM.bankAccounts.firstWhere(
        (ledger) => ledger.ledgerName == selectedBankAccount,
        orElse: () => ledgerVM.bankAccounts.first,
      );
      selectedBankLedgerId = matchedLedger.ledgerId ?? 0;
    }

    final modeOfBankPayment = selectedBankMode ?? "";
    double roundOffValue = double.tryParse(roundOffController.text) ?? 0.0;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final viewModel = Provider.of<AddSaleViewModel>(context, listen: false);

      List<SalesDetail> salesDetails = _buildSalesDetails();
      List<SalesOtherCharge> otherCharges = _buildOtherCharges();

      final addSale = AddSaleModel(
        salesID: _isEdit ? (_editSaleId ?? 0) : 0,
        salesBillNo: "",
        salesDate: DateFormat('yyyy-MM-dd').format(salesDate),
        customerId: selectedCustomerId ?? 0,
        totalQty: totalQty,
        itemTotal: itemTotal,
        locationId: int.tryParse(selectedLocationId!) ?? 0,
        userID: userId,
        billType: selectedBillType ?? "",
        rateType: selectedRateType ?? "",
        taxIncludeExclude: taxTypeCode,
        salesType: selectedPayMode ?? "",
        paymentTerm: selectedPaymentTerm.toString(),
        cropType: "",
        freeQty: freeQty,
        subTotal: itemTotal,
        discPer: discountPercent,
        discAmt: discountAmt,
        totalDiscAmt: totalDiscAmt,
        totalAmt: totalAmt,
        freight: freightValue,
        taxableAmt: taxableAmt,
        totalTaxAmt: taxAmt,
        totalTaxableAmt: taxableAmt,
        invoiceChargesAmt: freightValue,
        billTotal: totalAmt + freightValue,
        roundOff: roundOffValue,
        netBillTotal: netBillTotal,
        netAmt: netBillAmt,
        netBillAmt: netBillAmt,
        narration: "",
        byHand: byHandController.text,
        vehicleDetails: "",
        isBillReceived: true,
        bankLedgerId: selectedBankLedgerId,
        isChallanInvoice: false,
        isQuotationInvoice: false,
        isWalkinCustomer: false,
        customerName: customerController.text,
        address: customerAddress ?? "",
        age: 0,
        cashPaidAmount: cashAmount,
        bankPaidAmount: bankAmount,
        modeOfBankPayment: modeOfBankPayment,
        customerOutstanding: 0,
        isSalesReturned: false,
        misc1: "",
        misc2: "",
        misc3: "",
        misc4: "",
        misc5: "",
        preparedBy: 0,
        checkedBy: 0,
        createdBy: 1,
        updatedBy: 1,
        phoneNumber: contactController.text,
        salesDetails: salesDetails,
        salesOtherCharges: otherCharges,
      );

      final requestBody = addSale.toJson();
      logLong('Request Body', jsonEncode(requestBody));

      final salesId = await viewModel.addSale(context, requestBody);
      final salesVM =
          Provider.of<SalesInvoiceViewmodel>(context, listen: false);
      salesVM.clearBillDetails();
      salesVM.clearCustomerDetails();
      Navigator.pop(context);

      if (salesId != null && salesId > 0) {
        Fluttertoast.showToast(
          msg: "Sale added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(initialIndex: 0),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Something went wrong: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  List<SalesDetail> _buildSalesDetails() {
    return items.map((item) {
      return SalesDetail(
        itemId: item.itemId,
        unitId: item.unitId,
        itemName: item.itemName,
        barcode: "",
        quantity: item.qty.toDouble(),
        rate: item.rate,
        freeQuantity: item.freeQty.toDouble(),
        itemTotal: item.subtotal,
        discPer: item.discountPerc.toString(),
        discAmt: item.discountAmt,
        totalDiscount: item.totalDisc,
        taxableAmt: item.taxable,
        taxPer: item.taxPerc,
        taxPer1: item.taxPer1,
        taxAmt1: item.taxAmt1,
        taxPer2: item.taxPer2,
        taxAmt2: item.taxAmt2,
        taxPer3: "0.00",
        taxAmt3: "0.00",
        taxPer4: "0.00",
        taxAmt4: "0.00",
        taxPer5: "0.00",
        taxAmt5: "0.00",
        taxGroupId: item.taxGroupId,
        purchaseRate: item.purchaseRate,
        purchaseRateWithTax: item.purchaseRateWithTax,
        mrp: item.mrp,
        stkPurchaseId: item.stkPurchaseId,
        totalTaxAmt: item.taxAmt,
        netAmt: item.netAmt,
        usedAs: "N/A",
        isWithoutGST: item.isNonGST,
        returnQty: item.returnQty.toString(),
        action: "",
      );
    }).toList();
  }

  List<SalesOtherCharge> _buildOtherCharges() {
    List<SalesOtherCharge> otherCharges = salesOtherCharges;

    salesOtherCharges = otherCharges.map((charge) {
      return SalesOtherCharge(
        ledgerId: charge.ledgerId,
        amount: charge.amount ?? 0.0,
        ledgerName: charge.ledgerName ?? "",
      );
    }).toList();

    return otherCharges;
  }

  // ═══════════════════════════════════════════════════
  //  PAGE NAVIGATION
  // ═══════════════════════════════════════════════════

  void _goToPage(int page) {
    if (page == 1 && !_validatePage1()) return;
    if (page == 2 && !_validatePage2()) {
      // Must validate page 1 too if jumping
      if (_currentPage == 0 && !_validatePage1()) return;
      if (_currentPage == 1 && !_validatePage2()) return;
      return;
    }

    // Save bill details to viewmodel when leaving page 1
    if (_currentPage == 0 && page > 0) {
      final salesVM =
          Provider.of<SalesInvoiceViewmodel>(context, listen: false);
      salesVM.setCustomerDetails(
        customer: selectedCustomer,
        byHand: byHandController.text,
      );
      salesVM.setBillDetails(
        locationId: selectedLocationId,
        billType: selectedBillType,
        rateType: selectedRateType,
        payMode: selectedPayMode,
        taxType: selectedTaxType,
      );

      // Load items for product page
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final itemVM =
          Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);
      itemVM.getItemsByProuctTypeApi(
          today, {"locationId": selectedLocationId ?? ""});

      Future.microtask(() => context.read<ItemViewmodel>().getRateTypes());
    }

    // When going to page 3, recalculate and prepare payment
    if (page == 2) {
      _recalculateTotals();
      cashAmountController.text = netBillAmt.toStringAsFixed(0);
      bankAmountController.text = "0";

      final ledgerVM = Provider.of<LedgerTypeViewmodel>(context, listen: false);
      if (ledgerVM.bankAccounts.isEmpty) {
        ledgerVM.loadBankAccounts();
      }
    }

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _selectSalesDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: salesDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => salesDate = picked);
    }
  }

  // ═══════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        final salesVM =
            Provider.of<SalesInvoiceViewmodel>(context, listen: false);
        salesVM.clearBillDetails();
        salesVM.clearCustomerDetails();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F8),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primary,
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          title: const Text("Sales (Invoice)",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 17)),
          actions: [
            GestureDetector(
              onTap: _selectSalesDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text(DateFormat('dd MMM yyyy').format(salesDate),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  STEP INDICATOR — slim inline progress bar
  // ═══════════════════════════════════════════════════

  Widget _buildStepIndicator() {
    const icons = [
      Icons.person_outline_rounded,
      Icons.inventory_2_outlined,
      Icons.check_circle_outline_rounded,
    ];
    const labels = ["Customer", "Products", "Confirm"];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: List.generate(labels.length, (idx) {
          final done = idx < _currentPage;
          final active = idx == _currentPage;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (done) {
                  _pageController.animateToPage(idx,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        done ? Icons.check_circle : icons[idx],
                        size: 16,
                        color: done
                            ? Colors.green
                            : active
                                ? primary
                                : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(labels[idx],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: done || active
                                ? (done ? Colors.green : primary)
                                : Colors.grey.shade500,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Progress bar segment
                  Container(
                    height: 3,
                    margin: EdgeInsets.only(
                      left: idx == 0 ? 0 : 2,
                      right: idx == labels.length - 1 ? 0 : 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: done
                          ? Colors.green
                          : active
                              ? primary
                              : Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PAGE 1 — Customer & Billing (vertical scroll layout)
  // ═══════════════════════════════════════════════════

  Widget _buildPage1() {
    final viewModel =
        Provider.of<SalesInvoiceViewmodel>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ══════════════════════════════════════════
                //  SECTION 1: Customer
                // ══════════════════════════════════════════
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              color: primary, size: 20),
                          const SizedBox(width: 6),
                          const Text("Customer",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                          const Spacer(),
                          SizedBox(
                            height: 26,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                    context, RouteNames.addCustomer);
                                if (result == true) {
                                  Provider.of<SalesInvoiceViewmodel>(context,
                                          listen: false)
                                      .getPartyApi();
                                }
                              },
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green, size: 16),
                              label: const Text("New",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.green)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ─── Select Customer autocomplete ───
                      Consumer<SalesInvoiceViewmodel>(
                        builder: (context, vm, _) {
                          if (vm.loading) {
                            return const SizedBox(
                              height: 44,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            );
                          }
                          final partyNames = vm.partyList
                              .map((p) => p.partyName ?? "")
                              .where((n) => n.isNotEmpty)
                              .toList();
                          return Autocomplete<String>(
                            initialValue:
                                TextEditingValue(text: selectedCustomer ?? ""),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return partyNames;
                              }
                              return partyNames.where((name) => name
                                  .toLowerCase()
                                  .contains(
                                      textEditingValue.text.toLowerCase()));
                            },
                            onSelected: (selection) async {
                              final party = vm.partyList.firstWhere(
                                (p) => p.partyName == selection,
                              );
                              setState(() {
                                selectedCustomer = party.partyName;
                                customerController.text = party.partyName ?? "";
                                contactController.text = party.mobile ?? "";
                                selectedCreditLimit = party.creditLimit ?? 0.0;
                                selectedCustomerId = party.partyId ?? 0;
                                customerAddress = party.address ?? "";
                              });
                              final today = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              await viewModel.getLedgerBalanceApi(
                                ledgerId: party.ledgerId ?? 0,
                                balanceAsOn: today,
                                balanceType: "T",
                              );
                              setState(() {
                                selectedOutstanding =
                                    (viewModel.ledgerBalance?.balance ?? 0.0)
                                        .toDouble();
                              });
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              if (options.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 6,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.85,
                                      maxHeight: 220,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return ListTile(
                                          dense: true,
                                          title: Text(option,
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              return SizedBox(
                                height: 44,
                                child: TextField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        selectedCustomer = null;
                                        selectedCustomerId = null;
                                        customerController.clear();
                                        contactController.clear();
                                        customerAddress = null;
                                        selectedCreditLimit = null;
                                        selectedOutstanding = null;
                                      });
                                    }
                                  },
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: "Search Customer...",
                                    hintStyle: const TextStyle(fontSize: 12),
                                    prefixIcon:
                                        const Icon(Icons.search, size: 16),
                                    suffixIcon: const Icon(
                                        Icons.arrow_drop_down,
                                        size: 20),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // ─── Outstanding & Credit Limit ───
                      if (selectedCustomer != null &&
                          selectedCustomer!.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.withAlpha(60)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Outstanding",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red)),
                                    const SizedBox(height: 2),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          "₹${(selectedOutstanding ?? 0).abs().toStringAsFixed(0)}",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.green.withAlpha(60)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Credit Limit",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.green)),
                                    const SizedBox(height: 2),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          "₹${(selectedCreditLimit ?? 0).toStringAsFixed(0)}",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ─── Address ───
                        if (customerAddress != null &&
                            customerAddress!.isNotEmpty &&
                            customerAddress != "-")
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    customerAddress ?? "",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],

                      // ─── By Hand ───
                      _miniField(byHandController, "By Hand", Icons.edit),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ══════════════════════════════════════════
                //  SECTION 2: Billing Type
                // ══════════════════════════════════════════
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              color: primary, size: 20),
                          const SizedBox(width: 6),
                          const Text("Billing Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ─── Location dropdown ───
                      Consumer<ItemsByProductTypeViewmodel>(
                        builder: (context, vm, _) {
                          if (vm.locationsLoading) {
                            return const SizedBox(
                              height: 42,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            );
                          }
                          return SizedBox(
                            height: 46,
                            child: DropdownButtonFormField<String>(
                              value: selectedLocationId,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: primary, size: 22),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              decoration: InputDecoration(
                                labelText: "Location",
                                labelStyle: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                                prefixIcon: Icon(Icons.location_on_outlined,
                                    size: 18, color: primary),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: primary, width: 1.5)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                              ),
                              items: vm.stockLocationsByUserList
                                  .where(
                                      (l) => (l.locationName ?? "").isNotEmpty)
                                  .map((l) => DropdownMenuItem<String>(
                                        value: l.locationId?.toString(),
                                        child: Text(l.locationName ?? "",
                                            overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedLocationId = val;
                                });
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // ─── Rate Type dropdown ───
                      _sectionTitle("Rate Type"),
                      const SizedBox(height: 6),
                      Consumer<SalesInvoiceViewmodel>(
                        builder: (context, vm, _) {
                          print(
                              "[RateType] Dropdown: Consumer rebuilding. vm.rateTypeList.length = ${vm.rateTypeList.length}");
                          for (var rt in vm.rateTypeList) {
                            print(
                                "[RateType] Dropdown: -> id=${rt.rateTypeId}, rateType='${rt.rateType}'");
                          }
                          final rateTypes = vm.rateTypeList
                              .map((r) => r.rateType ?? "")
                              .where((n) => n.isNotEmpty)
                              .toList();
                          print(
                              "[RateType] Dropdown: After filter, rateTypes = $rateTypes (length=${rateTypes.length})");
                          print(
                              "[RateType] Dropdown: selectedRateType = '$selectedRateType'");
                          if (rateTypes.isEmpty) {
                            return GestureDetector(
                              onTap: () async {
                                await vm.getRateTypeApi();
                                if (mounted &&
                                    vm.rateTypeList.isNotEmpty &&
                                    selectedRateType == null) {
                                  setState(() {
                                    selectedRateType =
                                        vm.rateTypeList.first.rateType;
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.refresh,
                                      size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 6),
                                  Text("Loading rate types... Tap to retry",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400)),
                                ],
                              ),
                            );
                          }
                          return SizedBox(
                            height: 46,
                            child: DropdownButtonFormField<String>(
                              value: selectedRateType != null &&
                                      rateTypes.contains(selectedRateType)
                                  ? selectedRateType
                                  : null,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: primary, size: 22),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              decoration: InputDecoration(
                                labelText: "Rate Type",
                                labelStyle: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                                prefixIcon: Icon(Icons.sell_outlined,
                                    size: 18, color: primary),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: primary, width: 1.5)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                              ),
                              items: rateTypes
                                  .map((r) => DropdownMenuItem<String>(
                                        value: r,
                                        child: Text(r,
                                            overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() => selectedRateType = val);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // ─── Pay Mode ───
                      _sectionTitle("Pay Mode"),
                      const SizedBox(height: 6),
                      _chipSelector(
                        options: payModes,
                        selected: selectedPayMode,
                        onSelected: (v) => setState(() => selectedPayMode = v),
                      ),
                      const SizedBox(height: 14),

                      // ─── Tax Type ───
                      _sectionTitle("Tax Type"),
                      const SizedBox(height: 6),
                      _chipSelector(
                        options: taxTypes,
                        selected: selectedTaxType,
                        onSelected: (v) => setState(() => selectedTaxType = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),

        // ─── Next button pinned at bottom ───
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _goToPage(1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Next: Select Products",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section title helper ───
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
    );
  }

  // ─── Chip selector row (wrapping) ───
  Widget _chipSelector({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: primary.withAlpha(40),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ]
                  : [],
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PAGE 2 — Products (40% Add Item, 60% Added Items)
  // ═══════════════════════════════════════════════════

  Widget _buildPage2() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
        child: Column(
          children: [
            // ─── Add Item section ───
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          color: primary, size: 18),
                      const SizedBox(width: 6),
                      const Text("Add Item",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      if (_selectedProductName != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_selectedProductName!,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primary),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ─── Row 1: Product autocomplete ───
                  Consumer<ItemsByProductTypeViewmodel>(
                    builder: (context, vm, _) {
                      if (vm.loading) {
                        return const SizedBox(
                          height: 44,
                          child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final productNames = vm.itemList
                          .map((p) => p.itemName ?? "")
                          .where((n) => n.isNotEmpty)
                          .toList();
                      return RawAutocomplete<String>(
                        textEditingController: productSearchCtrl,
                        focusNode: _productFocusNode,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return productNames;
                          }
                          return productNames.where((name) => name
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (selection) async {
                          productSearchCtrl.text = selection;
                          final item = vm.itemList.firstWhere(
                            (p) => p.itemName == selection,
                          );
                          await _onProductSelected(item);
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          if (options.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.85,
                                  maxHeight: 220,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      dense: true,
                                      title: Text(option,
                                          style: const TextStyle(fontSize: 13)),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          return SizedBox(
                            height: 44,
                            child: TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Search Product...",
                                hintStyle: const TextStyle(fontSize: 12),
                                prefixIcon: const Icon(Icons.search, size: 16),
                                suffixIcon:
                                    const Icon(Icons.arrow_drop_down, size: 20),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 6),

                  // ─── Stock indicator ───
                  if (_selectedProductItem != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 14,
                              color: _availableStock > 0
                                  ? Colors.green.shade600
                                  : Colors.red.shade400),
                          const SizedBox(width: 4),
                          Text(
                            "Available Stock: ${_availableStock.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _availableStock > 0
                                  ? Colors.green.shade700
                                  : Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ─── Row 2: Qty + Free Qty + Unit dropdown ───
                  Row(
                    children: [
                      Expanded(
                          child: _tinyField(
                              "Qty", _qtyCtrl, () => _calculateProduct())),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tinyField("Free Qty", _freeQtyCtrl, null)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer<ItemViewmodel>(
                          builder: (context, uvm, _) {
                            if (uvm.loading) {
                              return const SizedBox(
                                  height: 38,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)));
                            }
                            return SizedBox(
                              height: 38,
                              child: DropdownButtonFormField<ItemUnitModel>(
                                value: uvm.selectedUnit,
                                items: uvm.unitList
                                    .map((u) => DropdownMenuItem(
                                        value: u,
                                        child: Text(u.unitName,
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis)))
                                    .toList(),
                                onChanged: (val) {
                                  uvm.setSelectedUnit(val!);
                                  _selectedUnitModel = val;
                                  _loadItemRate();
                                },
                                decoration: InputDecoration(
                                  labelText: "Unit",
                                  labelStyle: const TextStyle(fontSize: 10),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                ),
                                isExpanded: true,
                                menuMaxHeight: 200,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ─── Row 3: Rate + Disc % + Disc Amt ───
                  Row(
                    children: [
                      Expanded(
                          child: _tinyField(
                              "Rate", _rateCtrl, () => _calculateProduct())),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tinyField("Disc %", _discPerCtrl,
                              () => _calculateProduct(activeField: "discper"))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tinyField("Disc Amt", _discAmtCtrl,
                              () => _calculateProduct(activeField: "discAmt"))),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ─── Row 4: Taxable + Tax % ───
                  Row(
                    children: [
                      _readOnlyMini("Taxable", _taxableCtrl.text),
                      const SizedBox(width: 8),
                      _readOnlyMini(
                          "Tax ${_taxPerCtrl.text}%", _taxAmtCtrl.text),
                    ],
                  ),
                  if (selectedTaxType?.toLowerCase() == "inclusive") ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _readOnlyMini("Base Rate", _baseRateCtrl.text),
                        const SizedBox(width: 8),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),

                  // ─── Row 5: Total + Add button ───
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: primary.withAlpha(12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primary.withAlpha(40)),
                          ),
                          child: Row(
                            children: [
                              Text("Total",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "₹${_totalCtrl.text.isEmpty ? "0.00" : _totalCtrl.text}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 38,
                        width: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedProductItem != null
                                ? Colors.green.shade600
                                : Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _selectedProductItem != null
                              ? _addProductToList
                              : null,
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ─── Items list header ───
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: primary, size: 18),
                const SizedBox(width: 6),
                Text("Added Items",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("${items.length} items",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: primary)),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ─── Added Items list (flexible, takes remaining space) ───
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_shopping_cart,
                                size: 40, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text(Strings.noSelectedProduct,
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final p = items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: primary.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text("${p.qty}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                            fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.productName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)),
                                      Text(
                                          "₹${p.rate.toStringAsFixed(2)} × ${p.qty}",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Text("₹${p.totalAmt.toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: primary)),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _showProductDetail(p),
                                  child: const Padding(
                                    padding: EdgeInsets.all(3),
                                    child: Icon(Icons.remove_red_eye_outlined,
                                        color: Colors.blue, size: 16),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      items.removeAt(index);
                                      if (items.isEmpty) {
                                        freightValue = 0;
                                        freightCharges.clear();
                                        discountController.clear();
                                        roundOffController.clear();
                                      }
                                      _recalculateTotals();
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(3),
                                    child: Icon(Icons.delete_outline,
                                        color: Colors.red, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // ─── Nav buttons (pinned at bottom) ───
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: primary),
                    ),
                    onPressed: () => _goToPage(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded,
                            size: 18, color: primary),
                        const SizedBox(width: 4),
                        const Text("Back"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_validatePage2()) _goToPage(2);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Next: Confirm & Pay",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(InvoiceItem product) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(product.productName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                ...[
                  [Strings.qty, product.qty.toString()],
                  [Strings.rate, product.rate.toStringAsFixed(2)],
                  [Strings.subTotal, product.subtotal.toStringAsFixed(2)],
                  [Strings.discPercent, product.discountPerc.toString()],
                  [Strings.totalDisc, product.totalDisc.toStringAsFixed(2)],
                  [Strings.taxableAmt, product.taxable.toStringAsFixed(2)],
                  [Strings.taxPerc, product.taxPerc.toString()],
                  [Strings.taxAmt, product.taxAmt.toStringAsFixed(2)],
                  [Strings.netTotal, product.totalAmt.toStringAsFixed(2)],
                  [
                    Strings.purchaseRate,
                    product.purchaseRate.toStringAsFixed(2)
                  ],
                  [Strings.stock, product.stock.toString()],
                  ["Non-GST", product.isNonGST ? "Yes" : "No"],
                  ["Return Qty", product.returnQty.toString()],
                  ["CGST (%)", product.taxPer1.toString()],
                  ["CGST Amt", product.taxAmt1.toStringAsFixed(2)],
                  ["SGST (%)", product.taxPer2.toString()],
                  ["SGST Amt", product.taxAmt2.toStringAsFixed(2)],
                  ["IGST (%)", product.taxPer3.toString()],
                  ["IGST Amt", product.taxAmt3.toStringAsFixed(2)],
                ].map((r) => _buildDetailRow(r[0], r[1])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PAGE 3 — Confirm Billing & Payment (non-scrollable)
  // ═══════════════════════════════════════════════════

  Widget _buildPage3() {
    final isCash = selectedPayMode?.trim().toLowerCase() != "credit";

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
              child: Column(
                children: [
                  // ─── Bill Summary ───
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_outlined,
                                color: primary, size: 18),
                            const SizedBox(width: 6),
                            const Text("Bill Summary",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // ─── Qty, Items, Free ───
                        _summaryFlexRow(
                          "Qty",
                          totalQty.toStringAsFixed(0),
                          "Items",
                          "${items.length}",
                          "Free",
                          freeQty.toStringAsFixed(0),
                        ),
                        const SizedBox(height: 8),

                        // ─── SubTotal, Total ───
                        _summaryFlexRow2(
                          "SubTotal",
                          "₹${itemTotal.toStringAsFixed(0)}",
                          "Total",
                          "₹${totalAmt.toStringAsFixed(0)}",
                        ),
                        const SizedBox(height: 8),

                        // ─── Taxable, Tax ───
                        _summaryFlexRow2(
                          "Taxable",
                          "₹${taxableAmt.toStringAsFixed(0)}",
                          "Tax",
                          "₹${taxAmt.toStringAsFixed(0)}",
                        ),
                        const SizedBox(height: 8),
                        Consumer<LedgerTypeViewmodel>(
                          builder: (context, ledgerVM, _) {
                            return Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _tinyDropdown<String>(
                                    label: "Freight Ledger",
                                    value: selectedFreightLedger,
                                    items: ledgerVM.freightPostageLedger
                                        .map((ledger) =>
                                            DropdownMenuItem<String>(
                                              value: ledger.ledgerName,
                                              child: Text(
                                                  ledger.ledgerName ?? "",
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      final selected = ledgerVM
                                          .freightPostageLedger
                                          .firstWhere(
                                              (e) => e.ledgerName == value);
                                      setState(() {
                                        selectedFreightLedger = value;
                                        selectedFreightLedgerId =
                                            selected.ledgerId;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  flex: 3,
                                  child: _tinyField(
                                      "Amount", freightChargeCtrl, null),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: primary.withAlpha(15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: primary.withAlpha(50)),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.add,
                                        color: primary, size: 18),
                                    onPressed: _addFreightCharge,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (freightCharges.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                List.generate(freightCharges.length, (index) {
                              final item = freightCharges[index];
                              return Chip(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: -4),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                label: Text(
                                    "${item["ledger"]}: ₹${(item["charge"] as double).toStringAsFixed(0)}",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                                deleteIcon: const Icon(Icons.close,
                                    size: 14, color: Colors.red),
                                onDeleted: () => _removeFreightCharge(index),
                              );
                            }),
                          ),
                        ],
                        const SizedBox(height: 8),

                        // ─── Freight Total, Gross Total ───
                        _summaryFlexRow2(
                          "Freight",
                          "₹${freightValue.toStringAsFixed(2)}",
                          "Gross Total",
                          "₹${netBillTotal.toStringAsFixed(2)}",
                        ),
                        const SizedBox(height: 8),

                        // ─── Disc %, Disc ───
                        Row(
                          children: [
                            Expanded(
                              child:
                                  _tinyField("Disc %", discountController, () {
                                _onDiscountChanged();
                              }),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _readOnlyMini("Disc",
                                  "₹${totalDiscAmt.toStringAsFixed(2)}"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // ─── Round Off ───
                        _tinyField("Round Off", roundOffController, () {
                          _onDiscountChanged();
                        }),
                      ],
                    ),
                  ),

                  // ─── Net Amount gradient strip ───
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, primary.withAlpha(200)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Net Bill Amount",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text("₹${netBillAmt.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),

                  // ─── Payment section ───
                  _card(
                    child: isCash
                        ? _buildCashPaymentSection()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primary.withAlpha(15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.credit_card,
                                    color: primary, size: 28),
                              ),
                              const SizedBox(height: 8),
                              const Text("Credit Payment",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text("Invoice will be saved on credit",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 8),

                  const Spacer(),
                  // ─── Buttons ───
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: primary),
                          ),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_rounded,
                                  size: 18, color: primary),
                              const SizedBox(width: 4),
                              const Text("Back"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          onPressed: _saveInvoice,
                          icon: const Icon(Icons.check_circle,
                              color: Colors.white, size: 20),
                          label: const Text("Save Invoice",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _summaryFlexRow(
    String l1,
    String v1,
    String l2,
    String v2,
    String l3,
    String v3,
  ) {
    Widget cell(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell(l1, v1),
        cell(l2, v2),
        cell(l3, v3),
      ],
    );
  }

  Widget _summaryFlexRow2(
    String l1,
    String v1,
    String l2,
    String v2,
  ) {
    Widget cell(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell(l1, v1),
        cell(l2, v2),
      ],
    );
  }

  Widget _buildCashPaymentSection() {
    return Consumer<LedgerTypeViewmodel>(
      builder: (context, ledgerVM, _) {
        final bankAmt = double.tryParse(bankAmountController.text) ?? 0;
        final bankEnabled = bankAmt > 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Row(
              children: [
                Icon(Icons.payments_outlined, color: primary, size: 16),
                const SizedBox(width: 4),
                const Text("Confirm Cash Payment",
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            // ─── Total Amount ───
            RichText(
              text: TextSpan(
                text: "Total Amount: ",
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: "₹${netBillAmt.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ─── Cash Payment Section ───
            _paymentSubSection(
              title: "Cash Payment",
              child: Row(
                children: [
                  Expanded(
                    child: _flexTextField(cashAmountController, "Cash Amount"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _flexReadOnlyChip("Mode: Cash"),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _flexReadOnlyChip("A/c: Cash"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ─── Bank Payment Section ───
            _paymentSubSection(
              title: "Bank Payment",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            _flexTextField(bankAmountController, "Bank Amount"),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _flexDropdown<String>(
                          label: "Mode",
                          value: selectedBankMode,
                          items: bankModes
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: bankEnabled
                              ? (v) => setState(() => selectedBankMode = v)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ledgerVM.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : _flexDropdown<String>(
                          label: "Bank Account",
                          value: ledgerVM.bankAccounts.isEmpty
                              ? "No Options"
                              : selectedBankAccount,
                          items: ledgerVM.bankAccounts.isEmpty
                              ? [
                                  const DropdownMenuItem(
                                      value: "No Options",
                                      child: Text("No Options"))
                                ]
                              : ledgerVM.bankAccounts
                                  .map((l) => DropdownMenuItem(
                                      value: l.ledgerName,
                                      child: Text(l.ledgerName ?? "",
                                          overflow: TextOverflow.ellipsis)))
                                  .toList(),
                          onChanged: bankEnabled
                              ? (v) => setState(() => selectedBankAccount = v)
                              : null,
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _paymentSubSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  // Flex-friendly variants (fixed height fallback to match UI bounds)
  Widget _flexTextField(TextEditingController ctrl, String label) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
      ),
    );
  }

  Widget _flexReadOnlyChip(String text) {
    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
    );
  }

  Widget _flexDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        isDense: true,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  void _addFreightCharge() {
    if (selectedFreightLedger != null && freightChargeCtrl.text.isNotEmpty) {
      double charge = double.tryParse(freightChargeCtrl.text) ?? 0;
      if (charge > 0) {
        setState(() {
          freightCharges.add({
            "ledgerId": selectedFreightLedgerId,
            "ledger": selectedFreightLedger ?? "",
            "charge": charge,
          });
          freightChargeCtrl.clear();
          selectedFreightLedger = null;

          freightValue = freightCharges.fold(
              0, (sum, item) => sum + (item["charge"] as double));
          _recalculateTotals();
          _onDiscountChanged();
        });
      }
    }
  }

  void _removeFreightCharge(int index) {
    setState(() {
      freightCharges.removeAt(index);
      freightValue = freightCharges.fold(
          0, (sum, item) => sum + (item["charge"] as double));
      _recalculateTotals();
      _onDiscountChanged();
    });
  }

  // ═══════════════════════════════════════════════════
  //  SHARED COMPACT WIDGETS
  // ═══════════════════════════════════════════════════

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _tinyField(
      String label, TextEditingController ctrl, VoidCallback? onChanged) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: ctrl,
        onChanged: (_) => onChanged?.call(),
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }

  Widget _tinyDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return SizedBox(
      height: 38,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        isDense: true,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _readOnlyMini(String label, String value, {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: highlight ? primary.withAlpha(15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: highlight ? primary.withAlpha(60) : Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: highlight ? primary : Colors.grey.shade600)),
            Text(value.isEmpty ? "—" : value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: highlight ? primary : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _miniField(TextEditingController ctrl, String label, IconData icon) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          prefixIcon: Icon(icon, size: 18),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ""),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return items;
        return items.where((item) =>
            item.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (selection) => onChanged(selection),
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                maxHeight: 220,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option, style: const TextStyle(fontSize: 13)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return SizedBox(
          height: 44,
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(fontSize: 12),
              hintText: "Search...",
              hintStyle: const TextStyle(fontSize: 12),
              suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
              filled: true,
              fillColor: Colors.grey.shade100,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _fieldRow(Widget a, Widget b) => Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
        ],
      );

  Widget _calcField(
      String label, TextEditingController c, VoidCallback? onChange,
      {bool ro = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: c,
          readOnly: ro,
          onChanged: (_) => onChange?.call(),
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 11),
            filled: true,
            fillColor: ro ? Colors.grey.shade200 : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
        ),
      ),
    );
  }
}
