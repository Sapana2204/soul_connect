import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/viewModel/sales_invoice_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/DCProduct_item_model.dart';
import '../model/delivery_challan_item_model.dart';
import '../model/delivery_challan_model.dart';
import '../model/party_model.dart';

import '../model/stock_locations_model.dart';
import '../res/widgets/custom_button.dart';
import '../utils/app_colors.dart';

import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/deliveryChallanDashboard_viewmodel.dart';
import 'DCProductDetailsPopup.dart';
import 'delivery_challan_info_popup.dart';
import 'delivery_challan_select_product_popup.dart';


class DeliveryChallan extends StatefulWidget {
  final DeliveryChallanModel challanModel;
  final bool isEdit;

  const DeliveryChallan({
    super.key,
    required this.challanModel,
    this.isEdit = false, // default false

  });

  @override
  State<DeliveryChallan> createState() => _DeliveryChallanState();
}

class _DeliveryChallanState extends State<DeliveryChallan> {
  final List<DeliveryChallanItem> items = [];
  List<DCProductItem> dcItems = [];
  DateTime challanDate = DateTime.now();

  PartyModel? selectedCustomer;
  int? selectedLocationId;

  final TextEditingController customerController = TextEditingController();
  final TextEditingController challanNoController =
  TextEditingController(text: "AUTO");
  // TextEditingController(text: "Challan No");

  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController byHandController = TextEditingController();


