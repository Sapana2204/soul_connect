import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/viewmodel/category_master_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../model/category_master_model.dart';
import '../model/items_model.dart';
import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import '../viewmodel/stock_report_viewmodel.dart';


class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  DateTimeRange _dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  int? selProd, selCat, selLoc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<StockViewModel>();
      final itemVm = context.read<ItemViewmodel>();
      final categoryVm = context.read<CategoryMasterViewmodel>();
      await vm.fetchDropdownData(itemVm, categoryVm);

      if (vm.locations.isNotEmpty) {
        setState(() {
          selLoc = vm.locations.first.locationId; // first product selected
        });
      }
      // _onSearch(vm); // Initial load
    });
  }

  // PDF Generation & Print Logic
  Future<void> _generatePdf(StockViewModel vm, {bool isPrint = false}) async {
    final pdf = pw.Document();
    final data = vm.filteredReportList;

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.noDataToExport)),
      );
      return;
    }

    final dateStr = "${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(Strings.stockReport, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text("Period: $dateStr", style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: ['Item Name', 'Batch', 'Exp Date', 'Opening', 'Purchase', 'Sales', 'Closing', 'MRP', 'Profit'],
            data: data.map((item) => [
              item.itemName ?? '',
              item.batchNo ?? '',
              item.expDate ?? '',
              item.opening?.toString() ?? '0',
              item.purchase?.toString() ?? '0',
              item.sales?.toString() ?? '0',
              item.closing?.toString() ?? '0',
              item.mrp?.toStringAsFixed(2) ?? '0.00',
              item.profitValue?.toStringAsFixed(2) ?? '0.00',
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Total Purchase Valuation: ${vm.totalPurVal.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("Total Sales Valuation: ${vm.totalSalVal.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                )
              ]
          )
        ],
      ),
    );

    if (isPrint) {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } else {
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'Stock_Report.pdf');
    }
  }

  void _onSearch(StockViewModel vm) {
    String from = DateFormat('yyyy-MM-dd').format(_dateRange.start);
    String to = DateFormat('yyyy-MM-dd').format(_dateRange.end);
    vm.fetchStockReport(from, to, prodId: selProd, catId: selCat, locId: selLoc);
  }

  Future<pw.Document> _buildStockReportPDF() async {
    final pdf = pw.Document();
    final vm = context.read<StockViewModel>();
    final stockItems = vm.filteredReportList;

    final fromDate =
    DateFormat('dd/MM/yyyy').format(_dateRange.start);
    final toDate =
    DateFormat('dd/MM/yyyy').format(_dateRange.end);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [

          /// 🔹 TITLE
          pw.Center(
            child: pw.Text(
              'Stock Report',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 6),

          /// 🔹 DATE RANGE
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From: $fromDate',
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('To: $toDate',
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Purchase Valuation: ${vm.totalPurVal.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Total Sales Valuation: ${vm.totalSalVal.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          /// 🔹 TABLE
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.grey300),

            headerStyle: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
            ),

            cellStyle: const pw.TextStyle(fontSize: 8),

            headers: const [
              'Item Name',
              'Batch',
              'Exp Date',
              'Opening',
              'Purchase',
              'Sales',
              'Sales Return',
              'Purchase Return',
              'Issue',
              'Expired',
              'Damage',
              'Inward',
              'Purchase Value',
              'Sales Value',
              'Closing',
              'Profit'
            ],

            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(1.2),
              4: pw.FlexColumnWidth(1.2),
              5: pw.FlexColumnWidth(1.2),
              6: pw.FlexColumnWidth(1.5),
              7: pw.FlexColumnWidth(1.5),
              8: pw.FlexColumnWidth(1.2),
              9: pw.FlexColumnWidth(1.2),
              10: pw.FlexColumnWidth(1.2),
              11: pw.FlexColumnWidth(1.2),
              12: pw.FlexColumnWidth(1.8),
              13: pw.FlexColumnWidth(1.8),
              14: pw.FlexColumnWidth(1.2),
              15: pw.FlexColumnWidth(1.5),
            },

            data: stockItems.map((item) {
              return [
                item.itemName ?? '',
                item.batchNo ?? '',
                item.expDate ?? '',
                item.opening?.toString() ?? '0',
                item.purchase?.toString() ?? '0',
                item.sales?.toString() ?? '0',
                item.salesReturn?.toString() ?? '0',
                item.purchaseReturn?.toString() ?? '0',
                item.issue?.toString() ?? '0',
                item.expired?.toString() ?? '0',
                item.damage?.toString() ?? '0',
                item.inward?.toString() ?? '0',
                item.purchaseValuation?.toStringAsFixed(2) ?? '0.00',
                item.salesValuation?.toStringAsFixed(2) ?? '0.00',
                item.closing?.toString() ?? '0',
                item.profitValue?.toStringAsFixed(2) ?? '0.00',
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 8),

          /// 🔹 FOOTER
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Generated on: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  Future<void> _generateAndSavePDF() async {
    final pdf = await _buildStockReportPDF();

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/Stock_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }
  void _clearFilters(StockViewModel vm) {

    setState(() {
      selProd = null;
      selCat = null;
      selLoc = null;
      vm.filteredReportList.clear();
    });
    // _onSearch(vm);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<StockViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        vm.filteredReportList.clear();
        vm.totalPurVal = 0;
        vm.totalSalVal = 0;
        vm.notifyListeners();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          title: const Text("Stock Report"),
          actions: [
            IconButton(
              tooltip: "Export PDF",
              color: Colors.white,
              onPressed: _generateAndSavePDF,
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),            IconButton(onPressed: () => _generatePdf(vm, isPrint: true), icon: const Icon(Icons.print),tooltip: "Print Report",),
            IconButton(
              onPressed: () => _clearFilters(vm),
              icon: const Icon(Icons.filter_alt_off),
              tooltip: "Clear Filters",
            ),
          ],

        ),
        body: Column(
          children: [
            _buildFilterPanel(vm),
            Expanded(
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.filteredReportList.isEmpty
                  ? const Center(child: Text("No records found"))
                  : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: vm.filteredReportList.length,
                itemBuilder: (ctx, i) {
                  final item = vm.filteredReportList[i];
                  return ReportCard(
                    data: item.toJson(),
                    title: item.itemName,
                    dateKey: "ExpDate",
                    dateLabel: "Exp",
                    accentColor: primary,
                    fields: const {
                      "Batch": "BatchNo",
                      "Opening": "Opening",
                      "Purchase": "Purchase",
                      "Sales": "Sales",
                      "Sales Return": "SalesReturn",
                      "Purchase Return": "PurchaseReturn",
                      "Issue": "Issue",
                      "Expired": "Expired",
                      "Damage": "Damage",
                      "Inward": "Inward",
                      "Purchase Value": "PurchaseValuation",
                      "Sales Value": "SalesValuation",
                      "Closing": "Closing",
                      "Profit": "ProfitValue",
                    },
                  );
                },
              ),
            ),
            /*_buildFooter(vm),*/
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(StockViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
      ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Period", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _datePill(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _drop("Product", vm.products, selProd, (v) => setState(() => selProd = v), vm.dropdownLoading)),
              const SizedBox(width: 8),
              Expanded(child: _drop("Category", vm.categories, selCat, (v) => setState(() => selCat = v), vm.dropdownLoading)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(flex: 3, child: _drop("Location", vm.locations, selLoc, (v) => setState(() => selLoc = v),vm.dropdownLoading)),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _onSearch(vm),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePill() {
    return ActionChip(
      label: Text(
        "${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}",
      ),
      onPressed: () async {
        final p = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2023),
          lastDate: DateTime(2027),
        );
        if (p != null) setState(() => _dateRange = p);
      },
    );
  }

  Widget _drop(String label, List<dynamic> list, int? val, Function(int?) onCh, bool loading) {
    if (loading) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: val,
      isExpanded: true,
      menuMaxHeight: 258,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        // labelStyle: const TextStyle(fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text("All $label", style: const TextStyle(color: Colors.grey)),
        ),
        ...list.map((e) {
          int id = (e is ItemsModel) ? e.itemId! : (e is CategoryMasterModel ? e.CateId! : e.locationId!);
          String name = (e is ItemsModel) ? e.itemName! : (e is CategoryMasterModel ? e.CateName! : e.locationName!);
          return DropdownMenuItem(value: id, child: Text(name));
        }),
      ],
      onChanged: onCh,
    );
  }
}