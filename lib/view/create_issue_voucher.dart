import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/issue_vch_request_model.dart';
import 'package:flutter_soulconnect/viewmodel/stock_vouchers_viewmodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/item_sales_details_model.dart';
import '../model/stock_issue_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import '../viewModel/login_viewmodel.dart';

class CreateIssueVoucher extends StatefulWidget {
  final StockIssueModel? voucher;

  const CreateIssueVoucher({super.key, this.voucher});

  @override
  State<CreateIssueVoucher> createState() => _CreateIssueVoucherState();
}

class _CreateIssueVoucherState extends State<CreateIssueVoucher> {

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

  String getFormattedDate() {
    final inputFormat = DateFormat("dd-MM-yyyy");
    final outputFormat = DateFormat("yyyy-MM-dd");

    DateTime date = inputFormat.parse(dateController.text);
    return outputFormat.format(date);
  }
  Future<void> createStockIssue() async {

    final vm =
    Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);
    final stockVchvm =
    Provider.of<StockVouchersViewmodel>(context, listen: false);
    List<StockIssueDetailsRequest> details = [];

    for (var item in products) {
      details.add(
        StockIssueDetailsRequest(
          itemId: item["itemId"],
          unitId: item["unitId"],
          quantity: item["qty"],
          rate: item["rate"],
          batchNo: item["batch"],
          mfgDate: item["mfgDate"],
          expDate: item["expDate"],
          barcode: item["barCode"],
          purchaseRate: item["purchaseRate"],
          purchaseRateWithTax: item["purchaseRateWithTax"],
          cashSalesRate: item["cashSalesRate"],
          outletSalesRate: item["outletSalesRate"],
          creditSalesRate: item["creditSalesRate"],
          mrp: item["mrp"],
          purchaseId: item["purchaseId"],
          fromLocationId: fromLocationId,
          toLocationId: toLocationId,
        ),
      );
    }

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userIdString = loginVM.userId;
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    IssueVchRequestModel request = IssueVchRequestModel(
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      userId: userId,
      issueDate: getFormattedDate(),
      stockIssueDetailsRequests: details,
    );

    /// 🔷 PRINT REQUEST JSON
    print("========== REQUEST BODY ==========");
    print(request.toJson());
    print("==================================");
    /// CALL API
    bool success = await stockVchvm.addIssueVchApi(request);

