import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/payment_voucher_viewmodel.dart';
import '../viewModel/sales_invoice_viewmodel.dart';

class AddPaymentVoucherDialog extends StatefulWidget {
  final AddVouchersModel? existingVoucher;

  const AddPaymentVoucherDialog({super.key, required this.existingVoucher});

  @override
  State<AddPaymentVoucherDialog> createState() =>
      _AddPaymentVoucherDialogState();
}

class _AddPaymentVoucherDialogState extends State<AddPaymentVoucherDialog> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();
  final TextEditingController _chequeNoController = TextEditingController();
  final TextEditingController _chequeDateController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  String? selectedPaidTo;
  String? selectedPayMode;
  String? selectedPaidBy;
  String? selectedPayType;
  String ledgerBalance = "";

  List<LedgerTypeModel> paidToLedgers = [];
  List<LedgerTypeModel> paidByLedgers = [];

  final List<String> payModeList = [
    Strings.cash,
    Strings.bank,
  ];

  final List<String> payTypeList = [
    Strings.card,
    Strings.upi,
    Strings.netBanking,
    Strings.cheque,
  ];


  @override
  void initState() {
    super.initState();

    final existing = widget.existingVoucher;

    if (existing != null) {
      _dateController.text =
          existing.vchDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      _amountController.text = existing.vchAmt?.toString() ?? '';
      _narrationController.text = existing.vchNarration ?? '';
      _chequeNoController.text = existing.chequeNo ?? '';
      _chequeDateController.text = existing.chequeDate ?? '';
      _bankNameController.text = existing.bankName ?? '';
      selectedPayMode = existing.payMode?.toUpperCase();
      selectedPayType = existing.payType?.toUpperCase();
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = Provider.of<PaymentVoucherViewmodel>(context, listen: false);

      await vm.loadAllLedgersOnce(groupId:25);

      setState(() {
        paidToLedgers = vm.paidToLedgers;

        if (selectedPayMode == Strings.cash) {
          paidByLedgers = vm.cashLedgers;
        } else {
          paidByLedgers = vm.bankLedgers;
        }

        if (existing != null) {
          selectedPaidTo = existing.debitLedgerName;
          selectedPaidBy = existing.creditLedgerName;
        }
      });
    });
  }

  Future<void> _fetchLedgers(PaymentVoucherViewmodel vm, int groupId,
      {required bool isPaidTo}) async {
    await vm.fetchAccLedgersByGrpId(groupId);
    if (isPaidTo) {
      setState(() => paidToLedgers = vm.accLedgerList);
    } else {
      setState(() => paidByLedgers = vm.accLedgerList);
    }
  }

  Widget _buildSearchableDropdown(
      String label,
      List<String> items,
      String? value,
      Function(String?) onChanged, {
        bool isLoading = false,
      }) {
    if (isLoading) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: lightGrey),
          borderRadius: BorderRadius.circular(8),
          color: white,
        ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ""),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return items;
        }

        return items.where((item) =>
            item.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (selection) {
        onChanged(selection);
      },

      /// ✅ CUSTOM DROPDOWN WIDTH
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: Container(
              width: 310, // 👈 SET YOUR DESIRED WIDTH HERE
              constraints: const BoxConstraints(maxHeight: 250),
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);

                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },

      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Select $label",
            suffixIcon: const Icon(Icons.arrow_drop_down),
            labelStyle: TextStyle(color: grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
            filled: true,
            fillColor: white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PaymentVoucherViewmodel>(context);
    final salesInvoiceVm =
    Provider.of<SalesInvoiceViewmodel>(context, listen: false);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
            widget.existingVoucher == null
            ? Strings.addPaymentVoucher
                : Strings.editPaymentVoucher,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: primary,
                      ),
                    ),
                    if (ledgerBalance.isNotEmpty)
                      Text(
                        "Bal: ₹$ledgerBalance",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(thickness: 1.2),

                // 🗓️ Date
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                  "${Strings.dateLabel}: ${_dateController.text}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: blue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined,
                            size: 20, color: Colors.black54),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 🟩 Section 1: Basic Details
                _buildCardSection(
                  children: [
                    _buildSearchableDropdown(
                     Strings.paidTo,
                      paidToLedgers.map((e) => e.ledgerName ?? '').toList(),
                      selectedPaidTo,
                      // (val) => setState(() => selectedPaidTo = val),
                          (val) async {
                        setState(() {
                          selectedPaidTo = val;
                        });

                        final ledger = paidToLedgers.firstWhere(
                              (e) => e.ledgerName == val,
                          orElse: () => LedgerTypeModel(ledgerId: 0, ledgerName: ""),
                        );

                        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

                        await salesInvoiceVm.getLedgerBalanceApi(
                          ledgerId: ledger.ledgerId ?? 0,
                          balanceAsOn: today,
                          balanceType: "T",
                        );

                        setState(() {
                          ledgerBalance = salesInvoiceVm.ledgerBalance?.balance?.abs().toString() ?? "";                        });
                      },
                      // isLoading: viewModel.isLoading && paidToLedgers.isEmpty,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                           Strings.payModeLabel,
                            payModeList,
                            selectedPayMode,
                            (val) async {
                              setState(() {
                                selectedPayMode = val;
                                selectedPaidBy = null;
                                paidByLedgers = [];
                              });

                              // 🟡 Hit API again based on Pay Mode
                              if (val == Strings.cash) {
                                await _fetchLedgers(viewModel, 11,
                                    isPaidTo: false);
                              } else if (val == Strings.bank) {
                                await _fetchLedgers(viewModel, 7,
                                    isPaidTo: false);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownDynamic(
                            Strings.paidBy,
                            paidByLedgers
                                .map((e) => e.ledgerName ?? '')
                                .toList(),
                            selectedPaidBy,
                            (val) => setState(() => selectedPaidBy = val),
                            isLoading:
                                viewModel.isLoading && paidByLedgers.isEmpty,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🟦 Section 2: Amount & Narration
                if (selectedPayMode != null)
                  _buildCardSection(
                    children: [
                      if (selectedPayMode == Strings.cash) ...[
                        _buildTextField(_amountController, Strings.amount, true),
                        const SizedBox(height: 12),
                        _buildTextField(
                            _narrationController,Strings.narration, false),
                      ] else if (selectedPayMode ==Strings.bank) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                Strings.payTypeLabel,
                                payTypeList,
                                selectedPayType,
                                (val) => setState(() => selectedPayType = val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildTextField(
                                    _amountController, "Amount", true)),
                          ],
                        ),
                        if (selectedPayType == Strings.cheque) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextField(
                                      _chequeNoController, Strings.chequeNo, true)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _chequeDateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: Strings.chequeDate,
                                    suffixIcon: const Icon(
                                        Icons.calendar_today_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 8),
                                  ),
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        _chequeDateController.text =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                              _bankNameController, Strings.bankName, false),
                        ],
                        const SizedBox(height: 12),
                        _buildTextField(
                            _narrationController, Strings.narration, false),
                      ],
                    ],
                  ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: grey,
                        side: BorderSide(color: lightGrey),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(Strings.cancel),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check, color: white, size: 18),
                        label: Text(
                          widget.existingVoucher == null
                              ? Strings.add
                              : Strings.update,
                          style: TextStyle(color: white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        onPressed: () async {
                          if (selectedPaidTo == null ||
                              selectedPaidBy == null ||
                              _amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(Strings.fillRequiredFields),
                              ),
                            );
                            return;
                          }

                          final viewModel =
                              Provider.of<PaymentVoucherViewmodel>(context,
                                  listen: false);

                          final debitLedger = paidToLedgers.firstWhere(
                            (e) => e.ledgerName == selectedPaidTo,
                            orElse: () =>
                                LedgerTypeModel(ledgerId: 0, ledgerName: ''),
                          );

                          final creditLedger = paidByLedgers.firstWhere(
                            (e) => e.ledgerName == selectedPaidBy,
                            orElse: () =>
                                LedgerTypeModel(ledgerId: 0, ledgerName: ''),
                          );
                          final loginVM = Provider.of<LoginViewModel>(context, listen: false);
                          final int userId = int.tryParse(loginVM.userId ?? "") ?? 0;
                          final int firmId = int.tryParse(loginVM.firmId ?? "") ?? 0;
                          final int locationId =
                              int.tryParse(loginVM.defaultPurchaseLocId ?? "") ?? 0;

                          final model = AddVouchersModel(
                            locationId: locationId,
                            debitLedgerId: debitLedger.ledgerId ?? 0,
                            creditLedgerId: creditLedger.ledgerId ?? 0,
                            voucherId: widget.existingVoucher?.voucherId ?? 0,
                            vchTypeId: 4,
                            vchSeriesId: 1,
                            vchNo: "",
                            firmId: firmId,
                            vchDate: _dateController.text,
                            vchAmt: double.tryParse(_amountController.text) ?? 0,
                            vchNarration: _narrationController.text,
                            debitLedgerName: selectedPaidTo ?? "",
                            creditLedgerName: selectedPaidBy ?? "",
                            refBillId: "",
                            voucherAt: "",
                            receiptNo: "",
                            chequeNo: _chequeNoController.text,
                            payMode: selectedPayMode ?? "",
                            payType: selectedPayType ?? "",
                            chequeDate: _chequeDateController.text,
                            bankName: _bankNameController.text,
                            chequeNarration: _narrationController.text,
                            userId: userId,
                            misc1: "",
                            misc2: "",
                            misc3: "",
                            misc4: "",
                            misc5: "",
                            createdBy: userId,
                            updatedBy: userId,
                          );

                          bool success;
                          if (widget.existingVoucher == null) {
                            success = await viewModel.addVoucher(
                                context, model); // Add
                          } else {
                            success = await viewModel.updateVoucher(context,
                                model); // ✅ Create update method in ViewModel
                          }

                          if (success) Navigator.pop(context, true);
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown (static)
  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  // Dropdown (dynamic + loading)
  Widget _buildDropdownDynamic(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool isLoading = false,
  }) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: _inputDecoration(label),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          );
  }

  // Text Field
  Widget _buildTextField(
      TextEditingController controller, String label, bool isNumeric) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    );
  }

  // Card Section
  Widget _buildCardSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lightGrey),
        boxShadow: [
          BoxShadow(
            color: grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
