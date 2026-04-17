import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../model/invoice_item_model.dart';
import '../model/item_sales_details_model.dart';
import '../model/sales_return_item_details_model.dart';
import '../utils/app_strings.dart';


class ItemDetailsPopup extends StatefulWidget {
  final ItemSalesDetailsModel? stock;
  final SalesReturnItemDetailsModel? returnstock;
  final bool isReturn;
  final String productName;
  final String payMode;
  final int taxGrpId;
  final String? taxType;

  const ItemDetailsPopup({
    Key? key,
     this.stock,
    required this.isReturn,
     this.returnstock,
    required this.productName,
    required this.payMode,
    required this.taxGrpId,
     this.taxType,
  }) : super(key: key);

  @override
  _ItemDetailsPopupState createState() => _ItemDetailsPopupState();
}

class _ItemDetailsPopupState extends State<ItemDetailsPopup> {
  late TextEditingController qtyController;
  late TextEditingController rateController;
  late TextEditingController freeQtyController;
  late TextEditingController subtotalController;
  late TextEditingController discPercController;
  late TextEditingController discAmtController;
  late TextEditingController totalDiscController;
  late TextEditingController taxableController;
  late TextEditingController taxPercController;
  late TextEditingController taxAmtController;
  late TextEditingController totalAmtController;

  late String _taxType;

  String get batchNo =>
      widget.isReturn ? (widget.returnstock?.batchNo ?? "") : (widget.stock?.batchNo ?? "");

  String get expDate =>
      widget.isReturn ? (widget.returnstock?.expDate ?? "") : (widget.stock?.expDate ?? "");

  double get taxPer =>
      widget.isReturn ? (widget.returnstock?.taxPer ?? 0) : (widget.stock?.taxPer ?? 0);

  double get rateValue {
    if (widget.isReturn) {
      return widget.returnstock?.rate ?? 0;
    }

    return widget.payMode.toLowerCase() == "cash"
        ? (widget.stock?.cashSalesRate ?? 0)
        : (widget.stock?.creditSalesRate ?? 0);
  }

  double get purchaseRate =>
      widget.isReturn ? (widget.returnstock?.purchaseRate ?? 0) : (widget.stock?.purchaseRate ?? 0);

  int get itemId =>
      widget.isReturn ? (widget.returnstock?.itemId ?? 0) : (widget.stock?.itemId ?? 0);

  int get unitId =>
      widget.isReturn ? (widget.returnstock?.unitId ?? 0) : (widget.stock?.unitId ?? 0);

  int get stkPurchaseId =>
      widget.isReturn ? (widget.returnstock?.stkPurchaseId ?? 0) : (widget.stock?.purchaseId ?? 0);

  double get mrp =>
      widget.isReturn ? (widget.returnstock?.mrp ?? 0) : (widget.stock?.mRP ?? 0);

  double get cashSalesRate =>
      widget.isReturn ? (widget.returnstock?. pflSalesRate?? 0) : (widget.stock?.cashSalesRate ?? 0);

  double get creditSalesRate =>
      widget.isReturn ? (widget.returnstock?. salesRate2?? 0) : (widget.stock?.creditSalesRate ?? 0);

  double get outletSalesRate =>
      widget.isReturn ? (widget.returnstock?. salesRate1?? 0) : (widget.stock?.outletSalesRate ?? 0);

  double get purchaseRateWithTax =>
      widget.isReturn ? (widget.returnstock?. pflPurchaseRate?? 0) : (widget.stock?.purchaseTaxRate ?? 0);

  double get stock =>
      widget.isReturn ? (widget.returnstock?. quantity?? 0) : (widget.stock?.stockQuantity ?? 0);

  double get isNonGst =>
      widget.isReturn ? (widget.returnstock?.taxPer?? 0) : (widget.stock?.taxPer ?? 0);

  String get taxIncludeExclude =>
      (widget.returnstock?.taxIncludeExclude ?? "");

  @override
  void initState() {
    super.initState();

    qtyController = TextEditingController(text: "1");
    // rateController = TextEditingController(text: widget.stock.cashSalesRate?.toString() ?? "0");
    rateController = TextEditingController(
      text: rateValue.toString(),
    );
    subtotalController = TextEditingController();
    freeQtyController = TextEditingController();
    discPercController = TextEditingController(text: "0");
    discAmtController = TextEditingController();
    taxableController = TextEditingController();
    taxPercController = TextEditingController(text: taxPer.toString());
    totalDiscController = TextEditingController();
    taxAmtController = TextEditingController();
    totalAmtController = TextEditingController();


    String taxTypeValue = taxIncludeExclude.toUpperCase();

    if (taxTypeValue == "I") {
      _taxType = "I";
    } else if (taxTypeValue == "N") {
      _taxType = "N";
    } else if (taxTypeValue == "E") {
      _taxType = "E";
    } else {
      _taxType = "-"; // default
    }

    _calculate();
  }