    if (success) {
      Fluttertoast.showToast(msg: "Stock Issue Created");
      /// 🔹 Refresh stock issue list
      await stockVchvm.fetchStockIssues();
      setState(() {
        products.clear();
      });

      Navigator.pop(context,true);
    } else {
      Fluttertoast.showToast(
        msg: "Failed to create Stock Issue",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> updateStockIssue() async {

    final stockVchvm =
    Provider.of<StockVouchersViewmodel>(context, listen: false);

    List<StockIssueDetailsRequest> details = [];

    for (var item in products) {
      details.add(
        StockIssueDetailsRequest(
          itemId: item["itemId"],
          unitId: item["unitId"],
          quantity: item["qty"],
          rate: item["rate"],
          batchNo: item["batch"],
          mfgDate: item["mfgDate"],
          expDate: item["expDate"],
          purchaseId: item["purchaseId"],
          fromLocationId: fromLocationId,
          toLocationId: toLocationId,
        ),
      );
    }

    IssueVchRequestModel request = IssueVchRequestModel(
      issueId: widget.voucher!.issueId??0,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      issueDate: getFormattedDate(),
      stockIssueDetailsRequests: details,
    );

    bool success = await stockVchvm.updateIssueVchApi(request);

    if (success) {
      Fluttertoast.showToast(msg: "Stock Issue Updated");
      Navigator.pop(context, true);
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

    /// EDIT MODE
    if (widget.voucher != null) {

      final v = widget.voucher!;

      dateController.text =
          DateFormat("dd-MM-yyyy").format(DateTime.parse(v.issueDate!));

      fromLocation = v.issueFromLocation;
      toLocation = v.issueToLocation;

      fromLocation = v.issueFromLocation;
      toLocation = v.issueToLocation;

      WidgetsBinding.instance.addPostFrameCallback((_) {

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
            widget.voucher==null ? "Create Issue Voucher": "Edit Issue Voucher",

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

                          onChanged: (value) {
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

                    const SizedBox(width: 12),

                    Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const Text("To Location *"),

                            value: toLocation,

                            items: filteredToLocations.map((loc) {
                              return DropdownMenuItem<String>(
                                value: loc.locationName,
                                child: Text(loc.locationName ?? ""),
                              );
                            }).toList(),

                            onChanged: (value) {
                              final selectedLoc =
                              locations.firstWhere((loc) => loc.locationName == value);

                              setState(() {
                                toLocation = selectedLoc.locationName;
                                toLocationId = selectedLoc.locationId;
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
                    itemVm.loading
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

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration:
                            inputStyle("Qty", Icons.numbers),
                          ),
                        ),

                        const SizedBox(width: 10),

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

                              /// ❌ Quantity greater than stock
                              if (enteredQty > availableQty) {
                                Fluttertoast.showToast(
                                  msg:
                                  "Only $availableQty available in stock for batch \"$batch\" of \"$product\"",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                                return;
                              }

                              /// ✅ Add product
                              // products.add({
                              //   "product": product,
                              //   "batch": batch,
                              //   "qty": enteredQty
                              // });
                              final selectedItem = productList[selectedIndex!];

                              // products.add({
                              //   "product": product,
                              //   "itemId": selectedItem.itemId,
                              //   "unitId": stock.unitId,
                              //   "qty": enteredQty,
                              //   "batch": stock.batchNo,
                              //   "mfgDate": stock.mfgDate,
                              //   "expDate": stock.expDate,
                              //   "purchaseRate": stock.purchaseRate,
                              //   "purchaseRateWithTax": stock.purchaseTaxRate,
                              //   "cashSalesRate": stock.cashSalesRate,
                              //   "outletSalesRate": stock.outletSalesRate,
                              //   "creditSalesRate": stock.creditSalesRate,
                              //   "mrp": stock.mRP,
                              //   "purchaseId": stock.purchaseId,
                              // });
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

              /// PRODUCT LIST
              Expanded(
                child: buildCard(
                  products.isEmpty
                      ? const Center(
                    child: Text(
                      "No records to display",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {

                      final item = products[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [

                            /// PRODUCT + BATCH
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["product"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Batch : ${item["batch"]}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// QTY
                            Expanded(
                              flex: 1,
                              child: Text(
                                item["qty"].toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            /// ACTIONS
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {

                                      final item = products[index];

                                      editingIndex = index;

                                      final prodIndex =
                                      productList.indexWhere((p) => p.itemId == item["itemId"]);

                                      final selectedItem = productList[prodIndex];

                                      setState(() {
                                        selectedIndex = prodIndex;
                                        product = item["product"];
                                        qtyController.text = item["qty"].toString();
                                        isLoadingStock = true;
                                      });

                                      final todayString = DateFormat('MM-dd-yyyy').format(DateTime.now());

                                      final stockList = await itemVm.getItemSalesDetailsApi(
                                        selectedItem.itemId ?? 0,
                                        todayString,
                                        fromLocationId?.toString() ?? "",
                                      );

                                      int batchIndex =
                                      stockList.indexWhere((b) => b.batchNo == item["batch"]);

                                      setState(() {
                                        filteredStock = stockList;
                                        selectedBatchIndex = batchIndex;
                                        batch = item["batch"];
                                        isLoadingStock = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        products.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // /// BUTTONS
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton(
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(
              //               vertical: 12),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //         onPressed: () {
              //           Navigator.pop(context);
              //         },
              //         child: const Text(Strings.cancel),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: primary,
              //           padding: const EdgeInsets.symmetric(
              //               vertical: 12),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //           onPressed: () async {
              //
              //             if (fromLocationId == null) {
              //               Fluttertoast.showToast(msg: "Please select From Location");
              //               return;
              //             }
              //
              //             if (toLocationId == null) {
              //               Fluttertoast.showToast(msg: "Please select To Location");
              //               return;
              //             }
              //
              //             if (products.isEmpty) {
              //               Fluttertoast.showToast(msg: "Please add at least one product");
              //               return;
              //             }
              //
              //             // await createStockIssue();
              //             if (widget.voucher == null) {
              //               await createStockIssue();
              //             } else {
              //               await updateStockIssue();
              //             }
              //         },
              //         child: Text(
              //           widget.voucher == null ? Strings.save : "Update",
              //           style: const TextStyle(color: Colors.white),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
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

                      if (toLocationId == null) {
                        Fluttertoast.showToast(msg: "Please select To Location");
                        return;
                      }

                      if (products.isEmpty) {
                        Fluttertoast.showToast(msg: "Please add at least one product");
                        return;
                      }

                      if (widget.voucher == null) {
                        await createStockIssue();
                      } else {
                        await updateStockIssue();
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