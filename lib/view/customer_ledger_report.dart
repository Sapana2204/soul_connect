import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/viewModel/sales_report_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewModel/login_viewmodel.dart';
import '../viewModel/sales_invoice_viewmodel.dart';

class CustomerLedgerReport extends StatefulWidget {
  @override
  _CustomerLedgerReportState createState() =>
      _CustomerLedgerReportState();
}

class _CustomerLedgerReportState extends State<CustomerLedgerReport>
    with SingleTickerProviderStateMixin {
  String selectedCustomer = "";
  DateTimeRange? selectedDateRange;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    Provider.of<SalesInvoiceViewmodel>(context, listen: false).getPartyApi();

    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.month >= 4 ? now.year : now.year - 1, 4, 1),
      end: DateTime(now.month >= 4 ? now.year + 1 : now.year, 3, 31),
    );
  }
  // @override
  // void initState() {
  //   super.initState();
  //   Provider.of<SalesInvoiceViewmodel>(context, listen: false)
  //       .getPartyApi();
  //
  //   final now = DateTime.now();
  //
  //   selectedDateRange = DateTimeRange(
  //     start: DateTime(now.month >= 4 ? now.year : now.year - 1, 4, 1),
  //     end: DateTime(now.month >= 4 ? now.year + 1 : now.year, 3, 31),
  //   );
  // }

  double outstandingBalance = 0.0;
  @override
  void dispose() {
    Provider.of<SalesReportViewModel>(context, listen: false).clearData();
    Provider.of<SalesInvoiceViewmodel>(context, listen: false).clearLedger();

    super.dispose();
  }


  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedDateRange ??
          DateTimeRange(
            start: DateTime(now.year, 4, 1),
            end: DateTime(now.year + 1, 3, 31),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });

      /// 🔥 CALL API ONLY IF CUSTOMER SELECTED
      if (selectedCustomer.isNotEmpty) {
        await _loadLedgerData();
      }
    }
  }

  Future<void> _loadLedgerData() async {
    final salesVm =
    Provider.of<SalesInvoiceViewmodel>(context, listen: false);

    final reportVm =
    Provider.of<SalesReportViewModel>(context, listen: false);

    final loginVM =
    Provider.of<LoginViewModel>(context, listen: false);

    if (salesVm.partyList.isEmpty) return;

    final selectedParty = salesVm.partyList.firstWhere(
          (p) => p.partyName == selectedCustomer,
      orElse: () => salesVm.partyList.first,
    );

    final now = DateTime.now();

    final fromDate = selectedDateRange != null
        ? DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)
        : DateFormat('yyyy-MM-dd').format(DateTime(now.year, 4, 1));

    final toDate = selectedDateRange != null
        ? DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)
        : DateFormat('yyyy-MM-dd').format(DateTime(now.year + 1, 3, 31));

    final userId =
        int.tryParse(loginVM.userId ?? '0') ?? 0;

    await Future.wait([
      salesVm.getLedgerBalanceApi(
        ledgerId: selectedParty.ledgerId ?? 0,
        balanceAsOn: toDate,
        balanceType: "T",
      ),

      reportVm.fetchCustomerStatementSummary(
        fromDate: fromDate,
        toDate: toDate,
        customerId: selectedParty.partyId,
      ),

      reportVm.getReceipts(
        fromDate: fromDate,
        toDate: toDate,
        ledgerId: selectedParty.ledgerId ?? 0,
        userId: userId,
      ),
    ]);

    setState(() {
      outstandingBalance =
          (salesVm.ledgerBalance?.balance ?? 0.0).toDouble();
    });
  }
  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Widget _buildSearchableDropdown(
      String label,
      List<String> items,
      String? value,
      Function(String?) onChanged, {
        bool isLoading = false,
      }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
      onSelected: (selection) => onChanged(selection),

      /// ✅ FIX: Proper overlay with visible width
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }

        final double fieldWidth = MediaQuery.of(context).size.width * 0.67;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: fieldWidth,
                maxHeight: 250, // ✅ prevents overflow
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },

      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Search $label",
            suffixIcon: const Icon(Icons.arrow_drop_down),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesVm = Provider.of<SalesReportViewModel>(context);
    double totalSales = 0;
    double totalReceipts = 0;

    for (var item in salesVm.customerStatementList) {
      if (item.customerName != "TOTAL") {
        totalSales += (item.netAmt ?? 0);
      }
    }

    for (var item in salesVm.receiptList) {
      totalReceipts += (item.vchAmt ?? 0);
    }
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          Provider.of<SalesReportViewModel>(context, listen: false).clearData();
          Provider.of<SalesInvoiceViewmodel>(context, listen: false).clearLedger();
          return true; // allow navigation
        },

          child: Scaffold(
      appBar: AppBar(
      title: const Text("Customer Ledger"),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: "Sales"),
          Tab(text: "Receipts"),
        ],
      ),
    ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  border: const Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tabController.index == 0
                          ? "Total Sales"
                          : "Total Receipts",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "₹ ${NumberFormat('#,##0.00').format(_tabController.index == 0 ? totalSales : totalReceipts)}" ,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          body: Column(
            children: [
              /// 🔹 Header Section
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    /// Customer Dropdown
                    Row(
                      children: [
                        const Text("Customer: ",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Expanded(
                          child:  Consumer<SalesInvoiceViewmodel>(
                            builder: (context, vm, _) {
                              if (vm.loading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              return _buildSearchableDropdown(
                                "Customer Name",
                                vm.partyList.map((e) => e.partyName ?? "").toList(),
                                selectedCustomer,
                                    (value) async {
                                  if (value == null) return;

                                  final viewModel =
                                  Provider.of<SalesInvoiceViewmodel>(context, listen: false);

                                  final reportVm =
                                  Provider.of<SalesReportViewModel>(context, listen: false);

                                  setState(() {
                                    selectedCustomer = value;
                                  });

                                  await _loadLedgerData();

                                  setState(() {
                                    outstandingBalance =
                                        (viewModel.ledgerBalance?.balance ?? 0.0).toDouble();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Date + Balance Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _pickDateRange,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.date_range, size: 16, color: Colors.deepPurple),
                                const SizedBox(width: 6),
                                Text(
                                  selectedDateRange == null
                                      ? "Select Date Range"
                                      : "${formatDate(selectedDateRange!.start)}  →  ${formatDate(selectedDateRange!.end)}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Consumer<SalesInvoiceViewmodel>(
                          builder: (context, vm, _) {
                            return Text(
                              "₹${outstandingBalance.abs()}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// 🔹 Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    /// Sales Statement
                    Consumer<SalesReportViewModel>(
                      builder: (context, vm, _) {
                        if (vm.customerStatementLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (vm.customerStatementList.isEmpty) {
                          return const Center(child: Text("No Sales Data"));
                        }

                        return ListView.builder(
                          itemCount: vm.customerStatementList.length,
                          itemBuilder: (context, index) {
                            final item = vm.customerStatementList[index];

                            /// 🚫 Skip TOTAL row
                            if (item.customerName == "TOTAL") {
                              return const SizedBox();
                            }

                            return _buildCompactCard(
                              title: item.salesBillNo ?? "-",
                              date: item.salesDate != null
                                  ? DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(item.salesDate!))
                                  : "-",
                              typeLabel: "Type",
                              typeValue: item.salesType ?? "-",
                              amount: (item.netAmt ?? 0).toInt(),
                            );
                          },
                        );
                      },
                    ),
                    // ListView.builder(
                    //   itemCount: salesStatement.length,
                    //   itemBuilder: (context, index) {
                    //     final item = salesStatement[index];
                    //     return _buildCompactCard(
                    //       title: item["billNo"],
                    //       date: item["date"],
                    //       typeLabel: "Pay Type",
                    //       typeValue: item["payType"],
                    //       amount: item["amount"],
                    //     );
                    //   },
                    // ),

                    /// Receipts
                    Consumer<SalesReportViewModel>(
                      builder: (context, vm, _) {
                        if (vm.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (vm.receiptList.isEmpty) {
                          return const Center(child: Text("No Receipts Data"));
                        }

                        return ListView.builder(
                          itemCount: vm.receiptList.length,
                          itemBuilder: (context, index) {
                            final item = vm.receiptList[index];

                            return _buildCompactCard(
                              title: item.vchNo ?? "-",
                              date: item.vchDate != null
                                  ? DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(item.vchDate!.toIso8601String()))
                                  : "-",
                              typeLabel: "Mode",
                              typeValue: item.payMode ?? "-",
                              amount: (item.vchAmt ?? 0).toInt(),
                            );
                          },
                        );
                      },
                    )
                    // ListView.builder(
                    //   itemCount: receipts.length,
                    //   itemBuilder: (context, index) {
                    //     final item = receipts[index];
                    //     return _buildCompactCard(
                    //       title: item["vchNo"],
                    //       date: item["date"],
                    //       typeLabel: "Mode",
                    //       typeValue: item["mode"],
                    //       amount: item["amount"],
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Reusable Compact Card
  Widget _buildCompactCard({
    required String title,
    required String date,
    required String typeLabel, // Pay Type / Mode
    required String typeValue,
    required int amount,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Top Row (Bill No + Amount)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  "₹$amount",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// 🔹 Bottom Row (Date + Pay Type/Mode)
            Row(
              children: [
                _infoItem("Date", date),
                const SizedBox(width: 12),
                _infoItem(typeLabel, typeValue),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _infoItem(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}