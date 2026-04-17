import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../model/item_master_model.dart';
import '../model/items_model.dart';
import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';
import '../utils/routes/utils.dart';
import '../viewModel/item_master_viewmodel.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewmodel/stock_report_viewmodel.dart';


class ItemLedgerReportScreen extends StatefulWidget {
  const ItemLedgerReportScreen({super.key});

  @override
  State<ItemLedgerReportScreen> createState() => _ItemLedgerReportScreenState();
}

class _ItemLedgerReportScreenState extends State<ItemLedgerReportScreen> {
  DateTimeRange _dateRange =
  DateTimeRange(start: DateTime.now(), end: DateTime.now());

  int? selItemId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemVm = context.read<ItemMasterViewmodel>();
      final reportVm = context.read<StockViewModel>();

      // itemVm.itemMastersApi(); // ✅ Item dropdown list

      // ✅ Default load (optional)
      // reportVm.fetchItemLedgerReport(
      //   fromDate: DateFormat('yyyy-MM-dd').format(_dateRange.start),
      //   toDate: DateFormat('yyyy-MM-dd').format(_dateRange.end),
      //   itemId: selItemId,
      // );
    });
  }

  // ============================================================
  // PDF Generation
  // ============================================================
  Future<void> _generatePdf(StockViewModel vm,
      {bool isPrint = false}) async {
    final pdf = pw.Document();
    final data = vm.itemLedgerList;

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data available to export")),
      );
      return;
    }

    final dateStr =
        "${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}";

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
                pw.Text(
                  "Item Ledger Report",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Period: $dateStr",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: [
              "Date",
              "Bill No",
              "Party Name",
              "Address",
              "Narration",
              "Inward",
              "Issue",
              "Balance",
            ],
            data: data.map((e) {
              return [
                e.transDate ?? "",
                e.billNo ?? "",
                e.partyName ?? "",
                e.partyAddress ?? "",
                e.narration ?? "",
                (e.inward ?? 0).toString(),
                (e.issue ?? 0).toString(),
                (e.balance ?? 0).toString(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    if (isPrint) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Item_Ledger_Report.pdf',
      );
    }
  }

  // ============================================================
  // Search
  // ============================================================
  void _onSearch(StockViewModel vm) {
    String from = DateFormat('yyyy-MM-dd').format(_dateRange.start);
    String to = DateFormat('yyyy-MM-dd').format(_dateRange.end);

    if (selItemId ==null) {
      Utils.toastMessage("Please select item.");
    }
    else{
      vm.fetchItemLedgerReport(
      fromDate: from,
      toDate: to,
      itemId: selItemId,
    );
  }}

  // ============================================================
  // Clear
  // ============================================================
  void _clearFilters(StockViewModel vm) {
    setState(() {
      selItemId = null;
      _dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
    });

    vm.fetchItemLedgerReport(
      fromDate: DateFormat('yyyy-MM-dd').format(_dateRange.start),
      toDate: DateFormat('yyyy-MM-dd').format(_dateRange.end),
      itemId: selItemId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportVm = Provider.of<StockViewModel>(context);
    final itemVm = Provider.of<ItemViewmodel>(context);

    return WillPopScope(
    onWillPop: () async {
      final stockReportVM =
      Provider.of<StockViewModel>(context, listen: false);

      stockReportVM.clearItemLedger(); // ✅ Clear when back pressed

      return true; // allow navigation
    },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Item Ledger Report"),
          actions: [
            IconButton(
              onPressed: () => _generatePdf(reportVm, isPrint: false),
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: "Save PDF Report",
            ),
            IconButton(
              onPressed: () => _generatePdf(reportVm, isPrint: true),
              icon: const Icon(Icons.print),
              tooltip: "Print Report",
            ),
            IconButton(
              onPressed: () => _clearFilters(reportVm),
              icon: const Icon(Icons.filter_alt_off),
              tooltip: "Clear Filters",
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterPanel(reportVm, itemVm),
            Expanded(
              child: reportVm.itemLedgerLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reportVm.itemLedgerList.isEmpty
                  ? const Center(child: Text("No records found"))
                  : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: reportVm.itemLedgerList.length,
                itemBuilder: (ctx, i) {
                  final item = reportVm.itemLedgerList[i];

                  return ReportCard(
                    data: item.toJson(),
                    title: "Bill No: ${item.billNo ?? ""}",
                    dateKey: "Date",
                    dateLabel: "Date",
                    accentColor: primary,
                    fields: const {
                      "Party Name": "PartyName",
                      "Address": "Address",
                      "Narration": "Narration",
                      "Inward": "Inward",
                      "Issue": "Issue",
                      "Balance": "Balance",
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Filter Panel (Only Item Dropdown + Date Range)
  // ============================================================
  Widget _buildFilterPanel(
      StockViewModel reportVm, ItemViewmodel itemVm) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        )
      ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Period",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _datePill(),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ Dropdown + Search Button in one row
          Row(
            children: [
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<int>(
                  value: selItemId,
                  isExpanded: true,
                  menuMaxHeight: 280,
                  decoration: InputDecoration(
                    labelText: "Select Item",
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text("All Items",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    ...itemVm.itemList.map((ItemsModel e) {
                      return DropdownMenuItem<int>(
                        value: e.itemId, // ✅ FIXED
                        child: Text(e.itemName ?? ""),
                      );
                    }).toList(),
                  ],
                  onChanged: (v) => setState(() => selItemId = v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _onSearch(reportVm),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ============================================================
  // Date Pill
  // ============================================================
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
}
