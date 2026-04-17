import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/res/widgets/gif_loader.dart';
import 'package:flutter_soulconnect/res/widgets/no_data.dart';
import 'package:flutter_soulconnect/viewModel/payment_voucher_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/accounts_model.dart';
import '../utils/app_colors.dart';
import '../viewModel/login_viewmodel.dart';

class ReceiptDashboardScreen extends StatefulWidget {
  const ReceiptDashboardScreen({super.key});

  @override
  State<ReceiptDashboardScreen> createState() =>
      _ReceiptDashboardScreenState();
}

class _ReceiptDashboardScreenState
    extends State<ReceiptDashboardScreen> {
  final TextEditingController searchController =
  TextEditingController();
  String searchQuery = "";
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);


    final request = AccountsModel(
      voucherId: null,
      vchTypeId: 3,
      vchDate: null,
      userId: loginVM.userId ?? "0",
      createdBy: 0,
      updatedBy: 0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentVoucherViewmodel>(context, listen: false)
          .getAllVouchers(request.toJson());
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PaymentVoucherViewmodel>(
        builder: (context, viewModel, _) {
          // final filteredVouchers =
          // viewModel.vouchers.where((voucher) {
          //   final query = searchQuery.toLowerCase();
          //
          //   return (voucher.creditLedgerName
          //       ?.toLowerCase()
          //       .contains(query) ??
          //       false) ||
          //       (voucher.debitLedgerName
          //           ?.toLowerCase()
          //           .contains(query) ??
          //           false) ||
          //       (voucher.payMode
          //           ?.toLowerCase()
          //           .contains(query) ??
          //           false) ||
          //       (voucher.vchAmt
          //           ?.toString()
          //           .contains(query) ??
          //           false);
          // }).toList();
      
          final filteredVouchers =
          viewModel.vouchers.where((voucher) {
            final query = searchQuery.toLowerCase();
      
            return (voucher.creditLedgerName
                ?.toLowerCase()
                .contains(query) ??
                false) ||
                (voucher.debitLedgerName
                    ?.toLowerCase()
                    .contains(query) ??
                    false) ||
                (voucher.payMode
                    ?.toLowerCase()
                    .contains(query) ??
                    false) ||
                (voucher.vchAmt
                    ?.toString()
                    .contains(query) ??
                    false);
          }).toList()
      
          /// 🔹 Sort newest first
            ..sort((a, b) => DateTime.parse(b.vchDate!)
                .compareTo(DateTime.parse(a.vchDate!)));
      
          return SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
      
                  /// 🔍 Search
                  if (viewModel.vouchers
                      .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                          vertical: 6),
                      child: TextField(
                        controller:
                        searchController,
                        decoration:
                        InputDecoration(
                          hintText:
                          "Search receipt...",
                          prefixIcon:
                          const Icon(
                              Icons.search),
                          suffixIcon:
                          searchController
                              .text
                              .isNotEmpty
                              ? IconButton(
                            icon: const Icon(
                                Icons
                                    .clear),
                            onPressed: () {
                              searchController
                                  .clear();
                              setState(() =>
                              searchQuery =
                              "");
                            },
                          )
                              : null,
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                12),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                12),
                            borderSide:
                            BorderSide(
                                color:
                                primary),
                          ),
                          contentPadding:
                          const EdgeInsets
                              .symmetric(
                              vertical:
                              6,
                              horizontal:
                              8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery =
                                value;
                          });
                        },
                      ),
                    ),
      
                  /// 📋 List
                  Expanded(
                    child: viewModel.loading
                        ? const Center(
                        child:
                        GifLoader())
                        : filteredVouchers
                        .isEmpty
                        ? const NoDataIcon(
                        size: 70)
                        : ListView
                        .builder(
                      itemCount:
                      filteredVouchers
                          .length,
                      itemBuilder:
                          (context,
                          index) {
                        final voucher =
                        filteredVouchers[
                        index];
      
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
      
                              /// TOP ROW
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.green,
                                ),
                              ),
      
                              const SizedBox(width: 12),
      
                              /// Right Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
      
                                    /// Title + Date
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            voucher.creditLedgerName ?? "",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          voucher.vchDate ?? "",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        )
                                      ],
                                    ),
      
                                    const SizedBox(height: 4),
      
                                    /// Mode
                                    Text(
                                      "Mode: ${voucher.payMode ?? "-"}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
      
      
                                    /// Amount
                                    // Text(
                                    //   "₹ ${NumberFormat("#,##0.00").format(voucher.vchAmt ?? 0)}",
                                    //   style: const TextStyle(
                                    //     fontWeight: FontWeight.bold,
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
      
                                    /// EXPANSION SECTION
                                    const SizedBox(height: 10),
      
                                    /// Amount + View Details
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
      
                                        /// Amount
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "₹ ${NumberFormat("#,##0.00").format(voucher.vchAmt ?? 0)}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.green
                                              ),
                                            ),
                                          ],
                                        ),
      
                                        /// View Details Toggle
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              expandedIndex = expandedIndex == index ? null : index;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              const Text(
                                                "View Details",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Icon(
                                                expandedIndex == index
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: Colors.blue,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
      
                                    /// Expanded Details
                                    if (expandedIndex == index) ...[
                                      Divider(color: Colors.grey.shade300),
      
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _detailColumn(
                                            "Pay Type",
                                            voucher.payType ?? "-",
                                          ),
                                          _detailColumn(
                                            "Received By",
                                            voucher.debitLedgerName ?? "-",
                                          ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ),
      
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detailColumn(
      String title,
      String value) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 12,
              color:
              Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontWeight:
              FontWeight.w600),
        ),
      ],
    );
  }
}