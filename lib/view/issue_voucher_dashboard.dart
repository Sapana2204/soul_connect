import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/viewmodel/stock_vouchers_viewmodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../model/stock_issue_model.dart';
import '../res/widgets/gif_loader.dart';
import '../res/widgets/no_data.dart';
import '../utils/app_colors.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import 'create_issue_voucher.dart';

class IssueVoucherDashboard extends StatefulWidget {
  const IssueVoucherDashboard({super.key});

  @override
  _IssueVoucherDashboardState createState() => _IssueVoucherDashboardState();
}

class _IssueVoucherDashboardState extends State<IssueVoucherDashboard> {
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController searchController = TextEditingController();
  List<StockIssueModel> filteredList = [];

  @override
  void initState() {
    super.initState();

    final stockVm = Provider.of<StockVouchersViewmodel>(context, listen: false);
    final itemVm = Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

    Future.microtask(() {
      stockVm.fetchStockIssues();
      itemVm.getStockLocationsByUserApi();
      itemVm.getStkLocationsApi();
    });
  }

  void filterSearch(String query, List<StockIssueModel> originalList) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredList = originalList.where((item) {
        return (item.issueDate ?? "").toLowerCase().contains(lowerQuery) ||
            (item.issueFromLocation ?? "").toLowerCase().contains(lowerQuery) ||
            (item.issueToLocation ?? "").toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    // Replace with your actual IssueVoucher ViewModel
    final vm = Provider.of<StockVouchersViewmodel>(context);
    final isLoading = vm.loading;
    final voucherList = vm.stockIssues;

    if (searchController.text.isEmpty) {
      filteredList = voucherList;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Issue Voucher Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primary,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Issue Vch", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  CreateIssueVoucher()),
          );

          if (result == true) {
            Provider.of<StockVouchersViewmodel>(context, listen: false)
                .fetchStockIssues();
          }
        },
      ),
      body: SafeArea(
        child:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by Date, From, To...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (value) {
                  filterSearch(value, voucherList);
                },
              ),
            ),
            isLoading
                ? const Expanded(child: Center(child: GifLoader()))
                : filteredList.isEmpty
                ? Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const NoDataIcon(size: 70),
                    const SizedBox(height: 10),
                    Text(
                      searchController.text.isEmpty
                          ? "No Issue Vouchers Found"
                          : "No Search Results Found",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
                : Expanded(
              child: ListView.separated(
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return _buildVoucherRow(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherRow(StockIssueModel item){
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Date
            Row(
              children: [
                Text(
        item.issueDate?.substring(0,10) ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () async {

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateIssueVoucher(
                          voucher: item,
                        ),
                      ),
                    );

                    if (result == true) {
                      Provider.of<StockVouchersViewmodel>(context, listen: false)
                          .fetchStockIssues();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.edit_note, color: Colors.blue, size: 20),
                  ),
                ),

                const SizedBox(width: 10),

                /// Delete
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

                              String message = await vm.deleteStockIssue(item.issueId??0);

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
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            /// From Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                const Text(
                  "From : ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Expanded(child: Text(item.issueFromLocation?? '')),
              ],
            ),

            const SizedBox(height: 6),

            /// To Location
            Row(
              children: [
                const Icon(Icons.store, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                const Text(
                  "To : ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Expanded(child: Text(item.issueToLocation?? '')),
              ],
            ),


            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                /// Edit

              ],
            )
          ],
        ),
      ),
    );
  }
}