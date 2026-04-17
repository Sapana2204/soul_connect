import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/purchase_challan_dashboard_model.dart';
import 'package:flutter_soulconnect/view/purchase_challan_screen.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../res/widgets/gif_loader.dart';
import '../res/widgets/no_data.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewmodel/purchaseDashboard_viewmodel.dart';

class PurchaseChallanDashboard extends StatefulWidget {
  const PurchaseChallanDashboard({super.key});

  @override
  _PurchaseChallanDashboardState createState() =>
      _PurchaseChallanDashboardState();
}

class _PurchaseChallanDashboardState extends State<PurchaseChallanDashboard> {
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController searchController = TextEditingController();
  List<PurchaseChallanDashboardModel> filteredPurchases = [];

  @override
  void initState() {
    super.initState();
    _fetchPurchaseChallan(); // fetch default on load
  }

  /// Fetch API
  void _fetchPurchaseChallan() async {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final purchaseVM =
    Provider.of<PurchaseDashboardViewmodel>(context, listen: false);

    final userIdString = loginVM.userId;

    final String fromDate =
    DateFormat('yyyy-MM-dd').format(startDate ?? DateTime.now());

    final String toDate =
    DateFormat('yyyy-MM-dd').format(endDate ?? DateTime.now());

    await purchaseVM.fetchPurchaseChallans(
      fromDate: fromDate,
      toDate: toDate,
    );

    setState(() {
      filteredPurchases = List.from(purchaseVM.challanList);
    });
  }

  void _filterSearchResults(String query) {
    final purchaseVM =
    Provider.of<PurchaseDashboardViewmodel>(context, listen: false);

    if (query.isEmpty) {
      setState(() {
        filteredPurchases = purchaseVM.challanList;
      });
      return;
    }

    setState(() {
      filteredPurchases = purchaseVM.challanList.where((purchase) {
        final supplierName = purchase.supplierName?.toLowerCase() ?? '';
        final purchaseId = purchase.purchaseId?.toString() ?? '';
        return supplierName.contains(query.toLowerCase()) ||
            purchaseId.contains(query);
      }).toList();
    });
  }



  /// show popup
  void _showDatePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(Strings.selectDateRange),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(startDate == null
                    ? Strings.pickStartDate
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
                leading: Icon(Icons.calendar_today, color: primary),
                title: Text(endDate == null
                    ? Strings.pickEndDateOptional
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
               Strings.apply,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
                _fetchPurchaseChallan(); // 👈 call API with selected range
              },
            ),
          ],
        );
      },
    );
  }

  void fetchDashboardData() {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userIdString = loginVM.userId;
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    final String fromDate =
    DateFormat('yyyy-MM-dd').format(startDate ?? DateTime.now());

    final String toDate =
    DateFormat('yyyy-MM-dd').format(endDate ?? DateTime.now());

    Provider.of<PurchaseDashboardViewmodel>(context, listen: false)
        .fetchPurchaseChallans(fromDate: fromDate, toDate: toDate);
  }

  @override
  Widget build(BuildContext context) {
    final purchaseVM = Provider.of<PurchaseDashboardViewmodel>(context);

    final list = searchController.text.isEmpty
        ? purchaseVM.challanList
        : purchaseVM.challanList.where((purchase) {
      final supplierName = purchase.supplierName?.toLowerCase() ?? '';
      final purchaseId = purchase.purchaseId?.toString() ?? '';
      return supplierName.contains(searchController.text.toLowerCase()) ||
          purchaseId.contains(searchController.text);
    }).toList();

    String? dateText;
    if (startDate != null && endDate != null) {
      dateText =
      "${startDate!.day}-${startDate!.month}-${startDate!.year} → ${endDate!.day}-${endDate!.month}-${endDate!.year}";
    } else if (startDate != null && endDate == null) {
      dateText =
      "${startDate!.day}-${startDate!.month}-${startDate!.year}"; // single date
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.purchaseChallan,
              style: TextStyle(color: white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          Strings.newPurchaseChallan,
          style: TextStyle(color: Colors.white),
        ),
        // onPressed: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const SalesReturnScreen(), // your add screen
        //     ),
        //   );
        // },
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseChallanScreen(),
            ),
          );

          if (result == true) {
            // 🔥 Refresh dashboard data
            fetchDashboardData();
          }

        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // if (purchaseVM.purchaseDashboardList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: Strings.purchaseSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _filterSearchResults("");
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
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    ),
                    onChanged: (value) {
                      _filterSearchResults(value);
                    },
                  ),
                ),

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

              Expanded(
                child: purchaseVM.loading
                    ? const Center(child: GifLoader())
                    : list.isEmpty
                    ? const NoDataIcon(size: 70)
                    : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                  final purchase = list[index];


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
                                  "# ${purchase.supplierBillNo ?? ''}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    purchase.purchaseDate != null
                                        ? DateFormat('dd MMM yyyy')
                                        .format(DateTime.parse(purchase.purchaseDate??""))
                                        : '',
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

                            /// Supplier
                            Text(
                              purchase.supplierName ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),


                            Divider(color: Colors.grey.shade300),


                            /// Amount Details
                            Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent, // remove default divider
                              ),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                childrenPadding: EdgeInsets.zero,
                                title: const Text(
                                  Strings.viewAmountDetails,
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
                                      _amountColumn(Strings.subTotal, purchase.subTotal),
                                      _amountColumn(Strings.tax, purchase.totalTaxAmt),
                                      _amountColumn(Strings.discount, purchase.discAmt),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),

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
                                    Strings.netAmount,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "₹ ${purchase.netAmt ?? 0}",
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
                  },
                ),
              ),
            ],
          ),
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
}