import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/view/purchase_mode.dart';
import 'package:flutter_soulconnect/view/purchase_select_product_popup.dart';
import 'package:flutter_soulconnect/view/purchase_select_supplier_popup.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/PurchaseInvoiceItem_model.dart';
import '../model/addPurchase_model.dart';
import '../model/party_model.dart';
import '../model/purchaseReturn_model.dart';
import '../utils/app_strings.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewmodel/addPurchase_viewmodel.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewmodel/ledger_type_viewmodel.dart';
import '../viewmodel/purchaseReturn_viewmodel.dart';
import '../viewmodel/purchase_invoice_viewmodel.dart';
import 'freightAndPostage_dialog.dart';
import '../model/addPurchase_model.dart' as ap;
import '../model/purchaseReturn_model.dart' as pr;

class PurchaseInwardScreen extends StatefulWidget {
  final bool isReturn;   // 👈 ADD

  const PurchaseInwardScreen({super.key,
    this.isReturn = false,
  });

  @override
  State<PurchaseInwardScreen> createState() => _PurchaseInwardScreenState();
}

class _PurchaseInwardScreenState extends State<PurchaseInwardScreen> {
  DateTime purchaseDate = DateTime.now(); // default today
  PartyModel? selectedSupplier;
  final bool isChallan = true;
  String? selectedPayMode;
  final List<PurchaseInvoiceItem> items = [];
  int? selectedLedgerId; // ✅ Also declare this to store the ID
  String? selectedPaymentTerm;
  String? selectedLocationId;
  String taxType = "E"; // default
  double ledgerOutstandingBalance = 0;
  String ledgerBalanceType = "Cr";
  List<Map<String, dynamic>> freightCharges = [];
  double freightValue = 0;

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

  bool _isTotalsExpanded = false;

  bool _isProductExpanded = false;

