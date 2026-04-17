import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/model/issue_vch_request_model.dart';
import 'package:flutter_soulconnect/viewmodel/stock_vouchers_viewmodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/item_sales_details_model.dart';
import '../model/stock_inward_model.dart';
import '../model/stock_inward_request_model.dart';
import '../model/stock_issue_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import '../viewModel/login_viewmodel.dart';

class CreateInwardStock extends StatefulWidget {
  final StockIssueModel? voucher;

  const CreateInwardStock({super.key, this.voucher});

  @override
  State<CreateInwardStock> createState() => _CreateInwardStockState();
}

class _CreateInwardStockState extends State<CreateInwardStock> {

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
  int? selectedIssueId;

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
  Future<void> createStockInward() async {

    final stockVm =
    Provider.of<StockVouchersViewmodel>(context, listen: false);

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = int.tryParse(loginVM.userId ?? "0") ?? 0;

    List<StockInwardDetails> details = [];

    for (var item in products) {

      double issueQty = item["qty"] ?? 0;
      double inwardQty = item["receivedQty"] ?? issueQty;

      if (inwardQty > issueQty) {
        Fluttertoast.showToast(
          msg: "Received qty cannot be greater than issued qty",
        );
        return;
      }

      details.add(
        StockInwardDetails(
          issueId: selectedIssueId ?? 0,
          itemId: item["itemId"],
          unitId: item["unitId"],
          issueQuantity: issueQty,
          inwardQuantity: inwardQty,
          excessShortageReason: item["reason"] ?? "",
          rate: item["purchaseRate"] ?? 0,
          batchNo: item["batch"] ?? "",
          mfgDate: item["mfgDate"],
          expDate: item["expDate"],
          barcode: item["barCode"] ?? "",
          purchaseRate: item["purchaseRate"] ?? 0,
          purchaseRateWithTax: item["purchaseRateWithTax"] ?? 0,
          cashSalesRate: item["cashSalesRate"] ?? 0,
          outletSalesRate: item["outletSalesRate"] ?? 0,
          creditSalesRate: item["creditSalesRate"] ?? 0,
          mrp: item["mrp"] ?? 0,
          purchaseId: item["purchaseId"] ?? 0,
          locationId: toLocationId ?? 0,
          fromLocationId: fromLocationId ?? 0,
        ),
      );
    }

    StockInwardRequestModel request = StockInwardRequestModel(
      inwardId: 0,
      issueId: selectedIssueId ?? 0,
      inwardDate: DateTime.now().toIso8601String(),
      createdBy: userId,
      locationId: toLocationId ?? 0,
      fromLocationId: fromLocationId ?? 0,
      details: details,
    );

    bool success = await stockVm.addStockInwardApi(request);

    if (success) {
      Fluttertoast.showToast(msg: "Stock Inward Created");
      Navigator.pop(context, true);
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
      Fluttertoast.showToast(msg: "Stock Inward Updated");
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

    final stockVm = Provider.of<StockVouchersViewmodel>(context);
    final issueList = stockVm.issueForInwardList;

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
            widget.voucher==null ? "Add Stock Inward": "Edit Stock Inward",

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
                          hint: const Text("To Location *"),

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

                            await Provider.of<StockVouchersViewmodel>(
                              context,
                              listen: false,
                            ).fetchStockIssueForInward(fromLocationId ?? 0);
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
                          child: DropdownButton2<int>(
                            isExpanded: true,
                            hint: const Text("Select Issue Voucher *"),

                            value: selectedIssueId,

                            items: issueList.map((issue) {
                              return DropdownMenuItem<int>(
                                value: issue.issueId,
                                child: Text("IV-${issue.issueId}"),
                              );
                            }).toList(),

                            onChanged: (value) {

                              print("Selected Issue ID: $value");
                              print("Issue List Length: ${issueList.length}");

                              final selectedIssue =
                              issueList.firstWhere((e) => e.issueId == value);

                              print("Selected Issue: ${selectedIssue.issueId}");
                              print("Details Count: ${selectedIssue.details?.length}");

                              List<Map<String, dynamic>> tempProducts = [];

                              for (var d in selectedIssue.details ?? []) {
                                print("Item: ${d.itemName}");

                                tempProducts.add({
                                  "product": d.itemName ?? "",
                                  "itemId": d.itemId,
                                  "unitId": d.unitId,
                                  "qty": d.issueQuantity ?? 0,
                                  "batch": d.batchNo ?? "",
                                  "mfgDate": d.mfgDate,
                                  "expDate": d.expDate,
                                  "purchaseRate": d.purchaseRate ?? 0,
                                  "purchaseRateWithTax": d.purchaseRateWithTax ?? 0,
                                  "cashSalesRate": d.salesRate ?? 0,
                                  "outletSalesRate": d.salesRate2 ?? 0,
                                  "creditSalesRate": d.salesRate1 ?? 0,
                                  "mrp": d.mrp ?? 0,
                                  "purchaseId": d.purchaseId,
                                });
                              }

                              setState(() {
                                selectedIssueId = value;
                                products = tempProducts;
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                    ),
                  ],
                ),
              ),

              /// PRODUCT LIST
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {

                    final item = products[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// PRODUCT NAME
                            Row(
                              children: [
                                Icon(Icons.inventory_2_outlined, color: primary, size: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item["product"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 20),

                            /// BATCH + RATE
                            Row(
                              children: [
                                Icon(Icons.qr_code, size: 18, color: Colors.grey),
                                const SizedBox(width: 4),
                                const Text(
                                  "Batch:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 6),
                                Text(item["batch"] ?? ""),

                                const Spacer(),

                                const Text(
                                  "Rate:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "₹${item["purchaseRate"] ?? 0}",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// ISSUED QTY+ Received Qty
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                /// ISSUED QTY
                                Icon(Icons.outbox, size: 18, color: Colors.grey),
                                const SizedBox(width: 4),

                                const Text(
                                  "Issue:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  item["qty"].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),

                                const Spacer(),

                                /// RECEIVED LABEL
                                const Text(
                                  "Received:",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),

                                const SizedBox(width: 8),

                                /// RECEIVED QTY BOX
                                SizedBox(
                                  width: 70,
                                  height: 38,
                                  child: TextFormField(
                                    initialValue: item["qty"].toString(),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {

                                      double received = double.tryParse(value) ?? 0;
                                      double issued = item["qty"] ?? 0;

                                      if (received > issued) {
                                        Fluttertoast.showToast(
                                          msg: "Received qty cannot be greater than issued qty",
                                          backgroundColor: Colors.red,
                                        );

                                        received = issued;
                                      }

                                      products[index]["receivedQty"] = received;
                                    },
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// REASON FIELD
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  "Reason (Optional)",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                TextFormField(
                                  cursorColor: primary,
                                  decoration: InputDecoration(
                                    hintText: "Enter reason for inward",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                    ),

                                    prefixIcon: Icon(
                                      Icons.edit_note,
                                      color: primary,
                                      size: 20,
                                    ),

                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.2,
                                      ),
                                    ),

                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),

                                  onChanged: (value) {
                                    products[index]["reason"] = value;
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
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

                          // await createStockIssue();
                          if (widget.voucher == null) {
                            await createStockInward();
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
            ],
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