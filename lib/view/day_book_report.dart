import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/viewModel/account_report_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';

class DayBookReportScreen extends StatefulWidget {
  const DayBookReportScreen({Key? key}) : super(key: key);

  @override
  State<DayBookReportScreen> createState() =>
      _DayBookReportScreenState();
}

class _DayBookReportScreenState extends State<DayBookReportScreen> {
  DateTimeRange? selectedDateRange;
  int? selectedUserId;
  String? selectedUserName;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    selectedDateRange = DateTimeRange(start: today, end: today);

    Future.microtask(() {
      context.read<AccountReportViewmodel>().fetchUsers();
    });
  }

  /// 🔹 Date Picker
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
      _fetchDayBook();
    }
  }

  /// 🔹 Call your DayBook API here
  void _fetchDayBook() {
    if (selectedDateRange == null || selectedUserId == null) return;

    final fromDate =
    DateFormat("yyyy-MM-dd").format(selectedDateRange!.start);
    final toDate =
    DateFormat("yyyy-MM-dd").format(selectedDateRange!.end);

    final vm = context.read<AccountReportViewmodel>();

    vm.fetchDayBookReport(
      fromDate: fromDate,
      toDate: toDate,
      userId: selectedUserId!,
    );

    vm.fetchDayBookSummaryReport(   // ✅ NEW CALL
      fromDate: fromDate,
      toDate: toDate,
      userId: selectedUserId!,
    );
  }

  /// 🔹 PDF GENERATE
  Future<void> _generatePDF() async {
    final vm = context.read<AccountReportViewmodel>();

    if (vm.dayBookList.isEmpty) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Day Book Report",
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: [
              "Date",
              "Time",
              "Vch No",
              "Party",
              "Transaction",
              "PayType",
              "Amount",
              "Debit",
              "Credit"
            ],
            data: vm.dayBookList.map((e) {
              return [
                e.vchDate ?? '',
                e.vchTime ?? '',
                e.vchNo ?? '',
                e.party ?? '',
                e.transaction ?? '',
                e.payMode ?? '',
                (e.amount ?? 0).toString(),
                (e.debit ?? 0).toString(),
                (e.credit ?? 0).toString(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/daybook.pdf");

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  /// 🔹 PRINT
  Future<void> _printPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Center(child: pw.Text("Day Book Report")),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeText =
        '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} → ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';



    return Scaffold(
      appBar: AppBar(
        title: const Text("Day Book Report"),
        backgroundColor: primary,
        actions: [
          IconButton(
              onPressed: _generatePDF,
              icon: const Icon(Icons.picture_as_pdf)),
          IconButton(
              onPressed: _printPDF,
              icon: const Icon(Icons.print)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 FILTER CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8)
                ],
              ),
              child: Row(
                children: [
                  /// ✅ FIXED: wrapped with Expanded
                  Expanded(
                    child: Consumer<AccountReportViewmodel>(
                      builder: (context, vm, _) {

                        if (vm.userLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (vm.userList.isEmpty) {
                          return const Text("No Users Found");
                        }

                        /// ✅ AUTO SELECT FIRST USER
                        if (selectedUserId == null) {
                          final firstUser = vm.userList.first;

                          selectedUserId = firstUser.userId;
                          selectedUserName = firstUser.userName;

                          /// 🔥 Call API after setting default
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _fetchDayBook();
                          });
                        }

                        return DropdownButtonFormField<int>(
                          value: selectedUserId,
                          hint: const Text("Select User"),
                          items: vm.userList.map((user) {
                            return DropdownMenuItem<int>(
                              value: user.userId,
                              child: Text(user.userName ?? ""),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final selectedUser =
                            vm.userList.firstWhere((u) => u.userId == val);

                            setState(() {
                              selectedUserId = val;
                              selectedUserName = selectedUser.userName;
                            });

                            _fetchDayBook();
                          },
                          decoration: InputDecoration(
                            labelText: "User",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// DATE RANGE
                  Expanded(
                    child: InkWell(
                      onTap: _pickDateRange,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Date Range",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(dateRangeText),
                      ),
                    ),
                  ),
                ],
              )
            ),

            const SizedBox(height: 12),

            /// 🔹 LIST
            Expanded(
              child: Consumer<AccountReportViewmodel>(
                builder: (context, vm, _) {
                  if (vm.dayBookLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.dayBookList.isEmpty) {
                    return const Center(child: Text("No data available"));
                  }

                  double totalAmount = 0;
                  double totalDebit = 0;
                  double totalCredit = 0;

                  for (var item in vm.dayBookList) {
                    totalAmount += item.amount ?? 0;
                    totalDebit += item.debit ?? 0;
                    totalCredit += item.credit ?? 0;
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: vm.dayBookList.length,
                          itemBuilder: (context, index) {
                            final item = vm.dayBookList[index];

                            return ReportCard(
                              title: item.party ?? '',
                              data: {
                                "date": item.vchDate ?? '',
                                "time": item.vchTime ?? '',
                                "vchNo": item.vchNo ?? '',
                                "party": item.party ?? '',
                                "transaction": item.transaction ?? '',
                                "payType": item.payMode ?? '',
                                "amount": item.amount ?? 0,
                                "debit": item.debit ?? 0,
                                "credit": item.credit ?? 0,
                              },
                              dateKey: 'date',
                              dateLabel: 'Date',
                              fields: const {
                                "Time": "time",
                                "Vch No": "vchNo",
                                "Transaction": "transaction",
                                "PayType": "payType",
                                "Amount": "amount",
                                "Debit": "debit",
                                "Credit": "credit",
                              },
                              accentColor: primary,
                            );
                          },
                        ),
                      ),

                      /// TOTALS
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Day Book Summary",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,color: primary, fontSize: 16)),
                                IconButton(
                                  icon: Icon(
                                      _isExpanded ? Icons.remove : Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                )
                              ],
                            ),

                            if (_isExpanded)
                              Column(
                                children: [
                                  ...vm.dayBookSummaryList.map((e) {
                                    return Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                e.payMode ?? "Unknown",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text("Dr: ₹${(e.debit ?? 0).toStringAsFixed(2)}"),
                                                  Text("Cr: ₹${(e.credit ?? 0).toStringAsFixed(2)}"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  }).toList(),

                                  const SizedBox(height: 8),


                                ],
                              )
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text("₹ ${value.toStringAsFixed(2)}"),
        ],
      ),
    );
  }
}