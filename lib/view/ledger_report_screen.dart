import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/ledger_report_request.dart';
import '../utils/app_colors.dart';
import '../res/widgets/reports_card.dart';
import 'dart:io';

import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter_soulconnect/viewModel/account_report_viewmodel.dart';


class LedgerReportScreen extends StatefulWidget {
  const LedgerReportScreen({Key? key}) : super(key: key);

  @override
  State<LedgerReportScreen> createState() => _LedgerReportScreenState();
}

class _LedgerReportScreenState extends State<LedgerReportScreen> {
  DateTimeRange? selectedDateRange;

  int? selectedLedgerId;
  String? selectedLedgerName;

  bool _isInit = true;

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }


  @override
  void initState() {
    super.initState();

    // ✅ Set default to current financial year
    selectedDateRange = _getCurrentFinancialYear();
  }

  @override
  void dispose() {
    context.read<AccountReportViewmodel>().clearLedgerReport();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      final ledgerVM =
      Provider.of<AccountReportViewmodel>(context, listen: false);

      ledgerVM.getLedgernameApi(); // 🔹 Ledger dropdown API

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchLedgerReport();
      });

      _isInit = false;
    }
  }

  Future<void> _generateAndSavePDF() async {
    final pdf = await _buildLedgerReportPDF();

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/Ledger_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  Future<pw.Document> _buildLedgerReportPDF() async {
    final pdf = pw.Document();
    final vm = context.read<AccountReportViewmodel>();
    final ledgerItems = vm.ledgerList;

    final fromDate =
    DateFormat('dd/MM/yyyy').format(selectedDateRange!.start);
    final toDate =
    DateFormat('dd/MM/yyyy').format(selectedDateRange!.end);

    final openingBalance = ledgerItems.isNotEmpty
        ? _parseAmount(ledgerItems.first.currentClosing)
        : 0;

    final closingBalance = ledgerItems.isNotEmpty
        ? _parseAmount(ledgerItems.last.currentClosing)
        : 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [
          // 🔹 TITLE
          pw.Center(
            child: pw.Text(
              'Ledger Report',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 6),

          // 🔹 LEDGER NAME
          pw.Center(
            child: pw.Text(
              selectedLedgerName ?? '',
              style: pw.TextStyle(fontSize: 11),
            ),
          ),

          pw.SizedBox(height: 8),

          // 🔹 DATE RANGE + BALANCES
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From: $fromDate', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('To: $toDate', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Opening: ${openingBalance.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Closing: ${closingBalance.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // 🔹 LEDGER TABLE
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
              'Date',
              'Voucher No',
              'Type',
              'Debit',
              'Credit',
              'Closing',
              'Narration',
            ],
            columnWidths: const {
              0: pw.FlexColumnWidth(1.5),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1.2),
              4: pw.FlexColumnWidth(1.2),
              5: pw.FlexColumnWidth(1.5),
              6: pw.FlexColumnWidth(3),
            },
            data: ledgerItems.map((item) {
              return [
                item.vchDate ?? '',
                item.vchNo ?? '',
                item.voucherType ?? '',
                item.debit?.toString() ?? '',
                item.credit?.toString() ?? '',
                item.currentClosing?.toString() ?? '',
                item.narration ?? '',
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 8),

          // 🔹 FOOTER
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

  Future<void> _printReport() async {
    final pdf = await _buildLedgerReportPDF();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  DateTimeRange _getCurrentFinancialYear() {
    final now = DateTime.now();

    // Financial year starts on 1st April
    final fyStart = (now.month >= 4)
        ? DateTime(now.year, 4, 1)
        : DateTime(now.year - 1, 4, 1);

    final fyEnd = DateTime(fyStart.year + 1, 3, 31);

    return DateTimeRange(start: fyStart, end: fyEnd);
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
      _fetchLedgerReport();
    }
  }

  /// 🔹 DATA API WILL BE ADDED LATER
  void _fetchLedgerReport() {
    if (selectedDateRange == null || selectedLedgerId == null) return;

    final request = LedgerReportRequest(
      fromDate: DateFormat('yyyy-MM-dd').format(selectedDateRange!.start),
      toDate: DateFormat('yyyy-MM-dd').format(selectedDateRange!.end),
      ledgerId: selectedLedgerId!,
    );

    context.read<AccountReportViewmodel>().fetchLedgerReport(request);
  }


  bool _validateAndFetch() {
    if (selectedLedgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a ledger first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    final fromDate =
    DateFormat('yyyy-MM-dd').format(selectedDateRange!.start);
    final toDate =
    DateFormat('yyyy-MM-dd').format(selectedDateRange!.end);

    final vm = context.read<AccountReportViewmodel>();

    // 🔹 1. Ledger Report
    vm.fetchLedgerReport(
      LedgerReportRequest(
        fromDate: fromDate,
        toDate: toDate,
        ledgerId: selectedLedgerId!,
      ),
    );

    // 🔹 2. Opening & Closing Balance API
    vm.fetchOpeningAndClosingBalance(
      ledgerId: selectedLedgerId!,
      fromDate: fromDate,
      toDate: toDate,
    );

    return true;
  }


  @override
  Widget build(BuildContext context) {
    final ledgerVM = Provider.of<AccountReportViewmodel>(context);
    final ledgers = ledgerVM.ledgernameList;

    // ✅ Convert ledger objects → list of names
    final ledgerNames = ledgers
        .map((e) => e.ledgerName ?? "")
        .where((name) => name.isNotEmpty)
        .toList();

    final dateRangeText =
        '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} → '
        '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';

    return WillPopScope(
      onWillPop: () async {
        context.read<AccountReportViewmodel>().clearLedgerReport();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primary,
          title: const Text(
            "Ledger Report",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              tooltip: "Export PDF",
              color: Colors.white,
              onPressed: _generateAndSavePDF,
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
            IconButton(
              tooltip: "Print",
              color: Colors.white,
              onPressed: _printReport,
              icon: const Icon(Icons.print_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Container(
          color: const Color(0xFFF5F7FA),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 🔹 Filter Card
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),


                  child: Column(
                    children: [
                      Row(
                        children: [
                          // 🔹 Ledger Dropdown
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 58,
                              child: _buildSearchableDropdown(
                                "Ledger",
                                ledgerNames,
                                selectedLedgerName,
                                    (value) {
                                  setState(() {
                                    selectedLedgerName = value;

                                    final ledger = ledgers.firstWhere(
                                          (l) => l.ledgerName == value,
                                    );

                                    selectedLedgerId = ledger.ledgerId;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 58,
                              child: InkWell(
                                onTap: _pickDateRange,
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date Range',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.date_range, color: primary, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dateRangeText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // ✅ shows both dates properly
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 12),

                      // 🔍 SEARCH BUTTON (CENTERED)
                      Center(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.search, size: 18,color: Colors.white,),
                            label: const Text(
                              'Search',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _validateAndFetch,

                          ),
                        ),
                      ),
                    ],
                  ),

                ),

                const SizedBox(height: 16),

                // 🔹 Ledger Report Data (placeholder)
                Expanded(
                  child: Consumer<AccountReportViewmodel>(
                    builder: (context, vm, _) {
                      if (vm.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: primary,
                            strokeWidth: 3,
                          ),
                        );
                      }

                      if (vm.error != null) {
                        return Center(
                          child: Text(
                            vm.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (vm.ledgerList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No ledger data found',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      // final openingBalance = vm.openingBalance ?? 0;
                      // final closingBalance = vm.closingBalance ?? 0;
                      final openingBalance = vm.openingBalance ?? 0;

                      double runningBalance = openingBalance;

                      final processedLedgerList = vm.ledgerList.map((item) {
                        final debit = _parseAmount(item.debit);
                        final credit = _parseAmount(item.credit);

                        runningBalance = runningBalance + debit - credit;

                        final json = item.toJson();
                        json['CurrentClosing'] = runningBalance.abs().toStringAsFixed(2);

                        return json;
                      }).toList();

                      final closingBalance = runningBalance;

                      return Column(
                        children: [
                          // 🔹 OPENING & CLOSING BALANCE CARD
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _balanceColumn(
                                  "Opening Balance",
                                  openingBalance,
                                  Colors.green.shade700,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                _balanceColumn(
                                  "Closing Balance",
                                  closingBalance,
                                  Colors.red.shade700,
                                ),
                              ],
                            ),
                          ),

                          // 🔹 LEDGER LIST
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 12),
                              itemCount: processedLedgerList.length,
                              itemBuilder: (context, index) {
                                final item = processedLedgerList[index];


                                return ReportCard(
                                  accentColor: primary,
                                  data: item,
                                  title: item['VchNo'] ?? '',                                  dateKey: 'VchDate',
                                  dateLabel: 'Vch Date',
                                  fields: const {
                                    'Type': 'VoucherType',
                                    'Debit': 'Debit',
                                    'Credit': 'Credit',
                                    'Closing': 'CurrentClosing',
                                    'Pay Mode': 'PayMode',
                                    'Dr/Cr': 'DrCrType',
                                    'Narration': 'Narration',
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                      },
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  Widget _buildSearchableDropdown(
      String label,
      List<String> items,
      String? value,
      Function(String?) onChanged, {
        bool isLoading = false,
      }) {
    if (isLoading) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: lightGrey),
          borderRadius: BorderRadius.circular(8),
          color: white,
        ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ""),

      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return items;
        }

        return items.where((item) =>
            item.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },

      onSelected: (selection) {
        onChanged(selection);
      },

      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Select $label",
            suffixIcon: const Icon(Icons.arrow_drop_down), // dropdown arrow
            labelStyle: TextStyle(color: grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
            filled: true,
            fillColor: white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          onTap: () {
            focusNode.requestFocus(); // open dropdown suggestions
          },
        );
      },

      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              width: MediaQuery.of(context).size.width * 0.4,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);

                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _balanceColumn(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          NumberFormat.currency(symbol: "₹ ").format(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
