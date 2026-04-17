import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/view/send_msg_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'dart:developer';


import '../model/add_sale_model.dart';
import '../model/invoice_item_model.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/sales_invoice_viewmodel.dart';
import '../viewmodel/add_sale_view_model.dart';
import '../viewmodel/ledger_type_viewmodel.dart';
import 'homeScreen.dart';

class ConfirmCashPaymentDialog extends StatefulWidget {
  // final bool isEdit;
  final double totalAmount;
  final double totalQty;
  final double itemTotal;
  final double discountPercent;
  final double discountAmt;
  final double totalDiscAmt;
  final double taxableAmt;
  final double taxAmt;
  final double totalAmt;
  final double freight;
  final double roundOff;
  final double netBillTotal;
  final double netBillAmt;
  final double freeQty;
  final List<InvoiceItem> items;
  final List<Map<String, dynamic>> otherCharges;
  final int customerId;
  final String customerName;
  final String address;
  final String contact;
  final String byHand;
  final String billType;
  final String rateType;
  final String salesType;
  final String locationId;
  final double invoiceChargesAmt;
  final int salesId;
 final String payMode;
 final String salesDate;
 final String paymentTerm;
 final String taxType;

  const ConfirmCashPaymentDialog({
    super.key,
    // required this.isEdit,
    required this.totalAmount,
    required this.totalQty,
    required this.itemTotal,
    required this.discountPercent,
    required this.discountAmt,
    required this.taxableAmt,
    required this.taxAmt,
    required this.totalAmt,
    required this.freight,
    required this.roundOff,
    required this.netBillTotal,
    required this.netBillAmt,
    required this.freeQty,
    required this.items,
    required this.otherCharges,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.invoiceChargesAmt,
    required this.byHand,
    required this.billType,
    required this.salesType,
    required this.rateType,
    required this.locationId,
    required this.contact,
    required this.totalDiscAmt,
    required this.salesId,
    required this.payMode,
    required this.salesDate,
    required this.paymentTerm,
    required this.taxType
  });

  @override
  State<ConfirmCashPaymentDialog> createState() =>
      _ConfirmCashPaymentDialogState();
}

class _ConfirmCashPaymentDialogState extends State<ConfirmCashPaymentDialog> {
  final TextEditingController cashAmountController = TextEditingController();
  final TextEditingController bankAmountController = TextEditingController();

  String cashMode = "Cash";
  String cashAccount = "Cash";
  String? selectedBankMode;
  String? selectedBankAccount;

  final List<String> bankModes = ["UPI", "Net Banking", "Card"];
  List<SalesOtherCharge> salesOtherCharges = [];


  bool _isUpdating = false;
  bool isBankFieldsEnabled = false;


