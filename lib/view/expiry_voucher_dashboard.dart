import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/get_expiry_model.dart';
import 'package:flutter_soulconnect/view/expiry_voucher.dart';
import 'package:flutter_soulconnect/viewmodel/stock_vouchers_viewmodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../model/stock_issue_model.dart';
import '../res/widgets/gif_loader.dart';
import '../res/widgets/no_data.dart';
import '../utils/app_colors.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import 'create_issue_voucher.dart';

class ExpiryVoucherDashboard extends StatefulWidget {
  const ExpiryVoucherDashboard({super.key});

  @override
  _ExpiryVoucherDashboardState createState() => _ExpiryVoucherDashboardState();
}

class _ExpiryVoucherDashboardState extends State<ExpiryVoucherDashboard> {
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController searchController = TextEditingController();
  List<ExpiryModel> filteredList = [];

  @override
  void initState() {
    super.initState();

    final stockVm = Provider.of<StockVouchersViewmodel>(context, listen: false);
    final itemVm = Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

    Future.microtask(() {
      stockVm.fetchExpiryVch();
      itemVm.getStockLocationsByUserApi();
      itemVm.getStkLocationsApi();
    });
  }

  void filterSearch(String query, List<ExpiryModel> originalList) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredList = originalList.where((item) {
        return (item.expiryDate ?? "").toLowerCase().contains(lowerQuery) ||
            (item.locationId.toString() ?? "").toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    // Replace with your actual IssueVoucher ViewModel
    final vm = Provider.of<StockVouchersViewmodel>(context);
    final isLoading = vm.loading;
    final voucherList = vm.expiryVch;

    if (searchController.text.isEmpty) {
      filteredList = voucherList;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Expiry Voucher Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primary,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Expiry Vch", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  ExpiryVoucher()),
          );

          if (result == true) {
            Provider.of<StockVouchersViewmodel>(context, listen: false)
                .fetchExpiryVch();
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

  Widget _buildVoucherRow(ExpiryModel item) {

    if (item.details == null || item.details!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: item.details!.map((detail) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// DATE + ACTIONS
                Row(
                  children: [
                    Text(
                      item.expiryDate?.substring(0, 10) ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const Spacer(),

                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpiryVoucher(voucher: item),
                          ),
                        );

                        if (result == true) {
                          Provider.of<StockVouchersViewmodel>(context, listen: false)
                              .fetchExpiryVch();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.edit, color: Colors.blue, size: 18),
                      ),
                    ),

                    const SizedBox(width: 10),

                    InkWell(
                      onTap: () async {
                        final vm = Provider.of<StockVouchersViewmodel>(
                            context,
                            listen: false);

                        String message =
                        await vm.deleteExpiryVch(item.expiryId ?? 0);

                        Fluttertoast.showToast(
                          msg: message,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 18),

                /// LOCATION
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    const Text("Location : ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(item.locationId?.toString() ?? ''),
                  ],
                ),

                const SizedBox(height: 6),

                /// ITEM NAME
                Row(
                  children: [
                    const Icon(Icons.inventory_2, size: 18, color: Colors.green),
                    const SizedBox(width: 6),
                    const Text("Item : ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(child: Text(detail.itemName ?? '')),
                  ],
                ),

                const SizedBox(height: 6),

                /// BATCH
                Row(
                  children: [
                    const Icon(Icons.qr_code, size: 18, color: Colors.orange),
                    const SizedBox(width: 6),
                    const Text("Batch : ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(detail.batchNo ?? ''),
                  ],
                ),

                const SizedBox(height: 6),

                /// QUANTITY
                Row(
                  children: [
                    const Icon(Icons.scale, size: 18, color: Colors.purple),
                    const SizedBox(width: 6),
                    const Text("Qty : ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text("${detail.quantity ?? 0}"),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}