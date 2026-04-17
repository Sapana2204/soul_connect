import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/items_by_product_type_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/invoice_item_model.dart';
import '../model/item_sales_details_model.dart';
import '../model/item_unit_model.dart';
import '../model/items_by_product_type.dart';
import '../viewmodel/sales_return_viewmodel.dart';


class SelectProductPopup extends StatefulWidget {
  final String? billType;
  final int locationId;
  final String payMode;
  final String taxType;
  final String rateType;
  final bool isReturn;
  final int custId;

  const SelectProductPopup({
    super.key,
    this.billType,
    required this.locationId,
    required this.payMode,
    required this.taxType,
    required this.rateType,
    this.isReturn = false,
    required this.custId
  });

  @override
  State<SelectProductPopup> createState() =>
      _SelectProductPopupState();
}

class _SelectProductPopupState extends State<SelectProductPopup> {
  final searchController = TextEditingController();

  // Selected product from GetItemsByProductType API
  ItemsByProductTypeModel? selectedItem;
  ItemSalesDetailsModel? stock;
  String? selectedProduct;
  int? taxGroupId;
  List<ItemUnitModel> unitList = [];
  ItemUnitModel? selectedUnit;
  bool unitLoading = false;
  ItemUnitModel? selectedUnitModel;
  int? selectedItemId;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;


  // Controllers
  final unitNameCtrl = TextEditingController(text: "1");
  final qtyCtrl = TextEditingController(text: "1");
  final freeQtyCtrl = TextEditingController(text: "0");
  final rateCtrl = TextEditingController();
  final baseRateCtrl = TextEditingController();
  final subtotalCtrl = TextEditingController();
  final discPerCtrl = TextEditingController(text: "0");
  final discAmtCtrl = TextEditingController();
  final totalDiscCtrl = TextEditingController();
  final taxableCtrl = TextEditingController();
  final taxPerCtrl = TextEditingController();
  final taxAmtCtrl = TextEditingController();
  final totalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // vm.getItemsByProuctTypeApi(today, {"locationId": widget.locationId.toString() ?? ""});
    Future.microtask(() =>
        context.read<ItemViewmodel>().getRateTypes());
    if (!widget.isReturn) {
      vm.getItemsByProuctTypeApi(today, {"locationId": widget.locationId.toString() ?? ""});
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }


  bool get canAddItem => selectedItem != null && qtyCtrl.text.isNotEmpty;

  // void _calculate({String? active}) {
  //   final qty = int.tryParse(qtyCtrl.text) ?? 1;
  //   final rate = double.tryParse(rateCtrl.text) ?? 0;
  //   double gst = double.tryParse(taxPerCtrl.text) ?? 0;
  //
  //   final taxType = widget.taxType.toLowerCase();
  //
  //   final isInclusive = taxType == "inclusive";
  //   final isExclusive = taxType == "exclusive";
  //   final isNoTax = taxType == "no tax";
  //
  //   // 🚫 NO TAX → force GST = 0
  //   if (isNoTax) {
  //     gst = 0;
  //   }
  //
  //   double baseRate;
  //   double baseAmount;
  //
  //   if (isInclusive) {
  //     baseRate = gst > 0 ? (rate * 100) / (100 + gst) : rate;
  //     baseAmount = baseRate * qty;
  //     baseRateCtrl.text = baseRate.toStringAsFixed(2);
  //   } else {
  //     baseRate = rate;
  //     baseAmount = rate * qty;
  //     baseRateCtrl.clear();
  //   }
  //
  //   // ---------- Discount ----------
  //   double discTotal = 0;
  //   final discPer = double.tryParse(discPerCtrl.text) ?? 0;
  //   final discAmt = double.tryParse(discAmtCtrl.text) ?? 0;
  //
  //   if (active == "per") {
  //     final perItem = (baseRate * discPer) / 100;
  //     discTotal = perItem * qty;
  //     discAmtCtrl.text = perItem.toStringAsFixed(2);
  //   } else if (active == "amt") {
  //     discTotal = discAmt * qty;
  //     discPerCtrl.text =
  //     baseRate > 0 ? ((discAmt / baseRate) * 100).toStringAsFixed(2) : "0";
  //   } else {
  //     discTotal = ((baseRate * discPer) / 100) * qty;
  //   }
  //
  //   final taxable = baseAmount - discTotal;
  //   final tax = isNoTax ? 0 : (taxable * gst) / 100;
  //
  //   subtotalCtrl.text = baseAmount.toStringAsFixed(2);
  //   totalDiscCtrl.text = discTotal.toStringAsFixed(2);
  //   taxableCtrl.text = taxable.toStringAsFixed(2);
  //   taxAmtCtrl.text = tax.toStringAsFixed(2);
  //
  //   if (isInclusive) {
  //     totalCtrl.text = (rate * qty).toStringAsFixed(2);
  //   } else {
  //     totalCtrl.text = (taxable + tax).toStringAsFixed(2);
  //   }
  // }

