import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/add_vouchers_model.dart';
import '../model/ledger_type_model.dart';
import '../utils/app_colors.dart';
import '../viewModel/payment_voucher_viewmodel.dart';
import '../viewmodel/contra_voucher_viewmodel.dart';


class AddContraVoucherDialog extends StatefulWidget {
  final AddVouchersModel? existingVoucher;

  const AddContraVoucherDialog({super.key, this.existingVoucher});

  @override
  State<AddContraVoucherDialog> createState() =>
      _AddContraVoucherDialogState();
}

class _AddContraVoucherDialogState extends State<AddContraVoucherDialog> {
  final _formKey = GlobalKey<FormState>();

  LedgerTypeModel? _fromAccount;
  LedgerTypeModel? _toAccount;
  int? _fromLedgerId;
  int? _toLedgerId;


  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _narrationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingVoucher != null) {
      _amountController.text =
          widget.existingVoucher!.vchAmt?.toString() ?? "";
      _referenceController.text =
          widget.existingVoucher!.refBillId ?? "";
      _narrationController.text =
          widget.existingVoucher!.vchNarration ?? "";

      _fromLedgerId = widget.existingVoucher!.creditLedgerId;
      _toLedgerId = widget.existingVoucher!.debitLedgerId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contraVM =
      Provider.of<ContraVoucherViewModel>(context, listen: false);

      if (widget.existingVoucher != null &&
          contraVM.contraLedgers.isNotEmpty) {
        setState(() {
          _fromAccount = contraVM.contraLedgers.firstWhere(
                  (e) => e.ledgerId == _fromLedgerId);
          _toAccount = contraVM.contraLedgers.firstWhere(
                  (e) => e.ledgerId == _toLedgerId);
        });

        debugPrint(
          "🪟 [ContraDialog] Using cached ledgers → "
              "From:${_fromAccount?.ledgerName}, "
              "To:${_toAccount?.ledgerName}",
        );
      }
    });

  }



  Future<void> _saveContraVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccount == null || _toAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both accounts")),
      );
      return;
    }

    final model = AddVouchersModel(
      locationId: 1,
      debitLedgerId: _toAccount!.ledgerId,
      creditLedgerId: _fromAccount!.ledgerId,
      voucherId: widget.existingVoucher?.voucherId ?? 0,
      vchTypeId: 7, // ✅ Contra
      vchSeriesId: 1,
      vchNo: "",
      firmId: 1,
      vchDate: DateFormat('yyyy-MM-dd').format(DateTime.now()), // today's date
      vchAmt: double.tryParse(_amountController.text) ?? 0,
      vchNarration: _narrationController.text,
      debitLedgerName: _toAccount?.ledgerName ?? "",
      creditLedgerName: _fromAccount?.ledgerName ?? "",
      refBillId: _referenceController.text,
      voucherAt: "",
      receiptNo: "",
      chequeNo: "", // required by API
      payMode: "CASH", // default for contra
      payType: "",
      chequeDate: "",
      bankName: "",
      chequeNarration: _narrationController.text,
      userId: 1,
      misc1: "",
      misc2: "",
      misc3: "",
      misc4: "",
      misc5: "",
      createdBy: 1,
      updatedBy: 1,
    );

    // 🔹 Add / Update via Payment VM
    final paymentVM =
    Provider.of<PaymentVoucherViewmodel>(context, listen: false);

    final success = widget.existingVoucher == null
        ? await paymentVM.addVoucher(context, model)
        : await paymentVM.updateVoucher(context, model);

    if (success) {
      // 🔹 Refresh Contra list
      final contraVM =
      Provider.of<ContraVoucherViewModel>(context, listen: false);

      await contraVM.getAllContraVouchers({
        "VoucherId": null,
        "VchTypeId": 7,
        "VchDate": null,
        "UserId": "1",
      });

      // 🔹 Close dialog and go back to Contra screen
      Navigator.pop(context, true);
    }
  }


  @override
  Widget build(BuildContext context) {
    final contraVM = Provider.of<ContraVoucherViewModel>(context);

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
          ),
        ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.existingVoucher == null
                            ? "Add Contra Voucher"
                            : "Edit Contra Voucher",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1.2),

                  /// 🔹 Date (same as payment dialog)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🟩 Section 1: Accounts
                  _buildCardSection(
                    children: [
                      contraVM.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<LedgerTypeModel>(
                        value: _fromAccount,
                        decoration: _dropdownDecoration("From Account *"),
                        isDense: true,
                        items: contraVM.contraLedgers.map((ledger) {
                          return DropdownMenuItem(
                            value: ledger,
                            child: Text(ledger.ledgerName ?? ""),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _fromAccount = val;
                            if (_toAccount?.ledgerId == val?.ledgerId) {
                              _toAccount = null;
                            }
                          });
                        },
                        validator: (v) => v == null ? "Select From Account" : null,
                      ),




                      const SizedBox(height: 12),


                      DropdownButtonFormField<LedgerTypeModel>(
                        value: _toAccount,
                        decoration: _dropdownDecoration("To Account *"),
                        isDense: true,
                        items: contraVM.contraLedgers
                            .where((e) => e.ledgerId != _fromAccount?.ledgerId)
                            .map((ledger) {
                          return DropdownMenuItem(
                            value: ledger,
                            child: Text(ledger.ledgerName ?? ""),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _toAccount = val),
                        validator: (v) => v == null ? "Select To Account" : null,
                      ),


                    ],
                  ),

                  const SizedBox(height: 16),

                  /// 🟦 Section 2: Amount & Narration
                  _buildCardSection(
                    children: [
                      Row(
                        children: [
                          /// 💰 Amount
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _flatInputDecoration(
                                label: "Amount *",
                                icon: Icons.currency_rupee,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return "Required";
                                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                                  return "Invalid amount";
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// 🧾 Reference No
                          Expanded(
                            child: TextFormField(
                              controller: _referenceController,
                              decoration: _flatInputDecoration(
                                label: "Reference No",
                                icon: Icons.receipt_long,
                              ),
                            ),
                          ),
                        ],
                      ),


                      const SizedBox(height: 12),

                      /// 📝 Narration
                      TextFormField(
                        controller: _narrationController,
                        minLines: 2, // 👈 start height
                        maxLines: null, // 👈 auto-expand
                        keyboardType: TextInputType.multiline,
                        decoration: _flatInputDecoration(
                          label: "Narration",
                          icon: Icons.notes,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 24),

                  /// 🔘 Buttons (same as payment)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check,
                            color: Colors.white, size: 18),
                        label: Text(
                            widget.existingVoucher == null ? "Add" : "Update"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _saveContraVoucher,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _flatInputDecoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: primary) : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // ❌ no border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    );
  }
  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,

      contentPadding:
      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }


  Widget _buildTextField(
      TextEditingController controller, String label, bool isNumeric) {
    return TextFormField(
      controller: controller,
      keyboardType:
      isNumeric ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label),
      validator: (v) =>
      label.contains('*') && (v == null || v.isEmpty)
          ? "Required"
          : null,
    );
  }

  Widget _buildCardSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }


}


