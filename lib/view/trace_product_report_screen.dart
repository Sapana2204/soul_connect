import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../model/item_sales_details_model.dart';

import '../model/purchaseReportDetails_model.dart';
import '../model/salesReportDetails_model.dart';
import '../res/widgets/app_urls.dart';
import '../utils/app_colors.dart';
import '../viewModel/item_master_viewmodel.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewmodel/stock_report_viewmodel.dart';


class TraceProductReportScreen extends StatefulWidget {
  const TraceProductReportScreen({super.key});

  @override
  State<TraceProductReportScreen> createState() =>
      _TraceProductReportScreenState();
}

class _TraceProductReportScreenState extends State<TraceProductReportScreen> {
  final BaseApiServices _apiServices = NetworkApiServices();

  int? selLocationId;
  int? selItemId;
// Add to your state class
  String stockItemName = "-";
  double stockQty = 0;
  double taxPercent = 0;


  int selectedTab = 0; // 0 = Purchase, 1 = Sales
  Future<List<ItemSalesDetailsModel>> _fetchItemSalesDetails(
      int itemId, String date, String locationId) async {
    try {
      final String url =
          "${AppUrls.getItemSalesDetailsUrl}/$itemId/$date?locationId=$locationId";
      print('Get Item Sales Details URL: $url');

      dynamic response = await _apiServices.getGetApiResponse(url);

      print('Get Item Sales Details Response: $response');

      List<ItemSalesDetailsModel> itemDetailsList =
      (response as List)
          .map((data) => ItemSalesDetailsModel.fromJson(data))
          .toList();

      return itemDetailsList;
    } catch (e) {
      print("Error fetching items sales details: $e");
      return [];
    }
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemVm = context.read<ItemViewmodel>();
      final itemMasterVm = context.read<ItemMasterViewmodel>();

      // Load dropdowns
      // await itemVm.getStockLocationsApi();
      // await itemMasterVm.itemMastersApi();

      // Default selection (first item)
      // if (itemVm.stockLocationsList.isNotEmpty) {
      //   selLocationId = itemVm.stockLocationsList.first.locationId;
      // }
      //
      // if (itemMasterVm.itemList.isNotEmpty) {
      //   selItemId = itemMasterVm.itemList.first.itemId;
      // }

      setState(() {}); // update dropdowns

      // Fetch initial stock & tax values
      final stockVm = context.read<StockViewModel>();
      await _fetchTrace(stockVm);
    });

  }

  // ============================================================
  // SEARCH
  // ============================================================
  void _onSearch() {
    if (selLocationId == null || selItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Location & Product")),
      );
      return;
    }


    setState(() {});
  }

  // ============================================================
  // CLEAR
  // ============================================================
  void _clearFilters() {
    setState(() {
      selLocationId = null;
      selItemId = null;
      selectedTab = 0;
      Provider.of<StockViewModel>(context, listen: false).clearReports();
    });

    // TODO: Clear your lists from ViewModel if needed
  }

  @override
  Widget build(BuildContext context) {
    final itemVm = Provider.of<ItemViewmodel>(context);
    final itemMasterVm = Provider.of<ItemMasterViewmodel>(context);
    final stockVm = context.watch<StockViewModel>();

    final purchaseList = stockVm.purchaseReportDetailsList;
    final salesList = stockVm.salesReportDetailsList;

    final list = selectedTab == 0 ? purchaseList : salesList;



    final int purchaseTotalQty = stockVm.purchaseReportDetailsList.fold<double>(
      0.0,
          (sum, e) => sum + (e.quantity ?? 0.0),
    ).toInt();

    final int salesTotalQty = stockVm.salesReportDetailsList.fold<double>(
      0.0,
          (sum, e) => sum + (e.quantity ?? 0.0),
    ).toInt();

    return WillPopScope(
      onWillPop: () async {
        final stockReportVM =
    Provider.of<StockViewModel>(context, listen: false);

    stockReportVM.clearReports(); // ✅ Clear when back pressed

    return true; // allow navigation
  },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trace Product"),
          actions: [
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off),
              tooltip: "Clear Filters",
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterPanel(itemVm, itemMasterVm),

            _buildStockCard(
              itemName: stockItemName,
              stkQty: stockQty.toInt(),
              taxPercent: taxPercent,
            ),


            _buildSwitchTabs(
              purchaseQty: purchaseTotalQty,
              salesQty: salesTotalQty,
            ),


            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text("No records found"))
                  : Expanded(
                child: list.isEmpty
                    ? const Center(child: Text("No records found"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    if (selectedTab == 0) {
                      return _purchaseHistoryCard(purchaseList[i]);
                    } else {
                      return _salesHistoryCard(salesList[i]);
                    }
                  },
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _purchaseHistoryCard(PurchaseReportDetailsModel e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Purchase ID: ${e.purchaseId ?? "-"}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 10,
            spacing: 12,
            children: [
              _miniField("Supplier", e.supplierName ?? "-"),
              _miniField("Date", (e.purchaseDate ?? "-").split("T").first),
              _miniField("Qty", (e.quantity ?? 0).toString()),
              _miniField("Rate", (e.rate ?? 0).toString()),
              _miniField("Tax", (e.totalTaxAmt ?? 0).toString()),
              _miniField("Net Amt", (e.netAmt ?? 0).toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _salesHistoryCard(SalesDetailsReportModel e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sales Bill No: ${e.salesBillNo ?? "-"}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 10,
            spacing: 12,
            children: [
              _miniField("Customer", e.customerName ?? "-"),
              _miniField("Date", (e.salesDate ?? "-").split("T").first),
              _miniField("Qty", (e.quantity ?? 0).toString()),
              _miniField("Rate", (e.rate ?? 0).toString()),
              _miniField("Tax", (e.totalTaxAmt ?? 0).toString()),
              _miniField("Net Amt", (e.netAmt ?? 0).toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(
      ItemViewmodel itemVm, ItemMasterViewmodel itemMasterVm) {
    final stockVm = context.read<StockViewModel>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        )
      ]),
      child: Row(
        children: [
          // LOCATION
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selLocationId,
              isExpanded: true,
              menuMaxHeight: 280,
              decoration: InputDecoration(
                labelText: "Select Location",
                isDense: true,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: itemVm.stockLocationsList.map((e) {
                return DropdownMenuItem<int>(
                  value: e.locationId,
                  child: Text(e.locationName ?? ""),
                );
              }).toList(),
              onChanged: (v) async {
                setState(() => selLocationId = v);
                await _fetchTrace(stockVm);
              },
            ),
          ),

          const SizedBox(width: 12),

          // PRODUCT ITEM
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selItemId,
              isExpanded: true,
              menuMaxHeight: 280,
              decoration: InputDecoration(
                labelText: "Product (Item)",
                isDense: true,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: itemMasterVm.itemList.map((e) {
                return DropdownMenuItem<int>(
                  value: e.itemId,
                  child: Text(
                    e.itemName ?? "",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) async {
                setState(() => selItemId = v);
                await _fetchTrace(stockVm);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTrace(StockViewModel stockVm) async {
    if (selLocationId != null && selItemId != null) {
      try {
        // STOCK + TAX CARD API
        List<ItemSalesDetailsModel> stockData = await _fetchItemSalesDetails(
          selItemId!,
          DateTime.now().toIso8601String().split("T")[0],
          selLocationId.toString(),
        );

        if (stockData.isNotEmpty) {
          final data = stockData.first;
          setState(() {
            stockItemName = data.itemName ?? "-";
            stockQty = data.stockQuantity ?? 0;
            taxPercent = data.taxPer ?? 0;
          });
        }
      } catch (e) {
        debugPrint("Error fetching stock data: $e");
      }

      // ✅ GET USER ID FROM LOGIN VIEWMODEL
      final loginVm = context.read<LoginViewModel>();
      final int userId = int.tryParse(loginVm.userId ?? "0") ?? 0;

      // ✅ CALL API BASED ON SELECTED TAB
      if (selectedTab == 0) {
        await stockVm.fetchPurchaseDetailsReport(
          userId: userId,
          locationId: selLocationId!,
          itemId: selItemId!,
        );
      } else {
        await stockVm.fetchSalesDetailsReport(
          userId: userId,
          locationId: selLocationId!,
          itemId: selItemId!,
        );
      }
    }
  }


  Widget _buildStockCard({
    required String itemName,
    required int stkQty,
    required double taxPercent,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AVAILABLE STOCK",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _stockField("Item Name", itemName)),
              Expanded(child: _stockField("STK Qty", stkQty.toString())),
              Expanded(
                  child: _stockField("Tax %", taxPercent.toStringAsFixed(0))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SWITCH TABS (Purchase / Sales)
  // ============================================================
  Widget _buildSwitchTabs({
    required int purchaseQty,
    required int salesQty,
  }) {
    final stockVm = context.read<StockViewModel>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() => selectedTab = 0);
                await _fetchTrace(stockVm); // ✅ call Purchase API
              },
              child: _tabButton(
                title: "Purchase History (Inward)",
                qty: purchaseQty,
                active: selectedTab == 0,
                badgeColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() => selectedTab = 1);
                await _fetchTrace(stockVm); // ✅ call Sales API
              },
              child: _tabButton(
                title: "Sales History (Outward)",
                qty: salesQty,
                active: selectedTab == 1,
                badgeColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _tabButton({
    required String title,
    required int qty,
    required bool active,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? primary : Colors.black12, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: active ? primary : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Total Qty: $qty",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD FOR HISTORY LIST
  // ============================================================
  Widget _historyCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bill No: ${data.billNo ?? "-"}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 10,
            spacing: 12,
            children: [
              _miniField("Party", "${data.partyName ?? "-"}"),
              _miniField("Date", "${data.billDate ?? "-"}"),
              _miniField("Qty", "${data.qty ?? 0}"),
              _miniField("Rate", "${data.rate ?? 0}"),
              _miniField("Amt", "${data.amount ?? 0}"),
              _miniField("Free", "${data.freeQty ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }


  Widget _miniField(String label, String value) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