  Widget _buildRowField({
    required String leftLabel,
    required TextEditingController leftController,
    required String rightLabel,
    required TextEditingController rightController,
    bool leftReadOnly = true,
    bool rightReadOnly = false,
    Function(String)? onRightChanged,
  }) {
    return Row(
      children: [
        // 🔹 LEFT SIDE (Non Editable)
        Expanded(
          child: _buildTextField(
            leftLabel,
            controller: leftController,
            readOnly: leftReadOnly,
          ),
        ),

        const SizedBox(width: 12),

        // 🔹 RIGHT SIDE (Editable)
        Expanded(
          child: _buildTextField(
            rightLabel,
            controller: rightController,
            readOnly: rightReadOnly,
            onChanged: onRightChanged,
          ),
        ),
      ],
    );
  }

  void _calculate({String? activeField}) {
    final qtyVal = double.tryParse(qtyController.text) ?? 1;
    final rateVal = double.tryParse(rateController.text) ?? 0;
    final taxPercent = double.tryParse(taxPercController.text) ?? (widget.stock?.taxPer?.toDouble() ?? 0);

    // Map widget.taxType string to the codes used in your React reference
    // "I" = Inclusive, "E" = Exclusive, "N" = No Tax
    String tType = "E";
    if (widget.taxType?.toLowerCase() == "inclusive") tType = "I";
    if (widget.taxType?.toLowerCase() == "no tax") tType = "N";

    // 1. Calculate Base Rate (Logic from React: displayRate)
    double baseRate = rateVal;
    if (tType == "I" && taxPercent > 0) {
      baseRate = double.parse((rateVal / (1 + taxPercent / 100)).toStringAsFixed(2));
    }

    // 2. Calculate Subtotal (Logic from React: baseTotal)
    // For inclusive, subtotal = qty * baseRate without tax.
    double subTotal = double.parse((qtyVal * baseRate).toStringAsFixed(2));

    // 3. Calculate Discount (Logic from React: discountTotal)
    double discountTotal = 0;
    double discPerVal = double.tryParse(discPercController.text) ?? 0;
    double discAmtPerItem = double.tryParse(discAmtController.text) ?? 0;

    if (activeField == "discper") {
      // Discount based on percentage of the baseRate
      discAmtPerItem = double.parse(((baseRate * discPerVal) / 100).toStringAsFixed(2));
      discountTotal = double.parse((discAmtPerItem * qtyVal).toStringAsFixed(2));
      discAmtController.text = discAmtPerItem.toStringAsFixed(2);
    } else if (activeField == "discAmt") {
      discountTotal = double.parse((discAmtPerItem * qtyVal).toStringAsFixed(2));
      double calculatedDiscPer = baseRate > 0 ? (discAmtPerItem / baseRate) * 100 : 0;
      discPercController.text = calculatedDiscPer.toStringAsFixed(2);
    } else {
      discAmtPerItem = double.parse(((baseRate * discPerVal) / 100).toStringAsFixed(2));
      discountTotal = double.parse((discAmtPerItem * qtyVal).toStringAsFixed(2));
      discAmtController.text = discAmtPerItem.toStringAsFixed(2);
    }

    // 4. Calculate Taxable and Tax (Logic from React)
    double taxable = 0;
    double taxAmount = 0;
    double total = 0;
    double netAmount = subTotal - discountTotal;

    if (tType == "E") {
      taxable = double.parse(netAmount.toStringAsFixed(2));
      taxAmount = double.parse(((taxable * taxPercent) / 100).toStringAsFixed(2));
      total = double.parse((taxable + taxAmount).toStringAsFixed(2));
    } else if (tType == "I") {
      total = double.parse((qtyVal * rateVal).toStringAsFixed(2));
      taxable = double.parse(netAmount.toStringAsFixed(2));
      taxAmount = double.parse((total - taxable).toStringAsFixed(2));
    } else {
      taxable = double.parse(netAmount.toStringAsFixed(2));
      taxAmount = 0;
      total = taxable;
    }

    // 5. Update Controllers
    setState(() {
      subtotalController.text = subTotal.toStringAsFixed(2);
      totalDiscController.text = discountTotal.toStringAsFixed(2);
      taxableController.text = taxable.toStringAsFixed(2);
      taxAmtController.text = taxAmount.toStringAsFixed(2);
      totalAmtController.text = total.toStringAsFixed(2);
    });
  }

