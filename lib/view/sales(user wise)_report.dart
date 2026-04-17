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
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/sales_report_view_model.dart';

class SalesUserwiseReportScreen extends StatefulWidget {
  const SalesUserwiseReportScreen({Key? key}) : super(key: key);

  @override
  State<SalesUserwiseReportScreen> createState() =>
      _SalesUserwiseReportScreenState();
}

class _SalesUserwiseReportScreenState extends State<SalesUserwiseReportScreen> {
  String? selectedUser;
  DateTimeRange? selectedDateRange;

  int? selectedUserId;
  String? selectedUserName;

  bool _isInit = true; // To prevent multiple API calls

  @override
  void initState() {
    super.initState();

    // Set default date range to today's date
    final today = DateTime.now();
    selectedDateRange = DateTimeRange(start: today, end: today);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      // Safe to call Provider here
      final salesReportVM = Provider.of<SalesReportViewModel>(context, listen: false);
      salesReportVM.fetchUsers(); // Call your API safely here

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
    final salesItems = viewModel.salesListByUser;

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
              'Sales statement salesman_wise Report',
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
                item.salesBillNo ?? '',
                item.salesDate ?? '',
                item.customerName ?? '',
                (item.subTotal ?? 0).toString(),
                (item.taxableAmt ?? 0).toString(),
                (item.totalTaxAmt ?? 0).toString(),
                (item.netAmt ?? 0).toString(),
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
        "Sales_Statement_Salesmanwise_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
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
    final salesItems = viewModel.salesListByUser;

    final fromDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate = DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Sales statement salesman_wise Report',
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
              "Bill No",
              "Date",
              "Customer",
              "Sub Total",
              "Taxable",
              "Tax",
              "Net Amt",
            ],
            data: salesItems.map((item) {
              return [
                item.salesBillNo ?? '',
                item.salesDate ?? '',
                item.customerName ?? '',
                (item.subTotal ?? 0).toString(),
                (item.taxableAmt ?? 0).toString(),
                (item.totalTaxAmt ?? 0).toString(),
                (item.netAmt ?? 0).toString(),
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
    if (selectedDateRange == null || selectedUserId == null) return;

    context.read<SalesReportViewModel>().fetchSalesSummary(
      userId: selectedUserId!,
      fromDate: DateFormat('MM-dd-yyyy').format(selectedDateRange!.start),
      toDate: DateFormat('MM-dd-yyyy').format(selectedDateRange!.end),
    );
  }


  @override
  Widget build(BuildContext context) {
    final salesReportVM = Provider.of<SalesReportViewModel>(context);
    final users = salesReportVM.userList;
// ✅ Set first location as default
    if (selectedUserId == null && users.isNotEmpty) {
      selectedUserId = users.first.userId;
      selectedUserName = users.first.userName;

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
        title: const Text("Sales Report (User Wise)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _generateAndSavePDF,
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),

          // IconButton(
          //     onPressed: _printReport,
          //     icon: const Icon(Icons.print, color: Colors.white)),
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

              final salesItems = viewModel.salesListByUser;

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
                            value: selectedUserId,
                            hint: const Text('Select User'),
                            decoration: InputDecoration(
                              labelText: 'Users',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: users
                                .map((user) => DropdownMenuItem<int>(
                              value: user.userId,
                              child: Text(user.userName??""),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedUserId = val;
                                selectedUserName = users
                                    .firstWhere((user) => user.userId == val).userName;
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
                        : ListView.builder(
                      itemCount: salesItems.length,
                        itemBuilder: (context, index) {
                          final item = salesItems[index];

                          return ReportCard(
                            title: item.customerName ?? "",
                            data: {
                              "BillNo": item.salesBillNo,
                              "Date": item.salesDate,
                              "CustomerName": item.customerName,
                              // "BillType": item.billType,
                              "PayMode": item.salesType,
                              "SubTotal": item.subTotal,
                              "TaxableAmt": item.taxableAmt,
                              "TaxAmt": item.totalTaxAmt,
                              "NetAmt": item.netAmt,
                            },
                            fields: {
                              "Bill No": "BillNo",
                              "Date": "Date",
                              "Customer": "CustomerName",
                              // "Bill Type": "BillType",
                              "Pay Mode": "PayMode",
                              "Sub Total": "SubTotal",
                              "Taxable": "TaxableAmt",
                              "Tax": "TaxAmt",
                              "Net": "NetAmt",
                            },
                            accentColor: primary,
                          );
                        }
                      // itemBuilder: (context, index) {
                      //   final item = salesItems[index];
                      //   return ReportCard(
                      //     data: item,
                      //     title: item.customerName,
                      //     dateKey: 'ExpDate',
                      //     dateLabel: 'Exp Date',
                      //     fields: {
                      //       // "Batch": "BatchNo",
                      //       // "Exp Dt": "ExpDate",
                      //       "Qty": "Quantity",
                      //       "Rate": "Rate",
                      //       "Disc": "DiscAmt",
                      //       "Sch Amt": "SchemeAmt",
                      //       "Taxable": "TaxableAmt",
                      //       // "Tax Amt": "TotalTaxAmt",
                      //       "Net Amt": "NetAmt",
                      //     },
                      //     accentColor: primary,
                      //   );
                      // },
                    )

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