  @override
  void initState() {
    super.initState();

    discountController.addListener(_applyGlobalDiscount);
    roundOffController.addListener(_recalculateTotals);

  }

//check expiry date
  bool _isExpired(String? expiry) {
    if (expiry == null || expiry.isEmpty) return false;

    try {
      // ✅ Parse DD-MM-YYYY correctly
      final expiryDate = DateFormat('dd-MM-yyyy').parseStrict(expiry);

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final expDate =
          DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

      return expDate.isBefore(todayDate);
    } catch (e) {
      debugPrint("❌ Expiry parse failed: $expiry");
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

  Future<void> _selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        purchaseDate = picked;
      });
    }
  }

  void _showExpiredMsg(String expiry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Text(
          Strings.purchaseExpiredProductMessage.replaceAll("{date}", expiry),
        ),
      ),
    );
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return dateTime; // fallback if parsing fails
    }
  }

  final TextEditingController discountController = TextEditingController();
  final TextEditingController roundOffController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController billNoController = TextEditingController();
  TextEditingController chargeController = TextEditingController();
  TextEditingController ledgerController = TextEditingController();

  void _applyGlobalDiscount() {
    double globalDiscPer = double.tryParse(discountController.text) ?? 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      double baseTotal = item.originalItemTotal ?? 0;

      // ✅ ONLY bill discount
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

        // keep original untouched
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

  Map<String, dynamic> _buildPurchaseRequest() {
    final now = DateTime.now().toUtc();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    final int userId = int.tryParse(loginVM.userId ?? "0") ?? 0;
    final int firmId = int.tryParse(loginVM.firmId ?? "0") ?? 0;
    final int locationId = int.tryParse(
            selectedLocationId ?? loginVM.defaultPurchaseLocId ?? "0") ??
        0;

    final purchaseVM =
        Provider.of<PurchaseInvoiceViewmodel>(context, listen: false);

    final purchase = AddPurchaseModel(
      purchaseId: 0,
      purchaseSeriesId: 1,
      purchaseDate: DateFormat('yyyy-MM-dd').format(purchaseDate),
      supplierId: selectedSupplier?.partyId ?? 0,
      supplierBillNo: billNoController.text.trim(),
      totalQty: totalQtyValue ?? 0,
      freeQty: freeQtyValue ?? 0,
      subTotal: itemTotalValue ?? 0,
      discAmt: discAmtValue ?? 0,
      taxableAmt: taxableAmtValue ?? 0,
      totalTaxAmt: taxAmtValue ?? 0,
      invoiceChargesAmt: freightCharges
          .fold<double>(0, (sum, item) => sum + (item["charge"] ?? 0))
          .toInt(),
      netAmt: netBillAmtValue ?? 0,
      grossBillDiscountAmt: 0,
      grossBillDiscountPer: discPercValue ?? 0,
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
      isChallan: isChallan ?? false,
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
      taxIncludeExclude: taxType ?? "E",
      createdOn: now.toIso8601String(),
      updatedOn: now.toIso8601String(),
      details: items.map((item) {
        final baseTotal = (item.qty ?? 0) * (item.rate ?? 0);

        final discPer = item.discountPerc ?? 0;
        final itemDisc = item.discountAmt ?? 0;   // ✅ USE STORED VALUE

        final taxable = item.taxableAmt ?? 0;     // ✅ DO NOT RECALCULATE
        final totalTaxAmt = item.taxAmt ?? 0;     // ✅ USE STORED
        final netAmt = item.netAmt ?? 0;          // ✅ USE STORED

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
          // ✅ required
          itemId: item.itemId!,   // 👈 FIX
          // itemId: item.itemId ?? 0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffEEF1F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isReturn
                  ? "Purchase Return"
                  : Strings.purchaseInvoiceBar4,
              style: TextStyle(color: white, fontWeight: FontWeight.w600),
            ),
            Text(
              DateFormat('dd-MM-yyyy').format(purchaseDate),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectPurchaseDate,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              bottom: bottomInset + 14,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    /// Top Card (Supplier + Product)
                    _glassCard(
                      child: Container(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final result = await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) => PurchaseSelectSupplierPopup(
                                    mode: widget.isReturn
                                        ? PurchaseMode.purchaseReturn
                                        : PurchaseMode.purchase,
                                    isChallan: true,
                                    hasItems: items.isNotEmpty,
                                    initialSupplier: selectedSupplier,
                                    initialLocationId: selectedLocationId,
                                    initialPayMode: selectedPayMode,
                                    initialPaymentTerm: selectedPaymentTerm,
                                    initialTaxType: taxType,
                                  ),
                                );

                                if (result != null) {
                                  setState(() {
                                    selectedSupplier = result['supplier'];
                                    selectedLocationId = result['locationId'];
                                    selectedPayMode = result['payMode'];
                                    selectedPaymentTerm = result['paymentTerm'];
                                    taxType = result['taxType'];
                                  });

                                  print("Supplier Selected: ${selectedSupplier?.partyName}");
                                  print("Supplier ID: ${selectedSupplier?.partyId}");
                                  print("Location ID: $selectedLocationId");
                                }

                                if (result != null) {
                                  final PartyModel? newSupplier =
                                      result['supplier'] as PartyModel?;
                                  final int? oldSupplierId =
                                      selectedSupplier?.partyId;
                                  final int? newSupplierId =
                                      newSupplier?.partyId;

                                  final bool supplierChanged =
                                      oldSupplierId != null &&
                                          newSupplierId != null &&
                                          oldSupplierId != newSupplierId;

                                  setState(() {
                                    // ✅ Clear products ONLY if supplier actually changed
                                    if (supplierChanged) {
                                      items.clear();
                                      freightCharges.clear();
                                      freightValue = 0;
                                      discountController.clear();
                                      roundOffController.clear();

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              Strings.purchaseSupplierChanged),
                                        ),
                                      );
                                    }

                                    selectedSupplier = newSupplier;
                                    supplierController.text =
                                        selectedSupplier?.partyName ?? '';

                                    if (selectedSupplier?.ledgerId != null) {
                                      _fetchLedgerBalance(
                                          selectedSupplier!.ledgerId!);
                                    }
                                    selectedLedgerId = result['ledgerId'] ?? 0;
                                    vehicleController.text =
                                        result['vehicle'] ?? '';
                                    billNoController.text =
                                        result['billNo'] ?? '';
                                    selectedLocationId = result['locationId'];
                                    selectedPayMode = result['payMode'];
                                    selectedPaymentTerm = result['paymentTerm'];
                                    taxType = result['taxType'] ?? "E";
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.08),
                                  // ✅ Your color
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedSupplier == null
                                        ? Colors.grey.shade300
                                        : primary.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  selectedSupplier?.partyName ??
                                      Strings.purchaseSelectSupplier,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: selectedSupplier == null
                                        ? Colors.grey
                                        : primary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2),

                            /// Outstanding Balance Display
                            if (selectedSupplier != null)
                              Text(
                                "${Strings.purchaseOutstandingBalance}: ₹ "
                                "${ledgerOutstandingBalance.toStringAsFixed(2)} "
                                "$ledgerBalanceType",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),

                            SizedBox(height: 2),
                            Opacity(
                              opacity: selectedSupplier == null ? 0.5 : 1,
                              child: GestureDetector(
                                onTap: (selectedSupplier == null || selectedLocationId == null)
                                    ? null
                                    : () async {

                                  final itemVM = Provider.of<ItemViewmodel>(context, listen: false);

                                  // ✅ ENSURE DATA IS LOADED BEFORE POPUP
                                  if (itemVM.itemList.isEmpty && !itemVM.loading) {
                                    await itemVM.getItemsApi();
                                  }

                                        final purchaseInvoiceVM = Provider.of<
                                                PurchaseInvoiceViewmodel>(
                                            context,
                                            listen: false);

                                        final ledgerBal = purchaseInvoiceVM.ledgerBalance;

                                        if (selectedSupplier == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Please select supplier first")),
                                          );
                                          return;
                                        }

                                        final invoiceItem = await showDialog<
                                            PurchaseInvoiceItem>(
                                          context: context,
                                          builder: (dialogContext) {
                                            return PurchaseSelectProductPopup(
                                              mode: widget.isReturn
                                                  ? PurchaseMode.purchaseReturn
                                                  : PurchaseMode.purchase,   // ✅ REQUIRED FIX

                                              payMode: selectedPayMode ?? "CASH",
                                              taxType: taxType,
                                              locationId: selectedLocationId ?? "",

                                              partyId: selectedSupplier?.partyId ?? 0,   // ✅ IMPORTANT (for return API)
                                            );
                                          },
                                        );

                                        if (invoiceItem != null) {
                                          if (_isExpired(invoiceItem.expiry)) {
                                            _showExpiredMsg(_formatDate(
                                                invoiceItem.expiry));
                                            return;
                                          }

                                          final alreadyExists = items.any((e) =>
                                              (e.itemId ==
                                                  invoiceItem.itemId) &&
                                              (e.batch?.trim().toLowerCase() ==
                                                  invoiceItem.batch
                                                      ?.trim()
                                                      .toLowerCase()));

                                          if (alreadyExists) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(Strings
                                                    .purchaseProductBatchExists),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() {
                                            items.add(invoiceItem);
                                            _recalculateTotals();
                                          });
                                        }
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selectedSupplier == null
                                          ? Colors.grey.shade300
                                          : Colors.black,
                                    ),
                                    color: selectedSupplier == null
                                        ? Colors.grey.shade100
                                        : Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Strings.purchaseSelectProduct,
                                        style: TextStyle(
                                          color: selectedSupplier == null
                                              ? Colors.grey
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 3),

                    /// Selected Products
                    Expanded(
                      flex: _isProductExpanded ? 5 : 3,
                      // Expand when toggled
                      child: _glassCard(
                        child: Container(
                          height: MediaQuery.sizeOf(context).height * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: items.isEmpty
                              ? const Center(
                                  child: Text(
                                    Strings.purchaseNoProductsSelected,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(6),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final product = items[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${product.qty} × ${product.productName}",
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),

                                          /// 👁 VIEW BUTTON
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: Icon(
                                              Icons.remove_red_eye_outlined,
                                              size: 18,
                                              color: primary,
                                            ),
                                            onPressed: () {
                                              _showProductDetails(product);
                                            },
                                          ),

                                          /// 🗑 DELETE BUTTON
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                items.removeAt(index);
                                                _recalculateTotals(); // ✅ recalc after delete
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    /// Totals Section (Fixed Bottom Style)
                    Expanded(
                      flex: _isTotalsExpanded ? 5 : 1,
                      // Expand when toggled
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// Expand Header Row
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isTotalsExpanded = !_isTotalsExpanded;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    Strings.purchaseInvoiceSummary,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isTotalsExpanded
                                          ? Icons.remove
                                          : Icons.add,
                                      size: 18,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// Expandable Area
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: _isTotalsExpanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Column(
                                children: [

                                  /// 1️⃣ Total Qty | Free Qty
                                  _compactRow(
                                    Strings.totalQty,
                                    totalQtyValue.toStringAsFixed(2),
                                    Strings.freeQty,
                                    freeQtyValue.toStringAsFixed(2),
                                  ),

                                  /// 2️⃣ Item Total | Disc %
                                  _compactMixedRow(
                                    Strings.purchaseItemTotal,
                                    "₹${itemTotalValue.toStringAsFixed(2)}",
                                    Strings.discPercent,
                                    discountController,
                                  ),

                                  /// 3️⃣ Disc Amt | Taxable Amt
                                  _compactRow(
                                    Strings.discAmt,
                                    "₹${discAmtValue.toStringAsFixed(2)}",
                                    Strings.taxableAmt,
                                    "₹${taxableAmtValue.toStringAsFixed(2)}",
                                  ),

                                  /// 4️⃣ Tax Amt | Total Amt
                                  _compactRow(
                                    Strings.taxAmt,
                                    "₹${taxAmtValue.toStringAsFixed(2)}",
                                    Strings.totalAmt,
                                    "₹${totalAmtValue.toStringAsFixed(2)}",
                                  ),

                                  /// 5️⃣ Freight | Net Bill
                                  _compactCustomRow(
                                    Strings.freight,
                                    Row(
                                      children: [
                                        Text(
                                          "₹${freightValue.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff2E3A59),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () async {
                                            final result = await showDialog(
                                              context: context,
                                              builder: (_) => FreightAndPostageDialog(
                                                initialCharges: freightCharges,
                                              ),
                                            );

                                            if (result != null) {
                                              setState(() {
                                                freightValue = result["total"];
                                                freightCharges =
                                                List<Map<String, dynamic>>.from(
                                                    result["chargesList"]);
                                                _recalculateTotals();
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.edit_rounded,
                                              size: 16,
                                              color: primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Strings.purchaseNetBill,
                                    "₹${netBillTotalValue.toStringAsFixed(2)}",
                                  ),

                                  /// 6️⃣ Round Off | Final Purchase
                                  _compactEditableRow(
                                    Strings.roundOff,
                                    roundOffController,
                                    Strings.purchaseFinalPurchase,
                                    "₹${netBillAmtValue.toStringAsFixed(2)}",
                                  ),

                                  const SizedBox(height: 2),
                                  Divider(color: Colors.grey.shade300),
                                ],
                              ),
                              secondChild: const SizedBox(),
                            ),

                            /// ⚠️ DO NOT CHANGE BELOW THIS

                            /// Final Highlight Amount (Always Visible)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  Strings.purchaseFinalPurchaseAmount,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "₹${netBillAmtValue.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primary),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// Buttons (Always Fixed)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Text(Strings.cancel,
                                        style: TextStyle(color: primary)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {

                                      if (selectedSupplier == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(Strings.purchaseSelectSupplierError),
                                          ),
                                        );
                                        return;
                                      }

                                      if (items.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(Strings.purchaseAddProductError),
                                          ),
                                        );
                                        return;
                                      }

                                      // 👇 ADD THIS BLOCK
                                      for (var item in items) {
                                        if (item.itemId == null || item.itemId == 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Invalid product itemId")),
                                          );
                                          return;
                                        }
                                      }

                                      Map<String, dynamic> requestBody;

                                      if (widget.isReturn) {
                                        requestBody = _buildPurchaseReturnRequest();
                                      } else {
                                        requestBody = _buildPurchaseRequest();
                                      }

                                      debugPrint("=========== API REQUEST ===========");
                                      debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
                                      debugPrint("===================================");

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
                                    },


                                    child: const Text(
                                      Strings.save,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _compactRow(
      String title1, String value1, String title2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _alignedField(title1, value1),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _alignedField(title2, value2),
          ),
        ],
      ),
    );
  }

  Widget _alignedField(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff2E3A59),
          ),
        ),
      ],
    );
  }

  Widget _compactEditableRow(String title, TextEditingController controller,
      String title2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  height: 34,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _alignedField(title2, value2),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          )
        ],
      ),
      child: child,
    );
  }

  InputDecoration _modernInput(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _compactMixedRow(
      String leftTitle,
      String leftValue,
      String rightTitle,
      TextEditingController rightController,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _alignedField(leftTitle, leftValue),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    rightTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  height: 34,
                  child: TextField(
                    controller: rightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactCustomRow(
    String title1,
    Widget valueWidget1,
    String title2,
    String value2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                valueWidget1, // 👈 Custom widget here
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _alignedField(title2, value2),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(PurchaseInvoiceItem item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                      child: Text(
                        item.productName ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDetailRow("Batch No", item.batch ?? ""),
                _buildDetailRow("Expiry", _formatDate(item.expiry)),
                _buildDetailRow("Rate", "₹${item.rate.toStringAsFixed(2)}"),
                _buildDetailRow("Quantity", "${item.qty}"),
                _buildDetailRow("Free Qty", "${item.free}"),
                _buildDetailRow("MRP", "₹${item.mrp.toStringAsFixed(2)}"),
                _buildDetailRow("HSN", item.hsn ?? ""),
                const Divider(),
                _buildDetailRow("Discount (%)", "${item.discountPerc}"),
                _buildDetailRow(
                    "Discount Amt", "₹${item.discountAmt.toStringAsFixed(2)}"),
                _buildDetailRow("Scheme (%)", "${item.schemePerc}"),
                _buildDetailRow(
                    "Scheme Amt", "₹${item.schemeAmt.toStringAsFixed(2)}"),
                const Divider(),
                _buildDetailRow("Tax (%)", "${item.taxPerc}"),
                _buildDetailRow("Taxable", "₹${item.taxableAmt}"),
                _buildDetailRow(
                    "Total Tax Amt", "₹${item.totalTaxAmt.toStringAsFixed(2)}"),
                _buildDetailRow(
                    "Net Amount", "₹${item.netAmt.toStringAsFixed(2)}"),
              ],
            ),
          ),
        ),
      ),
    );
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
}
