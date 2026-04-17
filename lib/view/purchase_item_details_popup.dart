import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/view/purchase_mode.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../model/PurchaseInvoiceItem_model.dart';
import '../model/purchaseItemDetails_model.dart';
import '../utils/app_strings.dart';

class PurchaseItemDetailsPopup extends StatefulWidget {
  final PurchaseItemDetailsModel stock;
  final String productName;
  final PurchaseInvoiceItem? existingItem; // ✅ optional for edit
  final PurchaseMode mode;

  // ✅ ADD THESE
  final String payMode; // "CREDIT" or "CASH"
  final double outstanding; // current outstanding amount
  final double creditLimit; // allowed credit limit
  final String taxType; // "E", "I", "N"

  const PurchaseItemDetailsPopup({
    Key? key,
    required this.stock,
    required this.productName,
    required this.payMode,
    required this.outstanding,
    required this.creditLimit,
    required this.taxType,
    required this.mode, // ✅ ADD

    this.existingItem,
  }) : super(key: key);

  @override
  _PurchaseItemDetailsPopupState createState() =>
      _PurchaseItemDetailsPopupState();
}

class _PurchaseItemDetailsPopupState extends State<PurchaseItemDetailsPopup> {
  bool get isPurchaseReturn => widget.mode == PurchaseMode.purchaseReturn;

  late TextEditingController batchController;
  late TextEditingController gstController;
  late TextEditingController expDtController;
  late TextEditingController qtyController;
  late TextEditingController rateController;
  late TextEditingController rateWithGSTController;
  late TextEditingController schemePercController;
  late TextEditingController schemeAmtController;
  late TextEditingController totalSchemeController;
  late TextEditingController discPercController;
  late TextEditingController discAmtController;
  late TextEditingController totalDiscController;
  late TextEditingController netTotalController;
  late TextEditingController mrpController;
  late TextEditingController cashController;
  late TextEditingController creditController;
  late TextEditingController outletController;
  late TextEditingController freeController;
  late TextEditingController barcodeController;
  late TextEditingController hsnController;
  bool _isAdjustmentExpanded = false;
  final ScrollController _scrollController = ScrollController();
  late TextEditingController taxableAmtController;
  late TextEditingController taxAmtController;

  final List<double> gstOptions = [0, 5, 12, 18];
  double selectedGst = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("✅ Popup Stock Loaded → "
        "TaxGroupId=${widget.stock.taxGroupId}, "
        "TaxPer=${widget.stock.taxPer}");

    final item = widget.existingItem;

    print(
        "Received unitId in initstate of purchase item details popup:${widget.stock.unitId}");
    selectedGst =
        (widget.existingItem?.taxPerc ?? widget.stock.taxPer ?? 0).toDouble();

    gstController = TextEditingController(text: formatNumber(selectedGst));

    batchController = TextEditingController(
      text: item?.batch ?? widget.stock.batchNo ?? "",
    );
    taxAmtController = TextEditingController();

    expDtController = TextEditingController(
      text: _formatDate(item?.expiry ?? widget.stock.expDate),
    );

    barcodeController = TextEditingController(
      text: item?.barcode,
    );
    hsnController = TextEditingController(
      text: widget.existingItem?.hsn ?? widget.stock.hSNCode ?? "",
    );
    qtyController = TextEditingController(text: formatNumber(item?.qty ?? 1));
    rateController = TextEditingController(
      text: formatNumber(item?.rate ?? widget.stock.rate ?? 0),
    );
    rateWithGSTController = TextEditingController(
      text: formatNumber(item?.rateWithGST ?? widget.stock.rateWithTax ?? 0),
    );
    freeController = TextEditingController(
      text: formatNumber(item?.free ?? 0),
    );

    taxableAmtController = TextEditingController();

    schemePercController = TextEditingController(
      text: formatNumber(item?.schemePerc ?? 0),
    );
    schemeAmtController = TextEditingController(
      text: formatNumber(item?.schemeAmt ?? 0),
    );
    totalSchemeController = TextEditingController();