  void _calculate({String? activeField}) {
    double r2(double v) => double.parse(v.toStringAsFixed(2));

    final qty = double.tryParse(qtyCtrl.text) ?? 1;
    final rate = double.tryParse(rateCtrl.text) ?? 0;
    double gst = double.tryParse(taxPerCtrl.text) ?? 0;

    String tType = "E";
    if (widget.taxType?.toLowerCase() == "inclusive") tType = "I";
    if (widget.taxType?.toLowerCase() == "no tax") tType = "N";

    /// ---------- BASE RATE ----------
    double baseRate = rate;

    if (tType == "I" && gst > 0) {
      baseRate = r2(rate * 100 / (100 + gst));
    }

    /// ---------- SUBTOTAL ----------
    double subTotal = r2(baseRate * qty);

    /// ---------- DISCOUNT ----------
    double discPer = double.tryParse(discPerCtrl.text) ?? 0;
    double discAmtPerItem = double.tryParse(discAmtCtrl.text) ?? 0;

    if (activeField == "discper") {
      discAmtPerItem = r2((baseRate * discPer) / 100);
      discAmtCtrl.text = discAmtPerItem.toStringAsFixed(2);
    } else if (activeField == "discAmt") {
      discPer = baseRate > 0 ? r2((discAmtPerItem / baseRate) * 100) : 0;
      discPerCtrl.text = discPer.toStringAsFixed(2);
    } else {
      discAmtPerItem = r2((baseRate * discPer) / 100);
      discAmtCtrl.text = discAmtPerItem.toStringAsFixed(2);
    }

    double totalDisc = r2(discAmtPerItem * qty);

    /// ---------- TAXABLE ----------
    double taxable = r2(subTotal - totalDisc);

    /// ---------- TAX ----------
    double taxAmt = 0;
    double total = 0;

    if (tType == "E") {
      taxAmt = r2((taxable * gst) / 100);
      total = r2(taxable + taxAmt);
    }
    else if (tType == "I") {
      total = r2(rate * qty);
      taxAmt = r2(total - taxable);
      baseRateCtrl.text = baseRate.toStringAsFixed(2);
    }
    else {
      taxAmt = 0;
      total = taxable;
    }

    /// ---------- UPDATE UI ----------
    setState(() {
      subtotalCtrl.text = subTotal.toStringAsFixed(2);
      totalDiscCtrl.text = totalDisc.toStringAsFixed(2);
      taxableCtrl.text = taxable.toStringAsFixed(2);
      taxAmtCtrl.text = taxAmt.toStringAsFixed(2);
      totalCtrl.text = total.toStringAsFixed(2);
    });
  }

  int _i(TextEditingController c, {int def = 0}) {
    return int.tryParse(c.text) ?? def;
  }

  double _d(TextEditingController c, {double def = 0.0}) {
    return double.tryParse(c.text) ?? def;
  }

  int _resolveRateTypeId(ItemViewmodel vm) {
    // widget.rateType example: "CASH", "MRP", "GOLD"
    final match = vm.rateTypes.firstWhere(
          (e) => e.rateType?.toUpperCase() == widget.rateType.toUpperCase(),
      orElse: () => vm.rateTypes.first,
    );

    return match.rateTypeId ?? 1;
  }

