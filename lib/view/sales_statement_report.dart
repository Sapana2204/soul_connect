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
import '../utils/app_strings.dart';
import '../viewModel/items_by_product_type_viewmodel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../viewModel/sales_report_view_model.dart';

class SalesStatementReport extends StatefulWidget {
  const SalesStatementReport({Key? key}) : super(key: key);

  @override
  State<SalesStatementReport> createState() =>
      _SalesStatementReportScreenState();
}

class _SalesStatementReportScreenState extends State<SalesStatementReport> {
  String? selectedLocation;
  DateTimeRange? selectedDateRange;

  int? selectedLocationId;
  String? selectedLocationName;

  bool _showTotals = false;
  bool _isInit = true; //

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
    final pdf = await _buildSalesStatementPDF();

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/Sales_Statement_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }


  Future<pw.Document> _buildSalesStatementPDF() async {
    final pdf = pw.Document();
    final viewModel = context.read<SalesReportViewModel>();
    final salesItems = viewModel.reportList;

    final fromDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(15),
        pageFormat: PdfPageFormat.a4.landscape, // 👈 Landscape fits more columns
        build: (context) => [
          pw.Center(
            child: pw.Text(
              Strings.salesSummarystmt,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From Date: $fromDate', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('To Date: $toDate', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Text(
                'Total Records: ${salesItems.length}',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8.5,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.center,
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2.5),
              3: pw.FlexColumnWidth(1.2),
              4: pw.FlexColumnWidth(1.2),
              5: pw.FlexColumnWidth(1.2),
              6: pw.FlexColumnWidth(1.2),
              7: pw.FlexColumnWidth(1.2),
              8: pw.FlexColumnWidth(1.2),
              9: pw.FlexColumnWidth(1.2),
              10: pw.FlexColumnWidth(1.2),
              11: pw.FlexColumnWidth(1.2),
              12: pw.FlexColumnWidth(1.2),
              13: pw.FlexColumnWidth(1.2),
              14: pw.FlexColumnWidth(1.2),
              15: pw.FlexColumnWidth(1.2),
            },
            headers: [
              "Bill No",
              "Date",
              "Name",
              // "Bill Type",
              // "Rate Type",
              // "Sale Type",
              // "Crop",
              // "Pay Term",
              "SubTotal",
              "Disc",
              "Taxable",
              "Tax Amt",
              "Postage",
              "Bill Total",
              "Round Off",
              "Net Amt"
            ],
            data: salesItems.map((item) {
              return [
                item['SalesBillNo'] ?? '',
                item['SalesDate'] ?? '',
                item['CustomerName'] ?? '',
                // item['BillType'] ?? '',
                // item['RateType'] ?? '',
                // item['SalesType'] ?? '',
                // item['CropType'] ?? '',
                // item['PaymentTerm']?.toString() ?? '',
                item['SubTotal']?.toString() ?? '',
                item['DiscAmt']?.toString() ?? '',
                item['TaxableAmt']?.toString() ?? '',
                item['TotalTaxAmt']?.toString() ?? '',
                item['OtherCharges']?.toString() ?? '',
                item['BillTotal']?.toString() ?? '',
                item['RoundOff']?.toString() ?? '',
                item['NetAmt']?.toString() ?? '',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Generated on: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );


    return pdf;
  }

  Future<void> _printReport() async {
    final pdf = await _buildSalesStatementPDF();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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

    final request = SalesItemwiseReportRequest(
      fromDate: DateFormat('MM-dd-yyyy').format(selectedDateRange!.start),
      toDate: DateFormat('MM-dd-yyyy').format(selectedDateRange!.end),
      userId: 1, // Example user
      locationId: selectedLocationId, // ✅ Pass selected location ID
    );

    context.read<SalesReportViewModel>().fetchReportStmtReport(request);
  }


  @override
  Widget build(BuildContext context) {
    final itemVM = Provider.of<ItemsByProductTypeViewmodel>(context);
    final locations = itemVM.stockLocationsByUserList; // ✅ fetched from ViewModel
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
        title: const Text(Strings.salesStmt,
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
     color: Colors.white,
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
              double totalSubTotal = 0;
              double totalDisc = 0;
              double totalTaxable = 0;
              double totalTax = 0;
              double totalPostage = 0;
              double totalBillTotal = 0;
              double totalRoundOff = 0;
              double totalNet = 0;

              for (var item in salesItems) {
                totalSubTotal += (item['SubTotal'] ?? 0).toDouble();
                totalDisc += (item['DiscAmt'] ?? 0).toDouble();
                totalTaxable += (item['TaxableAmt'] ?? 0).toDouble();
                totalTax += (item['TotalTaxAmt'] ?? 0).toDouble();
                totalPostage += (item['OtherCharges'] ?? 0).toDouble();
                totalBillTotal += (item['BillTotal'] ?? 0).toDouble();
                totalRoundOff += (item['RoundOff'] ?? 0).toDouble();
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
                            hint: const Text(Strings.selectLocation),
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
                            padding: const EdgeInsets.only(bottom: 10),
                            itemCount: salesItems.length,
                            itemBuilder: (context, index) {
                              final item = salesItems[index];

                              return ReportCard(
                                title: item['CustomerName'],
                                data: item,
                                dateKey: 'SalesDate',
                                dateLabel: 'Date',
                                fields: {
                                  "Bill No": "SalesBillNo",
                                  "SubTotal": "SubTotal",
                                  "Disc": "DiscAmt",
                                  "Taxable": "TaxableAmt",
                                  "Tax": "TotalTaxAmt",
                                  "Postage": "OtherCharges",
                                  "Bill Total": "BillTotal",
                                  "Roundoff": "RoundOff",
                                  "Net": "NetAmt",
                                },
                                accentColor: primary,
                              );
                            },
                          ),
                        ),

                        /// TOTALS CARD (Expandable)
                        SafeArea(
                          top: false,
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
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

                                /// EXPANDABLE CONTENT
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 250),
                                  crossFadeState: _showTotals
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,

                                  firstChild: Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                    child: Column(
                                      children: [

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                                       _totalItem("SubTotal", totalSubTotal),
                                                        _totalItem("Disc", totalDisc),
                                                        _totalItem("Taxable", totalTaxable),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _totalItem("Tax", totalTax),
                                            _totalItem("Postage", totalPostage),
                                            _totalItem("Bill Total", totalBillTotal),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _totalItem("Roundoff", totalRoundOff),
                                            _totalItem("Net Amount", totalNet),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),

                                  secondChild: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // SafeArea(
                        //   top: false,
                        //   child: Container(
                        //     margin: const EdgeInsets.only(top: 6),
                        //     padding: const EdgeInsets.all(14),
                        //     decoration: BoxDecoration(
                        //       color: primary.withOpacity(0.08),
                        //       borderRadius: BorderRadius.circular(14),
                        //       border: Border.all(color: primary),
                        //     ),
                        //     child: Column(
                        //       children: [
                        //
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             _totalItem("SubTotal", totalSubTotal),
                        //             _totalItem("Disc", totalDisc),
                        //             _totalItem("Taxable", totalTaxable),
                        //             _totalItem("Tax", totalTax),
                        //           ],
                        //         ),
                        //
                        //         const SizedBox(height: 8),
                        //
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             _totalItem("Postage", totalPostage),
                        //             _totalItem("Bill Total", totalBillTotal),
                        //             _totalItem("Roundoff", totalRoundOff),
                        //             _totalItem("Net Amount", totalNet),
                        //           ],
                        //         ),
                        //
                        //       ],
                        //     ),
                        //   ),
                        // ),
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
  Widget _totalItem(String label, double value) {
    return SizedBox(
      width: 85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
