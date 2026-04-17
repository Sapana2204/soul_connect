

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/view/purchase_mode.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/PurchaseInvoiceItem_model.dart';
import '../model/itemDetailsForPurchaseReturn_model.dart';
import '../model/item_unit_model.dart';
import '../model/items_model.dart';
import '../utils/app_colors.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewmodel/purchaseReturn_viewmodel.dart';

class PurchaseSelectProductPopup extends StatefulWidget {
  final String? billType;
  final String locationId;
  final String payMode;
  final String taxType;
  final PurchaseMode mode;
  final int partyId;


  const PurchaseSelectProductPopup({
    super.key,
    this.billType,
    required this.locationId,
    required this.payMode,
    required this.taxType,
    required this.mode,        // ✅ ADD
    this.partyId = 0,          // ✅ ADD
  });

  @override
  State<PurchaseSelectProductPopup> createState() => _PurchaseSelectProductPopupState();
}

class _PurchaseSelectProductPopupState extends State<PurchaseSelectProductPopup> {
  final searchController = TextEditingController();

  ItemsModel? selectedItem;
  int? selectedItemId;
  double selectedGst = 0;
  String? selectedUnit;
  ItemUnitModel? selectedUnitModel;
  String selectedTaxType = "E"; // default

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;
  List<ItemDetailsForPurchaseReturnModel> returnItems = [];
  bool isReturnLoading = false;

  // Controllers
  final barcodeCtrl = TextEditingController();
  final netTotalCtrl = TextEditingController();

  final qtyCtrl = TextEditingController(text: "1");
  final freeQtyCtrl = TextEditingController(text: "0");

  final rateCtrl = TextEditingController();
  final discPerCtrl = TextEditingController(text: "0");
  final discAmtCtrl = TextEditingController(text: "0");
  final baseRateCtrl = TextEditingController();
  final subtotalCtrl = TextEditingController();
  final totalDiscCtrl = TextEditingController();
  final taxableCtrl = TextEditingController();
  final taxAmtCtrl = TextEditingController();


  // Readonly info fields
  final hsnCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final mrpCtrl = TextEditingController();
  final lastPurchaseDateCtrl = TextEditingController();
  final gstCtrl = TextEditingController();

  // Final total
  final totalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    print("Received tax type: ${widget.taxType}");

