import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../model/purchase_itemwise_report_request.dart';
import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewModel/purchase_report_viewmodel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;



class PurchaseStatementReport extends StatefulWidget {
  const PurchaseStatementReport({Key? key}) : super(key: key);

  @override
  State<PurchaseStatementReport> createState() =>
      _PurchaseStatementReportScreenState();
}

class _PurchaseStatementReportScreenState extends State<PurchaseStatementReport> {
  String? selectedLocation;
  DateTimeRange? selectedDateRange;
  bool _isExpanded = false;
  int? selectedLocationId;
  String? selectedLocationName;


  bool _isInit = true; // 👈 To prevent multiple API calls

  @override
  void initState() {
    super.initState();

    // 🔹 Set default date range to today's date
    final today = DateTime.now();
    selectedDateRange = DateTimeRange(start: today, end: today);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      // ✅ Safe to call Provider here
      final itemVM = Provider.of<ItemViewmodel>(context, listen: false);
      itemVM.getStockLocationsApi(); // Call your API safely here

      // Fetch initial report for today after locations load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchReport();
      });

      _isInit = false;
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() => selectedDateRange = picked);

      // 🔹 Auto-fetch report when user selects new date range
      _fetchReport();
    }
  }



  void _fetchReport() {
    if (selectedDateRange == null) return;

    final request = PurchaseItemwiseReportRequest(
      fromDate: DateFormat('yyyy-MM-dd') // ✅ FIXED
          .format(selectedDateRange!.start),
      toDate: DateFormat('yyyy-MM-dd') // ✅ FIXED
          .format(selectedDateRange!.end),
      userId: 1,
      locationId: selectedLocationId,
    );

    context.read<PurchaseReportViewModel>().fetchReportStmtReport(request);
  }


  Future<void> _generateAndSavePurchasePDF() async {
    final pdf = pw.Document();
    final viewModel = context.read<PurchaseReportViewModel>();
    final purchaseItems = viewModel.reportList;

    if (purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data available to export")),
      );
      return;
    }

    final fromDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Purchase Statement Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From Date: $fromDate'),
                  pw.Text('To Date: $toDate'),
                  if (selectedLocationName != null)
                    pw.Text('Location: $selectedLocationName'),
                ],
              ),
              pw.Text(
                'Total Records: ${purchaseItems.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.Table.fromTextArray(
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: pw.TextStyle(fontSize: 9),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.5),
              6: const pw.FlexColumnWidth(1.5),
              7: const pw.FlexColumnWidth(1.5),
              8: const pw.FlexColumnWidth(1.5),
              9: const pw.FlexColumnWidth(1.5),
              10: const pw.FlexColumnWidth(1.5),
              11: const pw.FlexColumnWidth(1.5),
            },
            headers: [
              "Bill No",
              "Supplier",
              "Date",
              "Qty",
              "Free Qty",
              "Subtotal",
              "Taxable Amt",
              "Tax Amt",
              "Postage",
              "Roundoff",
              "Disc",
              "Net Amt",
            ],
            data: purchaseItems.map((item) {
              return [
                item['SupplierBillNo'] ?? '',
                item['SupplierName'] ?? '',
                item['PurchaseDate'] ?? '',
                item['TotalQty']?.toString() ?? '',
                item['FreeQty']?.toString() ?? '',
                item['SubTotal']?.toString() ?? '',
                item['TaxableAmt']?.toString() ?? '',
                item['TotalTaxAmt']?.toString() ?? '',
                item['OtherCharges']?.toString() ?? '',
                item['RoundOff']?.toString() ?? '',
                item['GrossBillDiscountAmt']?.toString() ?? '',
                item['NetAmt']?.toString() ?? '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 15),

          // 🔹 Optional Summary Row
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}",
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    // 🔹 Save to device
    final output = await getApplicationDocumentsDirectory();
    final file = File(
      "${output.path}/Purchase_Statement_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // ✅ Open file after saving
    await OpenFile.open(file.path);
  }

  Future<void> _printPurchasePDF() async {
    final pdf = pw.Document();
    final viewModel = context.read<PurchaseReportViewModel>();
    final purchaseItems = viewModel.reportList;

    if (purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data available to print")),
      );
      return;
    }

    final fromDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Purchase Statement Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From Date: $fromDate'),
                  pw.Text('To Date: $toDate'),
                  if (selectedLocationName != null)
                    pw.Text('Location: $selectedLocationName'),
                ],
              ),
              pw.Text(
                'Total Records: ${purchaseItems.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.Table.fromTextArray(
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: pw.TextStyle(fontSize: 9),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.5),
              6: const pw.FlexColumnWidth(1.5),
              7: const pw.FlexColumnWidth(1.5),
              8: const pw.FlexColumnWidth(1.5),
              9: const pw.FlexColumnWidth(1.5),
              10: const pw.FlexColumnWidth(1.5),
              11: const pw.FlexColumnWidth(1.5),
            },
            headers: [
              "Bill No",
              "Supplier",
              "Date",
              "Qty",
              "Free Qty",
              "Subtotal",
              "Taxable Amt",
              "Tax Amt",
              "Postage",
              "Roundoff",
              "Disc",
              "Net Amt",
            ],
            data: purchaseItems.map((item) {
              return [
                item['SupplierBillNo'] ?? '',
                item['SupplierName'] ?? '',
                item['PurchaseDate'] ?? '',
                item['TotalQty']?.toString() ?? '',
                item['FreeQty']?.toString() ?? '',
                item['SubTotal']?.toString() ?? '',
                item['TaxableAmt']?.toString() ?? '',
                item['TotalTaxAmt']?.toString() ?? '',
                item['OtherCharges']?.toString() ?? '',
                item['RoundOff']?.toString() ?? '',
                item['GrossBillDiscountAmt']?.toString() ?? '',
                item['NetAmt']?.toString() ?? '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 15),
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}",
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    // 🔹 Directly show native print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final itemVM = Provider.of<ItemViewmodel>(context);
    final locations = itemVM.stockLocationsList; // ✅ fetched from ViewModel

    final dateRangeText =
        '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} → ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';

    return Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text("Purchase Statement",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: _generateAndSavePurchasePDF,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white)),
          IconButton(
              onPressed: _printPurchasePDF,
              icon: const Icon(Icons.print, color: Colors.white)),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
          child: Consumer<PurchaseReportViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(child: Text("Error: ${viewModel.error}"));
              }

              final purchaseItems = viewModel.reportList;

              double totalQty = 0;
              double totalFreeQty = 0;
              double totalSubTotal = 0;
              double totalTaxable = 0;
              double totalTax = 0;
              double totalPostage = 0;
              double totalRoundOff = 0;
              double totalDisc = 0;
              double totalNet = 0;

              for (var item in purchaseItems) {
                totalQty += (item['TotalQty'] ?? 0).toDouble();
                totalFreeQty += (item['FreeQty'] ?? 0).toDouble();
                totalSubTotal += (item['SubTotal'] ?? 0).toDouble();
                totalTaxable += (item['TaxableAmt'] ?? 0).toDouble();
                totalTax += (item['TotalTaxAmt'] ?? 0).toDouble();
                totalPostage += (item['OtherCharges'] ?? 0).toDouble();
                totalRoundOff += (item['RoundOff'] ?? 0).toDouble();
                totalDisc += (item['GrossBillDiscountAmt'] ?? 0).toDouble();
                totalNet += (item['NetAmt'] ?? 0).toDouble();
              }

              return Column(
                children: [
                  // 🔹 Filter Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            value: selectedLocationId,
                            hint: const Text('Select Location'),
                            decoration: InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: locations
                                .map((loc) => DropdownMenuItem<int>(
                              value: loc.locationId,
                              child: Text(loc.locationName!),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedLocationId = val;
                                selectedLocationName = locations
                                    .firstWhere((loc) => loc.locationId == val).locationName;
                              });
                              _fetchReport(); // 🔹 Fetch report again when location changes
                            },
                          ),
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: _pickDateRange,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date Range',
                                prefixIcon:
                                    Icon(Icons.date_range, color: primary),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(dateRangeText),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 🔹 Data Table
                  Expanded(
                    child: purchaseItems.isEmpty
                        ? const Center(child: Text('No data available'))
                        : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: purchaseItems.length,
                            itemBuilder: (context, index) {
                              final item = purchaseItems[index];
                              return ReportCard(
                                title: item['SupplierName'],
                                data: item,
                                dateKey: 'PurchaseDate',
                                dateLabel: 'Purchase Date',
                                fields: const {
                                  "Bill No": "SupplierBillNo",
                                  "Qty": "TotalQty",
                                  "Free Qty": "FreeQty",
                                  "Subtotal": "SubTotal",
                                  "Taxable": "TaxableAmt",
                                  "Tax": "TotalTaxAmt",
                                  "Postage": "OtherCharges",
                                  "Roundoff": "RoundOff",
                                  "Disc": "GrossBillDiscountAmt",
                                  "Net Amt": "NetAmt",

                                },
                                accentColor: primary,
                              );
                            },
                          ),
                        ),

                        // 🔥 TOTALS SECTION
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primary.withOpacity(0.08), Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Totals Summary",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: primary,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isExpanded = !_isExpanded;
                                      });
                                    },
                                    child: Icon(
                                      _isExpanded ? Icons.remove : Icons.add,
                                      color: primary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              if (_isExpanded) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _summaryChip("Qty", totalQty),
                                    _summaryChip("Free", totalFreeQty),
                                    _summaryChip("SubTotal", totalSubTotal),
                                    _summaryChip("Taxable", totalTaxable),
                                    _summaryChip("Tax", totalTax),
                                    _summaryChip("Postage", totalPostage),
                                    _summaryChip("Round Off", totalRoundOff),
                                    _summaryChip("Disc", totalDisc),
                                  ],
                                ),
                              ],

                              SizedBox(height: _isExpanded ? 12 : 6),
                              const Divider(),

                              // 🔥 Highlight Net Amount
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Net Amount",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "₹ ${totalNet.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _summaryChip(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
