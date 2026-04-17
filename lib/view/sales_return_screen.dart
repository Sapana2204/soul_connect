import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/view/select_bill_details_dialog.dart';
import 'package:flutter_soulconnect/view/select_cutomer_dialog.dart';
import 'package:flutter_soulconnect/view/select_product_popup.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/add_sale_model.dart';
import '../model/add_sale_return_model.dart';
import '../model/invoice_item_model.dart';
import '../model/party_model.dart';
import '../model/sales_dashboard_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/routes/routes_names.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/sales_invoice_viewmodel.dart';
import '../viewmodel/sales_dashboard_viewmodel.dart';
import '../viewmodel/sales_return_viewmodel.dart';
import 'freightAndPostage_dialog.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController billDetailsController = TextEditingController();
  final TextEditingController productController = TextEditingController();

  double totalQty = 0;
  double freeQty = 0;
  double itemTotal = 0;
  double totalDiscAmt = 0;
  double taxableAmt = 0;
  double taxAmt = 0;
  double totalAmt = 0;
  double netBillTotal = 0;
  double netBillAmt = 0;

  PartyModel? selectedSupplier;
  final bool isChallan = true;
  String? selectedPayMode;
  String? selectedPaymentTerm;
  String? selectedLocationId;
  final List<InvoiceItem> items = [];
  bool _isTotalsExpanded = false;
  List<Map<String, dynamic>> freightCharges = [];
  double freightValue = 0;
  bool _isProductExpanded = true;

  String? selectedRateType;
  String? selectedBillType;
  int selectedCustId = 0;
  String selectedCreditLimit = "0";
  String selectedOpeningBal = "0";
  String address = "-";
  String byHand = "-";
  String contact = "-";
  String rateType = "-";
  String payMode = "-";
  String selectedTaxType = "-";

  @override
  void initState() {
    super.initState();

    final viewModel =
    Provider.of<SalesInvoiceViewmodel>(context, listen: false);

    viewModel.getPartyApi();
    viewModel.fetchTaxGroupPercentage();

    roundOffController.addListener(_recalculateTotals);
    roundOffController.addListener(_onDiscountChanged);
    discountController.addListener(_onDiscountChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
      ModalRoute
          .of(context)!
          .settings
          .arguments as Map<String, dynamic>?;

      if (args != null) {
        final isEdit = args['isEdit'] ?? false;
        final sale = args['saleData'] as SalesDashboardModel?;
        final rateTypeArg = args['rateType'];

        if (isEdit && sale != null) {
          setState(() {
            rateType = rateTypeArg ?? '-';
          });

          _fetchSaleDetailsById(sale.salesID ?? 0);
        }
      }
    });
  }

  void _onDiscountChanged() {
    double discountPercent =
        double.tryParse(discountController.text) ?? 0.0;

    // 🔹 Use already calculated itemTotal from _recalculateTotals
    double billDiscountAmt = (itemTotal * discountPercent) / 100;

    double newTaxableAmt = itemTotal - billDiscountAmt;
    if (newTaxableAmt < 0) newTaxableAmt = 0;

    // 🔹 Get current tax rate from existing values
    double taxRate = 0;
    if (taxableAmt > 0) {
      taxRate = taxAmt / taxableAmt;
    }

    double newTaxAmt = newTaxableAmt * taxRate;

    double newTotalAmt = newTaxableAmt + newTaxAmt;

    double newNetBillTotal = newTotalAmt + freightValue;

    double roundOffValue =
        double.tryParse(roundOffController.text) ?? 0.0;

    setState(() {
      totalDiscAmt = billDiscountAmt;   // only bill discount
      taxableAmt = newTaxableAmt;
      taxAmt = newTaxAmt;
      totalAmt = newTotalAmt;
      netBillTotal = newNetBillTotal;
      netBillAmt = newNetBillTotal + roundOffValue;
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
      freeQty += item.freeQty ?? 0;
      itemTotal += item.subtotal;
      totalDiscAmt += item.totalDisc;
      taxableAmt += item.taxable;
      taxAmt += item.taxAmt;
      totalAmt += item.totalAmt;
    }

    netBillTotal = totalAmt + freightValue;

    double roundOffValue = double.tryParse(roundOffController.text) ?? 0.0;

    netBillAmt = netBillTotal + roundOffValue;

    setState(() {});
  }

  void _fetchSaleDetailsById(int saleId) async {
    final dashboardVM =
    Provider.of<SalesDashboardViewModel>(context, listen: false);
    if (saleId == 0) return;

    final saleDetail = await dashboardVM.getSalesById(saleId);

    if (saleDetail != null) {
      setState(() {
        // Populate customer details
        customerController.text = saleDetail.customerName ?? "";
        selectedCustId = saleDetail.customerId ?? 0;
        address = saleDetail.address ?? "-";
        byHand = saleDetail.byHand ?? "-";
        contact = saleDetail.phoneNumber ?? "-";
        selectedCreditLimit = saleDetail.customerOutstanding?.toString() ?? "0";
        selectedOpeningBal = saleDetail.totalAmt?.toString() ?? "0";
        rateType = saleDetail.rateType ?? "-";
        payMode = saleDetail.salesType ?? "-";
        selectedBillType = saleDetail.billType ?? "-";

        // Populate product items
        items.clear();
        if (saleDetail.salesDetails != null &&
            saleDetail.salesDetails!.isNotEmpty) {
          items.clear();

          for (var detail in saleDetail.salesDetails!) {
            print("sale details:${detail.toJson()}");

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

  String get billDetailsSummary {
    if (selectedBillType == "-" || selectedBillType == null) {
      return Strings.selectBillDetails;
    }

    return "${selectedBillType ?? '-'} • "
        "${payMode ?? '-'} • "
        "${selectedTaxType ?? '-'}";
  }

//check expiry date
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
      debugPrint("❌ Expiry parse failed: $expiry");
      return false;
    }
  }

  void _showExpiredMsg(String expiry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Text(
          "Cannot add expired products.\nExpiry date ($expiry) is before today's date.",
        ),
      ),
    );
  }

  /// Add a new product item to existing sale (Edit Mode only)
  Future<void> _addNewItemToExistingSale(String? billType, int? locationId,
      String? payMode, String taxType, int custId) async {
    try {
      final newItem = await showDialog<InvoiceItem>(
        context: context,
        builder: (BuildContext context) {
          return SelectProductPopup(
              billType: billType,
              locationId: locationId??0,
              payMode: payMode ?? "",
              taxType: taxType,
               custId: custId,
            isReturn: true,
            rateType: rateType,);
        },
      );
      String _formatDate(String? dateTime) {
        if (dateTime == null || dateTime.isEmpty) return "";
        try {
          final parsedDate = DateTime.parse(dateTime);
          return DateFormat('dd-MM-yyyy').format(parsedDate);
        } catch (e) {
          return dateTime; // fallback if parsing fails
        }
      }

      if (newItem != null) {
        // Expiry Check
        // if (_isExpired(newItem.expiry)) {
        //   _showExpiredMsg(_formatDate(newItem.expiry));
        //   return;
        // }
        // 🔹 Prevent duplicate product (same itemId + batch)
        final exists = items.any((item) =>
        item.itemId == newItem.itemId);

        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(Strings.existItemSnack),
              backgroundColor: Colors.red.shade600,
            ),
          );
          return;
        }

        // 🔹 Add to list
        setState(() {
          items.add(newItem);
        });

        debugPrint("Added new item in Edit Mode: ${newItem.productName}");
      }
    } catch (e) {
      debugPrint(" Error adding new item in edit mode: $e");
    }
  }

  final TextEditingController discountController = TextEditingController();
  final TextEditingController roundOffController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController billNoController = TextEditingController();

  Future<void> _submitSalesReturn({required bool isEdit, SalesDashboardModel? sale}) async {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = int.tryParse(loginVM.userId ?? '0') ?? 0;

    // Make sure latest totals are used
    _recalculateTotals();
    _onDiscountChanged();

    // Build Details
    List<SalesReturnDetail> buildReturnDetails() {
      return items.map((item) {
        return SalesReturnDetail(
          itemId: item.itemId,
          unitId: item.unitId,
          quantity: item.returnQty.toDouble(),
          freeQuantity: (item.freeQty ?? 0).toDouble(),
          rate: item.rate,
          itemTotal: item.subtotal,
          discPer: item.discountPerc,
          discAmt: item.discountAmt,
          taxableAmt: item.taxable,
          totalTaxAmt: item.taxAmt,
          netAmt: item.netAmt,
          taxPer1: item.taxPer1,
          taxAmt1: item.taxAmt1,
          taxPer2: item.taxPer2,
          taxAmt2: item.taxAmt2,
          // if IGST present in your model:
          taxPer3: item.taxPer3,
          taxAmt3: item.taxAmt3,
          isWithoutGST: item.isNonGST,
          actRetQty: item.returnQty.toDouble(),
          locationId: int.tryParse(selectedLocationId!)??0,
          purchaseRate: item.purchaseRate,
          pflPurchaseRate: item.purchaseRate,
        );
      }).toList();
    }

    // Build Other Charges (Freight & Postage)
    List<SalesReturnOtherCharge> buildOtherCharges() {
      return freightCharges.map((e) {
        return SalesReturnOtherCharge(
          ledgerId: e["ledgerId"] ?? 0,
          amount: (e["amount"] ?? 0.0) as double,
          ledgerName: e["ledgerName"] ?? "",
        );
      }).toList();
    }

    // Prepare payload
    final discountPercent = double.tryParse(discountController.text) ?? 0.0;
    final roundOffValue = double.tryParse(roundOffController.text) ?? 0.0;
    final billLevelDiscAmt = (itemTotal * discountPercent) / 100;

    // Keep consistency with your on-screen totals:
    final payload = AddSaleReturnModel(
      returnId: isEdit ? (sale?.salesID ?? 0) : 0,
      returnDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      customerId: selectedCustId,
      customerName: customerController.text,
      address: address,
      mobile: contact,
      payMode: "", // fill if backend needs it; you used "" in dialog
      totalQty: totalQty,
      freeQty: freeQty,
      subTotal: itemTotal,
      discAmt: billLevelDiscAmt, // or totalDiscAmt if that’s your agreed field
      taxableAmt: taxableAmt,
      totalTaxAmt: taxAmt,
      invoiceChargesAmt: freightValue,
      roundOff: roundOffValue,
      netAmt: netBillAmt,
      narration: "",
      byHand: byHand,
      locationId: int.tryParse(selectedLocationId!)??0,
      salesId: sale?.salesID ?? 0,
      createdBy: userId,
      createdOn: DateTime.now().toIso8601String(),
      userId: userId,
      isCreditNoteCreated: true,
      creditNoteVchId: 0,
      isVoucher: true,
      isCreditNote: true,
      details: buildReturnDetails(),
      otherCharges: buildOtherCharges(),
    );

    // Debug pretty print (split to safe chunks)
    void _printRequestBody(Map<String, dynamic> body) {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(body);
      const int chunkSize = 800;
      for (int i = 0; i < prettyJson.length; i += chunkSize) {
        debugPrint(prettyJson.substring(
          i,
          (i + chunkSize > prettyJson.length) ? prettyJson.length : i + chunkSize,
        ));
      }
    }

    final requestBody = payload.toJson();

    debugPrint("📦 Sales Return REQUEST BODY START");
    _printRequestBody(requestBody);
    debugPrint("📦 Sales Return REQUEST BODY END");

    final salesReturnVM = Provider.of<SalesReturnViewModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      int? returnId;
      if (isEdit) {
        debugPrint("✏️ Calling UPDATE Sales Return API");
        returnId = await salesReturnVM.updateSalesReturn(context, requestBody);
      } else {
        debugPrint("➕ Calling ADD Sales Return API");
        returnId = await salesReturnVM.addSalesReturn(context, requestBody);
      }

      Navigator.pop(context); // loader

      if (returnId != null) {
        // Feedback + Navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sales Return saved successfully (ID: $returnId)"),
            backgroundColor: primary,
          ),
        );
        Navigator.pushReplacementNamed(context, RouteNames.salesReturnDashboard);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to save sales return: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  bool _validateBillDetails() {
    if (selectedBillType == "-" || selectedBillType == null) {
      _showValidation("Please select Bill Type");
      return false;
    }

    if (payMode == "-" || payMode == null) {
      _showValidation("Please select Pay Mode");
      return false;
    }

    if (selectedTaxType == "-" || selectedTaxType == null) {
      _showValidation("Please select Tax Type");
      return false;
    }

    if (selectedLocationId == null || selectedLocationId == "-") {
      _showValidation("Please select Location");
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
  @override
  Widget build(BuildContext context) {
    bool isCustomerSelected = customerController.text.isNotEmpty;

    final args =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>?;

    final isEdit = args?['isEdit'] ?? false;
    final sale = args?['saleData'] as SalesDashboardModel?;

    if (isEdit && sale != null && customerController.text.isEmpty) {
      // Prefill customer details
      customerController.text = sale.customerName ?? "";
      selectedCustId = sale.customerId ?? 0;
      address = sale.address ?? "-";
      byHand = sale.byHand ?? "-";
      contact = sale.phoneNumber ?? "-";
      selectedCreditLimit = sale.customerOutstanding?.toString() ?? "0";
      selectedOpeningBal = sale.totalAmt?.toString() ?? "0";
      rateType = sale.rateType ?? "-";
      payMode = sale.salesType ?? "-";
      selectedBillType = sale.billType ?? "-";

      // Prefill product items
      items.clear();
      final salesDetails = sale.salesDetails;
      if (salesDetails != null && salesDetails is List) {
        for (var detail in salesDetails) {
          items.add(InvoiceItem.fromJson(detail as Map<String, dynamic>));
        }
      }
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

    return WillPopScope(
      onWillPop: () async {
        final salesVM =
        Provider.of<SalesInvoiceViewmodel>(context, listen: false);

        salesVM.clearBillDetails(); // ✅ Clear when back pressed
        salesVM.clearCustomerDetails(); // ✅ Clear when back pressed

        return true; // allow navigation
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xffEEF1F8),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: primary,
            title: Text(
              Strings.salesReturnAppbar1,
              style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          body: SafeArea(
              child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bottomInset = MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom;
      
                    return SingleChildScrollView(
      
                      padding: EdgeInsets.only(
                        left: 14,
                        right: 14,
                        bottom: bottomInset + 14,
                      ),
      
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              /// Top Card (Supplier + Product)
                              _glassCard(
                                child: Container(
                                  // height: MediaQuery.sizeOf(context).height*0.19,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await showGeneralDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            barrierLabel: MaterialLocalizations
                                                .of(context)
                                                .modalBarrierDismissLabel,
                                            pageBuilder: (context, animation1,
                                                animation2) {
                                              return const SizedBox.shrink();
                                            },
                                            transitionBuilder: (context, a1, a2,
                                                widget) {
                                              return const Stack(
                                                children: [
                                                  Positioned(
                                                    top: 125,
                                                    left: 1,
                                                    right: 25,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: SelectCustomerDialog(isReturn: true,),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
                                          );
      
                                          if (result != null &&
                                              result is Map<String, dynamic>) {
                                            setState(() {
                                              customerController.text =
                                                  result['customer'] ?? "";
                                              selectedCustId =
                                                  result['customerId'] ?? 0;
                                              address = result['address'] ?? "-";
                                              byHand = result['byHand'] ?? "-";
                                              contact = result['contact'] ?? "-";
                                              selectedCreditLimit =
                                                  result['creditLimit']
                                                      ?.toString() ?? "0";
                                              selectedOpeningBal =
                                                  result['openingBal']
                                                      ?.toString() ?? "0";
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(
                                                12),
                                            border: Border.all(
                                              color: customerController.text
                                                  .isEmpty
                                                  ? Colors.grey.shade300
                                                  : primary.withOpacity(0.4),
                                            ),
                                          ),
                                          child: Text(
                                            customerController.text.isEmpty
                                                ? Strings.selectCustomerHeading
                                                : customerController.text,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: customerController.text
                                                  .isEmpty
                                                  ? Colors.grey
                                                  : primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 🔹 Outstanding & Credit Limit Row
                                      if (customerController.text.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              const Text(
                                                Strings.outstanding,
                                                style:
                                                TextStyle(fontSize: 12,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                "₹${double.parse(selectedOpeningBal).abs()}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Spacer(),
                                              const Text(
                                                Strings.creditLimit,
                                                style:
                                                TextStyle(fontSize: 12,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                "₹$selectedCreditLimit",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await showGeneralDialog(context: context, barrierDismissible: true, barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                            pageBuilder: (context, animation1, animation2) {return const SizedBox.shrink();
                                            }, transitionBuilder: (context, a1, a2, widget) {
                                              return const Stack(
                                                children: [
                                                  Positioned(
                                                    top: 125,
                                                    left: 1,
                                                    right: 25,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: SelectBillDetailsDialog(isReturn: true),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 300),
                                          );

                                          if (result != null &&
                                              result is Map<String, dynamic>) {
                                            setState(() {
                                              selectedCreditLimit =
                                                  result['creditLimit']
                                                      ?.toString() ?? "0";
                                              selectedOpeningBal =
                                                  result['openingBal']
                                                      ?.toString() ?? "0";
                                              rateType =
                                                  result['rateType'] ?? "-";
                                              payMode = result['payMode'] ?? "-";
                                              selectedTaxType =
                                                  result['taxType'] ?? "-";
                                              selectedBillType =
                                                  result['billType'] ?? "-";
                                              selectedLocationId = result['locationId']?? "-";
                                              selectedPayMode = result['payMode']?.toString()??"-";
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(
                                                12),
                                            border: Border.all(
                                              color: selectedBillType == "-" ||
                                                  selectedBillType == null
                                                  ? Colors.grey.shade300
                                                  : primary.withOpacity(0.4),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.receipt_long,
                                                size: 18,
                                                color: selectedBillType == "-" ||
                                                    selectedBillType == null
                                                    ? Colors.grey
                                                    : primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  billDetailsSummary,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: selectedBillType ==
                                                        "-" ||
                                                        selectedBillType == null
                                                        ? Colors.grey
                                                        : primary,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.keyboard_arrow_down,
                                                color: Colors.grey.shade600,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: !isCustomerSelected
                                            ? null
                                            : () async {
                                          if (!_validateBillDetails()) {
                                            return;
                                          }
                                          if (isEdit) {
                                            await _addNewItemToExistingSale(
                                              selectedBillType,
                                              int.tryParse(selectedLocationId!),
                                              payMode,
                                              selectedTaxType,
                                              selectedCustId
                                            );
                                          } else {
                                            final invoiceItem =
                                            await showDialog<InvoiceItem>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return SelectProductPopup(
                                                  billType: selectedBillType,
                                                  locationId: int.tryParse(selectedLocationId!)??0,
                                                  payMode: payMode,
                                                  taxType: selectedTaxType,
                                                  custId: selectedCustId,
                                                  isReturn: true,
                                                  rateType: rateType
                                                );
                                              },
                                            );
      
                                            if (invoiceItem != null) {
                                              // if (_isExpired(
                                              //     invoiceItem.expiry)) {
                                              //   _showExpiredMsg(
                                              //       _formatDate(
                                              //           invoiceItem.expiry));
                                              //   return;
                                              // }
      
                                              // STOCK CHECK
                                              if (invoiceItem.qty >
                                                  invoiceItem.stock) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.red
                                                        .shade600,
                                                    content: Text(
                                                      "Only ${invoiceItem
                                                          .stock} qty available in stock",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
      
                                              //Check free qty
                                              if (invoiceItem.freeQty >
                                                  invoiceItem.stock) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Colors.red
                                                        .shade600,
                                                    content: Text(
                                                      "Free quantity (${invoiceItem
                                                          .freeQty}) cannot exceed available stock (${invoiceItem
                                                          .stock}).",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
      
                                              final exists = items.any((item) =>
                                              item.itemId == invoiceItem.itemId);
      
                                              if (exists) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                        Strings.existItemSnack),
                                                    backgroundColor: Colors.red
                                                        .shade600,
                                                  ),
                                                );
                                                return;
                                              }
      
                                              setState(() {
                                                items.add(invoiceItem);
                                                _recalculateTotals();
                                              });
                                            }
                                          }
                                        },
                                        child: AbsorbPointer(
                                          child: Opacity(
                                            opacity: isCustomerSelected ? 1 : 0.2,
                                            child: TextField(
                                              readOnly: true,
                                              controller: productController,
                                              decoration: InputDecoration(
                                                hintText: isCustomerSelected
                                                    ? "${Strings.salesInvoiceProductBar}"
                                                    : "Select Customer First",
                                                // label: const Text("Product name"),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(12),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(21),
                                                  borderSide: BorderSide(
                                                      color: primary),
                                                ),
                                                contentPadding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 6, horizontal: 8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
      
                              /// Selected Products
                              Expanded(
                                flex: _isProductExpanded ? 4 : 2,
                                child: _glassCard(
                                  child: Container(
                                    height: MediaQuery
                                        .sizeOf(context)
                                        .height * 0.20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: items.isEmpty
                                        ? const Center(
                                      child: Text(
                                        Strings.noSelectedProduct,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                        : ListView.builder(
                                        padding: const EdgeInsets.all(6),
                                        itemCount: items.length,
                                        itemBuilder: (context, index) {
                                          final product = items[index];
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${product.qty}* ${product
                                                      .productName}",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        Dialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(12)),
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .all(16.0),
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        product
                                                                            .productName,
                                                                        style: const TextStyle(
                                                                          fontSize: 18,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .close),
                                                                        onPressed: () {
                                                                          Navigator
                                                                              .pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height: 10),
      
                                                                  // All product details
                                                                  // _buildDetailRow(
                                                                  //     Strings.dashboardProductRow3,
                                                                  //     product
                                                                  //         .batch),
                                                                  // _buildDetailRow(
                                                                  //     Strings.dashboardProductRow4,
                                                                  //     product
                                                                  //         .expiry !=
                                                                  //         null
                                                                  //         ? _formatDate(
                                                                  //         product
                                                                  //             .expiry)
                                                                  //         : "-"),
                                                                  _buildDetailRow(
                                                                      Strings.qty,
                                                                      product.qty
                                                                          .toString()),
                                                                  _buildDetailRow(
                                                                      Strings.rate,
                                                                      product.rate
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      Strings.subTotal,
                                                                      product
                                                                          .subtotal
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      Strings.discPercent,
                                                                      product
                                                                          .discountPerc
                                                                          .toString()),
                                                                  _buildDetailRow(
                                                                      Strings.totalDisc,
                                                                      product
                                                                          .totalDisc
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      Strings.taxableAmt,
                                                                      product
                                                                          .taxable
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      Strings.taxPerc,
                                                                      product
                                                                          .taxPerc
                                                                          .toString()),
                                                                  _buildDetailRow(
                                                                      Strings.taxAmt,
                                                                      product
                                                                          .taxAmt
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      Strings.netTotal,
                                                                      product
                                                                          .totalAmt
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      Strings.purchaseRate,
                                                                      product
                                                                          .purchaseRate
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      Strings.stock,
                                                                      product
                                                                          .stock
                                                                          .toString()),
                                                                  _buildDetailRow(
                                                                      "Non-GST",
                                                                      product
                                                                          .isNonGST
                                                                          ? "Yes"
                                                                          : "No"),
                                                                  _buildDetailRow(
                                                                      "Return Qty",
                                                                      product
                                                                          .returnQty
                                                                          .toString()),
                                                                  // _buildDetailRow(
                                                                  //     "GatePass",
                                                                  //     product
                                                                  //         .gatePassItem ??
                                                                  //         "-"),
                                                                  _buildDetailRow(
                                                                      "CGST (%)",
                                                                      product
                                                                          .taxPer1
                                                                          .toString()),
                                                                  _buildDetailRow(
                                                                      "CGST Amt",
                                                                      product
                                                                          .taxAmt1
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      "SGST (%)",
                                                                      product
                                                                          .taxPer2
                                                                          .toString()),
                                                                  _buildDetailRow(
                                                                      "SGST Amt",
                                                                      product
                                                                          .taxAmt2
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                  _buildDetailRow(
                                                                      "IGST (%)",
                                                                      product
                                                                          .taxPer3
                                                                          .toString()),
                                                                  _buildDetailRow(
                                                                      "IGST Amt",
                                                                      product
                                                                          .taxAmt3
                                                                          .toStringAsFixed(
                                                                          2)),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  // color: Theme.of(context).colorScheme.secondary,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 18, color: Colors.red),
                                                onPressed: () {
                                                  setState(() {
                                                    items.removeAt(index);

                                                    if (items.isEmpty) {
                                                      freightValue = 0.0;
                                                      freightCharges.clear();
                                                      discountController.clear();
                                                      roundOffController.clear();
                                                    }

                                                    _recalculateTotals();
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
      
                              /// Totals Section
                              Expanded(
                                flex: _isTotalsExpanded ? 5 : 1,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 16,
                                    bottom: MediaQuery
                                        .of(context)
                                        .viewInsets
                                        .bottom,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
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
                                            _isTotalsExpanded =
                                            !_isTotalsExpanded;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            const Text(
                                              Strings.billDetails,
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
      
                                      /// Expandable Area
                                      AnimatedCrossFade(
                                        duration: const Duration(
                                            milliseconds: 250),
                                        crossFadeState: _isTotalsExpanded
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        firstChild: Column(
                                          children: [
                                            _twoColumnRow(
                                              leftLabel: Strings.totalQty,
                                              leftValue: Text(
                                                "${totalQty.toStringAsFixed(2)}",
                                                style:
                                                const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              rightLabel: Strings.freeQty,
                                              rightValue: Text(
                                                "${freeQty.toStringAsFixed(2)}",
                                                style:
                                                const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            _twoColumnRow(
                                              leftLabel: Strings.subTotal,
                                              leftValue: Text(
                                                "₹${itemTotal.toStringAsFixed(
                                                    2)}",
                                                style:
                                                const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              rightLabel: Strings.discPercent,
                                              rightValue: SizedBox(
                                                width: 60,
                                                height: 30,
                                                child: TextField(
                                                  controller: discountController,
                                                  keyboardType: TextInputType
                                                      .number,
                                                  decoration: const InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),),

                                            _twoColumnRow(
                                              leftLabel: Strings.discAmt,
                                              leftValue: Text(
                                                  "₹${totalDiscAmt.toStringAsFixed(
                                                      2)}",
                                                  style:
                                                  const TextStyle(
                                                      fontWeight: FontWeight.w600),
                                                ),
                                              rightLabel: Strings.taxableAmt,
                                              rightValue: Text(
                                                "₹${taxableAmt.toStringAsFixed(
                                                    2)}",
                                                style:
                                                const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            _twoColumnRow(
                                              leftLabel: Strings.taxAmt,
                                              leftValue: Text(
                                                "₹${taxAmt.toStringAsFixed(2)}",
                                                style:
                                                const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              rightLabel: Strings.totalAmt,
                                              rightValue: Text(
                                                "₹${totalAmt.toStringAsFixed(2)}",
                                                style:
                                                const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),

                                            _twoColumnRow(
                                              leftLabel: Strings.freight,
                                              leftValue: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "₹${freightValue
                                                        .toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight
                                                            .w600),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final result = await showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            FreightAndPostageDialog(
                                                              initialCharges: freightCharges,
                                                            ),
                                                      );
      
                                                      if (result != null) {
                                                        setState(() {
                                                          freightValue =
                                                          result["total"];
                                                          freightCharges =
                                                          List<Map<String,
                                                              dynamic>>.from(
                                                              result["chargesList"]);
                                                          _recalculateTotals(); // recalc with freight
                                                          _onDiscountChanged();
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .all(4),
                                                      decoration: BoxDecoration(
                                                        color: primary
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 16,
                                                        color: primary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              rightLabel: Strings.grossTotal,
                                              rightValue: Text(
                                                "₹${netBillTotal.toStringAsFixed(
                                                    2)}",
                                                style:
                                                const TextStyle(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),

                                            _twoColumnRow(
                                                leftLabel: Strings.roundOff,
                                                leftValue: SizedBox(
                                                  width: 60,
                                                  height: 30,
                                                  child: TextField(
                                                    controller: roundOffController,
                                                    keyboardType: TextInputType
                                                        .number,
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 6),
                                                      border: OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                rightLabel: "",
                                                rightValue: Text("")),
                                          ],
                                        ),
                                        secondChild: const SizedBox(),
                                      ),
                                      Divider(),
      
                                      /// Final Highlight Amount (Always Visible)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text(
                                            Strings.netBillAmount,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            "₹${netBillAmt.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              /// Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        final salesVM =
                                        Provider.of<SalesInvoiceViewmodel>(context, listen: false);

                                        salesVM.clearBillDetails();
                                        salesVM.clearCustomerDetails();
                                        Navigator.pop(context);
                                      },
                                      child: const Text(Strings.cancel),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () async {
                                        // CUSTOMER VALIDATION
                                        if (customerController.text
                                            .trim()
                                            .isEmpty ||
                                            selectedCustId == 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red
                                                  .shade600,
                                              content: Text(Strings
                                                  .selectCustomerSnackText),
                                            ),
                                          );
                                          return;
                                        }
      
                                        // PRODUCT VALIDATION
                                        if (items.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red
                                                  .shade600,
                                              content: const Text(
                                                  Strings.salesInvoiceSnackText),
                                            ),
                                          );
                                          return;
                                        }
      
                                        if (selectedBillType == null ||
                                            selectedBillType == "-") {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red
                                                  .shade600,
                                              content: const Text(
                                                  Strings.selectBillDetailsSnack),
                                            ),
                                          );
                                          return;
                                        }

                                          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
                                          final isEdit = args?['isEdit'] ?? false;
                                          final sale = args?['saleData'] as SalesDashboardModel?;

                                          await _submitSalesReturn(isEdit: isEdit, sale: sale);
                                      },
                                      child: Text(Strings.save,
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              )
          ),
                    ),
    );
                }

                Widget _buildDetailRow(String label, String value) {
        return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(
        label,
        style: const TextStyle(
        fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ],
        ),
        );
        }

        Widget _twoColumnRow({
    required String leftLabel,
    required Widget leftValue,
    required String rightLabel,
    required Widget rightValue,
    })
    {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    leftLabel,
                    style: const TextStyle(fontSize: 14),
                  ),
                  leftValue,
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rightLabel,
                    style: const TextStyle(fontSize: 14),
                  ),
                  rightValue,
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _glassCard({required Widget child}) {
      return Container(
        padding: const EdgeInsets.all(10),
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
  }
