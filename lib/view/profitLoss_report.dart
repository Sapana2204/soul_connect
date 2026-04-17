import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../model/party_model.dart';
import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';
import '../viewModel/account_report_viewmodel.dart';
import '../viewModel/sales_invoice_viewmodel.dart';

class ProfitLossReportScreen extends StatefulWidget {
  const ProfitLossReportScreen({super.key});

  @override
  State<ProfitLossReportScreen> createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends State<ProfitLossReportScreen> {
  DateTimeRange _dateRange =
  DateTimeRange(start: DateTime.now(), end: DateTime.now());

  int? selCustomerId;
  String? selPayType;

  final List<String> payTypes = ["CASH", "CREDIT", "BANK"];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final partyVm = context.read<SalesInvoiceViewmodel>();
      final reportVm = context.read<AccountReportViewmodel>();

      partyVm.getPartyApi(); // ✅ customer list
      reportVm.fetchProfitLossReport(); // ✅ today-today default load
    });
  }

  // ============================================================
  // PDF Generation & Print Logic (Same like Stock Report)
  // ============================================================
  Future<void> _generatePdf(AccountReportViewmodel vm,
      {bool isPrint = false}) async {
    final pdf = pw.Document();
    final data = vm.profitLossList;

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
                  "Profit Loss Report",
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

          // =======================
          // TABLE
          // =======================
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
              'Bill No',
              'Date',
              'Customer',
              'PayType',
              'Qty',
              'Bill Amt',
              'Margin',
              'GST Amt',
              'Profit/Loss',
            ],
            data: data.map((item) {
              return [
                item.salesBillNo ?? '',
                item.salesDate ?? '',
                item.customerName ?? '',
                item.payType ?? '',
                (item.totalQty ?? 0).toString(),
                (item.billAmt ?? 0).toString(),
                (item.margin ?? 0).toString(),
                (item.taxAmount ?? 0).toString(),
                (item.profitLoss ?? 0).toStringAsFixed(2),
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),
          pw.Divider(),

          // =======================
          // TOTALS
          // =======================
          if (vm.profitLossTotals != null)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Total Qty: ${(vm.profitLossTotals!.totalQtyTotal ?? 0)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Total Bill Amt: ${(vm.profitLossTotals!.billAmtTotal ?? 0)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Total Margin: ${(vm.profitLossTotals!.marginTotal ?? 0)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Total GST Amt: ${(vm.profitLossTotals!.taxAmountTotal ?? 0)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Total Profit/Loss: ${(vm.profitLossTotals!.profitLossTotal ?? 0).toStringAsFixed(2)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                )
              ],
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
        filename: 'Profit_Loss_Report.pdf',
      );
    }
  }

  // ============================================================
  // Search
  // ============================================================
  void _onSearch(AccountReportViewmodel vm) {
    String from = DateFormat('yyyy-MM-dd').format(_dateRange.start);
    String to = DateFormat('yyyy-MM-dd').format(_dateRange.end);

    vm.fetchProfitLossReport(
      fromDate: from,
      toDate: to,
      customerId: selCustomerId,
      salesType: selPayType,
    );
  }

  // ============================================================
  // Clear
  // ============================================================
  void _clearFilters(AccountReportViewmodel vm) {
    setState(() {
      selCustomerId = null;
      selPayType = null;
      _dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
    });

    vm.fetchProfitLossReport(); // reload default today
  }

  @override
  Widget build(BuildContext context) {
    final reportVm = Provider.of<AccountReportViewmodel>(context);
    final partyVm = Provider.of<SalesInvoiceViewmodel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profit Loss Report"),
        actions: [
          IconButton(
            onPressed: () => _generatePdf(reportVm, isPrint: false),
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Save PDF Report",
          ),
          // IconButton(
          //   onPressed: () => _generatePdf(reportVm, isPrint: true),
          //   icon: const Icon(Icons.print),
          //   tooltip: "Print Report",
          // ),
          IconButton(
            onPressed: () => _clearFilters(reportVm),
            icon: const Icon(Icons.filter_alt_off),
            tooltip: "Clear Filters",
          ),
        ],

      ),
      body: Column(
        children: [
          _buildFilterPanel(reportVm, partyVm),
          Expanded(
            child: reportVm.profitLossLoading
                ? const Center(child: CircularProgressIndicator())
                : reportVm.profitLossList.isEmpty
                ? const Center(child: Text("No records found"))
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: reportVm.profitLossList.length,              itemBuilder: (ctx, i) {


                final item = reportVm.profitLossList[i];

                return ReportCard(
                  data: item.toJson(),
                  title: "Bill No: ${item.salesBillNo ?? ""}",
                  dateKey: "SalesDate",
                  dateLabel: "Date",
                  accentColor: primary,
                  fields: const {
                    "Customer": "CustomerName",
                    "PayType": "PayType",
                    "Qty": "TotalQty",
                    "Bill Amt": "BillAmt",
                    "Margin": "Margin",
                    "GST Amt": "TaxAmount",
                    "Profit/Loss": "ProfitLoss",
                  },
                );
              },
            ),
          ),


          // Totals Footer
          if (reportVm.profitLossTotals != null) _buildTotals(reportVm),
        ],
      ),
    );
  }


  Widget _totalCell(
      String value, {
        int flex = 2,
        bool isHeader = false,
        bool isProfit = false,
      }) {
    double? profitVal =
    isProfit ? double.tryParse(value.replaceAll("₹", "")) : null;

    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isHeader ? primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHeader
                ? Colors.white
                : isProfit && profitVal != null && profitVal < 0
                ? Colors.red
                : Colors.black87,
          ),
        ),
      ),
    );
  }


  // ============================================================
  // Filter Panel
  // ============================================================
  Widget _buildFilterPanel(
      AccountReportViewmodel reportVm, SalesInvoiceViewmodel partyVm) {
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

          // Customer Dropdown
          DropdownButtonFormField<int>(
            value: selCustomerId,
            isExpanded: true,
            menuMaxHeight: 258,
            decoration: InputDecoration(
              labelText: "Customer",
              isDense: true,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text("All Customers",
                    style: TextStyle(color: Colors.grey)),
              ),
              ...partyVm.partyList.map((PartyModel e) {
                return DropdownMenuItem<int>(
                  value: e.partyId,
                  child: Text(e.partyName ?? ""),
                );
              }).toList(),
            ],
            onChanged: (v) => setState(() => selCustomerId = v),
          ),

          const SizedBox(height: 10),

          // PayType Dropdown + Search Button
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: selPayType,
                  isExpanded: true,
                  menuMaxHeight: 258,
                  decoration: InputDecoration(
                    labelText: "PayType",
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("All PayTypes",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    ...payTypes.map((e) {
                      return DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                  ],
                  onChanged: (v) => setState(() => selPayType = v),
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

  // ============================================================
  // Totals Footer
  // ============================================================
  Widget _buildTotals(AccountReportViewmodel vm) {
    final t = vm.profitLossTotals!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _footItem("Qty", (t.totalQtyTotal ?? 0).toString()),
          _footItem("Bill", "₹${(t.billAmtTotal ?? 0)}"),
          _footItem("Margin", "₹${(t.marginTotal ?? 0)}"),
          _footItem("GST", "₹${(t.taxAmountTotal ?? 0)}"),
          _footItem(
            "Profit/Loss",
            "₹${(t.profitLossTotal ?? 0).toStringAsFixed(2)}",
          ),
        ],
      ),
    );
  }

  Widget _footItem(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
