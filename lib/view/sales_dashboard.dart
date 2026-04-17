import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/sales_dashboard_model.dart';
import '../res/widgets/gif_loader.dart';
import '../res/widgets/no_data.dart';
import '../utils/app_colors.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewmodel/sales_dashboard_viewmodel.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  _SalesDashboardScreenState createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboard> {
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController searchController = TextEditingController();
  List<SalesDashboardModel> filteredList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTodaySales();
    });
  }

  Future<void> _onRefresh() async {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final salesVM = Provider.of<SalesDashboardViewModel>(context, listen: false);

    final userId = int.tryParse(loginVM.userId ?? '0') ?? 0;
    if (userId == 0) return;

    // ✅ Clear search state
    searchController.clear();
    filteredList.clear();

    String fromDate;
    String toDate;

    // ✅ If date range is already selected, refresh with it
    if (startDate != null) {
      fromDate =
      "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}";

      final effectiveEndDate = endDate ?? DateTime.now();
      toDate =
      "${effectiveEndDate.year}-${effectiveEndDate.month.toString().padLeft(2, '0')}-${effectiveEndDate.day.toString().padLeft(2, '0')}";
    } else {
      // ✅ Default: refresh today's sales
      final today = DateTime.now();
      fromDate =
      "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      toDate = fromDate;
    }

    // ✅ Call API
    await salesVM.fetchSalesByFilter(
      fromDate: fromDate,
      toDate: toDate,
      userId: userId,
    );
  }
  void _fetchTodaySales() {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userIdString = loginVM.userId;
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    if (userId == 0) {
      return;
    }
    final salesVM = Provider.of<SalesDashboardViewModel>(context, listen: false);
    salesVM.fetchSalesByFilter(
      fromDate: formattedDate,
      toDate: formattedDate,
      userId: userId,
    );
  }

  void _filterSearchResults(String query, List<SalesDashboardModel> fullList) {
    if (query.isEmpty) {
      setState(() => filteredList = []);
      return;
    }

    setState(() {
      filteredList = fullList.where((sale) {
        final lowerQuery = query.toLowerCase();
        return (sale.salesBillNo?.toLowerCase().contains(lowerQuery) ?? false) ||
            (sale.customerName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (sale.salesDate?.toLowerCase().contains(lowerQuery) ?? false) ||
            (sale.subTotal?.toString().contains(lowerQuery) ?? false) ||
            (sale.netAmt?.toString().contains(lowerQuery) ?? false);
      }).toList();
    });
  }

  void _showDatePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Date / Range"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.blue),
                    title: Text(
                      startDate == null
                          ? "Pick Start Date"
                          : "Start: ${startDate!.day}-${startDate!.month}-${startDate!.year}",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setStateDialog(() => startDate = picked);
                        setState(() => startDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: primary),
                    title: Text(
                      endDate == null
                          ? "Pick End Date (Optional)"
                          : "End: ${endDate!.day}-${endDate!.month}-${endDate!.year}",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? (startDate ?? DateTime.now()),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setStateDialog(() => endDate = picked);
                        setState(() => endDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Clear"),
                  onPressed: () {
                    setStateDialog(() {
                      startDate = null;
                      endDate = null;
                    });
                    setState(() {
                      startDate = null;
                      endDate = null;
                    });
                    Navigator.pop(context);
                    _fetchTodaySales();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  child: const Text("Apply"),
                  onPressed: () {
                    Navigator.pop(context);
                    if (startDate != null) {
                      final from =
                          "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}";
                      final effectiveEndDate = endDate ?? DateTime.now();
                      final to =
                          "${effectiveEndDate.year}-${effectiveEndDate.month.toString().padLeft(2, '0')}-${effectiveEndDate.day.toString().padLeft(2, '0')}";

                      final loginVM = Provider.of<LoginViewModel>(context, listen: false);
                      final userId = int.tryParse(loginVM.userId ?? '0') ?? 0;

                      final salesVM = Provider.of<SalesDashboardViewModel>(context, listen: false);
                      salesVM.fetchSalesByFilter(fromDate: from, toDate: to, userId: userId);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesDashboardViewModel>(
      builder: (context, salesVM, _) {
        final salesList = salesVM.salesList;

        // Logic: If search is empty, show original list. Else show filtered.
        final listToShow = (searchController.text.isEmpty)
            ? salesList
            : filteredList;

        return RefreshIndicator(
          onRefresh: _onRefresh,
          displacement: 40,
          color: primary,

          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // 🔹 Change: Search Bar visibility logic
                  // Visible only if the actual source list (salesList) has data
                  // if (salesList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search by Customer name & bill no",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              _filterSearchResults("", salesList);
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primary)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                        ),
                        onChanged: (value) {
                          _filterSearchResults(value, salesList);
                        },
                      ),
                    ),
                  Expanded(
                    child: salesVM.loading && salesVM.salesList.isEmpty
                        ? const Center(child: GifLoader())
                        : listToShow.isEmpty
                        ? const NoDataIcon(size: 70)
                        : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: listToShow.length,
                      itemBuilder: (context, index) {
                        final sale = listToShow[index];
                        return _buildSaleCard(sale, salesVM);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Extracted Card for cleaner code
  Widget _buildSaleCard(SalesDashboardModel sale, SalesDashboardViewModel salesVM) {
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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "# ${sale.salesBillNo ?? ''}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.salesDate?.split('T').first ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Customer Name
            Text(
              sale.customerName ?? '',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            /// Amount Details
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // remove default divider
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: const
                Text(
                  "View Amount Details",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                iconColor: primary,
                collapsedIconColor: Colors.grey,
                children: [

                  /// Amount Details (Same alignment as before)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _amountColumn("Sub Total", sale.subTotal),
                      _amountColumn("Tax", sale.totalTaxAmt),
                      _amountColumn("Discount", sale.discAmt),
                    ],
                  ),

                ],
              ),
            ),
            Divider(color: Colors.grey.shade300),


            /// Net Amount Highlight
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Net Amount",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹ ${sale.netAmt ?? 0}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _confirmDelete(SalesDashboardModel sale, SalesDashboardViewModel salesVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${sale.customerName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              final success = await salesVM.deleteSaleApi(sale.salesID ?? 0);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "Deleted successfully." : "Failed to delete."),
                    backgroundColor: success ? primary : Colors.red,
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}