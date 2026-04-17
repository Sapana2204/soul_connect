import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';
import '../utils/app_colors.dart';
import '../viewmodel/journal_voucher_viewmodel.dart';

class AddJournalVoucherDialog extends StatefulWidget {
  final AddVouchersModel? existingVoucher;

  const AddJournalVoucherDialog({super.key, this.existingVoucher});

  @override
  State<AddJournalVoucherDialog> createState() =>
      _AddJournalVoucherDialogState();
}

class _AddJournalVoucherDialogState
    extends State<AddJournalVoucherDialog> {
  final _formKey = GlobalKey<FormState>();

  LedgerTypeModel? _fromAccount; // CR (BC)
  LedgerTypeModel? _toAccount;   // DR (E)
  int? _fromLedgerId; // CR
  int? _toLedgerId;   // DR


  List<LedgerTypeModel> _fromAccounts = [];
  List<LedgerTypeModel> _toAccounts = [];

  final TextEditingController _amountController =
  TextEditingController();
  final TextEditingController _narrationController =
  TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //
  //   if (widget.existingVoucher != null) {
  //     _amountController.text =
  //         widget.existingVoucher!.vchAmt?.toString() ?? "";
  //     _narrationController.text =
  //         widget.existingVoucher!.vchNarration ?? "";
  //
  //     _fromLedgerId = widget.existingVoucher!.creditLedgerId; // CR
  //     _toLedgerId = widget.existingVoucher!.debitLedgerId;   // DR
  //   }
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final vm =
  //     Provider.of<JournalVoucherViewModel>(context, listen: false);
  //
  //     // 🔹 Load From A/c (CR - BC)
  //     await vm.loadLedgerAccounts("BC");
  //     _fromAccounts = vm.bankAccounts;
  //
  //     // 🔹 Load To A/c (DR - E)
  //     await vm.loadLedgerAccounts("E");
  //     _toAccounts = vm.bankAccounts;
  //
  //     // 🔑 Map IDs → dropdown objects
  //     if (widget.existingVoucher != null) {
  //       setState(() {
  //         _fromAccount = _fromAccounts.firstWhere(
  //               (e) => e.ledgerId == _fromLedgerId,
  //         );
  //
  //         _toAccount = _toAccounts.firstWhere(
  //               (e) => e.ledgerId == _toLedgerId,
  //         );
  //       });
  //     } else {
  //       setState(() {});
  //     }
  //   });
  // }


  @override
  void initState() {
    super.initState();

    final vm =
    Provider.of<JournalVoucherViewModel>(context, listen: false);

    _fromAccounts = vm.creditLedgers;
    _toAccounts = vm.debitLedgers;

    if (widget.existingVoucher != null) {
      _amountController.text =
          widget.existingVoucher!.vchAmt?.toString() ?? "";
      _narrationController.text =
          widget.existingVoucher!.vchNarration ?? "";

      _fromAccount = _fromAccounts.firstWhere(
            (e) => e.ledgerId == widget.existingVoucher!.creditLedgerId,
      );

      _toAccount = _toAccounts.firstWhere(
            (e) => e.ledgerId == widget.existingVoucher!.debitLedgerId,
      );
    }
  }

  Future<void> _saveJournalVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccount == null || _toAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select both accounts")),
      );
      return;
    }

    final model = AddVouchersModel(
      voucherId: widget.existingVoucher?.voucherId ?? 0,
      vchTypeId: 8, // ✅ JOURNAL
      vchSeriesId: 1,
      vchNo: "",
      firmId: 1,
      locationId: 1,
      vchDate:
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      vchAmt:
      double.tryParse(_amountController.text) ?? 0,
      debitLedgerId: _toAccount!.ledgerId,
      creditLedgerId: _fromAccount!.ledgerId,
      debitLedgerName: _toAccount!.ledgerName ?? "",
      creditLedgerName: _fromAccount!.ledgerName ?? "",
      vchNarration: _narrationController.text,
      payMode: "",
      payType: "",
      chequeNo: "",
      chequeDate: "",
      bankName: "",
      chequeNarration: _narrationController.text,
      receiptNo: "",
      voucherAt: "",
      userId: 1,
      createdBy: 1,
      updatedBy: 1,
      misc1: "",
      misc2: "",
      misc3: "",
      misc4: "",
      misc5: "",
    );

    final journalVM =
    Provider.of<JournalVoucherViewModel>(context,
        listen: false);

    final success = widget.existingVoucher == null
        ? await journalVM.addJournalVoucher(context, model)
        : await journalVM.updateJournalVoucher(context, model);

    if (success) {
      await journalVM.getAllJournalVouchers({
        "VoucherId": null,
        "VchTypeId": 8,
        "VchDate": null,
        "UserId": "1",
      });

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm =
    Provider.of<JournalVoucherViewModel>(context);

    return Dialog(
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 Header
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingVoucher == null
                          ? "Add Journal Voucher"
                          : "Edit Journal Voucher",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🟩 Accounts
                _buildCardSection(
                  children: [
                    DropdownButtonFormField<LedgerTypeModel>(
                      decoration:
                      _inputDecoration("From A/c (CR) *"),
                      value: _fromAccount,
                      items: _fromAccounts
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child:
                        Text(e.ledgerName ?? ""),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _fromAccount = v),
                      validator: (v) =>
                      v == null ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LedgerTypeModel>(
                      decoration:
                      _inputDecoration("To A/c (DR) *"),
                      value: _toAccount,
                      items: _toAccounts
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child:
                        Text(e.ledgerName ?? ""),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _toAccount = v),
                      validator: (v) =>
                      v == null ? "Required" : null,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// 🟦 Amount & Narration
                _buildCardSection(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: _flatInputDecoration(
                          label: "Amount *",
                          icon: Icons.currency_rupee),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (double.tryParse(v) == null ||
                            double.parse(v) <= 0) {
                          return "Invalid amount";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _narrationController,
                      minLines: 2,
                      maxLines: null,
                      decoration: _flatInputDecoration(
                          label: "Narration",
                          icon: Icons.notes),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// 🔘 Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text("Cancel")),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check,
                          color: Colors.white),
                      label: Text(widget.existingVoucher == null
                          ? "Add"
                          : "Update"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primary),
                      onPressed: _saveJournalVoucher,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  InputDecoration _flatInputDecoration(
      {required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: primary) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border:
      OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildCardSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}
