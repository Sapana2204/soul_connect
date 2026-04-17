import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/DCProduct_item_model.dart';
import '../model/get_item_unit_converted_model.dart';
import '../model/item_sales_details_model.dart';
import '../model/items_by_product_type.dart';
import '../utils/app_colors.dart';
import 'package:flutter_soulconnect/viewmodel/deliveryChallanDashboard_viewmodel.dart';

class DCSelectProductPopup extends StatefulWidget {
  final DeliveryChallanDashboardViewmodel dcVM;
  final String locationId;

  const DCSelectProductPopup({
    super.key,
    required this.dcVM,
    required this.locationId,
  });


  @override
  State<DCSelectProductPopup> createState() => _DCSelectProductPopupState();
}


class _DCSelectProductPopupState extends State<DCSelectProductPopup> {
  final _formKey = GlobalKey<FormState>();
  ItemsByProductTypeModel? selectedProduct;
  ItemSalesDetailsModel? selectedBatch;
  GetItemUnitConvertedModel? selectedUnit;

  List<ItemSalesDetailsModel> batchList = [];
  bool batchLoading = false;


  final barcodeController = TextEditingController();
  final qtyController = TextEditingController();

  List<GetItemUnitConvertedModel> itemUnitList = [];
  bool unitLoading = false;




  @override
  void initState() {
    super.initState();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryChallanDashboardViewmodel>().preloadDropdowns(
        stockDate: today,
        locationId: widget.locationId,
      );

    });
  }

  DateTime? _parseDate(String? date) {
    if (date == null || date.isEmpty) return null;
    return DateTime.tryParse(date);
  }


  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Add Products",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Divider(thickness: 1),


              /// Barcode
              Row(
                children: [
                  SizedBox(
                    width: 180, // 👈 adjust as needed
                    child: TextFormField(
                      controller: barcodeController,
                      enabled: selectedBatch != null,
                      decoration: _dec("Barcode"),
                    ),

                  ),
                ],
              ),


              const SizedBox(height: 12),

              /// Product dropdown (name + qty)
              AnimatedBuilder(
                animation: widget.dcVM,
                builder: (context, _) {
                  if (widget.dcVM.itemDetailsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.dcVM.itemList.isEmpty) {
                    return const Text(
                      "No products found for this location",
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return _buildProductSearchableDropdown(
                    label: "Product *",
                    items: widget.dcVM.itemList,
                    value: selectedProduct,
                    onChanged: (v) async {
                      if (v == null) return;

                      setState(() {
                        selectedProduct = v;
                        selectedBatch = null;
                        batchList.clear();
                        batchLoading = true;
                        selectedUnit = null;
                        itemUnitList.clear();
                        unitLoading = true;
                      });

                      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

                      final batchResult = await widget.dcVM.fetchItemSalesDetails(
                        v.itemId!,
                        today,
                        widget.locationId,
                      );

                      final unitResult =
                      await widget.dcVM.fetchItemUnitConverted(v.itemId!);

                      setState(() {
                        batchList = batchResult;
                        batchLoading = false;

                        itemUnitList = unitResult;
                        unitLoading = false;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 12),

              /// Batch dropdown
              batchLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<ItemSalesDetailsModel>(
                decoration: _dec("Select Batch"),
                isDense: true,
                menuMaxHeight: 250,
                value: selectedBatch,

                /// 👇 This controls what is shown AFTER selection
                selectedItemBuilder: (context) {
                  return batchList.map((b) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        b.batchNo ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList();
                },

                /// 👇 This controls dropdown menu items
                items: batchList.map((b) {
                  return DropdownMenuItem<ItemSalesDetailsModel>(
                    value: b,
                    child: SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            b.batchNo ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Qty: ${b.stockQuantity}",
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                onChanged: (v) {
                  setState(() {
                    selectedBatch = v;

                    // ✅ AUTO FILL BARCODE FIELD
                    barcodeController.text = v?.barcode ?? '';
                  });
                },
                validator: (v) => v == null ? 'Select batch' : null,
              ),


              const SizedBox(height: 12),

              /// Qty + Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: _dec("Qty"),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Qty required';
                        final enteredQty = double.tryParse(v);
                        if (enteredQty == null) return 'Invalid number';

                        final availableStock = selectedBatch?.stockQuantity ?? 0;
                        if (enteredQty > availableStock) {
                          return 'Qty exceeding stock ($availableStock)';
                        }

                        return null;
                      },
                    ),
                  ),


                  const SizedBox(width: 12),
                  Expanded(
                    child: unitLoading
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<GetItemUnitConvertedModel>(
                      decoration: _dec("Unit"),
                      value: selectedUnit,
                      items: itemUnitList.map((u) {
                        return DropdownMenuItem<GetItemUnitConvertedModel>(
                          value: u,
                          child: Text(u.unitName ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedUnit = v),
                      validator: (v) => v == null ? 'Unit required' : null,
                    )

                  ),

                ],
              ),

              const SizedBox(height: 20),

              /// Add button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(
                        context,
                        DCProductItem(
                          itemId: selectedProduct!.itemId,
                          unitId: selectedUnit!.unitId!,
                          barcode: barcodeController.text.isNotEmpty
                              ? barcodeController.text
                              : selectedBatch!.barcode.toString(),
                          productName: selectedProduct!.itemName!,
                          batchNo: selectedBatch!.batchNo!, // ✅ ensure correct key
                          qty: double.parse(qtyController.text),
                          unit: selectedUnit!.unitName!,
                          batch: selectedBatch!.batchNo.toString(),
                          // 🔥 IMPORTANT FOR API
                          salesId: selectedBatch!.salesId,
                          purchaseId: selectedBatch!.purchaseId,
                          purchaseRate: selectedBatch!.purchaseRate,
                          salesRate: selectedBatch!.salesRate,
                          mrp: selectedBatch!.mRP,
                          mfgDate: _parseDate(selectedBatch!.mfgDate),
                          expDate: _parseDate(selectedBatch!.expDate),
                        ),
                      );

                    }
                  },
                  child: Text("Add",style: TextStyle(color: primary),),
                ),

              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSearchableDropdown({
    required String label,
    required List<ItemsByProductTypeModel> items,
    required ItemsByProductTypeModel? value,
    required Function(ItemsByProductTypeModel?) onChanged,
  }) {
    return Autocomplete<ItemsByProductTypeModel>(
      initialValue: TextEditingValue(text: value?.itemName ?? ""),

      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return items;
        }

        return items.where((item) =>
            (item.itemName ?? "")
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
      },

      displayStringForOption: (ItemsByProductTypeModel option) =>
      option.itemName ?? "",

      onSelected: (selection) {
        onChanged(selection);
      },

      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Search product",
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (v) =>
          value == null ? "Product is required" : null,
        );
      },

      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              width: MediaQuery.of(context).size.width * 0.9,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options.elementAt(index);

                  return ListTile(
                    title: Text(item.itemName ?? ''),
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