  @override
  void initState() {
    super.initState();
    challanDate = widget.challanModel.challanDate ?? DateTime.now();
    /// Prefill header fields
    customerController.text = widget.challanModel.customerName;
    challanNoController.text = widget.challanModel.challanNo;
    vehicleController.text = widget.challanModel.vehicleNo ?? '';
    byHandController.text = widget.challanModel.byHand ?? '';

    /// Set selected customer model (IMPORTANT)
    selectedCustomer = PartyModel(
      partyId: widget.challanModel.customerId,
      partyName: widget.challanModel.customerName,
    );

    /// Set selected location
    selectedLocationId = widget.challanModel.locationId;

    /// Prefill product items for edit
    if (widget.challanModel.details != null) {
      dcItems = widget.challanModel.details!.map((item) {
        return DCProductItem(
          itemId: item.itemId,
          productName: item.itemName.toString(),
          unitId: item.unitId ?? 0,
          unit: item.unitName.toString(),
          qty: item.qty.toDouble(),
          barcode: item.barcode.toString(),
          batchNo: item.batchNo,
          mfgDate: item.mfgDate,
          expDate: item.expDate,
          purchaseId: item.purchaseId,
          purchaseRate: item.purchaseRate,
          pflPurchaseRate: item.pflPurchaseRate,
          salesRate: item.salesRate,
          salesRate1: item.salesRate1,
          salesRate2: item.salesRate2,
          mrp: item.mrp,
          batch: item.batchNo.toString(),
        );
      }).toList();
    }



    /// Preload dropdown APIs ONCE (no re-hit)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryChallanDashboardViewmodel>().preloadDropdowns(
        stockDate: DateFormat('yyyy-MM-dd').format(
          widget.challanModel.challanDate ?? DateTime.now(),
        ),
        locationId: selectedLocationId.toString(),
      );
    });
  }


  double get totalSelectedQty {
    return dcItems.fold<double>(
      0.0,
          (sum, item) => sum + (item.qty ?? 0),
    );
  }

  Map<String, dynamic> _buildAddChallanRequest() {
    return {
      "ChallanId": 0,
      "ChallanSeriesId": 0,
      "ChallanNo": "0", // ✅ ALWAYS send 0 as STRING
      "ChallanDate": widget.challanModel.challanDate?.toIso8601String(),
      "CustomerId": selectedCustomer?.partyId ?? 0,
      "TotalQty": totalSelectedQty.toInt(),
      "ByHand": byHandController.text,
      "VehicleDetails": vehicleController.text,
      "FirmId": 0 ,
      "LocationId": selectedLocationId ?? 0,
      "Contact": widget.challanModel.contact ?? "",
      "DeliveryAddress": widget.challanModel.deliveryAddress ?? "",
      "PreparedBy": 0,
      "CheckedBy": 0,
      "CreatedBy": 0,
      "CreatedOn": DateTime.now().toIso8601String(),
      "UpdatedBy": 0,
      "UpdatedOn": DateTime.now().toIso8601String(),
      "Narration": "",
      "SalesId": 0,
      "IsCancelled": false,
      // "UserId": widget.challanModel.userId ?? 0,
      "UserId": 1,

      /// 🔥 DETAILS ARRAY
      "Details": dcItems.map((item) {
        return {
          "ChallanId": 0,
          "ItemId": item.itemId ?? 0,
          "UnitId": item.unitId ?? 0,
          "Quantity": item.qty ?? 0,
          "Barcode": item.barcode ?? "",
          "BatchNo": item.batchNo ?? "",
          "MfgDate": item.mfgDate?.toIso8601String(),
          "ExpDate": item.expDate?.toIso8601String(),
          "PurchaseId": item.purchaseId ?? 0,
          "PurchaseRate": item.purchaseRate ?? 0,
          "PFL_PurchaseRate": item.pflPurchaseRate ?? 0,
          "SalesRate": item.salesRate ?? 0,
          "SalesRate1": item.salesRate1 ?? 0,
          "SalesRate2": item.salesRate2 ?? 0,
          "MRP": item.mrp ?? 0,
          "FirmId": 0,
          "LocationId": selectedLocationId ?? 0,
        };
      }).toList(),
    };
  }

  Future<void> _selectChallanDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: challanDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        challanDate = picked;
        widget.challanModel.challanDate = picked; // 🔥 important
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final deliveryChallanDashboardVM =
    context.read<DeliveryChallanDashboardViewmodel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Challan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              DateFormat('dd-MM-yyyy').format(challanDate),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectChallanDate,
          ),
        ],
      ),

      body: Column(
        children: [

          /// HEADER
          Container(
            height: screenHeight * 0.09,
            padding: const EdgeInsets.fromLTRB(6, 14, 6, 0),
            child: InkWell(
              onTap: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => DeliveryChallanInfoPopup(
                    partyVM: context.read<SalesInvoiceViewmodel>(),
                    itemVM: context.read<ItemViewmodel>(),


                    /// 🔥 PASS EXISTING VALUES
                    initialCustomer: selectedCustomer,
                    initialLocation: selectedLocationId != null
                        ? StockLocationsModel(locationId: selectedLocationId)
                        : null,
                    initialContact: widget.challanModel.contact,
                    initialAddress: widget.challanModel.deliveryAddress,
                    initialVehicle: vehicleController.text,
                    initialByHand: byHandController.text,
                  ),
                );


                if (result != null) {
                  setState(() {
                    selectedCustomer = PartyModel(
                      partyId: result['customerId'],
                      partyName: result['customerName'],
                    );

                    selectedLocationId = result['locationId'];

                    widget.challanModel.customerName = result['customerName'];
                    widget.challanModel.challanNo = result['challanNo'];
                    widget.challanModel.challanDate = result['date'];
                    widget.challanModel.contact = result['contact'];
                    widget.challanModel.deliveryAddress = result['address'];

                    vehicleController.text = result['vehicle'] ?? '';
                    byHandController.text = result['byHand'] ?? '';
                    customerController.text = result['customerName'] ?? '';

                  });
                }


              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Customer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  customerController.text.isEmpty
                      ? 'Tap to select customer'
                      : customerController.text,
                  style: TextStyle(
                    color: customerController.text.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),

          const Divider(thickness: 2),

          /// PRODUCT SECTION
          Container(
            height: screenHeight * 0.68,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [

                /// Add Product
                TextField(
                  readOnly: true,
                  enabled: selectedLocationId != null,
                  decoration: InputDecoration(
                    hintText: "Select Product",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primary),
                    ),
                  ),
                  onTap: () async {
                    if (selectedLocationId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select location first")),
                      );
                      return;
                    }

                    final result = await showDialog<DCProductItem>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => DCSelectProductPopup(
                        dcVM: deliveryChallanDashboardVM,
                        locationId: selectedLocationId!.toString(), // API needs String
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        dcItems.add(result);
                      });
                    }
                  },
                ),





                const SizedBox(height: 8),

                /// Items
                Expanded(
                  child: ListView.builder(
                    itemCount: dcItems.length,
                    padding: const EdgeInsets.only(bottom: 8),

                    itemBuilder: (context, index) {
                      final item = dcItems[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Barcode: ${item.barcode}",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Product: ${item.productName}"),
                              Text("Qty: ${item.qty} ${item.unit}"),

                              const SizedBox(height: 8),

                              /// Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.visibility),
                                    label: const Text("View"),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => DCProductDetailsPopup(
                                          item: item,
                                        ),
                                      );
                                    },
                                  ),

                                  TextButton.icon(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text("Delete",
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      setState(() => dcItems.removeAt(index));
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Qty",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        totalSelectedQty.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          const Divider(thickness: 2),

          /// ACTIONS
          SizedBox(
            height: screenHeight * 0.08,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      color: grey,
                      text: "Exit",
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      color: primary,
                      text: "Save",
                      onPressed: () async {
                        if (dcItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please add at least one product")),
                          );
                          return;
                        }

                        final requestBody = _buildAddChallanRequest();

// 🔥 PRINT FULL REQUEST (pretty format)
                        final prettyJson = const JsonEncoder.withIndent('  ').convert(requestBody);
                        debugPrint("📤 Add Delivery Challan Request:\n$prettyJson");

// API call
                        final success = await deliveryChallanDashboardVM
                            .addDeliveryChallan(requestBody);


                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Delivery Challan Added Successfully")),
                          );

                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("❌ Failed to add Delivery Challan")),
                          );
                        }
                      },

                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
