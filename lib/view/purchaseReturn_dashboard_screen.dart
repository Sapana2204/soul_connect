import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/view/purchase_inward_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../res/widgets/gif_loader.dart';
import '../res/widgets/no_data.dart';
import '../utils/app_colors.dart';
import '../viewmodel/purchaseReturn_viewmodel.dart';

class PurchaseReturnDashboard extends StatefulWidget {
  const PurchaseReturnDashboard({super.key});

  @override
  State<PurchaseReturnDashboard> createState() =>
      _PurchaseReturnDashboardState();
}

class _PurchaseReturnDashboardState extends State<PurchaseReturnDashboard> {
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPurchaseReturns();
    });
  }

  /// Fetch API
  Future<void> _fetchPurchaseReturns() async {
    final returnVM =
    Provider.of<PurchaseReturnViewmodel>(context, listen: false);

    final String fromDate = startDate != null
        ? DateFormat('yyyy-MM-dd').format(startDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    final String toDate = endDate != null
        ? DateFormat('yyyy-MM-dd').format(endDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    await returnVM.getPurchaseReturnApi(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// Date popup
  void _showDatePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Date / Range"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(startDate == null
                    ? "Pick Start Date"
                    : "${startDate!.day}-${startDate!.month}-${startDate!.year}"),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: Text(endDate == null
                    ? "Pick End Date (Optional)"
                    : "${endDate!.day}-${endDate!.month}-${endDate!.year}"),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Clear", style: TextStyle(color: primary)),
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                });
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              child: const Text(
                "Apply",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
                _fetchPurchaseReturns();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final returnVM = Provider.of<PurchaseReturnViewmodel>(context);

    String? dateText;
    if (startDate != null && endDate != null) {
      dateText =
      "${startDate!.day}-${startDate!.month}-${startDate!.year} → ${endDate!.day}-${endDate!.month}-${endDate!.year}";
    } else if (startDate != null && endDate == null) {
      dateText = "${startDate!.day}-${startDate!.month}-${startDate!.year}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Purchase Return Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(color: primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: _showDatePopup,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔍 Search bar
              if (returnVM.purchaseReturnList.isNotEmpty)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by supplier or Return ID...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          returnVM.filterPurchaseReturns("");
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                    ),
                    onChanged: (value) {
                      returnVM.filterPurchaseReturns(value);
                    },
                  ),
                ),

              /// 📅 Selected Date
              if (dateText != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dateText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),

              /// ✅ Loader + NoData + List
              Expanded(
                child: returnVM.loading
                    ? const Center(child: GifLoader())
                    : returnVM.purchaseReturnList.isEmpty
                    ? const NoDataIcon(size: 70)
                    : ListView.builder(
                  itemCount: returnVM.purchaseReturnList.length,
                  itemBuilder: (context, index) {
                    final r = returnVM.purchaseReturnList[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xfff8f9ff), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// HEADER (Return No + Date)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Return #${r.returnId ?? ''}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  r.returnDate != null
                                      ? DateFormat('dd MMM yyyy')
                                      .format(DateTime.parse(r.returnDate!))
                                      : '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// SUPPLIER
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// SUPPLIER (LEFT)
                                Expanded(
                                  child: Text(
                                    r.supplierName ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// LOCATION (RIGHT)
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      r.locationName ?? "Location 2",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Divider(color: Colors.grey.shade300),

                            /// QTY + NET AMOUNT ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                /// QTY
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Total Qty",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${r.totalQty ?? 0}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                /// NET AMOUNT
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Net Amount",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "₹ ${r.netAmt ?? 0}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),


                            /// OPTIONAL EXPANSION (Keep your existing)
                            Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                childrenPadding: EdgeInsets.zero,
                                title: const Text(
                                  "View Amount Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                iconColor: primary,
                                collapsedIconColor: Colors.grey,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _amountColumn("Sub Total", r.subTotal),
                                      _amountColumn("Tax", r.totalTaxAmt),
                                      _amountColumn("Discount", r.discAmt),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ],
                        )
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      /// ➕ Add Purchase Return
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Return",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PurchaseInwardScreen(
                isReturn: true,   // 👈 this tells screen it is RETURN
              ),
            ),
          );

          if (added == true) {
            _fetchPurchaseReturns();
          }
        },
      ),
    );
  }

  Widget _amountColumn(String title, dynamic amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "₹ ${amount ?? 0}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
