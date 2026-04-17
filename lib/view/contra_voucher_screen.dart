import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/add_vouchers_model.dart';
import '../res/widgets/gif_loader.dart';
import '../utils/app_colors.dart';
import '../viewModel/payment_voucher_viewmodel.dart';
import '../viewmodel/contra_voucher_viewmodel.dart';
import 'add_contra_voucher_dialog.dart';


class ContraVoucherScreen extends StatefulWidget {
  const ContraVoucherScreen({super.key});

  @override
  State<ContraVoucherScreen> createState() => _ContraVoucherScreenState();
}

class _ContraVoucherScreenState extends State<ContraVoucherScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Map<String, dynamic> get _requestBody => {
    "VoucherId": null,
    "VchTypeId": 7, // ✅ CONTRA
    "VchDate": null,
    "UserId": "1",

  };

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Provider.of<ContraVoucherViewModel>(context, listen: false)
  //         .getAllContraVouchers(_requestBody);
  //
  //   });
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contraVM =
      Provider.of<ContraVoucherViewModel>(context, listen: false);

      contraVM.getAllContraVouchers(_requestBody);

      // ✅ PRELOAD DROPDOWNS ONCE
      contraVM.preloadContraDropdowns();
    });
  }


  void _openAddDialog({dynamic existingVoucher}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AddContraVoucherDialog(existingVoucher: existingVoucher),
    );

    if (result == true) {
      Provider.of<PaymentVoucherViewmodel>(context, listen: false)
          .getAllVouchers(_requestBody);
    }
  }

  void _confirmDelete(AddVouchersModel voucher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Contra Voucher"),
        content: const Text("Are you sure you want to delete this voucher?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel",style: TextStyle(color: primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete",style: TextStyle(color: white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final vm =
      Provider.of<ContraVoucherViewModel>(context, listen: false);

      final success =
      await vm.deleteContraVoucher(voucher.voucherId!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🗑 Contra voucher deleted")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          "Contra Voucher",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Consumer<ContraVoucherViewModel>(
        builder: (context, viewModel, _) {
          final filteredVouchers = viewModel.contraVouchers.where((v) {
            final q = _searchQuery.toLowerCase();
            return (v.vchNo?.toString().contains(q) ?? false) ||
                (v.debitLedgerName?.toLowerCase().contains(q) ?? false) ||
                (v.creditLedgerName?.toLowerCase().contains(q) ?? false) ||
                (v.vchAmt?.toString().contains(q) ?? false);
          }).toList();

          return Column(
            children: [
              // 🔍 Search + Add
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: "Search contra vouchers...",
                          prefixIcon:
                          const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _openAddDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🌀 Loader / Empty / List
              if (viewModel.loading)
                const Expanded(child: GifLoader())
              else if (filteredVouchers.isEmpty)
                const Expanded(
                    child: Center(
                        child: Text("No vouchers found",
                            style: TextStyle(color: Colors.grey))))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredVouchers.length,
                    itemBuilder: (context, index) {
                      final v = filteredVouchers[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Voucher No + Date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Voucher No: ${v.vchNo ?? '-'}",
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        v.vchDate != null && v.vchDate!.isNotEmpty
                                            ? DateFormat('dd MMM yyyy')
                                            .format(DateTime.parse(v.vchDate!))
                                            : "-",
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Amount
                              Text(
                                "₹ ${NumberFormat("#,##0.00").format(v.vchAmt ?? 0)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _infoRow("From A/c", v.creditLedgerName),
                              _infoRow("To A/c", v.debitLedgerName),

                              // Narration
                              if (v.vchNarration != null && v.vchNarration!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.notes,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        v.vchNarration!,
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const Divider(height: 16),

                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                    onPressed: () {
                                      _openAddDialog(existingVoucher: v);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(v),
                                  ),

                                ],
                              ),
                            ],
                          ),

                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),

    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }
}
