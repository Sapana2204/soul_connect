import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../model/customerForCustomerStatement_model.dart';
import '../model/customerStatement_model.dart';

import '../res/widgets/reports_card.dart';
import '../utils/app_colors.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/sales_report_view_model.dart';

class CustomerStatementReportScreen extends StatefulWidget {
  const CustomerStatementReportScreen({super.key});

  @override
  State<CustomerStatementReportScreen> createState() =>
      _CustomerStatementReportScreenState();
}

class _CustomerStatementReportScreenState
    extends State<CustomerStatementReportScreen> {
  DateTimeRange _dateRange =
  DateTimeRange(start: DateTime.now(), end: DateTime.now());

  int? selCustomerId;
  String? selCustomerName;
  CustomerForCustomerStatementModel? selectedCustomer;

  // CASH / CREDIT Toggle
  String selSalesType = "CASH";
  final List<String> salesTypes = ["CASH", "CREDIT"];

  @override
  void initState() {
    super.initState();

    _dateRange = _getFinancialYearRange();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SalesReportViewModel>();
      vm.fetchCashCustomers();
    });
  }

  DateTimeRange _getFinancialYearRange() {
    DateTime now = DateTime.now();
    DateTime startFY;
    DateTime endFY;

    if (now.month >= 4) {
      startFY = DateTime(now.year, 4, 1);
      endFY = DateTime(now.year + 1, 3, 31);
    } else {
      startFY = DateTime(now.year - 1, 4, 1);
      endFY = DateTime(now.year, 3, 31);
    }

    return DateTimeRange(start: startFY, end: endFY);
  }

  // ============================================================
  // PDF Generation & Print Logic
  // ============================================================
  Future<void> _generatePdf(SalesReportViewModel vm) async {
    final pdf = pw.Document();
    final data = vm.customerStatementList;

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data available to export")),
      );
      return;
    }

    final dateStr =
        "${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}";

    // Remove TOTAL from list
    final normalList = data
        .where((e) => (e.customerName ?? "").toUpperCase() != "TOTAL")
        .toList();

    // Get TOTAL item
    CustomerStatementModel? totalItem;
    for (var e in data) {
      if ((e.customerName ?? "").toUpperCase() == "TOTAL") {
        totalItem = e;
        break;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),

        build: (pw.Context context) => [

          /// ================= HEADER =================
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Customer Statement Report",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "Period: $dateStr  |  Type: $selSalesType",
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          /// ================= TABLE =================
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),

            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.blueGrey800),

            cellStyle: const pw.TextStyle(fontSize: 9),

            headers: const [
              "Bill No",
              "Date",
              "Customer",
              "Bill Amt",
            ],

            data: normalList.map((item) {

              String date = "";
              if (item.salesDate != null && item.salesDate!.isNotEmpty) {
                date = DateFormat("dd/MM/yyyy")
                    .format(DateTime.parse(item.salesDate!));
              }

              return [
                item.salesBillNo ?? "",
                date,
                item.customerName ?? "",
                "₹ ${(item.netAmt ?? 0).toStringAsFixed(2)}",
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          /// ================= TOTAL =================
          if (totalItem != null)
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "TOTAL : ₹ ${(totalItem.netAmt ?? 0).toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );

    /// ================= PDF PREVIEW =================
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // ============================================================
  // Search
  // ============================================================
  void _onSearch(SalesReportViewModel vm) {
    String from = DateFormat('yyyy-MM-dd').format(_dateRange.start);
    String to = DateFormat('yyyy-MM-dd').format(_dateRange.end);
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final userIdString = loginVM.userId;
    final userId = int.tryParse(userIdString ?? '0') ?? 0;
    vm.fetchCustomerStatementSummary(
      fromDate: from,
      toDate: to,
      customerId: selCustomerId??0,   // 🔥 VERY IMPORTANT
      userId: 1,
      customerName: selCustomerName, // ✅ ADD THIS
    );
  }

  // ============================================================
  // Clear
  // ============================================================
  void _clearFilters(SalesReportViewModel vm) {
    setState(() {
      selectedCustomer = null;   // ✅ ADD THIS
      selCustomerId = null;
      selCustomerName = null;
      selSalesType = "CASH";
      _dateRange = _getFinancialYearRange(); // 🔥 FIXED
      vm.clearData();
    });
    vm.fetchCashCustomers(); // ✅ reload dropdown

    // vm.fetchCustomerStatementSummary(
    //   fromDate: DateFormat('yyyy-MM-dd').format(_dateRange.start),
    //   toDate: DateFormat('yyyy-MM-dd').format(_dateRange.end),
    //   customerId: null,
    //   userId: 1,
    // );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SalesReportViewModel>(context);

    print("CASH COUNT: ${vm.cashCustomerList.length}");
    print("CREDIT COUNT: ${vm.creditCustomerList.length}");


    final normalList = vm.customerStatementList
        .where((e) => (e.customerName ?? "").toUpperCase() != "TOTAL")
        .toList();

    CustomerStatementModel? totalItem;
    for (var e in vm.customerStatementList) {
      if ((e.customerName ?? "").toUpperCase() == "TOTAL") {
        totalItem = e;
        break;
      }
    }
    return WillPopScope(
      onWillPop: () async {
        final salesReportVM =
        Provider.of<SalesReportViewModel>(context, listen: false);

        salesReportVM.clearData(); // ✅ Clear when back pressed

        return true; // allow navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Customer Statement"),
          actions: [
            IconButton(
              onPressed: () => _generatePdf(vm),
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: "Save PDF Report",
            ),
            // IconButton(
            //   onPressed: () => _generatePdf(vm, isPrint: true),
            //   icon: const Icon(Icons.print),
            //   tooltip: "Print Report",
            // ),
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
              child: vm.customerStatementLoading
                  ? const Center(child: CircularProgressIndicator())
                  : normalList.isEmpty
                  ? const Center(child: Text("No records found"))
                  : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: normalList.length,
                      itemBuilder: (ctx, i) {
                        final item = normalList[i];

                        return ReportCard(
                          data: item.toJson(),
                          title: "Bill No: ${item.salesBillNo ?? ""}",
                          dateKey: "SalesDate",
                          dateLabel: "Date",
                          accentColor: primary,
                          fields: const {
                            "Customer": "CustomerName",
                            "Bill Amt": "NetAmt",
                          },
                        );
                      },
                    ),
                  ),

                  // 🔥 TOTAL SECTION
                  if (totalItem != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "TOTAL",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹ ${(totalItem.netAmt ?? 0).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Filter Panel
  // ============================================================
  Widget _buildFilterPanel(SalesReportViewModel vm) {
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
          // ==========================
          // CASH / CREDIT TOGGLE
          // ==========================
          Row(
            children: [
              Expanded(
                child: ToggleButtons(
                  isSelected: salesTypes.map((e) => e == selSalesType).toList(),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: primary,
                  color: Colors.black87,
                  constraints: const BoxConstraints(minHeight: 42),
                  onPressed: (index) {
                    setState(() {
                      selSalesType = salesTypes[index];
                      selectedCustomer = null; // ✅ MUST ADD
                      selCustomerId = null;
                      selCustomerName = null;
                    });

                    if (selSalesType == "CASH") {
                      vm.fetchCashCustomers();
                    } else {
                      vm.fetchCreditCustomers();
                    }
                  },
                  children: salesTypes
                      .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      e,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),


          // ==========================
          // DATE RANGE
          // ==========================
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


          // ==========================
          // Customer Dropdown
          // ==========================

          DropdownButtonFormField<CustomerForCustomerStatementModel?>(
            value: selectedCustomer,

            isExpanded: true,
            menuMaxHeight: 300,

            decoration: InputDecoration(
              labelText: "Customer",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            items: [
              const DropdownMenuItem<CustomerForCustomerStatementModel?>(
                value: null,
                child: Text("All Customers"),
              ),

              ...(selSalesType == "CASH"
                  ? vm.cashCustomerList
                  : vm.creditCustomerList)
                  .where((e) => (e.partyName ?? "").trim().isNotEmpty)
                  .map((e) => DropdownMenuItem<CustomerForCustomerStatementModel?>(
                value: e,
                child: Text(e.partyName!),
              ))
                  .toList(),
            ],

            onChanged: (val) {
              setState(() {
                selectedCustomer = val;
                selCustomerId = val?.partyId;
                selCustomerName = val?.partyName;
              });
              // _onSearch(vm);
            },
          ),

          const SizedBox(height: 10),

          // ==========================
          // Search Button
          // ==========================
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _onSearch(vm),
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text(
                      "Search",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
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
