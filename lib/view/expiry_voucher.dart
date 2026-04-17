import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/get_expiry_model.dart';
import 'package:flutter_soulconnect/model/issue_vch_request_model.dart';
import 'package:flutter_soulconnect/viewmodel/stock_vouchers_viewmodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/expiring_item_model.dart';
import '../model/item_sales_details_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import '../viewModel/login_viewmodel.dart';

class ExpiryVoucher extends StatefulWidget {
  final ExpiryModel? voucher;

  const ExpiryVoucher({super.key, this.voucher});

  @override
  State<ExpiryVoucher> createState() => _ExpiryVoucherState();
}

class _ExpiryVoucherState extends State<ExpiryVoucher> {

  final TextEditingController dateController =
  TextEditingController();

  final TextEditingController qtyController = TextEditingController();
  final TextEditingController searchController = TextEditingController();


  String? fromLocation;
  int? fromLocationId;
  String? toLocation;
  int? toLocationId;
  int? editingIndex;

  String? product;
  String? batch;
  int? selectedIndex;
  String? selectedProduct;
  bool isLoadingStock = false;
  List<ItemSalesDetailsModel> filteredStock = [];
  int? taxGroupId;
  int? selectedBatchIndex;
  List<ExpiringItemModel> expiredItems = [];
  bool loadingExpired = false;

  List<Map<String, dynamic>> products = [];

