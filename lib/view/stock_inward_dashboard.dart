import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/view/create_inward_stock.dart';
import 'package:flutter_soulconnect/view/sales_invoice_screen.dart';
import 'package:flutter_soulconnect/viewmodel/stock_vouchers_viewmodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../model/stock_inward_model.dart';
import '../res/widgets/gif_loader.dart';
import '../res/widgets/no_data.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';

class StockInwardDashboard extends StatefulWidget {
  const StockInwardDashboard({super.key});

  @override
  State<StockInwardDashboard> createState() => _StockInwardDashboardState();
}

class _StockInwardDashboardState extends State<StockInwardDashboard> {

  TextEditingController searchController = TextEditingController();

  List<StockInwardModel> filteredList = [];

  @override
  void initState() {
    super.initState();
    final stockVm = Provider.of<StockVouchersViewmodel>(context, listen: false);
    final itemVm = Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

    Future.microtask(() =>
        stockVm.fetchStockInwards());
    itemVm.getStockLocationsByUserApi();
  }

  /// SEARCH FILTER
  void filterSearch(String query, List<StockInwardModel> originalList) {

    final lower = query.toLowerCase();

    setState(() {
      filteredList = originalList.where((item) {
        return (item.inwardDate ?? "").toLowerCase().contains(lower) ||
            (item.inwardId.toString()).contains(lower);
      }).toList();
    });
  }

  /// TOTAL QTY
  double getTotalQty(StockInwardModel item) {

    double total = 0;

    if (item.details != null) {
      for (var d in item.details!) {
        total += d.issueQuantity ?? 0;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {

    final vm = Provider.of<StockVouchersViewmodel>(context);

    final inwardList = vm.stockInwards;
    final isLoading = vm.loading;

    if (filteredList.isEmpty &&
        inwardList.isNotEmpty &&
        searchController.text.isEmpty) {
      filteredList = inwardList;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stock Inward",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primary,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateInwardStock(),
                  settings: RouteSettings(

                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                Strings.inwardStock,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by date / issue id",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                filterSearch(value, inwardList);
              },
            ),
          ),

          /// BODY
          isLoading
              ? const Expanded(child: Center(child: GifLoader()))
              : filteredList.isEmpty
              ? const Expanded(child: Center(child: NoDataIcon()))
              : Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {

                final item = filteredList[index];

                final totalQty = getTotalQty(item);

                return _buildCard(item, totalQty);
              },
            ),
          )
        ],
      ),
    );
  }

  /// CARD UI
  Widget _buildCard(StockInwardModel item, double totalQty) {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// DATE + ACTIONS
            Row(
              children: [

                Text(
                  item.inwardDate?.substring(0, 10) ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),

                const Spacer(),

                /// EDIT
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                ),

                const SizedBox(width: 10),

                /// DELETE
                InkWell(
                  onTap: () {

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Stock Inward"),
                        content: const Text("Are you sure you want to delete this record?"),
                        actions: [

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),

                          TextButton(
                            onPressed: () async {

                              Navigator.pop(context);

                              final vm =
                              Provider.of<StockVouchersViewmodel>(context, listen: false);

                              String message = await vm.deleteStockInward(item.inwardId??0);

                              Fluttertoast.showToast(
                                msg: message,
                                backgroundColor: Colors.black87,
                                textColor: Colors.white,
                                gravity: ToastGravity.BOTTOM,
                              );

                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            /// ISSUE ID
            Row(
              children: [
                const Icon(Icons.confirmation_number,
                    size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                const Text(
                  "Issue ID : ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(item.issueId.toString()),
              ],
            ),

            const SizedBox(height: 6),

            /// TOTAL QTY
            Row(
              children: [
                const Icon(Icons.inventory_2,
                    size: 18, color: Colors.green),
                const SizedBox(width: 6),
                const Text(
                  "Total Qty : ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(totalQty.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}