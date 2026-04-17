import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/viewmodel/stock_report_viewmodel.dart';
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

import '../viewmodel/sales_report_view_model.dart';

class ExpiryReport extends StatefulWidget {
  const ExpiryReport({Key? key}) : super(key: key);

  @override
  State<ExpiryReport> createState() =>
      _ExpiryReportState();
}

class _ExpiryReportState extends State<ExpiryReport> {
  String? selectedLocation;
  DateTimeRange? selectedDateRange;

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

  Widget _buildField(String title, String? value,
      {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value ?? '',
          style: TextStyle(
            fontSize: 13,
            fontWeight:
            isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
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
    final viewModel = context.read<StockViewModel>();
    final items = viewModel.expiringList;

    final fromDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(15),
        pageFormat: PdfPageFormat.a4.landscape, // 👈 Landscape fits more columns
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Expiry Report",
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
                'Total Records: ${items.length}',
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
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.center,
            headers: [
              "Item Name",
              "Expiry Date",
              "Batch No",
              "HSN Code",
              "Stock",
            ],
            data: items.map((item) {
              return [
                item.itemName ?? '',
                item.expDate != null
                    ? DateFormat('dd-MM-yyyy').format(item.expDate!)
                    : '',
                item.batchNo ?? '',
                item.hsnCode ?? '',
                item.closing?.toString() ?? '',
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

      final fromDate = DateFormat('MM-dd-yyyy').format(selectedDateRange!.start);
      final toDate = DateFormat('MM-dd-yyyy').format(selectedDateRange!.end);
      final locationId = selectedLocationId;// ✅ Pass selected location ID


    context.read<StockViewModel>().fetchExpiryReport(fromDate: fromDate, toDate: toDate, locationId: locationId);
  }


  @override
  Widget build(BuildContext context) {
    final itemVM = Provider.of<ItemsByProductTypeViewmodel>(context);
    final locations = itemVM.stockLocationsByUserList; // ✅ fetched from ViewModel
// ✅ Set first location as default
//     if (selectedLocationId == null && locations.isNotEmpty) {
//       selectedLocationId = locations.first.locationId;
//       selectedLocationName = locations.first.locationName;
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _fetchReport();
//       });
//     }
    final dateRangeText =
        '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} → ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';


    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text("Item Expiry",
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
          child: Consumer<StockViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(child: Text("Error: ${viewModel.error}"));
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
                          child:DropdownButtonFormField<int?>(
                            value: selectedLocationId,
                            hint: const Text("Select Locations"),
                            decoration: InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text("All Locations"), // 👈 Important
                              ),
                              ...locations.map((loc) => DropdownMenuItem<int?>(
                                value: loc.locationId,
                                child: Text(loc.locationName!),
                              ))
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedLocationId = val;
                                selectedLocationName = val == null
                                    ? null
                                    : locations
                                    .firstWhere((loc) => loc.locationId == val)
                                    .locationName;
                              });

                              _fetchReport(); // 🔥 refresh
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
                    child: viewModel.expiringList.isEmpty
                        ? const Center(child: Text('No data available'))
                        : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: viewModel.expiringList.length,
                      itemBuilder: (context, index) {
                        final item = viewModel.expiringList[index];

                        Color statusColor = Colors.red;

                        return ReportCard(
                          title: item.itemName ?? '',
                          data: {
                            "ExpDate": item.expDate != null
                                ? DateFormat('dd-MM-yyyy').format(item.expDate!)
                                : '',
                            "BatchNo": item.batchNo,
                            "HSN": item.hsnCode,
                            "Stock": item.closing?.toString(),
                          },

                          dateKey: "ExpDate",
                          dateLabel: "Expiry Date",

                          fields: {
                            "Batch No": "BatchNo",
                            "HSN Code": "HSN",
                            "Stock": "Stock",
                          },

                          accentColor: Colors.red, // 👈 expiry highlight
                        );
                      },
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
}
