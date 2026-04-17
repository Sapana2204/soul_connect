import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../model/sales_itemwise_report_request.dart';
import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../viewModel/login_viewmodel.dart';
import '../viewModel/sales_report_view_model.dart';


class SalesItemwiseReportScreen extends StatefulWidget {
  const SalesItemwiseReportScreen({Key? key}) : super(key: key);

  @override
  State<SalesItemwiseReportScreen> createState() =>
      _SalesItemwiseReportScreenState();
}

class _SalesItemwiseReportScreenState extends State<SalesItemwiseReportScreen> {
  String? selectedLocation;
  DateTimeRange? selectedDateRange;

  int? selectedLocationId;
  String? selectedLocationName;

  bool _showTotals = false;
  bool _isInit = true; // To prevent multiple API calls

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
      final itemVM = Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);
      itemVM.getStockLocationsByUserApi(); // Call your API safely here

      // Fetch initial report for today after locations load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchReport();
      });

      _isInit = false;
    }
  }

  Future<void> _generateAndSavePDF() async {
    final pdf = pw.Document();
    final viewModel = context.read<SalesReportViewModel>();
    final salesItems = viewModel.reportList;

    if (salesItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    final fromDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          // 🔹 Header
          pw.Center(
            child: pw.Text(
              'Sales Itemwise Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 15),

          // 🔹 Date Range and Total Records
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From Date: $fromDate'),
                  pw.Text('To Date: $toDate'),
                ],
              ),
              pw.Text(
                'Total Records: ${salesItems.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),

          // 🔹 Data Table
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.center,
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(1),
              5: pw.FlexColumnWidth(1.5),
              6: pw.FlexColumnWidth(1.5),
              7: pw.FlexColumnWidth(1.5),
              8: pw.FlexColumnWidth(1.5),
              9: pw.FlexColumnWidth(1.5),
            },
            headers: [
              "Item Name",
              // "Batch",
              // "Exp Dt",
              "Qty",
              "Rate",
              "Disc",
              "Sch Amt",
              "Taxable",
              // "Tax Amt",
              "Net Amt",
            ],
            data: salesItems.map((item) {
              return [
                item['ItemName'] ?? '',
                // item['BatchNo'] ?? '',
                // item['ExpDate'] ?? '',
                (item['Quantity'] ?? '').toString(),
                (item['Rate'] ?? '').toString(),
                (item['DiscAmt'] ?? '').toString(),
                (item['SchemeAmt'] ?? '').toString(),
                (item['TaxableAmt'] ?? '').toString(),
                // (item['TotalTaxAmt'] ?? '').toString(),
                (item['NetAmt'] ?? '').toString(),
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          // 🔹 Footer / Signature Area
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Generated on: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ],
      ),
    );

    // 🔹 Save file locally
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        "Sales_Itemwise_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    // 🔹 Open PDF after saving
    await OpenFile.open(file.path);
  }

  Future<void> _printReport() async {
    final pdf = await _buildSalesReportPDF();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<pw.Document> _buildSalesReportPDF() async {
    final pdf = pw.Document();
    final viewModel = context.read<SalesReportViewModel>();
    final salesItems = viewModel.reportList;

    final fromDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Sales Itemwise Report',
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
                ],
              ),
              pw.Text(
                'Total Records: ${salesItems.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.center,
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(1),
              5: pw.FlexColumnWidth(1.5),
              6: pw.FlexColumnWidth(1.5),
              7: pw.FlexColumnWidth(1.5),
              8: pw.FlexColumnWidth(1.5),
              9: pw.FlexColumnWidth(1.5),
            },
            headers: [
              "Item Name",
              // "Batch",
              // "Exp Dt",
              "Qty",
              "Rate",
              "Disc",
              "Sch Amt",
              "Taxable",
              // "Tax Amt",
              "Net Amt",
            ],
            data: salesItems.map((item) {
              return [
                item['ItemName'] ?? '',
                // item['BatchNo'] ?? '',
                // item['ExpDate'] ?? '',
                (item['Quantity'] ?? '').toString(),
                (item['Rate'] ?? '').toString(),
                (item['DiscAmt'] ?? '').toString(),
                (item['SchemeAmt'] ?? '').toString(),
                (item['TaxableAmt'] ?? '').toString(),
                // (item['TotalTaxAmt'] ?? '').toString(),
                (item['NetAmt'] ?? '').toString(),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Generated on: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
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

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userId = int.tryParse(loginVM.userId ?? '0') ?? 0;
    final request = SalesItemwiseReportRequest(
      fromDate: DateFormat('MM-dd-yyyy').format(selectedDateRange!.start),
      toDate: DateFormat('MM-dd-yyyy').format(selectedDateRange!.end),
      userId: userId, // Example user
      locationId: selectedLocationId, // ✅ Pass selected location ID
    );

    context.read<SalesReportViewModel>().fetchReport(request);
  }


  @override
  Widget build(BuildContext context) {
    final itemVM = Provider.of<ItemsByProductTypeViewmodel>(context);
    final locations = itemVM.stockLocationsByUserList;
// ✅ Set first location as default
    if (selectedLocationId == null && locations.isNotEmpty) {
      selectedLocationId = locations.first.locationId;
      selectedLocationName = locations.first.locationName;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchReport();
      });
    }
    final dateRangeText =
        '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} → ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';

    return Scaffold(

      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text("Sales Statement - Item Wise",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _generateAndSavePDF,
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),

          IconButton(
              onPressed: _printReport,
              icon: const Icon(Icons.print, color: Colors.white)),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          child: Consumer<SalesReportViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(child: Text("Error: ${viewModel.error}"));
              }

              final salesItems = viewModel.reportList;

              double totalQty = 0;
              double totalRate = 0;
              double totalTaxable = 0;
              double totalNet = 0;
              double totalDisc = 0;
              double totalScheme = 0;

              for (var item in salesItems) {
                double qty = (item['Quantity'] ?? 0).toDouble();
                double rate = (item['Rate'] ?? 0).toDouble();

                totalQty += qty;
                totalTaxable += (item['TaxableAmt'] ?? 0).toDouble();
                totalNet += (item['NetAmt'] ?? 0).toDouble();
                totalDisc += (item['DiscAmt'] ?? 0).toDouble();
                totalScheme += (item['SchemeAmt'] ?? 0).toDouble();

                totalRate += rate * qty; // weighted rate
              }

// ✅ Calculate average rate OUTSIDE loop
              double avgRate = totalQty == 0 ? 0 : totalRate / totalQty;

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
                  // 🔹 Data Table
                  Expanded(
                    child: salesItems.isEmpty
                        ? const Center(child: Text('No data available'))
                        : Column(
                      children: [

                        /// LIST
                        Expanded(
                          child: ListView.builder(
                            itemCount: salesItems.length,
                            itemBuilder: (context, index) {
                              final item = salesItems[index];

                              return ReportCard(
                                data: item,
                                title: item['ItemName'],
                                dateKey: 'ExpDate',
                                dateLabel: 'Exp Date',
                                fields: {
                                  "Qty": "Quantity",
                                  "Rate": "Rate",
                                  "Disc": "DiscAmt",
                                  "Sch Amt": "SchemeAmt",
                                  "Taxable": "TaxableAmt",
                                  "Net Amt": "NetAmt",
                                },
                                accentColor: primary,
                              );
                            },
                          ),
                        ),

                        /// TOTAL CARD
                        SafeArea(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: primary),
                            ),
                            child: Column(
                              children: [

                                /// HEADER ROW
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showTotals = !_showTotals;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Totals",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          _showTotals ? Icons.remove : Icons.add,
                                          color: primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// EXPANDABLE SECTION
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 250),
                                  crossFadeState: _showTotals
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  firstChild: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      spacing: 20,
                                      runSpacing: 10,
                                      children: [
                                        _totalItem("Qty", totalQty.toStringAsFixed(2)),
                                        _totalItem("Rate", avgRate.toStringAsFixed(2)),
                                        _totalItem("Disc", totalDisc.toStringAsFixed(2)),
                                        _totalItem("Scheme", totalScheme.toStringAsFixed(2)),
                                        _totalItem("Taxable", totalTaxable.toStringAsFixed(2)),
                                        _totalItem("Net", totalNet.toStringAsFixed(2)),
                                      ],
                                    ),
                                  ),
                                  secondChild: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  Widget _totalItem(String label, String value) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
