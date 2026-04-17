// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_soulconnect/view/send_msg_dialog.dart';
//
// import 'package:provider/provider.dart';
//
// import '../model/add_sale_model.dart';
// import '../model/invoice_item_model.dart';
// import '../viewModel/login_viewmodel.dart';
// import '../viewModel/sales_invoice_viewmodel.dart';
// import '../viewmodel/add_sale_view_model.dart';
// import 'homeScreen.dart';
//
// class ConfirmCreditSalePopup extends StatefulWidget {
//   // final bool isEdit;
//   final double totalAmount;
//   final double totalQty;
//   final double itemTotal;
//   final double discountPercent;
//   final double discountAmt;
//   final double totalDiscAmt;
//   final double taxableAmt;
//   final double taxAmt;
//   final double totalAmt;
//   final double freight;
//   final double roundOff;
//   final double netBillTotal;
//   final double netBillAmt;
//   final double freeQty;
//   final List<InvoiceItem> items;
//   final List<Map<String, dynamic>> otherCharges;
//   final int customerId;
//   final String customerName;
//   final String address;
//   final String contact;
//   final String byHand;
//   final String billType;
//   final String rateType;
//   final String salesType;
//   final String locationId;
//   final double invoiceChargesAmt;
//   final int salesId;
//   final String payMode;
//   final String salesDate;
//
//   const ConfirmCreditSalePopup({
//     super.key,
//     // required this.isEdit,
//     required this.totalAmount,
//     required this.totalQty,
//     required this.itemTotal,
//     required this.discountPercent,
//     required this.discountAmt,
//     required this.taxableAmt,
//     required this.taxAmt,
//     required this.totalAmt,
//     required this.freight,
//     required this.roundOff,
//     required this.netBillTotal,
//     required this.netBillAmt,
//     required this.freeQty,
//     required this.items,
//     required this.otherCharges,
//     required this.customerId,
//     required this.customerName,
//     required this.address,
//     required this.invoiceChargesAmt,
//     required this.byHand,
//     required this.billType,
//     required this.salesType,
//     required this.rateType,
//     required this.locationId,
//     required this.contact,
//     required this.totalDiscAmt,
//     required this.salesId,
//     required this.payMode,
//     required this.salesDate
//   });
//
//   @override
//   State<ConfirmCreditSalePopup> createState() =>
//       _ConfirmCreditSalePopupState();
// }
//
// class _ConfirmCreditSalePopupState extends State<ConfirmCreditSalePopup> {
//   final TextEditingController paymentTermController = TextEditingController();
//   List<SalesOtherCharge> salesOtherCharges = [];
//
//
//   Future<void> _addSaleAPI(BuildContext context) async {
//     final paymentTerm = int.tryParse(paymentTermController.text.trim()) ?? 0;
//
//
//     final loginVM = Provider.of<LoginViewModel>(context, listen: false);
//     final userIdString = loginVM.userId;
//     final userId = int.tryParse(userIdString ?? '0') ?? 0;
//     // final paymentTerm = paymentTermController.text.trim();
//
//     try {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(child: CircularProgressIndicator()),
//       );
//
//       final viewModel = Provider.of<AddSaleViewModel>(context, listen: false);
//
//       List<SalesDetail> salesDetails = widget.items.asMap().entries.map((entry) {
//         final item = entry.value;
//
//         return SalesDetail(
//           itemId: item.itemId,
//           unitId: item.unitId,
//           itemName: item.itemName,
//           barcode: "",
//           // batchNo: item.batchNo,
//           // expDate: item.expiry,
//           quantity: item.qty.toDouble(),
//           rate: item.rate,
//           freeQuantity: item.freeQty.toDouble(),
//           itemTotal: item.subtotal,
//           discPer: item.discountPerc.toString(),
//           discAmt: item.discountAmt,
//           totalDiscount: item.totalDisc,
//           taxableAmt: item.taxable,
//           taxPer: item.taxPerc,
//           taxPer1: item.taxPer1,
//           taxAmt1: item.taxAmt1,
//           taxPer2: item.taxPer2,
//           taxAmt2: item.taxAmt2,
//           taxPer3: "0.00",
//           taxAmt3: "0.00",
//           taxPer4: "0.00",
//           taxAmt4: "0.00",
//           taxPer5: "0.00",
//           taxAmt5: "0.00",
//           taxGroupId: item.taxGroupId,
//           purchaseRate: item.purchaseRate,
//           purchaseRateWithTax: item.purchaseRate * 1.05, // example calc
//           // cashSalesRate: item.rate,
//           // creditSalesRate: item.rate + 100,
//           // outletSalesRate: item.rate - 100,
//           mrp: item.rate + 500,
//           stkPurchaseId: 0,
//           totalTaxAmt: item.taxAmt,
//           netAmt: item.netAmt,
//           // pflPurchaseRate: item.cashSalesRate,
//           usedAs: "N/A",
//           isWithoutGST: item.isNonGST,
//           returnQty: item.returnQty.toString(),
//           action: "",
//         );
//       }).toList();
//       // List<SalesDetail> salesDetails = widget.items.map((item) {
//       //   return SalesDetail(
//       //     itemId: item.itemId,
//       //     unitId: item.unitId,
//       //     itemName: item.itemName,
//       //     quantity: item.qty.toDouble(),
//       //     rate: item.rate,
//       //     itemTotal: item.subtotal,
//       //     discPer: item.discountPerc,
//       //     discAmt: item.discountAmt,
//       //     totalDiscount: item.totalDisc,
//       //     taxableAmt: item.taxable,
//       //     taxPer: item.taxPerc,
//       //     taxPer1: item.taxPer1,
//       //     taxAmt1: item.taxAmt1,
//       //     taxPer2: 0.0,
//       //     taxAmt2: 0.0,
//       //     totalTaxAmt: 0.0,
//       //     netAmt: item.netAmt,
//       //   );
//       // }).toList();
//
//       // Convert other charges
//       List<SalesOtherCharge> otherCharges = salesOtherCharges;
//
//       // Create AddSaleModel instance
//       final addSale = AddSaleModel(
//         salesID: widget.salesId,
//         // salesID: widget.isEdit ? widget.salesId : 0,
//         salesBillNo: "",
//         salesDate: widget.salesDate,
//         customerId: widget.customerId,
//         totalQty: widget.totalQty,
//         itemTotal: widget.itemTotal,
//         locationId: int.tryParse(widget.locationId) ?? 0,
//         userID: userId,
//         billType: widget.billType,
//         rateType: widget.rateType,
//         salesType: widget.payMode,
//         paymentTerm: paymentTerm,
//         cropType: "",
//         freeQty: widget.freeQty,
//         subTotal: widget.itemTotal,
//         discPer: widget.discountPercent,
//         discAmt: widget.discountAmt,
//         totalDiscAmt: widget.totalDiscAmt,
//         totalAmt: widget.totalAmt,
//         freight: widget.freight,
//         taxableAmt: widget.taxableAmt,
//         totalTaxAmt: widget.taxAmt,
//         totalTaxableAmt: widget.taxableAmt,
//         invoiceChargesAmt: widget.invoiceChargesAmt,
//         billTotal: widget.totalAmt + widget.freight,
//         roundOff: widget.roundOff,
//         netBillTotal: widget.netBillTotal,
//         netAmt: widget.netBillAmt,
//         netBillAmt: widget.netBillAmt,
//         narration: "",
//         byHand: widget.byHand,
//         vehicleDetails: "",
//         isBillReceived: 0,
//         bankLedgerId: 0,
//         isChallanInvoice: false,
//         isQuotationInvoice: false,
//         isWalkinCustomer: false,
//         customerName: widget.customerName,
//         address: widget.address,
//         age: 0,
//         cashPaidAmount: 0,
//         bankPaidAmount: 0,
//         modeOfBankPayment: "",
//         customerOutstanding: 0,
//         isSalesReturned: false,
//         misc1: "",
//         misc2: "",
//         misc3: "",
//         misc4: "",
//         misc5: "",
//         preparedBy: 0,
//         checkedBy: 0,
//         createdBy: 1,
//         updatedBy: 1,
//         phoneNumber: widget.contact,
//         salesDetails: salesDetails,
//         salesOtherCharges: otherCharges,
//       );
//
//
//       final requestBody = addSale.toJson();
//       debugPrint("=========== ADD PURCHASE REQUEST ===========");
//       debugPrint(const JsonEncoder.withIndent('  ').convert(requestBody));
//       debugPrint("============================================");
//
//       print("Add Sale Request: ${jsonEncode(requestBody)}");
//
//       // 🔹 Call API
//       // final salesId = await viewModel.addSale(context, requestBody);
//       int? salesId;
//
//       // if (widget.isEdit) {
//       //   print("✏️ Calling UPDATE Sales Return API");
//       //   salesId = await viewModel.updateSale(
//       //       context, requestBody);
//       // } else
//       {
//         print("➕ Calling ADD Sales Return API");
//         salesId = await viewModel.addSale(
//             context, requestBody);
//       }
//       final salesVM =
//       Provider.of<SalesInvoiceViewmodel>(context, listen: false);
//       salesVM.clearBillDetails();
//       salesVM.clearCustomerDetails();
//       Navigator.pop(context); // hide loader
//
//       if (salesId != null && salesId > 0) {
//         // Show success snackbar
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Sale added successfully!"),
//             backgroundColor: Colors.green,
//           ),
//         );
//
//         // Open SMS Dialog
//         await showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => SendBillMessageDialog(salesId: salesId??0),
//         );
//
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const HomeScreen(initialIndex: 0),
//           ),
//               (route) => false,
//         );
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Something went wrong: $e"),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }
//   // Future<void> _addSaleAPI(BuildContext context) async {
//   //   final paymentTerm = paymentTermController.text.trim();
//   //
//   //   // 🔹 Validation
//   //   if (paymentTerm.isEmpty) {
//   //     // Show error message
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text("Please enter Payment Term"),
//   //         backgroundColor: Colors.redAccent, // optional: red color
//   //       ),
//   //     );
//   //     return; // stop further execution
//   //   }
//   //
//   //   try {
//   //     // Show loading
//   //     showDialog(
//   //       context: context,
//   //       barrierDismissible: false,
//   //       builder: (_) => const Center(child: CircularProgressIndicator()),
//   //     );
//   //
//   //     final viewModel = Provider.of<AddSaleViewModel>(context, listen: false);
//   //
//   //     // Prepare request body
//   //     final requestBody = {
//   //       "SalesID": 0,
//   //       "SalesBillNo": "",
//   //       "SalesDate": DateTime.now().toIso8601String(),
//   //       "CustomerId": widget.customerId,
//   //       "TotalQty": widget.totalQty,
//   //       "ItemTotal": widget.itemTotal,
//   //       "LocationId": widget.locationId,
//   //       "UserID": 1,
//   //       "BillType": widget.billType,
//   //       "RateType": widget.rateType,
//   //       "SalesType": widget.salesType,
//   //       "PaymentTerm": paymentTerm,
//   //       "CropType": "",
//   //       "FreeQty": widget.freeQty,
//   //       "SubTotal": widget.itemTotal,
//   //       "DiscPer": widget.discountPercent,
//   //       "DiscAmt": widget.discountAmt,
//   //       "TotalDiscAmt": widget.totalDiscAmt,
//   //       "TotalAmt": widget.totalAmt,
//   //       "Freight": widget.freight,
//   //       "TaxableAmt": widget.taxableAmt,
//   //       "TotalTaxAmt": widget.taxAmt,
//   //       "InvoiceChargesAmt": widget.invoiceChargesAmt,
//   //       "BillTotal": widget.totalAmt + widget.freight,
//   //       "RoundOff": widget.roundOff,
//   //       "NetBillTotal": widget.netBillTotal,
//   //       "NetAmt": widget.netBillAmt,
//   //       "Narration": "",
//   //       "ByHand": widget.byHand,
//   //       "IsChallanInvoice": true,
//   //       "IsQuotationInvoice": true,
//   //       "CustomerName": widget.customerName,
//   //       "Address": widget.address,
//   //       "PhoneNumber": widget.contact,
//   //       "SalesDetails": widget.items.map((item) => item.toJson()).toList(),
//   //       "SalesOtherCharges": widget.otherCharges.map((charge) => {
//   //         "LedgerId": charge["ledgerId"] ?? 0,
//   //         "SalesId": 0,
//   //         "SalesOtherChargeId": 0,
//   //         "Amount": charge["charge"] ?? 0.0,
//   //         "LedgerName": charge["ledger"] ?? "",
//   //       }).toList(),
//   //     };
//   //
//   //     print("🔹 Add Sale Request: ${jsonEncode(requestBody)}");
//   //     await viewModel.addSale(context, requestBody);
//   //
//   //
//   //     // Navigator.pop(context); // Hide loader
//   //
//   //     // If success
//   //     Navigator.pushReplacementNamed(context, RouteNames.salesDashboard);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text("Sale added successfully!")),
//   //     );
//   //
//   //   } catch (e) {
//   //     Navigator.pop(context); // hide loader
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text("Something went wrong: $e")),
//   //     );
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//       child: Container(
//         width: 400, // fixed width for desktop/tablet look
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.white,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 Title Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Confirm Credit Sale",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.black54),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//
//             // 🔹 Label
//             const Text(
//               "Enter PayTerm For Credit Card",
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 8),
//
//             // 🔹 Input Field
//             TextField(
//               controller: paymentTermController,
//               decoration: InputDecoration(
//                 hintText: "Payment Term",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // 🔹 Buttons Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 // Add Sale
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade600,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 10),
//                   ),
//                   onPressed: () => _addSaleAPI(context),
//                   child: Text("Save Invoice", style: TextStyle(color: Colors.white),),
//                   // child: Text(widget.isEdit ? "Edit Invoice" : "Save Invoice"),
//
//                 ),
//                 const SizedBox(width: 10),
//
//                 // Save & Print
//                 // ElevatedButton(
//                 //   style: ElevatedButton.styleFrom(
//                 //     backgroundColor: Colors.green.shade400,
//                 //     shape: RoundedRectangleBorder(
//                 //       borderRadius: BorderRadius.circular(6),
//                 //     ),
//                 //     padding: const EdgeInsets.symmetric(
//                 //         horizontal: 20, vertical: 10),
//                 //   ),
//                 //   onPressed: () {
//                 //     Navigator.pop(context, {
//                 //       "action": "save_print",
//                 //       "term": paymentTermController.text.trim(),
//                 //     });
//                 //   },
//                 //   child: const Text(
//                 //     "Save & Print",
//                 //     style: TextStyle(color: Colors.white),
//                 //   ),
//                 // ),
//                 const SizedBox(width: 10),
//
//                 // Cancel
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey.shade900,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 10),
//                   ),
//                   onPressed: () => Navigator.pop(context, {"action": "cancel"}),
//                   child: const Text(
//                     "Cancel",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