  InputDecoration inputStyle(label, icon) {
    return InputDecoration(
      labelText: label,
      // prefixIcon: Icon(icon, color: primary),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String getFormattedDate() {
    final inputFormat = DateFormat("dd-MM-yyyy");
    final outputFormat = DateFormat("yyyy-MM-dd");

    DateTime date = inputFormat.parse(dateController.text);
    return outputFormat.format(date);
  }

  Future<void> fetchExpiredItems() async {

    setState(() {
      loadingExpired = true;
    });

    final vm =
    Provider.of<StockVouchersViewmodel>(context, listen: false);

    final formattedDate = getFormattedDate();

    final data = await vm.loadExpiringItems(
      formattedDate,
    );

    setState(() {
      expiredItems = vm.expiringItems;
      loadingExpired = false;
    });
  }

  Widget buildCard(child) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Future<void> createExpiryVoucher() async {
    final stockVm =
    Provider.of<StockVouchersViewmodel>(context, listen: false);

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = int.tryParse(loginVM.userId ?? "0") ?? 0;

    final now = DateTime.now().toIso8601String();

    /// 🔷 Convert products → ExpiryDetailsModel
    List<ExpiryDetailsModel> details = [];

    for (var item in products) {
      details.add(
        ExpiryDetailsModel(
          expiryId: 0,
          barcode: item["barCode"] ?? "",
          itemId: item["itemId"],
          unitId: item["unitId"],
          quantity: (item["qty"] ?? 0).toDouble(),
          batchNo: item["batch"],
          mfgDate: item["mfgDate"],
          expDate: item["expDate"],
          mrp: (item["mrp"] ?? 0).toDouble(),
          purchaseRate: (item["purchaseRate"] ?? 0).toDouble(),
          purchaseRateWithTax:
          (item["purchaseRateWithTax"] ?? 0).toDouble(),
          salesRate: (item["cashSalesRate"] ?? 0).toDouble(),
          salesRate1: (item["creditSalesRate"] ?? 0).toDouble(),
          salesRate2: (item["outletSalesRate"] ?? 0).toDouble(),
          purchaseId: item["purchaseId"],
          firmId: 0,
          locationId: fromLocationId,
        ),
      );
    }

    /// 🔷 Create main model
    ExpiryModel request = ExpiryModel(
      expiryId: 0,
      expiryDate: now,
      locationId: fromLocationId,
      createdby: userId,
      createdOn: now,
      updatedBy: userId,
      updatedOn: now,
      isCancelled: false,
      firmId: 0,
      details: details,
    );

    /// 🔥 PRINT JSON
    print("========== EXPIRY REQUEST ==========");
    print(request.toJson());
    print("====================================");

    /// 🔷 CALL API
    bool success = await stockVm.addExpiryApi(request);

    if (success) {
      Fluttertoast.showToast(msg: "Expiry Added Successfully");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: "Failed to add expiry",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> updateExpiryVoucher() async {
    final stockVm =
    Provider.of<StockVouchersViewmodel>(context, listen: false);

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = int.tryParse(loginVM.userId ?? "0") ?? 0;

    final now = DateTime.now().toIso8601String();

    List<ExpiryDetailsModel> details = [];

    for (var item in products) {
      details.add(
        ExpiryDetailsModel(
          expiryId: widget.voucher?.expiryId ?? 0,
          barcode: item["barCode"] ?? "",
          itemId: item["itemId"],
          unitId: item["unitId"],
          quantity: (item["qty"] ?? 0).toDouble(),
          batchNo: item["batch"],
          mfgDate: item["mfgDate"],
          expDate: item["expDate"],
          mrp: (item["mrp"] ?? 0).toDouble(),
          purchaseRate: (item["purchaseRate"] ?? 0).toDouble(),
          purchaseRateWithTax:
          (item["purchaseRateWithTax"] ?? 0).toDouble(),
          salesRate: (item["cashSalesRate"] ?? 0).toDouble(),
          salesRate1: (item["creditSalesRate"] ?? 0).toDouble(),
          salesRate2: (item["outletSalesRate"] ?? 0).toDouble(),
          purchaseId: item["purchaseId"],
          firmId: 0,
          locationId: fromLocationId,
        ),
      );
    }

    ExpiryModel request = ExpiryModel(
      expiryId: widget.voucher?.expiryId ?? 0,
      expiryDate: getFormattedDate(),
      locationId: fromLocationId,
      createdby: userId,
      createdOn: now,
      updatedBy: userId,
      updatedOn: now,
      isCancelled: false,
      firmId: 0,
      details: details,
    );

    bool success = await stockVm.updateExpiryApi(request); // 🔥 create this API

    if (success) {
      Fluttertoast.showToast(msg: "Expiry Updated Successfully");
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: "Failed to update expiry",
        backgroundColor: Colors.red,
      );
    }
  }
  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();

    dateController.text =
    "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}";

    /// Always load expired items
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   fetchExpiredItems();
    // });

    /// EDIT MODE
    if (widget.voucher != null) {

      final v = widget.voucher!;

      dateController.text =
          DateFormat("dd-MM-yyyy").format(DateTime.parse(v.expiryDate??""));

      fromLocation = v.locationId.toString();

      // fromLocation = v.issueFromLocation;
      // toLocation = v.issueToLocation;

      WidgetsBinding.instance.addPostFrameCallback((_) async {

        final itemVm =
        Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

        final fromLoc = itemVm.stockLocationsByUserList.firstWhere(
              (e) => e.locationName == fromLocation,
          orElse: () => itemVm.stockLocationsByUserList.first,
        );

        final toLoc = itemVm.stkLocationsList.firstWhere(
              (e) => e.locationName == toLocation,
          orElse: () => itemVm.stkLocationsList.first,
        );

        setState(() {
          fromLocationId = fromLoc.locationId;
          toLocationId = toLoc.locationId;
        });

        // fromLocationId = loc.locationId;

        /// Call API automatically
        String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        itemVm.getItemsByProuctTypeApi(
          todayDate,
          {"locationId": fromLocationId.toString()},
        );

        /// 🔥 CALL EXPIRED ITEMS API
        await fetchExpiredItems();
        setState(() {});
      });
      /// Prefill products
      if (v.details != null) {
        for (var d in v.details!) {
          products.add({
            "product": d.itemName,
            "itemId": d.itemId,
            "unitId": d.unitId,
            "qty": d.quantity,
            "batch": d.batchNo,
            "mfgDate": d.mfgDate,
            "expDate": d.expDate,
            "purchaseRate": d.purchaseRate,
            "purchaseRateWithTax": d.purchaseRateWithTax,
            "cashSalesRate": d.salesRate,
            "outletSalesRate": d.salesRate2,
            "creditSalesRate": d.salesRate1,
            "mrp": d.mrp,
            "purchaseId": d.purchaseId,
          });
        }
      }
    }

    /// Clear products initially
    Provider.of<ItemsByProductTypeViewmodel>(
      context,
      listen: false,
    ).clearProductData();
  }
  @override
  Widget build(BuildContext context) {
    final itemVm = Provider.of<ItemsByProductTypeViewmodel>(context);
    final locationsByUser = itemVm.stockLocationsByUserList;
    final locations = itemVm.stkLocationsList;

    final List<dynamic> productList = itemVm.itemList;

    /// Filter locations for "To Location"
    final filteredToLocations = locations
        .where((loc) => loc.locationName != fromLocation)
        .toList();

    return WillPopScope(
      onWillPop: () async {
        final salesVM =
        Provider.of<ItemsByProductTypeViewmodel>(context, listen: false)
            .clearProductData();
        return true; // allow navigation
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff5f6fa),

        /// APPBAR
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(.8)],
              ),
            ),
          ),
          title: Text(
            widget.voucher==null ? "Create Expiry Voucher": "Edit Expiry Voucher",

            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      dateController.text =
                      "${pickedDate.day.toString().padLeft(2, '0')}-"
                          "${pickedDate.month.toString().padLeft(2, '0')}-"
                          "${pickedDate.year}";
                    });
                  }
                },
                child: Center(
                  child: Text(
                    dateController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        body: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              /// LOCATION CARD
              buildCard(
                Row(
                  children: [
                    Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const Text("From Location *"),

                            value: fromLocation,

                            items: locationsByUser.map((loc) {
                              return DropdownMenuItem<String>(
                                value: loc.locationName,
                                child: Text(loc.locationName ?? ""),
                              );
                            }).toList(),

                            onChanged: (value) async {
                              final selectedLoc =
                              locationsByUser.firstWhere((loc) => loc.locationName == value);

                              setState(() {
                                fromLocation = selectedLoc.locationName;
                                fromLocationId = selectedLoc.locationId;
                              });

                              String todayDate =
                              DateFormat('yyyy-MM-dd').format(DateTime.now());

                              Provider.of<ItemsByProductTypeViewmodel>(
                                context,
                                listen: false,
                              ).getItemsByProuctTypeApi(todayDate, {"locationId": fromLocationId ?.toString() ?? ""});

                              await fetchExpiredItems();
                            },

                            buttonStyleData: ButtonStyleData(
                              height: 55,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                            ),

                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 300,
                              offset: const Offset(0, 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              elevation: 6,
                            ),

                            menuItemStyleData: const MenuItemStyleData(
                              height: 45,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        )
                    ),
                  ],
                ),
              ),


              /// ADD PRODUCT CARD
              buildCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_box, color: primary),
                        SizedBox(width: 6),
                        Text(
                          "Add Products",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 🔷 PRODUCT DROPDOWN
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: itemVm.loading
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonHideUnderline(
                            child: DropdownButton2<int>(
                              isExpanded: true,
                              hint: const Text("Select Product"),
                              value: selectedIndex,
                              items: List.generate(productList.length, (index) {
                                final item = productList[index];

                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(item.itemName ?? ""),
                                );
                              }),
                              onChanged: (index) async {
                                if (index == null) return;

                                final selectedItem = productList[index];

                                setState(() {
                                  selectedIndex = index;
                                  product = selectedItem.itemName;
                                  filteredStock = [];
                                  isLoadingStock = true;
                                });

                                {
                                  final todayString = DateFormat('MM-dd-yyyy')
                                      .format(DateTime.now());

                                  final stockList =
                                  await itemVm.getItemSalesDetailsApi(
                                    selectedItem.itemId ?? 0,
                                    todayString,
                                    fromLocationId ?.toString() ?? "",
                                  );

                                  setState(() {
                                    filteredStock = stockList;
                                    taxGroupId = selectedItem.taxGroupId;
                                    isLoadingStock = false;
                                  });
                                }
                              },

                              dropdownSearchData: DropdownSearchData(
                                  searchController: searchController,
                                  searchInnerWidgetHeight: 50,
                                  searchInnerWidget: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Search product...',
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black)
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchMatchFn: (item, searchValue) {
                                    final product = productList[item.value as int];
                                    return product.itemName!
                                        .toLowerCase()
                                        .contains(searchValue.toLowerCase());
                                  }
                              ),

                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                              ),

                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 400,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration:
                            inputStyle("Qty", Icons.numbers),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        Expanded(
                          flex: 2,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<int>(
                              isExpanded: true,
                              hint: const Text("Select Batch"),

                              value: selectedBatchIndex,

                              items: List.generate(filteredStock.length, (index) {
                                final stock = filteredStock[index];

                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Row(
                                    children: [
                                      Text(stock.batchNo ?? ""),
                                      Spacer(),
                                      Text("Qty:${stock.stockQuantity.toString() ?? ""})"),
                                    ],
                                  ),
                                );
                              }),
                              /// SELECTED FIELD (SHOW ONLY BATCH)
                              selectedItemBuilder: (context) {
                                return List.generate(filteredStock.length, (index) {
                                  final stock = filteredStock[index];
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(stock.batchNo ?? ""),
                                  );
                                });
                              },
                              onChanged: (index) {
                                if (index == null) return;

                                final stock = filteredStock[index];

                                setState(() {
                                  selectedBatchIndex = index;
                                  batch = stock.batchNo;
                                });
                              },

                              buttonStyleData: ButtonStyleData(
                                height: 55,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                              ),

                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 6,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: TextField(
                            enabled: false,
                            decoration: inputStyle("Expiry Date", Icons.date_range),
                            controller: TextEditingController(
                                text: selectedBatchIndex == null
                                    ? ""
                                    : filteredStock[selectedBatchIndex!].expDate ?? ""),
                          ),
                        ),

                        const SizedBox(width: 5),

                        /// ADD BUTTON
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              elevation: 3,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Icon(Icons.add, color: Colors.white,),
                            onPressed: () {

                              if (selectedBatchIndex == null) {
                                Fluttertoast.showToast(msg: "Please select batch");
                                return;
                              }

                              if (product == null || batch == null || qtyController.text.isEmpty) {
                                Fluttertoast.showToast(msg: "Please fill all fields");
                                return;
                              }

                              final enteredQty = double.tryParse(qtyController.text) ?? 0;
                              final stock = filteredStock[selectedBatchIndex!];
                              final availableQty = stock.stockQuantity ?? 0;

                              /// Quantity greater than stock
                              if (enteredQty > availableQty) {
                                Fluttertoast.showToast(
                                  msg:
                                  "Only $availableQty available in stock for batch \"$batch\" of \"$product\"",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                                return;
                              }

                              final selectedItem = productList[selectedIndex!];

                              Map<String, dynamic> newItem = {
                                "product": product,
                                "itemId": selectedItem.itemId,
                                "unitId": stock.unitId,
                                "qty": enteredQty,
                                "batch": stock.batchNo,
                                "mfgDate": stock.mfgDate,
                                "expDate": stock.expDate,
                                "purchaseRate": stock.purchaseRate,
                                "purchaseRateWithTax": stock.purchaseTaxRate,
                                "cashSalesRate": stock.cashSalesRate,
                                "outletSalesRate": stock.outletSalesRate,
                                "creditSalesRate": stock.creditSalesRate,
                                "mrp": stock.mRP,
                                "purchaseId": stock.purchaseId,
                              };

                              if (editingIndex != null) {
                                /// UPDATE EXISTING ITEM
                                products[editingIndex!] = newItem;
                                editingIndex = null;
                              } else {
                                /// ADD NEW ITEM
                                products.add(newItem);
                              }

                              setState(() {
                                /// Clear fields after adding
                                setState(() {
                                  selectedIndex = null;
                                  selectedBatchIndex = null;
                                  product = null;
                                  batch = null;
                                  filteredStock = [];
                                });
                              });

                              qtyController.clear();

                            }
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: loadingExpired
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                  children: [

                    /// EXPIRED ITEMS
                    // if (expiredItems.isEmpty)
                    //   const Center(child: Padding(
                    //     padding: EdgeInsets.all(20),
                    //     child: Text("No Expired Items"),
                    //   )),

                    ...expiredItems.map((item) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.itemName ?? "",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text("Batch : ${item.batchNo}",
                                        style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Expiry : ${item.expDate == null
                                          ? ""
                                          : DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(item.expDate??""))}",
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  const Text("Qty", style: TextStyle(fontSize: 12)),
                                  Text(item.closing.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),

                              const SizedBox(width: 10),

                              // IconButton(
                              //   icon: const Icon(Icons.delete, color: Colors.red),
                              //   onPressed: () {
                              //     setState(() {
                              //       products.remove(item);
                              //     });
                              //   },
                              // )
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    /// ✏️ EDIT
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        editingIndex = products.indexWhere((p) =>
                                        p["itemId"] == item.itemId &&
                                            p["batch"] == item.batchNo);
                                        editingIndex = editingIndex;

                                        final productList =
                                            Provider.of<ItemsByProductTypeViewmodel>(context, listen: false)
                                                .itemList;

                                        /// find product index
                                        final prodIndex = productList.indexWhere(
                                              (p) => p.itemId == item.itemId,
                                        );

                                        if (prodIndex == -1) return;

                                        final selectedItem = productList[prodIndex];

                                        setState(() {
                                          selectedIndex = prodIndex;
                                          product = item.itemName;
                                          qtyController.text = item.closing.toString();
                                          isLoadingStock = true;
                                        });

                                        final todayString =
                                        DateFormat('MM-dd-yyyy').format(DateTime.now());

                                        final stockList =
                                        await Provider.of<ItemsByProductTypeViewmodel>(
                                          context,
                                          listen: false,
                                        ).getItemSalesDetailsApi(
                                          selectedItem.itemId ?? 0,
                                          todayString,
                                          fromLocationId?.toString() ?? "",
                                        );

                                        final batchIndex = stockList.indexWhere(
                                              (b) => b.batchNo == item.batchNo,
                                        );

                                        setState(() {
                                          filteredStock = stockList;
                                          selectedBatchIndex = batchIndex >= 0 ? batchIndex : null;
                                          batch = item.batchNo;
                                          isLoadingStock = false;
                                        });
                                      },
                                    ),

                                    /// 🗑 DELETE
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          products.remove(item);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),

                    /// SELECTED PRODUCTS
                    ...products.map((item) {
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["product"] ?? "",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text("Batch : ${item["batch"]}",
                                        style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    // Text("Expiry : ${item["expDate"] ?? ""}",
                                    //     style: const TextStyle(color: Colors.red)),
                                    Text(
                                      "Expiry : ${item["expDate"] == null
                                          ? ""
                                          : DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(item["expDate"]))}",
                                      style: const TextStyle(color: Colors.red),
                                    )
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  const Text("Qty", style: TextStyle(fontSize: 12)),
                                  Text(item["qty"]?.toString() ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),

                              const SizedBox(width: 10),

                              // IconButton(
                              //   icon: const Icon(Icons.delete, color: Colors.red),
                              //   onPressed: () {
                              //     setState(() {
                              //       products.remove(item);
                              //     });
                              //   },
                              // )

                              Row(
                                children: [
                                  /// ✏️ EDIT BUTTON
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {

                                      editingIndex = products.indexOf(item);

                                      final prodIndex = productList.indexWhere(
                                              (p) => p.itemId == item["itemId"]);

                                      final selectedItem = productList[prodIndex];

                                      setState(() {
                                        selectedIndex = prodIndex;
                                        product = item["product"];
                                        qtyController.text = item["qty"].toString();
                                        isLoadingStock = true;
                                      });

                                      final todayString =
                                      DateFormat('MM-dd-yyyy').format(DateTime.now());

                                      final stockList = await itemVm.getItemSalesDetailsApi(
                                        selectedItem.itemId ?? 0,
                                        todayString,
                                        fromLocationId?.toString() ?? "",
                                      );

                                      int batchIndex = stockList.indexWhere(
                                              (b) => b.batchNo == item["batch"]);

                                      setState(() {
                                        filteredStock = stockList;
                                        selectedBatchIndex = batchIndex;
                                        batch = item["batch"];
                                        isLoadingStock = false;
                                      });
                                    },
                                  ),

                                  /// ❌ DELETE BUTTON
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        products.remove(item);
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(Strings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (fromLocationId == null) {
                        Fluttertoast.showToast(msg: "Please select From Location");
                        return;
                      }

                      // if (toLocationId == null) {
                      //   Fluttertoast.showToast(msg: "Please select To Location");
                      //   return;
                      // }

                      if (products.isEmpty) {
                        Fluttertoast.showToast(msg: "Please add at least one product");
                        return;
                      }

                      if (widget.voucher == null) {
                        await createExpiryVoucher();
                      } else {
                        await updateExpiryVoucher();
                      }
                    },
                    child: Text(
                      widget.voucher == null ? Strings.save : "Update",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    dateController.dispose();
    qtyController.dispose();
    searchController.dispose();

    filteredStock.clear();
    products.clear();
    /// clear provider product list
    Provider.of<ItemsByProductTypeViewmodel>(context, listen: false)
        .clearProductData();

    super.dispose();
  }
}