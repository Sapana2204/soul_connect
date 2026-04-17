import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/PurchaseInvoiceItem_model.dart';
import '../model/addPurchase_model.dart';
import '../model/item_unit_model.dart';
import '../model/items_model.dart';
import '../model/itemDetailsForPurchaseReturn_model.dart';
import '../model/party_model.dart';
import '../model/purchaseReturn_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewmodel/addPurchase_viewmodel.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewmodel/ledger_type_viewmodel.dart';
import '../viewmodel/purchaseReturn_viewmodel.dart';
import '../viewmodel/purchase_invoice_viewmodel.dart';
import 'purchase_mode.dart';
import '../model/addPurchase_model.dart' as ap;
import '../model/purchaseReturn_model.dart' as pr;

class NewPurchaseInwardUI extends StatefulWidget {
  final bool isReturn;

  const NewPurchaseInwardUI({super.key, this.isReturn = false});

  @override
  State<NewPurchaseInwardUI> createState() => _NewPurchaseInwardUIState();
}

class _NewPurchaseInwardUIState extends State<NewPurchaseInwardUI> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ─── Supplier & Bill Details (Page 1) ───
  DateTime purchaseDate = DateTime.now();
  PartyModel? selectedSupplier;
  final bool isChallan = true;
  String? selectedPayMode = "Cash";
  String? selectedPaymentTerm;
  String? selectedLocationId;
  String taxType = "E";
  int? selectedLedgerId;
  double ledgerOutstandingBalance = 0;
  String ledgerBalanceType = "Cr";

  final TextEditingController supplierController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController billNoController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  final List<String> payModes = ["Cash", "Credit"];
  final List<Map<String, String>> taxTypes = [
    {"label": "Exclusive (GST)", "value": "E"},
    {"label": "Inclusive (GST)", "value": "I"},
    {"label": "No Tax", "value": "N"},
  ];

  // ─── Products (Page 2) — inline entry fields ───
  final List<PurchaseInvoiceItem> items = [];

  // Product entry controllers (from PurchaseSelectProductPopup)
  final TextEditingController productSearchCtrl = TextEditingController();
  final FocusNode _productFocusNode = FocusNode();
  ItemsModel? _selectedProduct;
  int? _selectedProductId;
  double _selectedGst = 0;
  ItemUnitModel? _selectedUnitModel;
  List<ItemDetailsForPurchaseReturnModel> _returnItems = [];
  bool _isReturnLoading = false;

  final TextEditingController _barcodeCtrl = TextEditingController();
  final TextEditingController _hsnCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();
  final TextEditingController _mrpCtrl = TextEditingController();
  final TextEditingController _gstCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: "1");
  final TextEditingController _freeQtyCtrl = TextEditingController(text: "0");
  final TextEditingController _rateCtrl = TextEditingController();
  final TextEditingController _baseRateCtrl = TextEditingController();
  final TextEditingController _discPerCtrl = TextEditingController(text: "0");
  final TextEditingController _discAmtCtrl = TextEditingController(text: "0");
  final TextEditingController _totalDiscCtrl = TextEditingController();
  final TextEditingController _subtotalCtrl = TextEditingController();
  final TextEditingController _taxableCtrl = TextEditingController();
  final TextEditingController _taxAmtCtrl = TextEditingController();
  final TextEditingController _netTotalCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();

  // ─── Bill Totals (Page 3) ───
  double totalQtyValue = 0;
  double freeQtyValue = 0;
  double itemTotalValue = 0;
  double discPercValue = 0;
  double discAmtValue = 0;
  double taxableAmtValue = 0;
  double taxAmtValue = 0;
  double totalAmtValue = 0;
  double netBillTotalValue = 0;
  double netBillAmtValue = 0;
  double freightValue = 0;
  List<Map<String, dynamic>> freightCharges = [];

  final TextEditingController discountController = TextEditingController();
  final TextEditingController roundOffController = TextEditingController();

  // ─── Freight in-row state ───
  String? selectedFreightLedger;
  int? selectedFreightLedgerId;
  final TextEditingController freightChargeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    discountController.addListener(_applyGlobalDiscount);
    roundOffController.addListener(_recalculateTotals);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final purchaseVM =
        Provider.of<PurchaseInvoiceViewmodel>(context, listen: false);
    final itemVM = Provider.of<ItemViewmodel>(context, listen: false);
    final ledgerVM = Provider.of<LedgerTypeViewmodel>(context, listen: false);

    purchaseVM.getPurchasePartyApi();
    purchaseVM.fetchTaxGroupPercentage();
    itemVM.getStockLocationsApi();
    ledgerVM.loadFreightPostageLedger();

    // Load items for product search
    if (widget.isReturn) {
      // Return items loaded after supplier selected
    } else {
      itemVM.getItemsApi();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    supplierController.dispose();
    vehicleController.dispose();
    billNoController.dispose();
    gstController.dispose();
    discountController.dispose();
    roundOffController.dispose();
    freightChargeCtrl.dispose();
    productSearchCtrl.dispose();
    _productFocusNode.dispose();
    _barcodeCtrl.dispose();
    _hsnCtrl.dispose();
    _unitCtrl.dispose();
    _mrpCtrl.dispose();
    _gstCtrl.dispose();
    _qtyCtrl.dispose();
    _freeQtyCtrl.dispose();
    _rateCtrl.dispose();
    _baseRateCtrl.dispose();
    _discPerCtrl.dispose();
    _discAmtCtrl.dispose();
    _totalDiscCtrl.dispose();
    _subtotalCtrl.dispose();
    _taxableCtrl.dispose();
    _taxAmtCtrl.dispose();
    _netTotalCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════
  //  CALCULATION LOGIC (bill totals)
  // ═══════════════════════════════════════════════════

  void _applyGlobalDiscount() {
    double globalDiscPer = double.tryParse(discountController.text) ?? 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      double baseTotal = item.originalItemTotal ?? 0;
      double totalDiscAmt = baseTotal * globalDiscPer / 100;
      double taxableAmt = baseTotal - totalDiscAmt;
      double taxAmt = taxableAmt * (item.taxPerc ?? 0) / 100;
      double netAmt = taxableAmt + taxAmt;

      items[i] = PurchaseInvoiceItem(
        unitId: item.unitId,
        itemId: item.itemId,
        productName: item.productName,
        batch: item.batch,
        expiry: item.expiry,
        barcode: item.barcode,
        qty: item.qty,
        free: item.free,
        rate: item.rate,
        rateWithGST: item.rateWithGST,
        discountPerc: globalDiscPer,
        discountAmt: totalDiscAmt,
        taxPerc: item.taxPerc,
        taxRate: item.taxRate,
        itemTotal: baseTotal,
        taxableAmt: taxableAmt,
        taxAmt: taxAmt,
        netAmt: netAmt,
        totalTaxAmt: taxAmt,
        cash: item.cash,
        credit: item.credit,
        mrp: item.mrp,
        outlet: item.outlet,
        hsn: item.hsn,
        mfgDate: item.mfgDate,
        schemePerc: item.schemePerc,
        schemeAmt: item.schemeAmt,
        taxGroupId: item.taxGroupId,
        taxable: item.taxable,
        purDtlsId: item.purDtlsId,
        taxPer1: item.taxPer1,
        taxAmt1: item.taxAmt1,
        taxPer2: item.taxPer2,
        taxAmt2: item.taxAmt2,
        taxPer3: item.taxPer3,
        taxAmt3: item.taxAmt3,
        taxPer4: item.taxPer4,
        taxAmt4: item.taxAmt4,
        taxPer5: item.taxPer5,
        taxAmt5: item.taxAmt5,
        originalDiscountAmt: item.originalDiscountAmt,
        originalItemTotal: item.originalItemTotal,
      );
    }

    _recalculateTotals();
  }

  void _recalculateTotals() {
    double totalQty = 0;
    double freeQty = 0;
    double itemTotal = 0;
    double totalDiscount = 0;
    double taxableTotal = 0;
    double totalTax = 0;
    double totalNet = 0;

    for (var item in items) {
      totalQty += item.qty ?? 0;
      freeQty += item.free ?? 0;
      itemTotal += (item.rate ?? 0) * (item.qty ?? 0);
      totalDiscount += item.discountAmt ?? 0;
      taxableTotal += item.taxableAmt ?? 0;
      totalTax += item.taxAmt ?? 0;
      totalNet += item.netAmt ?? 0;
    }

    double roundOff = double.tryParse(roundOffController.text) ?? 0;
    double netBillTotal = totalNet + freightValue;
    double netBillAmt = netBillTotal + roundOff;

    setState(() {
      totalQtyValue = totalQty;
      freeQtyValue = freeQty;
      itemTotalValue = itemTotal;
      discPercValue = double.tryParse(discountController.text) ?? 0;
      discAmtValue = totalDiscount;
      taxableAmtValue = taxableTotal;
      taxAmtValue = totalTax;
      totalAmtValue = totalNet;
      netBillTotalValue = netBillTotal;
      netBillAmtValue = netBillAmt;
    });
  }

  // ═══════════════════════════════════════════════════
  //  PRODUCT CALCULATION (per item - from popup)
  // ═══════════════════════════════════════════════════

  double _d(TextEditingController c, {double def = 0.0}) =>
      double.tryParse(c.text.trim()) ?? def;

  int _i(TextEditingController c, {int def = 0}) =>
      int.tryParse(c.text.trim()) ?? def;

  void _calculateProductTotal({String? active}) {
    final qty = _i(_qtyCtrl, def: 1);
    final rate = _d(_rateCtrl);
    double gst = _d(_gstCtrl);

    final taxTypeUpper = taxType.toUpperCase();
    final isInclusive = taxTypeUpper == "I";
    final isNoTax = taxTypeUpper == "N";

    if (isNoTax) gst = 0;

    double baseRate;
    double baseAmount;

    if (isInclusive) {
      baseRate = gst > 0 ? (rate * 100) / (100 + gst) : rate;
      baseAmount = baseRate * qty;
      _baseRateCtrl.text = baseRate.toStringAsFixed(2);
    } else {
      baseRate = rate;
      baseAmount = rate * qty;
    }

    double discTotal = 0;
    _totalDiscCtrl.text = discTotal.toStringAsFixed(2);

    final discPer = _d(_discPerCtrl);
    final discAmt = _d(_discAmtCtrl);
    final discBase = isInclusive ? rate : baseRate;

    if (active == "per") {
      final perItem = double.parse(((discBase * discPer) / 100).toStringAsFixed(2));
      discTotal = double.parse((perItem * qty).toStringAsFixed(2));
      _discAmtCtrl.text = perItem.toStringAsFixed(2);
    } else if (active == "amt") {
      discTotal = double.parse((discAmt * qty).toStringAsFixed(2));
      _discPerCtrl.text =
          discBase > 0 ? ((discAmt / discBase) * 100).toStringAsFixed(2) : "0";
    } else {
      discTotal = double.parse((((discBase * discPer) / 100) * qty).toStringAsFixed(2));
    }

    final taxable = isInclusive && gst > 0
        ? double.parse(((rate * qty - discTotal) * 100 / (100 + gst)).toStringAsFixed(2))
        : double.parse((baseAmount - discTotal).toStringAsFixed(2));
    final tax = isNoTax ? 0.0 : double.parse(((taxable * gst) / 100).toStringAsFixed(2));

    _subtotalCtrl.text = baseAmount.toStringAsFixed(2);
    _totalDiscCtrl.text = discTotal.toStringAsFixed(2);
    _taxableCtrl.text = taxable.toStringAsFixed(2);
    _taxAmtCtrl.text = tax.toStringAsFixed(2);

    _totalCtrl.text = (taxable + tax).toStringAsFixed(2);

    _netTotalCtrl.text = _totalCtrl.text;
  }

  void _fillFieldsFromItem(ItemsModel item) {
    _hsnCtrl.text = item.hSNCode ?? "";
    _unitCtrl.text = item.unitName ?? "";

    final rate = item.lASTPURCHASERATE ?? item.lastPurchaseRate ?? 0;
    _rateCtrl.text = rate.toString();

    final baseRate = item.lastPurchaseRate ?? 0;
    _baseRateCtrl.text = baseRate.toString();

    final mrp = item.lASTMRP ?? item.baseRate ?? 0;
    _mrpCtrl.text = mrp.toString();

    final gst = double.tryParse(item.taxPer ?? "0") ?? 0;
    _selectedGst = gst;
    _gstCtrl.text = gst.toString();
    _barcodeCtrl.text = item.barcode ?? "";

    _qtyCtrl.text = "1";
    _freeQtyCtrl.text = "0";
    _discPerCtrl.text = "0";
    _discAmtCtrl.text = "0";
    _netTotalCtrl.text = _totalCtrl.text;

    _calculateProductTotal();
  }

  void _resetProductFields() {
    _selectedProduct = null;
    _selectedProductId = null;
    _selectedUnitModel = null;
    productSearchCtrl.clear();
    _barcodeCtrl.clear();
    _hsnCtrl.clear();
    _unitCtrl.clear();
    _mrpCtrl.clear();
    _gstCtrl.clear();
    _rateCtrl.clear();
    _baseRateCtrl.clear();
    _qtyCtrl.text = "1";
    _freeQtyCtrl.text = "0";
    _discPerCtrl.text = "0";
    _discAmtCtrl.text = "0";
    _totalDiscCtrl.clear();
    _subtotalCtrl.clear();
    _taxableCtrl.clear();
    _taxAmtCtrl.clear();
    _netTotalCtrl.clear();
    _totalCtrl.clear();
  }

  void _addProductToList() {
    if (widget.isReturn && _selectedProductId == null) {
      _showValidation("Please select a product");
      return;
    }
    if (!widget.isReturn && _selectedProduct == null) {
      _showValidation("Please select a product");
      return;
    }

    final qty = _i(_qtyCtrl, def: 1).toDouble();
    final rate = _d(_rateCtrl);
    final gst = _d(_gstCtrl);
    final discPer = _d(_discPerCtrl);
    final discAmt = _d(_discAmtCtrl);

    final base = qty * rate;
    final discountTotal =
        discAmt > 0 ? discAmt * qty : ((rate * discPer) / 100) * qty;

    final taxable = base - discountTotal;
    final taxAmt = (taxable * gst) / 100;

    final purchaseInvoiceItem = PurchaseInvoiceItem(
      unitId: _selectedUnitModel?.unitId ?? _selectedProduct?.unitId ?? 0,
      itemId: _selectedProduct?.itemId ?? _selectedProductId,
      productName: _selectedProduct?.itemName ??
          _returnItems
              .firstWhere((e) => e.itemId == _selectedProductId)
              .itemName,
      qty: qty,
      free: _d(_freeQtyCtrl),
      rate: rate,
      rateWithGST: rate,
      discountPerc: discPer,
      taxPerc: gst,
      itemTotal: _d(_subtotalCtrl),
      discountAmt: discountTotal,
      taxableAmt: _d(_taxableCtrl),
      netAmt: _d(_totalCtrl),
      cash: 0,
      credit: 0,
      mrp: int.tryParse(_mrpCtrl.text) ?? 0,
      outlet: 0,
      hsn: _hsnCtrl.text,
      mfgDate: "",
      schemePerc: 0,
      schemeAmt: 0,
      taxAmt: _d(_taxAmtCtrl),
      totalTaxAmt: _d(_taxAmtCtrl),
      taxable: taxType.toLowerCase() != "no tax",
      taxGroupId: _selectedProduct?.taxGroupId,
      originalDiscountAmt: discountTotal,
      originalItemTotal: _d(_subtotalCtrl),
    );

    // Check expiry
    if (_isExpired(purchaseInvoiceItem.expiry)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Text(
            Strings.purchaseExpiredProductMessage
                .replaceAll("{date}", _formatDate(purchaseInvoiceItem.expiry)),
          ),
        ),
      );
      return;
    }

    // Check duplicate
    final alreadyExists = items.any((e) =>
        (e.itemId == purchaseInvoiceItem.itemId) &&
        (e.batch?.trim().toLowerCase() ==
            purchaseInvoiceItem.batch?.trim().toLowerCase()));

    if (alreadyExists) {
      _showValidation(Strings.purchaseProductBatchExists);
      return;
    }

    setState(() {
      items.add(purchaseInvoiceItem);
      _recalculateTotals();
      _resetProductFields();
    });
  }

  Future<void> _loadReturnItems() async {
    if (selectedSupplier == null || selectedLocationId == null) return;
    setState(() => _isReturnLoading = true);

    try {
      final vm = Provider.of<PurchaseReturnViewmodel>(context, listen: false);
      final data = await vm.getItemDetailsForPurchaseReturn(
        locationId: int.parse(selectedLocationId!),
        partyId: selectedSupplier?.partyId ?? 0,
        itemId: 0,
      );
      setState(() {
        _returnItems = data;
      });
    } catch (e) {
      debugPrint("Error loading return items: $e");
    } finally {
      setState(() => _isReturnLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════

  bool _isExpired(String? expiry) {
    if (expiry == null || expiry.isEmpty) return false;
    try {
      final expiryDate = DateFormat('dd-MM-yyyy').parseStrict(expiry);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final expDate =
          DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
      return expDate.isBefore(todayDate);
    } catch (e) {
      return false;
    }
  }

  String? convertToIso(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      final parsed = DateFormat('dd-MM-yyyy').parse(date);
      return parsed.toUtc().toIso8601String();
    } catch (e) {
      return null;
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  int getLedgerIdFromName(String ledgerName) {
    final ledgerVM = Provider.of<LedgerTypeViewmodel>(context, listen: false);
    try {
      final ledger = ledgerVM.freightPostageLedger
          .firstWhere((l) => l.ledgerName == ledgerName);
      return ledger.ledgerId ?? 0;
    } catch (e) {
      return 0;
    }
  }

  void logLong(String tag, String message) {
    const int chunkSize = 800;
    for (int i = 0; i < message.length; i += chunkSize) {
      log(message.substring(
          i, i + chunkSize > message.length ? message.length : i + chunkSize));
    }
  }

  Future<void> _selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => purchaseDate = picked);
    }
  }

  Future<void> _fetchLedgerBalance(int ledgerId) async {
    final purchaseVM =
        Provider.of<PurchaseInvoiceViewmodel>(context, listen: false);
    final now = DateFormat("yyyy-MM-dd").format(DateTime.now());

    await purchaseVM.getLedgerBalanceApi(
      ledgerId: ledgerId,
      balanceAsOn: now,
      balanceType: "B",
    );

    final balance = purchaseVM.ledgerBalance;

    setState(() {
      ledgerOutstandingBalance = balance?.balance?.abs() ?? 0;
      ledgerBalanceType = (balance?.balanceType ?? "T") == "T"
          ? "Cr"
          : balance?.balanceType ?? "Cr";
    });
  }

  void _addFreightCharge() {
    final charge = double.tryParse(freightChargeCtrl.text) ?? 0;
    if (selectedFreightLedger == null || charge <= 0) return;

    setState(() {
      freightCharges.add({
        "ledger": selectedFreightLedger,
        "charge": charge,
      });
      freightValue =
          freightCharges.fold<double>(0, (sum, e) => sum + (e["charge"] ?? 0));
      selectedFreightLedger = null;
      selectedFreightLedgerId = null;
      freightChargeCtrl.clear();
      _recalculateTotals();
    });
  }

  void _removeFreightCharge(int index) {
    setState(() {
      freightCharges.removeAt(index);
      freightValue =
          freightCharges.fold<double>(0, (sum, e) => sum + (e["charge"] ?? 0));
      _recalculateTotals();
    });
  }

  // ═══════════════════════════════════════════════════
  //  VALIDATION
  // ═══════════════════════════════════════════════════

  bool _validatePage1() {
    if (selectedSupplier == null) {
      _showValidation("Please select a supplier");
      return false;
    }
    if (selectedLocationId == null) {
      _showValidation("Please select a stock location");
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  SAVE LOGIC
  // ═══════════════════════════════════════════════════

  Future<void> _saveInvoice() async {
    if (selectedSupplier == null) {
      _showValidation(Strings.purchaseSelectSupplierError);
      return;
    }
    if (items.isEmpty) {
      _showValidation(Strings.purchaseAddProductError);
      return;
    }
    for (var item in items) {
      if (item.itemId == null || item.itemId == 0) {
        _showValidation("Invalid product itemId");
        return;
      }
    }

    Map<String, dynamic> requestBody;
    if (widget.isReturn) {
      requestBody = _buildPurchaseReturnRequest();
    } else {
      requestBody = _buildPurchaseRequest();
    }

    logLong('Request Body', jsonEncode(requestBody));

    bool success;
    if (widget.isReturn) {
      final purchaseReturnVM =
          Provider.of<PurchaseReturnViewmodel>(context, listen: false);
      success = await purchaseReturnVM.addPurchaseReturn(requestBody);
    } else {
      final addPurchaseVM =
          Provider.of<AddPurchaseViewmodel>(context, listen: false);
      success = await addPurchaseVM.addPurchase(requestBody);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isReturn
                ? "Purchase Return Saved Successfully"
                : Strings.purchaseSaveSuccess,
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(Strings.purchaseSaveFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _buildPurchaseRequest() {
    final now = DateTime.now().toUtc();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final int userId = int.tryParse(loginVM.userId ?? "0") ?? 0;
    final int firmId = int.tryParse(loginVM.firmId ?? "0") ?? 0;
    final purchaseVM =
        Provider.of<PurchaseInvoiceViewmodel>(context, listen: false);

    final purchase = AddPurchaseModel(
      purchaseId: 0,
      purchaseSeriesId: 1,
      purchaseDate: DateFormat('yyyy-MM-dd').format(purchaseDate),
      supplierId: selectedSupplier?.partyId ?? 0,
      supplierBillNo: billNoController.text.trim(),
      totalQty: totalQtyValue,
      freeQty: freeQtyValue,
      subTotal: itemTotalValue,
      discAmt: discAmtValue,
      taxableAmt: taxableAmtValue,
      totalTaxAmt: taxAmtValue,
      invoiceChargesAmt: freightCharges
          .fold<double>(0, (sum, item) => sum + (item["charge"] ?? 0))
          .toInt(),
      netAmt: netBillAmtValue,
      grossBillDiscountAmt: 0,
      grossBillDiscountPer: discPercValue,
      paidAmt: 0,
      balAmt: 0,
      billPaidStatus: "",
      narration: "",
      byHand: "",
      vehicleDetails: vehicleController.text,
      isBillPaid: 1,
      createdBy: userId,
      updatedBy: userId,
      userId: userId,
      isChallan: isChallan,
      isPurchased: true,
      isWithoutGST: taxType == "E" ? false : true,
      isPurchaseReturned: false,
      isCancelled: false,
      locationId: int.tryParse(selectedLocationId ?? "0") ?? 0,
      firmId: firmId,
      supplierName: selectedSupplier?.partyName ?? "",
      address: selectedSupplier?.address ?? "",
      mobile: selectedSupplier?.mobile ?? "",
      gSTIN: selectedSupplier?.gSTIN ?? "",
      payMode: selectedPayMode ?? "",
      paymentTerm: selectedPaymentTerm ?? "",
      taxIncludeExclude: taxType,
      createdOn: now.toIso8601String(),
      updatedOn: now.toIso8601String(),
      details: items.map((item) {
        final baseTotal = (item.qty ?? 0) * (item.rate ?? 0);
        final discPer = item.discountPerc ?? 0;
        final itemDisc = item.discountAmt ?? 0;
        final taxable = item.taxableAmt ?? 0;
        final totalTaxAmt = item.taxAmt ?? 0;
        final netAmt = item.netAmt ?? 0;

        final taxComponents = purchaseVM.taxGroupList
            .where((t) => t.taxGroupId == item.taxGroupId)
            .toList();

        double taxPer1 = 0, taxAmt1 = 0;
        double taxPer2 = 0, taxAmt2 = 0;
        double taxPer3 = 0, taxAmt3 = 0;
        double taxPer4 = 0, taxAmt4 = 0;
        double taxPer5 = 0, taxAmt5 = 0;

        if (taxComponents.isNotEmpty) {
          if (taxComponents.length > 0) {
            taxPer1 = taxComponents[0].taxPer ?? 0;
            taxAmt1 = taxable * taxPer1 / 100;
          }
          if (taxComponents.length > 1) {
            taxPer2 = taxComponents[1].taxPer ?? 0;
            taxAmt2 = taxable * taxPer2 / 100;
          }
          if (taxComponents.length > 2) {
            taxPer3 = taxComponents[2].taxPer ?? 0;
            taxAmt3 = taxable * taxPer3 / 100;
          }
          if (taxComponents.length > 3) {
            taxPer4 = taxComponents[3].taxPer ?? 0;
            taxAmt4 = taxable * taxPer4 / 100;
          }
          if (taxComponents.length > 4) {
            taxPer5 = taxComponents[4].taxPer ?? 0;
            taxAmt5 = taxable * taxPer5 / 100;
          }
        }

        return ap.Details(
          purDtlsId: 0,
          purchaseId: 0,
          itemId: item.itemId!,
          unitId: item.unitId ?? 0,
          quantity: item.qty ?? 0,
          freeQuantity: item.free ?? 0,
          rate: item.rate ?? 0,
          itemTotal: baseTotal,
          discPer: discPer,
          discAmt: itemDisc,
          taxableAmt: taxable,
          totalTaxAmt: totalTaxAmt,
          totalTaxPer: taxPer1 + taxPer2 + taxPer3 + taxPer4 + taxPer5,
          netAmt: netAmt,
          taxPer1: taxPer1,
          taxAmt1: taxAmt1,
          taxPer2: taxPer2,
          taxAmt2: taxAmt2,
          taxPer3: taxPer3,
          taxAmt3: taxAmt3,
          taxPer4: taxPer4,
          taxAmt4: taxAmt4,
          taxPer5: taxPer5,
          taxAmt5: taxAmt5,
          taxGroupId: item.taxGroupId ?? 0,
          isWithoutGST: taxType == "E" ? false : true,
          schemePer: item.schemeAmt ?? 0,
          schemeAmt: item.schemeAmt ?? 0,
          barcode: item.barcode ?? "",
          mRP: (item.mrp).toDouble(),
          purchaseRate: item.rate,
          salesRate: (item.cash).toDouble(),
          salesRate1: (item.outlet).toDouble(),
          salesRate2: (item.credit).toDouble(),
          cashRateMargin: 0,
          creditRateMargin: 0,
          outletRateMargin: 0,
          returnQty: 0,
          hSNCode: item.hsn,
          itemName: item.productName ?? "",
          unitName: "",
          batchNo: item.batch ?? "",
          mfgDate: convertToIso(item.mfgDate),
          expDate: convertToIso(item.expiry),
          firmId: firmId,
          locationId: int.tryParse(selectedLocationId ?? "0") ?? 0,
        );
      }).toList(),
      purchaseOtherCharges: freightCharges.map((charge) {
        return PurchaseOtherCharges(
          purchaseInvChargeId: 0,
          purchaseId: 0,
          ledgerId: getLedgerIdFromName(charge["ledger"]),
          amount: charge["charge"],
          ledgerName: charge["ledger"],
        );
      }).toList(),
    );

    return purchase.toJson();
  }

  Map<String, dynamic> _buildPurchaseReturnRequest() {
    final now = DateTime.now().toIso8601String();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final int userId = int.tryParse(loginVM.userId ?? "0") ?? 0;
    final int firmId = int.tryParse(loginVM.firmId ?? "0") ?? 0;

    final model = PurchaseReturnModel(
      returnId: 0,
      returnDate: now,
      supplierId: selectedSupplier?.partyId ?? 0,
      totalQty: totalQtyValue.toInt(),
      freeQty: 0,
      subTotal: itemTotalValue.toInt(),
      discAmt: discAmtValue.toInt(),
      taxableAmt: taxableAmtValue.toInt(),
      totalTaxAmt: taxAmtValue.toInt(),
      invoiceChargesAmt: freightValue.toInt(),
      roundOff: double.tryParse(roundOffController.text)?.toInt() ?? 0,
      netAmt: netBillAmtValue.toInt(),
      narration: "",
      byHand: "",
      firmId: firmId,
      locationId: int.tryParse(selectedLocationId ?? "0") ?? 0,
      purchaseId: 0,
      isCancelled: false,
      preparedBy: userId,
      createdBy: userId,
      createdOn: now,
      updatedBy: userId,
      updatedOn: now,
      userID: userId,
      details: items.map((item) {
        return pr.Details(
          itemId: item.itemId ?? 0,
          unitId: item.unitId ?? 0,
          quantity: (item.qty ?? 0).toInt(),
          freeQuantity: 0,
          rate: (item.rate ?? 0).toInt(),
          purchaseRateWithTax: (item.rateWithGST ?? 0).toInt(),
          itemTotal: (item.itemTotal ?? 0).toInt(),
          discPer: (item.discountPerc ?? 0).toInt(),
          discAmt: (item.discountAmt ?? 0).toInt(),
          taxableAmt: (item.taxableAmt ?? 0).toInt(),
          totalTaxAmt: (item.taxAmt ?? 0).toInt(),
          netAmt: (item.netAmt ?? 0).toInt(),
          batchNo: item.batch ?? "",
          mfgDate: DateTime.now().toIso8601String(),
          expDate: DateTime.now().toIso8601String(),
          taxPer1: (item.taxPer1 ?? 0).toInt(),
          taxAmt1: (item.taxAmt1 ?? 0).toInt(),
          taxPer2: (item.taxPer2 ?? 0).toInt(),
          taxAmt2: (item.taxAmt2 ?? 0).toInt(),
          taxPer3: (item.taxPer3 ?? 0).toInt(),
          taxAmt3: (item.taxAmt3 ?? 0).toInt(),
          taxPer4: (item.taxPer4 ?? 0).toInt(),
          taxAmt4: (item.taxAmt4 ?? 0).toInt(),
          taxPer5: (item.taxPer5 ?? 0).toInt(),
          taxAmt5: (item.taxAmt5 ?? 0).toInt(),
          stkPurchaseId: 0,
          isWithoutGST: true,
          actRetQty: (item.qty ?? 0).toInt(),
          firmId: firmId,
          locationId: int.tryParse(selectedLocationId ?? "0") ?? 0,
          barcode: "",
        );
      }).toList(),
      otherCharges: freightCharges.map((charge) {
        return OtherCharges(
          ledgerId: getLedgerIdFromName(charge["ledger"]),
          amount: (charge["charge"] ?? 0).toInt(),
        );
      }).toList(),
    );

    return model.toJson();
  }

  void _showProductDetails(PurchaseInvoiceItem item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.productName ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _detailRow("Batch No", item.batch ?? ""),
                _detailRow("Expiry", _formatDate(item.expiry)),
                _detailRow("Rate", "₹${item.rate.toStringAsFixed(2)}"),
                _detailRow("Quantity", "${item.qty}"),
                _detailRow("Free Qty", "${item.free}"),
                _detailRow("MRP", "₹${item.mrp.toStringAsFixed(2)}"),
                _detailRow("HSN", item.hsn ?? ""),
                const Divider(),
                _detailRow("Discount (%)", "${item.discountPerc}"),
                _detailRow(
                    "Discount Amt", "₹${item.discountAmt.toStringAsFixed(2)}"),
                _detailRow("Scheme (%)", "${item.schemePerc}"),
                _detailRow(
                    "Scheme Amt", "₹${item.schemeAmt.toStringAsFixed(2)}"),
                const Divider(),
                _detailRow("Tax (%)", "${item.taxPerc}"),
                _detailRow("Taxable", "₹${item.taxableAmt}"),
                _detailRow(
                    "Total Tax Amt", "₹${item.totalTaxAmt.toStringAsFixed(2)}"),
                _detailRow("Net Amount", "₹${item.netAmt.toStringAsFixed(2)}"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PAGE NAVIGATION
  // ═══════════════════════════════════════════════════

  void _goToPage(int page) {
    if (page == 1 && !_validatePage1()) return;
    if (page == 2 && !_validatePage2()) return;
    if (page == 2) _recalculateTotals();

    // Load return items when moving to page 2 in return mode
    if (page == 1 && widget.isReturn) {
      _loadReturnItems();
    }

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // ═══════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentPage > 0) {
          _goToPage(_currentPage - 1);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xffEEF1F8),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primary,
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          title: Text(widget.isReturn ? "Purchase Return" : "Purchase (Inward)",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 17)),
          actions: [
            GestureDetector(
              onTap: _selectPurchaseDate,
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
                    Text(DateFormat('dd MMM yyyy').format(purchaseDate),
                        style: TextStyle(
                            fontSize: 12,
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
  //  STEP INDICATOR
  // ═══════════════════════════════════════════════════

  Widget _buildStepIndicator() {
    final steps = ["Supplier", "Products", "Confirm"];
    final icons = [
      Icons.business_outlined,
      Icons.inventory_2_outlined,
      Icons.check_circle_outline
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(steps.length, (i) {
          final done = _currentPage > i;
          final active = _currentPage == i;
          return GestureDetector(
            onTap: () {
              if (i < _currentPage) _goToPage(i);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icons[i],
                    size: 20,
                    color: active
                        ? primary
                        : (done ? Colors.green : Colors.grey.shade400)),
                const SizedBox(height: 2),
                Text(steps[i],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? primary
                            : (done ? Colors.green : Colors.grey.shade400))),
                const SizedBox(height: 2),
                Container(
                  height: 2.5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: active
                        ? primary
                        : (done ? Colors.green : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PAGE 1 — Supplier (inline fields)
  // ═══════════════════════════════════════════════════

  Widget _buildPage1() {
    final stklocviewModel = Provider.of<ItemViewmodel>(context);
    final purchaseInvoiceVM = Provider.of<PurchaseInvoiceViewmodel>(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ══════════════════════════════════════════
                //  SECTION 1: Supplier
                // ══════════════════════════════════════════
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business_outlined,
                              color: primary, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            widget.isReturn
                                ? "Purchase Return Details"
                                : Strings.supplierDetails,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ─── Location Dropdown ───
                      DropdownButtonFormField<String>(
                        value: selectedLocationId,
                        decoration: _inputDecoration(Strings.selectLocation,
                            icon: Icons.location_on),
                        isExpanded: true,
                        items:
                            stklocviewModel.stockLocationsList.map((location) {
                          return DropdownMenuItem<String>(
                            value: location.locationId?.toString(),
                            child:
                                Text(location.locationName ?? Strings.unknown),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLocationId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      // ─── Supplier Searchable Autocomplete ───
                      _buildSupplierAutocomplete(purchaseInvoiceVM),

                      const SizedBox(height: 14),

                      // ─── GST No (read-only, filled from supplier) ───
                      TextField(
                        controller: gstController,
                        readOnly: true,
                        decoration: _inputDecoration("GST No",
                            icon: Icons.confirmation_number),
                      ),

                      // ─── Outstanding Balance ───
                      if (selectedSupplier != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withAlpha(60)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Outstanding Balance",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red)),
                              const SizedBox(height: 2),
                              Text(
                                  "₹${ledgerOutstandingBalance.toStringAsFixed(2)} $ledgerBalanceType",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ══════════════════════════════════════════
                //  SECTION 2: Bill Settings
                // ══════════════════════════════════════════
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings_outlined,
                              color: primary, size: 20),
                          const SizedBox(width: 6),
                          const Text("Bill Settings",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ─── Pay Mode ───
                      if (!widget.isReturn) ...[
                        DropdownButtonFormField<String>(
                          value: selectedPayMode,
                          decoration: _inputDecoration(Strings.payMode,
                              icon: Icons.payment),
                          items: payModes.map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(mode),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPayMode = value;
                            });

                            if (value == "Credit") {
                              _showPaymentTermDialog();
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ─── Tax Type ───
                      if (!widget.isReturn) ...[
                        DropdownButtonFormField<String>(
                          value: taxType,
                          decoration: _inputDecoration(Strings.taxType,
                              icon: Icons.percent),
                          items: taxTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type["value"],
                              child: Text(type["label"]!),
                            );
                          }).toList(),
                          onChanged: items.isNotEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    taxType = value ?? "E";
                                  });
                                },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ─── Bill No ───
                      if (!widget.isReturn) ...[
                        TextField(
                          controller: billNoController,
                          decoration: _inputDecoration('Bill No',
                              icon: Icons.description),
                        ),
                        const SizedBox(height: 14),
                      ],
/* 
                      // ─── Vehicle Details ───
                      TextField(
                        controller: vehicleController,
                        decoration: _inputDecoration('Vehicle No',
                            icon: Icons.local_shipping),
                      ),
 */
                      // ─── Payment Term (show if set) ───
                      if (selectedPaymentTerm != null &&
                          selectedPaymentTerm!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _readOnlyChip(
                            "Payment Term", "$selectedPaymentTerm days"),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Next button ───
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

  Widget _buildSupplierAutocomplete(
      PurchaseInvoiceViewmodel purchaseInvoiceVM) {
    if (purchaseInvoiceVM.loading) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final supplierNames = selectedLocationId == null
        ? <String>[]
        : purchaseInvoiceVM.partyList
            .map((party) => party.partyName ?? "")
            .where((n) => n.isNotEmpty)
            .toList();

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: selectedSupplier?.partyName ?? ""),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return supplierNames;
        return supplierNames.where((item) =>
            item.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (selection) {
        final supplier = purchaseInvoiceVM.partyList
            .firstWhere((p) => p.partyName == selection);

        final int? oldSupplierId = selectedSupplier?.partyId;
        final int? newSupplierId = supplier.partyId;

        final bool supplierChanged = oldSupplierId != null &&
            newSupplierId != null &&
            oldSupplierId != newSupplierId;

        setState(() {
          if (supplierChanged) {
            items.clear();
            freightCharges.clear();
            freightValue = 0;
            discountController.clear();
            roundOffController.clear();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(Strings.purchaseSupplierChanged)),
            );
          }

          selectedSupplier = supplier;
          selectedLedgerId = supplier.ledgerId;
          supplierController.text = supplier.partyName ?? '';
          gstController.text =
              supplier.gSTIN?.isNotEmpty == true ? supplier.gSTIN! : '';

          if (supplier.ledgerId != null) {
            _fetchLedgerBalance(supplier.ledgerId!);
          }
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: Strings.selectSupplier,
            hintText: "Search supplier...",
            prefixIcon: Icon(Icons.business, color: primary),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            labelStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                selectedSupplier = null;
                selectedLedgerId = null;
                gstController.clear();
                ledgerOutstandingBalance = 0;
                ledgerBalanceType = "Cr";
              });
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              width: MediaQuery.of(context).size.width * 0.85,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentTermDialog() {
    TextEditingController paymentTermController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(Strings.paymentTerm),
          content: TextField(
            controller: paymentTermController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(Strings.enterPaymentTerm),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Strings.cancel, style: TextStyle(color: primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedPaymentTerm = paymentTermController.text;
                });
                Navigator.pop(context);
              },
              child: const Text(
                Strings.save,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════
  //  PAGE 2 — Products (inline entry fields)
  // ═══════════════════════════════════════════════════

  Widget _buildPage2() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
        child: Column(
          children: [
            // ─── Add Product section (inline fields from popup) ───
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          color: primary, size: 18),
                      const SizedBox(width: 6),
                      const Text("Add Product",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      if (_selectedProduct != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_selectedProduct!.itemName ?? "",
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

                  // ─── Row 1: Select Product ───
                  _buildProductAutocomplete(),
                  const SizedBox(height: 6),

                  // ─── Row 2: Barcode + HSN (read-only) ───
                  Row(
                    children: [
                      Expanded(
                          child: _tinyField("Barcode", _barcodeCtrl, null,
                              readOnly: true)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tinyField("HSN", _hsnCtrl, null,
                              readOnly: true)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ─── Row 3: Qty + Free Qty + Unit ───
                  Row(
                    children: [
                      Expanded(
                          child: _tinyField(
                              "Qty", _qtyCtrl, () => _calculateProductTotal())),
                      const SizedBox(width: 8),
                      if (!widget.isReturn)
                        Expanded(
                            child: _tinyField("Free Qty", _freeQtyCtrl, null)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildUnitDropdown()),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ─── Row 4: Rate + Base Rate ───
                  Row(
                    children: [
                      Expanded(
                          child: _tinyField("Rate", _rateCtrl,
                              () => _calculateProductTotal())),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tinyField("Base Rate", _baseRateCtrl, null,
                              readOnly: true)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ─── Row 5: Disc % + Disc Amt + GST % ───
                  Row(
                    children: [
                      Expanded(
                          child: _tinyField("Disc %", _discPerCtrl,
                              () => _calculateProductTotal(active: "per"))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tinyField("Disc Amt", _discAmtCtrl,
                              () => _calculateProductTotal(active: "amt"))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildGstDropdown()),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ─── Row 6: Tax Amt + Net Total + Add Button ───
                  Row(
                    children: [
                      Expanded(
                          child: _tinyField("Tax Amt", _taxAmtCtrl, null,
                              readOnly: true)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _tinyField("Net Total", _netTotalCtrl, null,
                              readOnly: true)),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: _addProductToList,
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 20),
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
                Text("Added Products",
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

            // ─── Added Products list ───
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
                            Text(Strings.purchaseNoProductsSelected,
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
                                    child: Text("${p.qty?.toInt()}",
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
                                      Text(p.productName ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)),
                                      Text(
                                          "₹${p.rate.toStringAsFixed(2)} × ${p.qty?.toInt()}",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Text("₹${p.netAmt.toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: primary)),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _showProductDetails(p),
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

            // ─── Nav buttons ───
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
                        Text("Next: Confirm & Save",
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

  Widget _buildProductAutocomplete() {
    if (widget.isReturn) {
      return _buildReturnProductAutocomplete();
    }

    return Consumer<ItemViewmodel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return const SizedBox(
            height: 44,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
            if (textEditingValue.text.isEmpty) return productNames;
            return productNames.where((name) => name
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (selection) async {
            productSearchCtrl.text = selection;
            final item = vm.itemList.firstWhere(
              (p) => p.itemName == selection,
            );
            setState(() {
              _selectedProductId = item.itemId;
              _selectedProduct = item;
            });
            _fillFieldsFromItem(item);

            // Load units
            await vm.getItemUnits(item.itemId ?? 0);
          },
          optionsViewBuilder: (context, onSelected, options) {
            if (options.isEmpty) return const SizedBox.shrink();
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
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
                        title:
                            Text(option, style: const TextStyle(fontSize: 13)),
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
                  hintText: "Search Product...",
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.search, size: 16),
                  suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReturnProductAutocomplete() {
    if (_isReturnLoading) {
      return const SizedBox(
        height: 44,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final productNames = _returnItems
        .map((p) => p.itemName ?? "")
        .where((n) => n.isNotEmpty)
        .toList();

    return RawAutocomplete<String>(
      textEditingController: productSearchCtrl,
      focusNode: _productFocusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return productNames;
        return productNames.where((name) =>
            name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (selection) {
        productSearchCtrl.text = selection;
        final item = _returnItems.firstWhere((p) => p.itemName == selection);

        setState(() {
          _selectedProductId = item.itemId;
          _selectedProduct = ItemsModel(
            itemId: item.itemId,
            itemName: item.itemName,
          );

          _rateCtrl.text = item.purchaseRate.toString();
          _qtyCtrl.text = "1";
          _gstCtrl.text = item.taxPer.toString();
          _selectedGst = item.taxPer ?? 0;
          _barcodeCtrl.text = item.barcode ?? "";
          _unitCtrl.text = item.unitName ?? "";
          _selectedUnitModel = ItemUnitModel(
            itemId: item.itemId ?? 0,
            unitId: item.unitId ?? 0,
            unitName: item.unitName ?? "",
          );
          _mrpCtrl.text = item.purchaseRate.toString();
        });

        _calculateProductTotal();
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
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
              hintText: "Search Product...",
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 16),
              suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
              filled: true,
              fillColor: Colors.grey.shade50,
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

  Widget _buildUnitDropdown() {
    if (widget.isReturn) {
      return _tinyField("Unit", _unitCtrl, null, readOnly: true);
    }

    return Consumer<ItemViewmodel>(
      builder: (context, unitVM, _) {
        if (unitVM.loading) {
          return const SizedBox(
              height: 38,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        return SizedBox(
          height: 38,
          child: DropdownButtonFormField<ItemUnitModel>(
            value: unitVM.selectedUnit,
            items: unitVM.unitList
                .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u.unitName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              unitVM.setSelectedUnit(val);
              setState(() {
                _selectedUnitModel = val;
                _unitCtrl.text = val.unitName;
              });
            },
            decoration: InputDecoration(
              labelText: "Unit",
              labelStyle: const TextStyle(fontSize: 10),
              filled: true,
              fillColor: Colors.grey.shade50,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            isExpanded: true,
            menuMaxHeight: 200,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        );
      },
    );
  }

  Widget _buildGstDropdown() {
    final gstList = [0, 5, 12, 18];

    return SizedBox(
      height: 38,
      child: DropdownButtonFormField<double>(
        value: _selectedGst,
        items: gstList
            .map((e) => DropdownMenuItem<double>(
                  value: e.toDouble(),
                  child: Text("$e %", style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            _selectedGst = v;
            _gstCtrl.text = v.toString();
            _calculateProductTotal();
          });
        },
        decoration: InputDecoration(
          labelText: "GST %",
          labelStyle: const TextStyle(fontSize: 10),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        isExpanded: true,
        menuMaxHeight: 200,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PAGE 3 — Confirm & Save
  // ═══════════════════════════════════════════════════

  Widget _buildPage3() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                            const Text("Invoice Summary",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ─── Qty, Items, Free ───
                        _summaryFlexRow(
                          "Qty",
                          totalQtyValue.toStringAsFixed(0),
                          "Items",
                          "${items.length}",
                          "Free",
                          freeQtyValue.toStringAsFixed(0),
                        ),
                        const SizedBox(height: 8),

                        // ─── SubTotal, Total ───
                        _summaryFlexRow2(
                          "SubTotal",
                          "₹${itemTotalValue.toStringAsFixed(0)}",
                          "Total",
                          "₹${totalAmtValue.toStringAsFixed(0)}",
                        ),
                        const SizedBox(height: 8),

                        // ─── Taxable, Tax ───
                        _summaryFlexRow2(
                          "Taxable",
                          "₹${taxableAmtValue.toStringAsFixed(0)}",
                          "Tax",
                          "₹${taxAmtValue.toStringAsFixed(0)}",
                        ),
                        const SizedBox(height: 8),

                        // ─── Freight Ledger, Amount, Add button ───
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

                        // ─── Disc %, Disc ───
                        Row(
                          children: [
                            Expanded(
                              child: _tinyField(
                                  "Disc %", discountController, null),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _readOnlyMini("Disc",
                                  "₹${discAmtValue.toStringAsFixed(2)}"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // ─── Round Off ───
                        _tinyField("Round Off", roundOffController, null),
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
                        const Text("Net Purchase Amount",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        Text("₹${netBillAmtValue.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),

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

  // ═══════════════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ═══════════════════════════════════════════════════

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: primary) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  Widget _summaryFlexRow(
      String l1, String v1, String l2, String v2, String l3, String v3) {
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

    return Row(children: [cell(l1, v1), cell(l2, v2), cell(l3, v3)]);
  }

  Widget _summaryFlexRow2(String l1, String v1, String l2, String v2) {
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

    return Row(children: [cell(l1, v1), cell(l2, v2)]);
  }

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
      String label, TextEditingController ctrl, VoidCallback? onChanged,
      {bool readOnly = false}) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: ctrl,
        readOnly: readOnly,
        onChanged: (_) => onChanged?.call(),
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade50,
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
        items: items,
        onChanged: onChanged,
        isExpanded: true,
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
      ),
    );
  }

  Widget _readOnlyChip(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _readOnlyMini(String label, String value) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