    discPercController = TextEditingController(
      text: formatNumber(item?.discountPerc ?? 0),
    );
    discAmtController = TextEditingController(
      text: formatNumber(item?.discountAmt ?? 0),
    );
    totalDiscController = TextEditingController();

    netTotalController = TextEditingController();

    mrpController = TextEditingController(
      text: formatNumber(item?.mrp ?? widget.stock.mRP ?? 0),
    );

    cashController = TextEditingController(
      text: formatNumber(item?.cash ?? widget.stock.cashSalesRate ?? 0),
    );

    creditController = TextEditingController(
      text: formatNumber(item?.credit ?? widget.stock.creditSalesRate ?? 0),
    );

    outletController = TextEditingController(
      text: formatNumber(item?.outlet ?? widget.stock.outletSalesRate ?? 0),
    );
    debugPrint("💰 New Batch Values → "
        "GST=${widget.stock.taxPer}, "
        "Cash=${widget.stock.cashSalesRate}, "
        "Credit=${widget.stock.creditSalesRate}, "
        "Outlet=${widget.stock.outletSalesRate}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculate();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isAdjustmentExpanded) {
          setState(() {
            _isAdjustmentExpanded = false;
          });
        }
      }
    });
  }

  String formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString(); // remove .0
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _calculate({String? activeField}) {
    final qty = double.tryParse(qtyController.text) ?? 1;
    final gst = double.tryParse(gstController.text) ?? 0;
    double rate = double.tryParse(rateController.text) ?? 0;
    double rateWithGST = double.tryParse(rateWithGSTController.text) ?? 0;
    final freeQty = double.tryParse(freeController.text) ?? 0;

    bool isExclusive = widget.taxType == "E";
    bool isInclusive = widget.taxType == "I" || widget.taxType == "N";

    /// -------- RATE CALCULATION --------

    if (isInclusive) {
      // Inclusive or No Tax → rate and rateWithGST same
      if (activeField == "rateWithGST") {
        rate = rateWithGST;
        rateController.text = formatNumber(rate);
      } else {
        rateWithGST = rate;
        rateWithGSTController.text = formatNumber(rateWithGST);
      }
    } else {
      // Exclusive → remove GST from rateWithGST
      if (activeField == "rateWithGST") {
        rate = rateWithGST / (1 + gst / 100);
        rateController.text = formatNumber(rate);
      }
    }

    // Scheme calculation
    double schemePerc = double.tryParse(schemePercController.text) ?? 0;
    double schemeAmtPerItem = double.tryParse(schemeAmtController.text) ?? 0;

    if (activeField == "schemeAmt") {
      schemePerc = rate == 0 ? 0 : (schemeAmtPerItem / rate) * 100;
      schemePercController.text = formatNumber(schemePerc);
    } else {
      schemeAmtPerItem = rate * schemePerc / 100;
      schemeAmtController.text = formatNumber(schemeAmtPerItem);
    }

    final totalSchemeAmt = schemeAmtPerItem * qty;
    totalSchemeController.text = formatNumber(totalSchemeAmt);

// Discount calculation
    double discPerc = double.tryParse(discPercController.text) ?? 0;
    double discAmtPerItem = double.tryParse(discAmtController.text) ?? 0;

    if (activeField == "discAmt") {
      discPerc = rate == 0 ? 0 : (discAmtPerItem / rate) * 100;
      discPercController.text = formatNumber(discPerc);
    } else {
      discAmtPerItem = rate * discPerc / 100;
      discAmtController.text = formatNumber(discAmtPerItem);
    }

    final totalDiscAmt = discAmtPerItem * qty;
    totalDiscController.text = formatNumber(totalDiscAmt);

    // Taxable & Net Total
    final adjustedRate = rate - schemeAmtPerItem - discAmtPerItem;
    final taxable = (adjustedRate * qty);
    taxableAmtController.text = formatNumber(taxable);
    double taxAmt = taxable * gst / 100;
    taxAmtController.text = formatNumber(taxAmt);

    double netTotal = taxable;

    if (isExclusive) {
      netTotal = taxable + taxAmt;
    }

    netTotalController.text = formatNumber(netTotal);

    // Update With GST if not actively edited
    if (isExclusive && activeField != "rateWithGST") {
      rateWithGSTController.text =
          formatNumber(adjustedRate + adjustedRate * gst / 100);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.itemDetails,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primary,
                      fontSize: 18)),
              const SizedBox(height: 10),

              // Product Info: Name, Batch, Expiry
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(widget.productName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                    Strings.batch,
                    controller: batchController,
                    readOnly: isPurchaseReturn,
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isPurchaseReturn
                          ? null
                          : () async {
                              final now = DateTime.now();

                              final picked = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: now,
                                // ❌ No past dates allowed
                                lastDate: DateTime(2100),

                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primary,
                                        // 🔵 Header background
                                        onPrimary: Colors.white,
                                        // 🔵 Header text color
                                        onSurface:
                                            Colors.black87, // Normal text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              primary, // OK & Cancel button color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (picked != null) {
                                setState(() {
                                  expDtController.text =
                                      DateFormat('dd-MM-yyyy').format(picked);
                                });
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                expDtController.text.isEmpty
                                    ? Strings.expiryLabel
                                    : expDtController.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: expDtController.text.isEmpty
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // GST & Qty
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: isPurchaseReturn
                          ? _buildTextField(
                              "Tax %",
                              controller: gstController,
                              readOnly: true,
                            )
                          : DropdownButtonFormField<double>(
                              value: gstOptions.contains(selectedGst)
                                  ? selectedGst
                                  : null,
                              items: gstOptions
                                  .map((gst) => DropdownMenuItem(
                                        value: gst,
                                        child: Text("${gst.toInt()}%"),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedGst = value ?? 0;
                                  gstController.text = selectedGst.toString();
                                  _calculate();
                                });
                              },
                              decoration: InputDecoration(
                                labelText: Strings.gstLabel,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      Strings.qtyShort,
                      controller: qtyController,
                      onChanged: (_) => _calculate(),
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (isPurchaseReturn)
                _buildTextField(
                  "Tax Type",
                  text: widget.taxType == "E"
                      ? "Exclusive"
                      : widget.taxType == "I"
                          ? "Inclusive"
                          : "No Tax",
                  readOnly: true,
                ),

              SizedBox(height: 10),

              // Rate & With GST
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: _buildTextField(
                        Strings.rate, controller: rateController,
                        onChanged: (_) => _calculate(),
                        isNumber: true, // ✅ IMPORTANT
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 2,
                      child: _buildTextField(
                        Strings.withGst,
                        controller: rateWithGSTController,
                        onChanged: (_) =>
                            _calculate(activeField: "rateWithGST"),
                        isNumber: true,
                      )),
                ],
              ),

              const SizedBox(height: 8),

              /// Taxable Amount Field
              if (!isPurchaseReturn)
                _buildTextField(
                  Strings.taxable,
                  controller: taxableAmtController,
                  readOnly: true,
                ),
              const SizedBox(height: 16),

              /// ================= PURCHASE MODE =================
              if (!isPurchaseReturn) ...[
                /// Adjustment Header
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAdjustmentExpanded = !_isAdjustmentExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          Strings.schemeDiscount,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                        Icon(
                          _isAdjustmentExpanded ? Icons.remove : Icons.add,
                          color: Colors.orange,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                /// Expandable Adjustment Section
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _isAdjustmentExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// FREE
                      const Text(
                        Strings.freeShort,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              Strings.freeQty,
                              controller: freeController,
                              onChanged: (_) => _calculate(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      /// SCHEME
                      const Text(
                        Strings.scheme,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(
                            Strings.percentSymbol,
                            controller: schemePercController,
                            onChanged: (_) =>
                                _calculate(activeField: "schemePerc"),
                          )),
                          const SizedBox(width: 5),
                          Expanded(
                              child: _buildTextField(
                            Strings.amountShort,
                            controller: schemeAmtController,
                            onChanged: (_) =>
                                _calculate(activeField: "schemeAmt"),
                          )),
                          const SizedBox(width: 5),
                          Expanded(
                              child: _buildTextField(
                            Strings.totalShort,
                            controller: totalSchemeController,
                            readOnly: true,
                          )),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /// DISCOUNT
                      const Text(
                        Strings.discount,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField(
                            Strings.percentSymbol,
                            controller: discPercController,
                            onChanged: (_) =>
                                _calculate(activeField: "discPerc"),
                          )),
                          const SizedBox(width: 5),
                          Expanded(
                              child: _buildTextField(
                            Strings.amountShort,
                            controller: discAmtController,
                            onChanged: (_) =>
                                _calculate(activeField: "discAmt"),
                          )),
                          const SizedBox(width: 5),
                          Expanded(
                              child: _buildTextField(
                            Strings.totalLabel,
                            controller: totalDiscController,
                            readOnly: true,
                          )),
                        ],
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                  secondChild: const SizedBox(),
                ),
              ],

              /// ================= PURCHASE RETURN MODE =================
              if (isPurchaseReturn) ...[
                /// DISCOUNT (Always visible in Return)
                const Text(
                  Strings.discount,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                      fontSize: 13),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                      Strings.percentSymbol,
                      controller: discPercController,
                      onChanged: (_) => _calculate(activeField: "discPerc"),
                    )),
                    const SizedBox(width: 5),
                    Expanded(
                        child: _buildTextField(
                      Strings.amountShort,
                      controller: discAmtController,
                      onChanged: (_) => _calculate(activeField: "discAmt"),
                    )),
                    const SizedBox(width: 5),
                    Expanded(
                        child: _buildTextField(
                      Strings.totalLabel,
                      controller: totalDiscController,
                      readOnly: true,
                    )),
                  ],
                ),

                const SizedBox(height: 12),
              ],

              SizedBox(height: 10),

              Text(
                Strings.totalLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              if (isPurchaseReturn)
                _buildTextField(
                  "Tax Amount",
                  controller: taxAmtController,
                  readOnly: true,
                ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: () {
                  if (_isAdjustmentExpanded) {
                    setState(() {
                      _isAdjustmentExpanded = false;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                    Strings.netTotal,
                    controller: netTotalController,
                    readOnly: true,
                  ),
                ),
              ),

              SizedBox(height: 3),

              if (!isPurchaseReturn) ...[
                const Text(
                  Strings.setBarcode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.lightGreen,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        Strings.barcode,
                        controller: barcodeController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],

              // Sales Rate Section
              if (!isPurchaseReturn) ...[
                const Text(
                  Strings.salesRate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        Strings.mrp,
                        controller: mrpController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        Strings.payModeCash,
                        controller: cashController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        Strings.payModeCredit,
                        controller: creditController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        Strings.outlet,
                        controller: outletController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Add / Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    elevation: 6,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                  ),
                  onPressed: () {
                    final qty = double.tryParse(qtyController.text) ?? 1;
                    final rate = double.tryParse(rateController.text) ?? 0;
                    final gst = double.tryParse(gstController.text) ?? 0;
                    final discPerc =
                        double.tryParse(discPercController.text) ?? 0;
                    final discAmt =
                        double.tryParse(discAmtController.text) ?? 0;
                    final schemePerc =
                        double.tryParse(schemePercController.text) ?? 0;
                    final schemeAmt =
                        double.tryParse(schemeAmtController.text) ?? 0;
                    final freeQty = double.tryParse(freeController.text) ?? 0;
                    final itemTotal = rate * qty;
                    final schemePerItem = schemeAmt; // already per item
                    final discPerItem = discAmt;
                    final totalScheme = schemePerItem * qty;
                    final totalDiscount = discPerItem * qty;
                    final taxableAmt = itemTotal - totalScheme - totalDiscount;

                    final taxAmt = taxableAmt * gst / 100;

// NET
                    final netTotal = taxableAmt + taxAmt;

                    final totalAmt =
                        double.tryParse(netTotalController.text) ?? 0;

                    if (widget.payMode == "CREDIT" &&
                        (widget.outstanding + totalAmt) > widget.creditLimit) {
                      _showError(Strings.creditLimitExceededMsg(widget.creditLimit));
                      return;
                    }

                    final batch = batchController.text.trim();
                    final expiry = expDtController.text.trim();

// 🚨 VALIDATIONS
                    if (batch.isEmpty) {
                      _showError("Batch is required");
                      return;
                    }

                    if (expiry.isEmpty) {
                      _showError("Expiry date is required");
                      return;
                    }

                    if (qty <= 0) {
                      _showError("Quantity must be greater than 0");
                      return;
                    }

                    if (rate <= 0) {
                      _showError("Rate must be greater than 0");
                      return;
                    }

                    print(
                        "unitId from purchase item details popup: ${widget.stock.unitId}");

                    final purchaseInvoiceItem = PurchaseInvoiceItem(
                      itemId: widget.stock.itemId ?? 0,
                      productName: widget.productName,
                      batch: batchController.text,
                      expiry: expDtController.text,

                      qty: qty,
                      rate: rate,
                      itemTotal: itemTotal,

                      mfgDate: "",

                      discountPerc: discPerc,
                      discountAmt: discAmt,

                      schemePerc: schemePerc,
                      schemeAmt: schemeAmt.toDouble(),

                      // ✅ VERY IMPORTANT FIX
                      taxGroupId: widget.stock.taxGroupId ?? 0,
                      taxPerc: selectedGst,

                      taxable: (widget.stock.taxPer ?? 0) > 0,
                      taxableAmt: taxableAmt,
                      taxAmt: taxAmt,
                      totalTaxAmt: taxAmt.toDouble(),

                      netAmt: netTotal,

                      unitId: widget.stock.unitId ?? 0,

                      cash: int.tryParse(cashController.text) ?? 0,
                      credit: int.tryParse(creditController.text) ?? 0,
                      mrp: int.tryParse(mrpController.text) ?? 0,
                      outlet: int.tryParse(outletController.text) ?? 0,
                      free: freeQty,

                      hsn: hsnController.text,
                      barcode: barcodeController.text,
                      rateWithGST:
                          double.tryParse(rateWithGSTController.text) ?? 0,
                      // ✅ ADD THESE 2 LINES (THIS FIXES YOUR ERROR)
                      // ✅ FINAL FIX
                      originalDiscountAmt:
                          widget.existingItem?.originalDiscountAmt ?? discAmt,
                      originalItemTotal:
                          widget.existingItem?.originalItemTotal ?? itemTotal,
                    );

                    debugPrint("✅ Product=${widget.productName}, "
                        "TaxGroupId=${widget.stock.taxGroupId}, "
                        "TaxPer=${widget.stock.taxPer}");

                    Navigator.pop(context, purchaseInvoiceItem);
                    debugPrint(
                        "🧪 Stock TaxGroupId = ${widget.stock.taxGroupId}, TaxPer = ${widget.stock.taxPer}");
                  },
                  icon: const Icon(Icons.shopping_cart,
                      color: Colors.white, size: 22),
                  label: const Text(Strings.addItem,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER, // 🔥 or TOP
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14,
    );

  }


  String _formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  Widget _buildTextField(
    String label, {
    TextEditingController? controller,
    String? text,
    bool readOnly = false,
    Function(String)? onChanged,
    bool isNumber = false, // ✅ ADD THIS
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller ?? TextEditingController(text: text ?? ""),
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: onChanged,
        // keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}
