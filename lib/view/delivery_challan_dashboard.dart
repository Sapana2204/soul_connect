import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/delivery_challan_model.dart';
import '../res/widgets/gif_loader.dart';
import '../utils/app_colors.dart';
import '../view/delivery_challan_dashboard.dart';
import 'package:flutter_soulconnect/viewmodel/deliveryChallanDashboard_viewmodel.dart';
import 'delivery_challan.dart';


class DeliveryChallanDashboard extends StatefulWidget {
  const DeliveryChallanDashboard({super.key});


  @override
  State<DeliveryChallanDashboard> createState() =>
      _DeliveryChallanDashboardState();
}

class _DeliveryChallanDashboardState extends State<DeliveryChallanDashboard> {
  List<DeliveryChallanModel> challans = [
    DeliveryChallanModel(
      challanId: 1,
      customerId: 101, // <-- required
      locationId: 201, // <-- required
      challanNo: "DC-001",
      challanDate: DateTime.now().subtract(const Duration(days: 2)),
      totalQty: 25,
      customerName: "ABC Traders",
    ),

    DeliveryChallanModel(
      challanId: 2,
      customerId: 102, // <-- required
      locationId: 202, // <-- required
      challanNo: "DC-002",
      challanDate: DateTime.now().subtract(const Duration(days: 4)),
      totalQty: 40,
      customerName: "XYZ Enterprises",
    ),
  ];

  DateTime? startDate;
  DateTime? endDate;

  List<DeliveryChallanModel> filteredChallans = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<DeliveryChallanDashboardViewmodel>()
          .fetchDeliveryChallanDashboards();
    });
  }


  String _formatDate(DateTime date) => DateFormat('dd-MM-yyyy').format(date);



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
                    : _formatDate(startDate!)),
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
                    : _formatDate(endDate!)),
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
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                  filteredChallans = List.from(challans);
                });
                searchController.clear();

                setState(() {
                  filteredChallans = [];
                  startDate = null;
                  endDate = null;
                });

                context
                    .read<DeliveryChallanDashboardViewmodel>()
                    .fetchDeliveryChallanDashboards();              },
              child: Text("Clear", style: TextStyle(color: primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              onPressed: () {
                Navigator.pop(context);

                context
                    .read<DeliveryChallanDashboardViewmodel>()
                    .fetchDeliveryChallanDashboards(
                  fromDate: startDate,
                  toDate: endDate,
                );

              },

              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      DeliveryChallanDashboardViewmodel vm,
      int challanId,
      ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Delete Delivery Challan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete this delivery challan?\nThis action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await vm.deleteDeliveryChallan(challanId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Challan deleted successfully"
                : "Failed to delete challan",
          ),
        ),
      );
    }
  }

  void _filterSearchResults(String query) {
    final vmList =
        context.read<DeliveryChallanDashboardViewmodel>().dashboardList;

    if (query.isEmpty) {
      setState(() {
        filteredChallans = [];
      });
      return;
    }

    setState(() {
      filteredChallans = vmList.where((challan) {
        final challanNo = challan.challanNo.toLowerCase();
        final customerName = challan.customerName.toLowerCase();

        return challanNo.contains(query.toLowerCase()) ||
            customerName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DeliveryChallanDashboardViewmodel>();

    final challans = searchController.text.isEmpty
        ? vm.dashboardList
        : filteredChallans;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Delivery Challan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: _showDatePopup,
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by Challan No or Customer...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                    });

                    context
                        .read<DeliveryChallanDashboardViewmodel>()
                        .fetchDeliveryChallanDashboards();

                    Navigator.pop(context);
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
                const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              ),
              onChanged: _filterSearchResults,
            ),
          ),

          if (startDate != null)
            Align(
              alignment: Alignment.centerRight, // <-- Align container to the right
              child: Container(
                margin: const EdgeInsets.only(bottom: 8,right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  endDate != null
                      ? "${_formatDate(startDate!)} → ${_formatDate(endDate!)}"
                      : _formatDate(startDate!),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),


          // 🔹 List of Delivery Challans
          Expanded(
            child: vm.dashboardLoading
                ? const Center(child: GifLoader())
                : challans.isEmpty
                ? const Center(child: Text("No data available"))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: challans.length,
              itemBuilder: (context, index) {
                final challan = challans[index];

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

                        /// 🔹 Header Row (Challan No + Date)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "# ${challan.challanNo}",
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
                                challan.challanDate != null
                                    ? DateFormat('dd MMM yyyy')
                                    .format(challan.challanDate)
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

                        /// 🔹 Customer Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                challan.customerName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Qty: ${challan.totalQty}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),



                        /// 🔹 Bottom Action Row (Edit/Delete)
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     IconButton(
                        //       icon: const Icon(Icons.edit, color: Colors.blue),
                        //       onPressed: () async {
                        //         final result = await Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (_) => DeliveryChallan(
                        //               challanModel: challan,
                        //               isEdit: true,
                        //             ),
                        //           ),
                        //         );
                        //
                        //         if (result == true) {
                        //           context
                        //               .read<DeliveryChallanDashboardViewmodel>()
                        //               .fetchDeliveryChallanDashboards();
                        //         }
                        //       },
                        //     ),
                        //     IconButton(
                        //       icon: const Icon(Icons.delete, color: Colors.red),
                        //       onPressed: () {
                        //         final vm = context.read<DeliveryChallanDashboardViewmodel>();
                        //         _confirmDelete(context, vm, challan.challanId!);
                        //       },
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )

        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add DC",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
          onPressed: () async {
            final model = DeliveryChallanModel(
              challanId: 0,
              challanNo: "AUTO",
              challanDate: DateTime.now(),
              customerName: "",
              totalQty: 0,
              customerId: 0,
              locationId: 0,
            );

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeliveryChallan(
                  challanModel: model,
                ),
              ),
            );

            /// 🔥 IMPORTANT: Refresh after coming back
            if (result == true) {
              context
                  .read<DeliveryChallanDashboardViewmodel>()
                  .fetchDeliveryChallanDashboards();
            }
          }
      ),



    );
  }

  Widget _infoColumn(String title, dynamic value) {
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
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