  void logLong(String tag, String text) {
    const int chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      log('${tag}_part${(i / chunkSize).floor()}: ${text.substring(i, end)}');
    }
  }


  void addOtherCharge(int ledgerId, double amount, String ledgerName) {
    setState(() {
      salesOtherCharges.add(
        SalesOtherCharge(
          ledgerId: ledgerId,
          amount: amount,
          ledgerName: ledgerName,
        ),
      );
    });
  }

  Future<void> _addSaleAPI(BuildContext context) async {
    final double cashAmount = double.tryParse(cashAmountController.text) ?? 0.0;
    final double bankAmount = double.tryParse(bankAmountController.text) ?? 0.0;

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userIdString = loginVM.userId;
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    // 🔹 Validation
    if (bankAmount > 0) {
      if (selectedBankMode == null || selectedBankMode!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a bank payment mode."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (selectedBankAccount == null || selectedBankAccount!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a bank account."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
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

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final viewModel = Provider.of<AddSaleViewModel>(context, listen: false);

      List<SalesDetail> salesDetails = widget.items.map((item) {

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
          // cashSalesRate: item.cashSalesRate,
          // creditSalesRate: item.creditSalesRate,
          // outletSalesRate: item.outletSalesRate,
          mrp: item.mrp,
          stkPurchaseId: item.stkPurchaseId,
          totalTaxAmt: item.taxAmt,
          netAmt: item.netAmt,
          // pflPurchaseRate: item.cashSalesRate,
          usedAs: "N/A",
          isWithoutGST: item.isNonGST,
          returnQty:item.returnQty.toString(),
          action: "",
        );
      }).toList();

      // Convert other charges
      List<SalesOtherCharge> otherCharges = salesOtherCharges;

      // Create AddSaleModel instance
      final addSale = AddSaleModel(
        salesID:  widget.salesId,
        // salesID: widget.isEdit ? widget.salesId: 0,
        salesBillNo: "",
        salesDate: widget.salesDate,
        customerId: widget.customerId,
        totalQty: widget.totalQty,
        itemTotal: widget.itemTotal,
        locationId: int.tryParse(widget.locationId) ?? 0,
        userID: userId,
        billType: widget.billType,
        rateType: widget.rateType,
        taxIncludeExclude: widget.taxType,
        salesType: widget.payMode,
        paymentTerm: widget.paymentTerm.toString(),
        cropType: "",
        freeQty: widget.freeQty,
        subTotal: widget.itemTotal,
        discPer: widget.discountPercent,
        discAmt: widget.discountAmt,
        totalDiscAmt: widget.totalDiscAmt,
        totalAmt: widget.totalAmt,
        freight: widget.freight,
        taxableAmt: widget.taxableAmt,
        totalTaxAmt: widget.taxAmt,
        totalTaxableAmt: widget.taxableAmt,
        invoiceChargesAmt: widget.invoiceChargesAmt,
        billTotal: widget.totalAmt + widget.freight,
        roundOff: widget.roundOff,
        netBillTotal: widget.netBillTotal,
        netAmt: widget.netBillAmt,
        netBillAmt: widget.netBillAmt,
        narration: "",
        byHand: widget.byHand,
        vehicleDetails: "",
        isBillReceived: true,
        bankLedgerId: selectedBankLedgerId,
        isChallanInvoice: false,
        isQuotationInvoice: false,
        isWalkinCustomer: false,
        customerName: widget.customerName,
        address: widget.address,
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
        phoneNumber: widget.contact,
        salesDetails: salesDetails,
        salesOtherCharges: otherCharges,
      );


      final requestBody = addSale.toJson();
      debugPrint("=========== ADD PURCHASE REQUEST ===========");
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
      debugPrint("============================================");
      // print("🔹 Add Sale Request: ${jsonEncode(requestBody)}");
      logLong('Request Body', jsonEncode(requestBody));

      // 🔹 Call API
      final salesId = await viewModel.addSale(context, requestBody);
      final salesVM =
      Provider.of<SalesInvoiceViewmodel>(context, listen: false);
      salesVM.clearBillDetails();
      salesVM.clearCustomerDetails();
      Navigator.pop(context); // hide loader

      if (salesId != null && salesId > 0) {
        // Show success snackbar
        Fluttertoast.showToast(
          msg: "Sale added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0,
        );

        // ✅ 2️⃣ Open SMS Dialog
        // await showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (context) => SendBillMessageDialog(salesId: salesId),
        // );

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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Something went wrong: $e"),
      //     backgroundColor: Colors.redAccent,
      //   ),
      // );
      Fluttertoast.showToast(
        msg: ("Something went wrong: $e"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }


  // Future<void> _addSaleAPI(BuildContext context) async {
  //   // 🔹 Get user-entered values
  //   final double cashAmount = double.tryParse(cashAmountController.text) ?? 0.0;
  //   final double bankAmount = double.tryParse(bankAmountController.text) ?? 0.0;
  //
  //   final ledgerVM = Provider.of<LedgerTypeViewmodel>(context, listen: false);
  //
  //   // 🔹 Get selected bank ledger id (from dropdown)
  //   int selectedBankLedgerId = 0;
  //   if (selectedBankAccount != null && ledgerVM.bankAccounts.isNotEmpty) {
  //     final matchedLedger = ledgerVM.bankAccounts.firstWhere(
  //           (ledger) => ledger.ledgerName == selectedBankAccount,
  //       orElse: () => ledgerVM.bankAccounts.first,
  //     );
  //     selectedBankLedgerId = matchedLedger.ledgerId ?? 0;
  //   }
  //
  //   // 🔹 Get selected mode of bank payment
  //   final modeOfBankPayment = selectedBankMode ?? "";
  //   try {
  //     // Show loader
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => const Center(child: CircularProgressIndicator()),
  //     );
  //
  //     final viewModel = Provider.of<AddSaleViewModel>(context, listen: false);
  //
  //     final requestBody = {
  //       "SalesID": 0,
  //       "SalesBillNo": "",
  //       "SalesDate": DateTime.now().toIso8601String(),
  //       "CustomerId": widget.customerId,
  //       "TotalQty": widget.totalQty,
  //       "ItemTotal": widget.itemTotal,
  //       "LocationId": widget.locationId,
  //       "UserID": 1,
  //       "BillType": widget.billType,
  //       "RateType": widget.rateType,
  //       "SalesType": widget.salesType,
  //       "PaymentTerm": 0,
  //       "CropType": "",
  //       "FreeQty": widget.freeQty,
  //       "SubTotal": widget.itemTotal,
  //       "DiscPer": widget.discountPercent,
  //       "DiscAmt": widget.discountAmt,
  //       "TotalDiscAmt": widget.totalDiscAmt,
  //       "TotalAmt": widget.totalAmt,
  //       "Freight": widget.freight,
  //       "TaxableAmt": widget.taxableAmt,
  //       "TotalTaxAmt": widget.taxAmt,
  //       "TotalTaxableAmt": widget.taxableAmt, // if same
  //       "InvoiceChargesAmt": widget.invoiceChargesAmt, // if no extra charges
  //       "BillTotal": widget.totalAmt + widget.freight,
  //       "RoundOff": widget.roundOff,
  //       "NetBillTotal": widget.netBillTotal,
  //       "NetAmt": widget.netBillAmt,
  //       // "NetBillAmt": widget.netBillAmt,
  //       "Narration": "",
  //       "ByHand": widget.byHand,
  //       "VehicleDetails": "",
  //       "IsBillReceived": 0,
  //       "BankLedgerId": selectedBankLedgerId,
  //       "IsChallanInvoice": true,
  //       "IsQuotationInvoice": true,
  //       "IsWalkinCustomer": false,
  //       "CustomerName": widget.customerName,
  //       "Address": widget.address,
  //       "Age": 0,
  //       "CashPaidAmount": cashAmount,
  //       "BankPaidAmount": bankAmount,
  //       "ModeOfBankPayment": modeOfBankPayment,
  //       "CustomerOutstanding": 0,
  //       "IsSalesReturned": false,
  //       "Misc1": "",
  //       "Misc2": "",
  //       "Misc3": "",
  //       "Misc4": "",
  //       "Misc5": "",
  //       "PreparedBy": 0,
  //       "CheckedBy": 0,
  //       "CreatedBy": 1,
  //       "UpdatedBy": 1,
  //       "PhoneNumber": widget.contact,
  //       "SalesDetails": widget.items.map((item) => item.toJson()).toList(),
  //       "SalesOtherCharges": salesOtherCharges.map((charge) => {
  //         "LedgerId": charge.ledgerId ?? 0,
  //         "SalesId": 0,
  //         "SalesOtherChargeId": 0,
  //         "Amount": charge.amount,
  //         "charges": charge.amount,
  //         "LedgerName": charge.ledgerName,
  //       }).toList(),
  //     };
  //
  //
  //     print("🔹 Add Sale Request: ${jsonEncode(requestBody)}");
  //     await viewModel.addSale(context, requestBody);
  //
  //     // Navigator.pop(context); // hide loader
  //     // If success
  //     Navigator.pushReplacementNamed(context, RouteNames.salesDashboard);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Sale added successfully!")),
  //     );
  //
  //   } catch (e) {
  //     Navigator.pop(context); // hide loader if error
  //     print("❌ Exception in Add Sale API: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Something went wrong: $e"),
  //         backgroundColor: Colors.redAccent,
  //       ),
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();

    // convert map data from Freight dialog into model list
    salesOtherCharges = widget.otherCharges.map((charge) {
      return SalesOtherCharge(
        ledgerId: charge["ledgerId"]??0, // if you have LedgerId in result, use that instead
        amount: charge["charge"] ?? 0.0,
        ledgerName: charge["ledger"] ?? "",
      );
    }).toList();

    cashAmountController.text = widget.totalAmount.toStringAsFixed(0);
    bankAmountController.text = "0";

    cashAmountController.addListener(_onCashChanged);
    bankAmountController.addListener(_onBankChanged);

    // 🔹 Trigger API once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ledgerVM = Provider.of<LedgerTypeViewmodel>(context, listen: false);
      if (ledgerVM.bankAccounts.isEmpty) {
        ledgerVM.loadBankAccounts();
      }
    });
  }

  void _onCashChanged() {
    if (_isUpdating) return;

    _isUpdating = true;
    final cashValue = double.tryParse(cashAmountController.text) ?? 0;
    final remaining =
        (widget.totalAmount - cashValue).clamp(0, widget.totalAmount);
    bankAmountController.text = remaining.toStringAsFixed(0);
    _isUpdating = false;

    _updateBankFieldState(remaining.toDouble()); // update enable/disable state
  }

  void _onBankChanged() {
    if (_isUpdating) return;

    _isUpdating = true;
    final bankValue = double.tryParse(bankAmountController.text) ?? 0;
    final remaining =
        (widget.totalAmount - bankValue).clamp(0, widget.totalAmount);
    cashAmountController.text = remaining.toStringAsFixed(0);
    _isUpdating = false;

    _updateBankFieldState(bankValue); // update enable/disable state
  }

  // Enable or disable bank mode/account fields dynamically
  void _updateBankFieldState(double bankAmount) {
    setState(() {
      isBankFieldsEnabled = bankAmount > 0;
      if (!isBankFieldsEnabled) {
        selectedBankMode = null;
        selectedBankAccount = null;
      }
    });
  }

  @override
  void dispose() {
    cashAmountController.dispose();
    bankAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * 0.8,
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Confirm Cash Payment",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Total
              RichText(
                text: TextSpan(
                  text: "Total Amount: ",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: "₹ ${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Cash section
              _sectionContainer(
                title: "Cash Payment",
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    SizedBox(
                      width: 140,
                      child: _buildTextField(
                        controller: cashAmountController,
                        label: "Cash Amount",
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: _buildTextField(
                        label: "Mode",
                        initialValue: cashMode,
                        readOnly: true,
                      ),
                    ),
                    SizedBox(
                      // width: 140,
                      child: _buildTextField(
                        label: "Cash Account",
                        initialValue: cashAccount,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Bank section
              _sectionContainer(
                title: "Bank Payment",
                child: Consumer<LedgerTypeViewmodel>(
                  builder: (context, ledgerVM, _) {
                    final isEnabled =
                        (double.tryParse(bankAmountController.text) ?? 0) > 0;

                    return Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      children: [
                        SizedBox(
                          width: 140,
                          child: _buildTextField(
                            controller: bankAmountController,
                            label: "Bank Amount",
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            decoration:
                                _inputDecoration("Mode", isEnabled: isEnabled),
                            value: selectedBankMode,
                            items: bankModes
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: isEnabled
                                ? (val) =>
                                    setState(() => selectedBankMode = val)
                                : null,
                          ),
                        ),
                        SizedBox(
                          child: ledgerVM.isLoading
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : DropdownButtonFormField<String>(
                                  decoration: _inputDecoration("Bank Account",
                                      isEnabled: isEnabled),
                                  value: selectedBankAccount,
                                  items: ledgerVM.bankAccounts
                                      .map((ledger) => DropdownMenuItem(
                                            value: ledger.ledgerName,
                                            child:
                                                Text(ledger.ledgerName ?? ""),
                                          ))
                                      .toList(),
                                  onChanged: isEnabled
                                      ? (val) => setState(
                                          () => selectedBankAccount = val)
                                      : null,
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: _buildButton(
                      label: "Save Invoice",
                      // label: widget.isEdit ? "Edit Invoice" : "Save Invoice",

                      color: Colors.green.shade600,
                      onPressed: () => _addSaleAPI(context),
                      // onPressed: () {
                      //   Navigator.pop(context, {
                      //     "cashAmount": cashAmountController.text,
                      //     "bankAmount": bankAmountController.text,
                      //     "bankMode": selectedBankMode,
                      //     "bankAccount": selectedBankAccount,
                      //   });
                      // },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Flexible(
                  //   child: _buildButton(
                  //     label: "Save & Print",
                  //     color: Colors.green.shade600,
                  //     onPressed: () => Navigator.pop(context),
                  //   ),
                  // ),
                  // Flexible(
                  //   child: _buildButton(
                  //     label: "Save & Print",
                  //     color: Colors.green.shade600,
                  //     onPressed: () async {
                  //       // Step 1️⃣: Open print preview
                  //       final result = await Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => InvoicePrintScreen(salesId: widget.salesId),
                  //         ),
                  //       );
                  //
                  //       // Step 2️⃣: After returning from print preview, check confirmation
                  //       if (result == true) {
                  //         _addSaleAPI(context); // Then add sale to backend
                  //       }
                  //     },
                  //   ),
                  // ),

                  const SizedBox(width: 10),
                  Flexible(
                    child: _buildButton(
                      label: "Cancel",
                      color: Colors.blueGrey.shade800,
                      onPressed: () => Navigator.pop(context),
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

  Widget _sectionContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(1, 2),
          )
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {bool isEnabled = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: isEnabled ? Colors.blueGrey.shade600 : Colors.grey,
      ),
      filled: true,
      fillColor: isEnabled ? Colors.white : Colors.grey.shade200,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isEnabled ? Colors.blueAccent : Colors.grey.shade400,
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
          vertical: 6, horizontal: 8),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? label,
    bool readOnly = false,
    String? initialValue,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label ?? ""),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 2,
      ),
      onPressed: onPressed,
      child: FittedBox(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