  Future<void> _onProductSelected(ItemsByProductTypeModel item) async {
    setState(() {
      selectedItem = item;
      selectedItemId = item.itemId;
      selectedProduct = item.itemName;
    });

    final unitVM = context.read<ItemViewmodel>();
    await unitVM.getItemUnits(item.itemId ?? 0);

    if (unitVM.unitList.isNotEmpty) {
      unitVM.setSelectedUnit(unitVM.unitList.first);
      selectedUnitModel = unitVM.selectedUnit;
    }

    qtyCtrl.text = "1";
    freeQtyCtrl.text = "0";
    rateCtrl.text = (item.baseRate ?? 0).toString();
    taxPerCtrl.text = (item.taxPer ?? 0).toString();

    await _loadItemRate();
    _calculate();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;
    } else {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
      _isDropdownOpen = true;
    }
  }

  OverlayEntry _createOverlay() {
    final vm = context.read<ItemsByProductTypeViewmodel>();
    final returnVM = context.read<SalesReturnViewModel>();


    final list = widget.isReturn
        ? returnVM.itemDetails
        : vm.itemList;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 28,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 55),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final item = vm.itemList[i];

                  return ListTile(
                    title: Text(item.itemName ?? ""),
                    onTap: () async {
                      _toggleDropdown();
                      await _onProductSelected(item);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadItemRate() async {
    if (selectedItem == null || selectedUnitModel == null) return;

    final vm = Provider.of<ItemViewmodel>(context, listen: false);
    final rateOn = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final rateTypeId = _resolveRateTypeId(vm);

    await vm.getItemRate(
      itemId: selectedItem!.itemId!,
      rateOn: rateOn,
      rateTypeId: rateTypeId, // ✅ dynamic
      customerId: null,
      unitId: selectedUnitModel!.unitId,
    );

    final rateData = vm.itemRate;
    if (rateData?.rate?.rate == null) return;

    print("Using RateType: ${widget.rateType}, ID: $rateTypeId");

    setState(() {
      rateCtrl.text =
          rateData!.rate!.rate!.toDouble().toStringAsFixed(2);
    });

    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ItemsByProductTypeViewmodel>(context);
    final unitVM = Provider.of<ItemViewmodel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Product Dropdown
              CompositedTransformTarget(
                link: _layerLink,
                child: GestureDetector(
                  onTap: _toggleDropdown,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedProduct ?? "Select Product"),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),


              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.grey.shade400),
              //     borderRadius: BorderRadius.circular(18),
              //     color: Colors.white,
              //   ),
              //   child: DropdownButtonHideUnderline(
              //     child: DropdownButton2<int>(
              //       isExpanded: true,
              //       hint: const Text("Select Product"),
              //       value: selectedItemId,
              //       items: vm.itemList.map((item) {
              //         return DropdownMenuItem<int>(
              //           value: item.itemId,
              //           child: Text(item.itemName ?? ""),
              //         );
              //       }).toList(),
              //       dropdownSearchData: DropdownSearchData(
              //         searchController: searchController,
              //         searchMatchFn: (ddItem, search) {
              //           final model = vm.itemList.firstWhere(
              //             (e) => e.itemId == ddItem.value,
              //             orElse: () => ItemsByProductTypeModel(),
              //           );
              //           return (model.itemName ?? "")
              //               .toLowerCase()
              //               .contains(search.toLowerCase());
              //         },
              //       ),
              //       onChanged: (id) async {
              //         if (id == null) return;
              //
              //         final item =
              //             vm.itemList.firstWhere((e) => e.itemId == id);
              //
              //         setState(() {
              //           selectedItemId = id;
              //           selectedItem = item;
              //           selectedProduct = item.itemName;
              //         });
              //
              //         // ✅ Load unit conversion list
              //         final unitVM =
              //             Provider.of<ItemViewmodel>(context, listen: false);
              //         await unitVM.getItemUnits(item.itemId ?? 0);
              //
              //         // ✅ Set default selected unit
              //         if (unitVM.unitList.isNotEmpty) {
              //           unitVM.setSelectedUnit(unitVM.unitList.first);
              //           setState(() {
              //             selectedUnitModel = unitVM.selectedUnit;
              //             unitNameCtrl.text = selectedUnitModel?.unitName ?? "";
              //           });
              //         }
              //
              //         // Set default values
              //         qtyCtrl.text = "1";
              //         freeQtyCtrl.text = "0";
              //         rateCtrl.text = (item.baseRate ?? 0).toString();
              //         taxPerCtrl.text = (item.taxPer ?? 0).toString();
              //
              //         await _loadItemRate();
              //         _calculate();
              //       },
              //     ),
              //   ),
              // ),

              const SizedBox(height: 14),
              // _field("Unit", unitNameCtrl, () => _calculate()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: unitVM.loading
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<ItemUnitModel>(
                  value: unitVM.selectedUnit,
                  decoration: InputDecoration(
                    labelText: "Unit",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    // loader inside field
                    suffixIcon: unitVM.loading
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : null,
                  ),

                  items: unitVM.unitList.map((u) {
                    return DropdownMenuItem(
                      value: u,
                      child: Text(u.unitName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    unitVM.setSelectedUnit(val!);
                  },
                ),
              ),

              _row(
                _field("Qty", qtyCtrl, () => _calculate()),
                _field("Free Qty", freeQtyCtrl, null),
              ),
              _row(
                _field("Rate", rateCtrl, () => _calculate()),
                _field("Subtotal", subtotalCtrl, null, ro: true),
              ),
              if (widget.taxType.toLowerCase() == "inclusive")
                _field(
                  "Base Rate",
                  baseRateCtrl,
                  null,
                  ro: true,
                ),

              _row(
                _field("Disc %", discPerCtrl, () => _calculate(activeField: "per")),
                _field(
                    "Disc Amt", discAmtCtrl, () => _calculate(activeField: "amt")),
              ),
              _field("Total Disc", totalDiscCtrl, null, ro: true),
              _field("Taxable", taxableCtrl, null, ro: true),
              _row(
                _field("Tax %", taxPerCtrl, null, ro: true),
                _field("Tax Amt", taxAmtCtrl, null, ro: true),
              ),
              _field("Total Amount", totalCtrl, null, ro: true),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: canAddItem
                    ? () {
                  final invoiceItem = InvoiceItem(
                    productName: selectedProduct!,
                    itemName: selectedProduct!,
                    qty: _i(qtyCtrl, def: 1),
                    freeQty: _i(freeQtyCtrl),
                    rate: _d(rateCtrl),
                    subtotal: _d(subtotalCtrl),
                    discountPerc: _d(discPerCtrl),
                    discountAmt: _d(discAmtCtrl),
                    totalDisc: _d(totalDiscCtrl),
                    taxable: _d(taxableCtrl),
                    taxPerc: _d(taxPerCtrl),
                    taxAmt: _d(taxAmtCtrl),
                    totalAmt: _d(totalCtrl),
                    netAmt: _d(totalCtrl),

                    // ✅ FROM selectedItem (NOT stock)
                    itemId: selectedItem!.itemId!,
                    unitId: selectedItem!.unitId ?? 0,
                    taxGroupId: taxGroupId ?? 0,

                    // ✅ SAFE DEFAULTS
                    stock: 0,
                    purchaseRate: selectedItem!.lastPurchaseRate ?? 0,
                    mrp: selectedItem!.lASTMRP ?? 0,
                    stkPurchaseId: 0,
                    firmId: 0,
                    locationId: widget.locationId,
                    isNonGST: (selectedItem!.taxPer ?? "0") != "0",
                    mfgDate: "",
                    purchaseRateWithTax: 0,
                    returnQty: 0,
                  );

                  // final invoiceItem = InvoiceItem(
                  //   productName: selectedProduct!,
                  //   itemName: selectedProduct!,
                  //   qty: _i(qtyCtrl, def: 1),
                  //   freeQty: _i(freeQtyCtrl),
                  //   rate: _d(rateCtrl),
                  //   subtotal: _d(subtotalCtrl),
                  //   discountPerc: _d(discPerCtrl),
                  //   discountAmt: _d(discAmtCtrl),
                  //   totalDisc: _d(totalDiscCtrl),
                  //   taxable: _d(taxableCtrl),
                  //   taxPerc: _d(taxPerCtrl),
                  //   taxAmt: _d(taxAmtCtrl),
                  //   totalAmt: _d(totalCtrl),
                  //   netAmt: _d(totalCtrl),
                  //   itemId: stock!.itemId??0,
                  //   unitId: stock!.unitId!??0,
                  //   taxGroupId: taxGroupId!,
                  //   stock: stock!.stockQuantity?.toInt() ?? 0,
                  //   purchaseRate: stock!.purchaseRate?.toDouble() ?? 0,
                  //   mrp: stock!.mRP?.toDouble() ?? 0,
                  //   stkPurchaseId: stock!.purchaseId ?? 0,
                  //   firmId: 0,
                  //   locationId: 0,
                  //   isNonGST: (stock?.taxPer ?? 0) > 0,
                  //   mfgDate: "",
                  //   purchaseRateWithTax: stock?.purchaseTaxRate ?? 0,
                  //   returnQty: 0,
                  // );

                  Navigator.pop(context, invoiceItem);
                } : null,
                child: const Text(
                  "Add Item",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(Widget a, Widget b) => Row(
    children: [
      Expanded(child: a),
      const SizedBox(width: 8),
      Expanded(child: b),
    ],
  );

  Widget _field(String label, TextEditingController c, VoidCallback? onChange,
      {bool ro = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        readOnly: ro,
        onChanged: (_) => onChange?.call(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: ro ? Colors.grey.shade200 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