    if (widget.mode == PurchaseMode.purchase) {
      final vm = Provider.of<ItemViewmodel>(context, listen: false);
      vm.getItemsApi();
    } else {
      _loadReturnItems();   // ✅ CALL RETURN API
    }
  }

  Future<void> _loadReturnItems() async {
    setState(() => isReturnLoading = true);

    try {
      final vm = Provider.of<PurchaseReturnViewmodel>(context, listen: false);

      final data = await vm.getItemDetailsForPurchaseReturn(
        locationId: int.parse(widget.locationId),
        partyId: widget.partyId,
        itemId: 0, // ✅ IMPORTANT → get all items
      );

      setState(() {
        returnItems = data;
      });

    } catch (e) {
      print("Error loading return items: $e");
    } finally {
      setState(() => isReturnLoading = false);
    }
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
    return OverlayEntry(
      builder: (context) {
        final vm = context.read<ItemViewmodel>();

        List filteredItems;

        if (widget.mode == PurchaseMode.purchase) {
          final vm = context.read<ItemViewmodel>();

          filteredItems = vm.itemList
              .where((e) => (e.itemName ?? "")
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
              .toList();
        } else {
          filteredItems = returnItems
              .where((e) => (e.itemName ?? "")
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
              .toList();
        }

        return Positioned(
          width: MediaQuery.of(context).size.width - 28,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: const Offset(0, 55),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 300,
                color: Colors.white,
                child: (widget.mode == PurchaseMode.purchase
                    ? vm.loading
                    : isReturnLoading)
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (_, i) {
                    final item = filteredItems[i];

                    return ListTile(
                      title: Text(item.itemName ?? ""),
                        onTap: () async {
                          _toggleDropdown();

                          if (widget.mode == PurchaseMode.purchase) {
                            final item = filteredItems[i] as ItemsModel;

                            setState(() {
                              selectedItemId = item.itemId;
                              selectedItem = item;
                            });

                            _fillFieldsFromItem(item);

                            final unitVM = context.read<ItemViewmodel>();
                            await unitVM.getItemUnits(item.itemId ?? 0);
                          } else {
                            final item = filteredItems[i] as ItemDetailsForPurchaseReturnModel;

                            setState(() {
                              selectedItemId = item.itemId;

                              // ✅ ADD THIS
                              selectedItem = ItemsModel(
                                itemId: item.itemId,
                                itemName: item.itemName,
                              );

                              rateCtrl.text = item.purchaseRate.toString();
                              qtyCtrl.text = "1";

                              gstCtrl.text = item.taxPer.toString();
                              selectedGst = item.taxPer ?? 0;

                              barcodeCtrl.text = item.barcode ?? "";
                              // ✅ FIXED UNIT
                              unitCtrl.text = item.unitName ?? "";

                              selectedUnitModel = ItemUnitModel(
                                itemId: item.itemId ?? 0,
                                unitId: item.unitId ?? 0,
                                unitName: item.unitName ?? "",
                              );

                              selectedTaxType = item.taxIncludeExclude ?? "E";

                              mrpCtrl.text = item.purchaseRate.toString();
                            });

                            _calculateTotal();
                          }
                        }
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  void dispose() {
    _overlayEntry?.remove();
    searchController.dispose();
    qtyCtrl.dispose();
    freeQtyCtrl.dispose();
    rateCtrl.dispose();
    discPerCtrl.dispose();
    discAmtCtrl.dispose();
    hsnCtrl.dispose();
    barcodeCtrl.dispose();
    netTotalCtrl.dispose();

    unitCtrl.dispose();
    mrpCtrl.dispose();
    lastPurchaseDateCtrl.dispose();
    gstCtrl.dispose();
    totalCtrl.dispose();
    super.dispose();
  }

  double _d(TextEditingController c, {double def = 0.0}) =>
      double.tryParse(c.text.trim()) ?? def;

  int _i(TextEditingController c, {int def = 0}) =>
      int.tryParse(c.text.trim()) ?? def;

  String _formatDate(String? apiDate) {
    if (apiDate == null || apiDate.isEmpty) return "";
    if (apiDate.startsWith("0001-01-01")) return "";

    try {
      final dt = DateTime.parse(apiDate);
      return DateFormat("dd-MM-yyyy").format(dt);
    } catch (_) {
      return apiDate;
    }
  }

  void _calculateTotal({String? active}) {
    final qty = _i(qtyCtrl, def: 1);
    final rate = _d(rateCtrl);
    double gst = _d(gstCtrl);

    final taxType = widget.taxType.toUpperCase();

    final isInclusive = taxType == "I";
    final isExclusive = taxType == "E";
    final isNoTax = taxType == "N";

    // 🚫 No Tax means GST = 0
    if (isNoTax) gst = 0;

    double baseRate;
    double baseAmount;

    // ✅ Inclusive: remove GST from rate
    if (isInclusive) {
      baseRate = gst > 0 ? (rate * 100) / (100 + gst) : rate;
      baseAmount = baseRate * qty;
      baseRateCtrl.text = baseRate.toStringAsFixed(2);
    } else {
      baseRate = rate;
      baseAmount = rate * qty;
    }

    // ---------- Discount ----------
    double discTotal = 0;
    totalDiscCtrl.text = discTotal.toStringAsFixed(2);

    final discPer = _d(discPerCtrl);
    final discAmt = _d(discAmtCtrl);

    if (active == "per") {
      final perItem = (baseRate * discPer) / 100;
      discTotal = perItem * qty;
      discAmtCtrl.text = perItem.toStringAsFixed(2);
    } else if (active == "amt") {
      discTotal = discAmt * qty;
      discPerCtrl.text =
      baseRate > 0 ? ((discAmt / baseRate) * 100).toStringAsFixed(2) : "0";
    } else {
      discTotal = ((baseRate * discPer) / 100) * qty;
    }

    final taxable = baseAmount - discTotal;
    final tax = isNoTax ? 0 : (taxable * gst) / 100;

    subtotalCtrl.text = baseAmount.toStringAsFixed(2);
    totalDiscCtrl.text = discTotal.toStringAsFixed(2);
    taxableCtrl.text = taxable.toStringAsFixed(2);
    taxAmtCtrl.text = tax.toStringAsFixed(2);

    // ✅ Total logic
    if (isInclusive) {
      totalCtrl.text = (rate * qty).toStringAsFixed(2);
    } else {
      totalCtrl.text = (taxable + tax).toStringAsFixed(2);
    }

    netTotalCtrl.text = totalCtrl.text;
  }



  void _fillFieldsFromItem(ItemsModel item) {
    // These names must match your model variables
    // (change if your model has different naming)

    hsnCtrl.text = item.hSNCode ?? "";
    unitCtrl.text = item.unitName ?? "";
    selectedUnit = item.unitName ?? "";


    // Prefer LAST_PURCHASERATE if available else LastPurchaseRate
    final rate = item.lASTPURCHASERATE ?? item.lastPurchaseRate ?? 0;
    rateCtrl.text = rate.toString();

    final baseRate = item.lastPurchaseRate ?? 0;
    baseRateCtrl.text = baseRate.toString();
    // MRP
    final mrp = item.lASTMRP ?? item.baseRate ?? 0;
    mrpCtrl.text = mrp.toString();

    // TaxPer is coming as string "5.00"
    final gst = double.tryParse(item.taxPer ?? "0") ?? 0;
    selectedGst = gst;
    gstCtrl.text = gst.toString();
    barcodeCtrl.text = item.barcode ?? ""; // change field name if different


    // Date
    lastPurchaseDateCtrl.text = _formatDate(item.lASTPURCHASEDATE);

    // reset entry fields
    qtyCtrl.text = "1";
    freeQtyCtrl.text = "0";
    discPerCtrl.text = "0";
    discAmtCtrl.text = "0";
    netTotalCtrl.text = totalCtrl.text;

    _calculateTotal();
  }

  Widget _taxTypeDropdown() {
    final types = [
      {"label": "Inclusive", "value": "I"},
      {"label": "Exclusive", "value": "E"},
      {"label": "No Tax", "value": "N"},
    ];

    return DropdownButtonFormField<String>(
        value: selectedTaxType,
        items: types.map((e) {
          return DropdownMenuItem<String>(
            value: e["value"],
            child: Text(e["label"]!),
          );
        }).toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            selectedTaxType = v;
          });

          // 🔥 recalculate with new tax type
          _calculateTotal();
        },
        decoration: InputDecoration(
          labelText: "Tax Type",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
  }

  Widget _gstDropdown() {
    final gstList = [0, 5, 12, 18];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<double>(
        value: selectedGst,
        items: gstList
            .map((e) => DropdownMenuItem<double>(
          value: e.toDouble(),
          child: Text("$e %"),
        ))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            selectedGst = v;
            gstCtrl.text = v.toString();
            _calculateTotal();
          });
        },
        decoration: InputDecoration(
          labelText: "GST %",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ItemViewmodel>(context);
    final unitVM = Provider.of<ItemViewmodel>(context);


    // Safety: if list reloads and selected id not present, reset
    if (selectedItemId != null &&
        !vm.itemList.any((e) => e.itemId == selectedItemId)) {
      selectedItemId = null;
      selectedItem = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// PRODUCT DROPDOWN
              DropdownButtonHideUnderline(
                child: CompositedTransformTarget(
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
                          Text(selectedItem?.itemName ?? "Select Product"),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 14),

              /// BASIC INFO (READ ONLY)
              _row(
                _field("Barcode", barcodeCtrl, null, ro: true, keyboardType: TextInputType.text),
                _field("HSN Code", hsnCtrl, null, ro: true, keyboardType: TextInputType.text),
              ),
              _row(
                _unitDropdown(unitVM),
                _gstDropdown(),
              ),


              const SizedBox(height: 14),

              /// ENTRY FIELDS
              widget.mode == PurchaseMode.purchase
                  ? _row(
                _field("Qty", qtyCtrl, () => _calculateTotal()),
                _field("Free Qty", freeQtyCtrl, null),
              )
                  : _field("Qty", qtyCtrl, () => _calculateTotal()),
              _field("Rate", rateCtrl, () => _calculateTotal()),
              _row(
                _field("Base Rate", baseRateCtrl, null, ro: true),
                _field("Tax Amt", taxAmtCtrl, null,
                    ro: true),
              ),

              const Divider(height: 20, thickness: 1),
              /// Discount
              _row(
                _field("Disc %", discPerCtrl, () => _calculateTotal(active: "per")),
                _field("Disc Amt", discAmtCtrl, () => _calculateTotal(active: "amt")),

              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _field(
                      "Total Disc Amt",
                      totalDiscCtrl,
                      null,
                      ro: true,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ✅ Show TaxType only in Purchase Return
                  if (widget.mode == PurchaseMode.purchaseReturn)
                    Expanded(child: _taxTypeDropdown()),
                ],
              ),


              const Divider(height: 20, thickness: 2),


              _field("Net Total", netTotalCtrl, null, ro: true),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  // ✅ VALIDATION (ADD HERE)
                  if (widget.mode == PurchaseMode.purchase && selectedItem == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select item")),
                    );
                    return;
                  }

                  if (widget.mode == PurchaseMode.purchaseReturn && selectedItemId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select item")),
                    );
                    return;
                  }

                  final qty = _i(qtyCtrl, def: 1).toDouble();
                  final rate = _d(rateCtrl);
                  final gst = _d(gstCtrl);

                  final discPer = _d(discPerCtrl);
                  final discAmt = _d(discAmtCtrl);

                  final base = qty * rate;

                  final discountTotal = discAmt > 0
                      ? discAmt * qty
                      : ((rate * discPer) / 100) * qty;

                  final taxable = base - discountTotal;
                  final taxAmt = (taxable * gst) / 100;
                  final total = taxable + taxAmt;

                  final purchaseInvoiceItem = PurchaseInvoiceItem(
                    unitId: selectedUnitModel?.unitId ?? selectedItem?.unitId ?? 0,
                    itemId: selectedItem?.itemId ?? selectedItemId,   // ✅ FIX
                    productName: selectedItem?.itemName ??
                        returnItems
                            .firstWhere((e) => e.itemId == selectedItemId)
                            .itemName,
                    qty: qty,
                    free: _d(freeQtyCtrl),
                    rate: rate,
                    rateWithGST: rate,

                    discountPerc: discPer,
                    taxPerc: gst,

                    itemTotal: _d(subtotalCtrl),
                    discountAmt: discountTotal,
                    taxableAmt: _d(taxableCtrl),
                    netAmt: _d(totalCtrl),

                    cash: 0,
                    credit: 0,
                    mrp: int.tryParse(mrpCtrl.text) ?? 0,
                    outlet: 0,

                    hsn: hsnCtrl.text,
                    mfgDate: "",

                    schemePerc: 0,
                    schemeAmt: 0,

                    taxAmt: _d(taxAmtCtrl),
                    totalTaxAmt: _d(taxAmtCtrl),

                    taxable: widget.taxType.toLowerCase() != "no tax",

                    taxGroupId: selectedItem?.taxGroupId,

                    originalDiscountAmt: discountTotal,
                    originalItemTotal: _d(subtotalCtrl),
                  );

                  Navigator.pop(context, purchaseInvoiceItem);
                },
                child: const Text(
                  "Add Item",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitDropdown(ItemViewmodel unitVM) {
    if (widget.mode == PurchaseMode.purchaseReturn) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: unitCtrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Unit",
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );
    }

    // ✅ NORMAL PURCHASE FLOW
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: unitVM.loading
          ? const Center(child: CircularProgressIndicator())
          : DropdownButtonFormField<ItemUnitModel>(
        value: unitVM.selectedUnit,
        items: unitVM.unitList.map((u) {
          return DropdownMenuItem<ItemUnitModel>(
            value: u,
            child: Text(u.unitName),
          );
        }).toList(),
        onChanged: (val) {
          if (val == null) return;
          unitVM.setSelectedUnit(val);

          setState(() {
            selectedUnitModel = val;
            unitCtrl.text = val.unitName;
          });
        },
        decoration: InputDecoration(
          labelText: "Unit",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
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

  Widget _field(
      String label,
      TextEditingController c,
      VoidCallback? onChange, {
        bool ro = false,
        TextInputType keyboardType = TextInputType.number,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        readOnly: ro,
        onChanged: (_) => onChange?.call(),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: ro ? Colors.grey.shade200 : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

}
