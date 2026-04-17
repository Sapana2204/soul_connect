import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';
import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/app_strings.dart';
import 'package:flutter_soulconnect/viewModel/purchase_report_viewmodel.dart';



class PurchaseReturnItemwiseReport extends StatefulWidget {
  const PurchaseReturnItemwiseReport({Key? key}) : super(key: key);

  @override
  State<PurchaseReturnItemwiseReport> createState() =>
      _PurchaseReturnItemwiseReportScreenState();
}

class _PurchaseReturnItemwiseReportScreenState extends State<PurchaseReturnItemwiseReport> {
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

    final fromDate =
    DateFormat('yyyy-MM-dd').format(selectedDateRange!.start);

    final toDate =
    DateFormat('yyyy-MM-dd').format(selectedDateRange!.end);

    context.read<PurchaseReportViewModel>().fetchReportReturnItemwise(
      fromDate: fromDate,
      toDate: toDate,
      locationId: selectedLocationId,
    );
  }


  Future<void> _generateAndSavePurchasePDF() async {
    final pdf = pw.Document();
    final viewModel = context.read<PurchaseReportViewModel>();
    final purchaseItems = viewModel.reportList;

    if (purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Strings.noDataToExport))      );
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
              'Purchase Return Itemwise Report',
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
                '${Strings.totalRecords}: ${purchaseItems.length}',
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
              Strings.billNo,
              Strings.supplier,
              Strings.date,
              Strings.qty,
              Strings.freeQty,
              Strings.subTotal,
              Strings.taxableAmt,
              Strings.taxAmt,
              Strings.postage,
              Strings.roundOff,
              Strings.disc,
              Strings.netAmt,
            ],
            data: purchaseItems.map((item) {
              return [
                item['PurchaseId']?.toString() ?? '',
                item['SupplierName'] ?? '',
                item['ReturnDate'] ?? '',
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
              "${Strings.generatedOn}: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}",
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
        const SnackBar(content: Text(Strings.noDataToPrint))
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
              Strings.purchaseReturnItemwiseReport,
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
                  pw.Text('${Strings.fromDate}: $fromDate'),
                  pw.Text('${Strings.toDate}: $toDate'),
                  if (selectedLocationName != null)
                    pw.Text('${Strings.location}: $selectedLocationName'),                ],
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

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text(Strings.purchaseReturnItemwise,
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

              // if (viewModel.error != null) {
              //   return Center(child: Text("${Strings.error}: ${viewModel.error}"));
              // }

              final purchaseItems = viewModel.reportList;

              return Column(
                children: [
                  // 🔹 Filter Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
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
                              labelText: Strings.location,
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
                                labelText: Strings.dateRange,
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
                        ? const Center(child: Text(Strings.noData))
                        : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: purchaseItems.length,
                      itemBuilder: (context, index) {
                        final item = purchaseItems[index];
                        return ReportCard(
                          title: item['ItemName'], // 👈 Item Name as title
                          data: item,
                          fields: const {
                            "Qty": "Quantity",
                            "Free Qty": "FreeQuantity",
                            "Rate": "Rate",
                            "Disc Amt": "DiscAmt",
                            "Taxable Amt": "TaxableAmt",
                            "Tax Amt": "TotalTaxAmt",
                            "Net Amt": "NetAmt",
                          },
                          accentColor: primary,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