  String get taxTypeText {
    switch (_taxType) {
      case "I":
        return "Inclusive";
      case "E":
        return "Exclusive";
      case "N":
        return "No Tax";
      default:
        return "Exclusive";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.inventory_2_rounded, color: Colors.black26, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${widget.productName}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                "Batch: ${batchNo}",
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                        "Expiry: ${_formatDate(expDate)}",
                        style: TextStyle(fontSize: 14, color: Colors.grey,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1.2),

                if (widget.isReturn) ...[
                  _buildTextField(
                    Strings.taxType,
                    controller: TextEditingController(text: taxTypeText),
                    readOnly: true,
                  ),
                ],
                // Qty, Free Qty
                _buildRowField(
                  leftLabel: Strings.subTotal,
                  leftController: subtotalController,
                  rightLabel: Strings.qty,
                  rightController: qtyController,
                  rightReadOnly: false,
                  onRightChanged: (_) => _calculate(),
                ),

                _buildRowField(
                  leftLabel: Strings.totalDisc,
                  leftController: totalDiscController,
                  rightLabel: Strings.freeQty,
                  rightController: freeQtyController,
                ),

                _buildRowField(
                  leftLabel: Strings.taxable,
                  leftController: taxableController,
                  rightLabel: Strings.rate,
                  rightController: rateController,
                  onRightChanged: (_) => _calculate(),
                ),

                _buildRowField(
                  leftLabel: Strings.taxPerc,
                  leftController: taxPercController,
                  rightLabel: Strings.discPercent,
                  rightController: discPercController,
                  onRightChanged: (_) => _calculate(activeField: "discper"),
                ),

                _buildRowField(
                  leftLabel: Strings.taxAmt,
                  leftController: taxAmtController,
                  rightLabel: Strings.discAmt,
                  rightController: discAmtController,
                  onRightChanged: (_) => _calculate(activeField: "discAmt"),
                ),


                // Add Button
                Row(
                  children: [

                    // Total Amount (Left Side)
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 28.0, left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Strings.totalAmt,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalAmtController.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Add Button (Right Side)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            final rate = double.tryParse(rateController.text) ?? 0;
                            final qty = double.tryParse(qtyController.text) ?? 0;

                            if (rate <= 0) {
                              Fluttertoast.showToast(
                                msg: Strings.rateCantZero,
                                gravity: ToastGravity.BOTTOM,
                              );
                              return; // ⛔ stop here
                            }

                            if (qty <= 0) {
                              Fluttertoast.showToast(
                                msg: Strings.qtyCantZero,
                                gravity: ToastGravity.BOTTOM,
                              );
                              return; // ⛔ stop here
                            }
                                final invoiceItem = InvoiceItem(
                                  productName: widget.productName,
                                  qty: int.tryParse(qtyController.text) ?? 1,
                                  rate: double.tryParse(rateController.text) ?? rateValue,
                                  subtotal: double.tryParse(subtotalController.text) ?? 0,
                                  discountPerc: double.tryParse(discPercController.text) ?? 0,
                                  discountAmt: double.tryParse(discAmtController.text) ?? 0,
                                  totalDisc: double.tryParse(totalDiscController.text) ?? 0,
                                  taxable: double.tryParse(taxableController.text) ?? 0,
                                  taxPerc: double.tryParse(taxPercController.text) ?? taxPer,
                                  taxAmt: double.tryParse(taxAmtController.text) ?? 0,
                                  totalAmt: double.tryParse(totalAmtController.text) ?? 0,
                                  purchaseRate: purchaseRate,
                                  stock: stock.toInt(),
                                  isNonGST: isNonGst > 0,
                                  returnQty: 0,
                                  itemId: itemId,
                                  unitId: unitId,
                                  firmId:  0,
                                  locationId:  0,
                                  mfgDate: "",
                                  taxPer1: double.tryParse(taxPercController.text) ?? 0,
                                  taxAmt1: double.tryParse(taxAmtController.text) ?? 0,
                                  itemName: widget.productName,
                                  netAmt: double.tryParse(totalAmtController.text) ?? 0,
                                  taxGroupId: widget.taxGrpId,
                                  freeQty: int.tryParse(freeQtyController.text) ?? 0,
                                  purchaseRateWithTax: purchaseRateWithTax,
                                  // cashSalesRate: cashSalesRate,
                                  // creditSalesRate: creditSalesRate,
                                  // outletSalesRate: outletSalesRate,
                                  mrp: mrp,
                                  stkPurchaseId: stkPurchaseId,
                                );

                            Navigator.pop(context, invoiceItem);
                          },
                          child: const Text(
                            Strings.addItem,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
        bool readOnly = false,
        Function(String)? onChanged,
      }) {
    final isEditable = !readOnly;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isEditable ? primary : Colors.grey.shade700,
          ),
          fillColor: isEditable ? Colors.white : Colors.grey.shade200,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isEditable ? Colors.grey.shade400 : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primary, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 6, horizontal: 8),
        ),
        style: TextStyle(
          color: isEditable ? Colors.black : Colors.grey.shade600,
          fontWeight: isEditable ? FontWeight.w500 : FontWeight.w400,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
