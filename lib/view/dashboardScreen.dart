import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/res/widgets/gif_loader.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';

import '../viewmodel/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currencyCompact = NumberFormat.compactCurrency(
    decimalDigits: 0,
    symbol: '₹ ',
  );

  final _productHeaderScrollCtrl = ScrollController();
  final _productBodyScrollCtrl = ScrollController();
  bool _isSyncingScroll = false;

  @override
  void dispose() {
    _productHeaderScrollCtrl.dispose();
    _productBodyScrollCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DashboardViewModel>(context, listen: false)
            .fetchDashboardData());


  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return const Scaffold(
            body: Center(child: GifLoader()),
          );
        }

        if (vm.error.isNotEmpty) {
          return Scaffold(
            body: Center(child: Text(vm.error)),
          );
        }

        // --- Safety: null/zero handling ---
        final salesTotal =
            (vm.salesSummary.total) <= 0 ? 0.0 : vm.salesSummary.total;
        final purchaseTotal =
            (vm.purchaseSummary.total) <= 0 ? 0.0 : vm.purchaseSummary.total;
        final maxAmount = [salesTotal, purchaseTotal]
            .fold<double>(0.0, (a, b) => a > b ? a : b);
        final hasMoneyData = (salesTotal + purchaseTotal) > 0;

        // Sales split
        final salesCash =
            vm.salesSummary.cash <= 0 ? 0.0 : vm.salesSummary.cash;
        final salesCredit =
            vm.salesSummary.credit <= 0 ? 0.0 : vm.salesSummary.credit;
        final salesBank =
            vm.salesSummary.bank <= 0 ? 0.0 : vm.salesSummary.bank;
        final salesModeTotal = salesCash + salesCredit + salesBank;

        final customersCount = (vm.customers.length).toDouble();
        final suppliersCount = (vm.suppliers.length).toDouble();
        final partyTotal = customersCount + suppliersCount;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xffF4F6FA),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      "Dashboard",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ), */
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF246BFD), Color(0xFF5B8DEF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF246BFD).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      tabs: const [
                        Tab(text: "Tabular Dashboard"),
                        Tab(text: "Analytical Dashboard"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 1. Tabular Dashboard
                        _buildTabularDashboard(vm, salesTotal, purchaseTotal,
                            salesCash, salesCredit, salesBank),
                        // 2. Analytical Dashboard
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// SALES VS PURCHASE (Bar)
                              _buildCard(
                                title: "Sales vs Purchase",
                                trailing: hasMoneyData
                                    ? Text(
                                        "Max: ${_currencyCompact.format(maxAmount)}",
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      )
                                    : null,
                                child: SizedBox(
                                  height: 280,
                                  child: hasMoneyData
                                      ? BarChart(
                                          BarChartData(
                                            maxY: _niceMaxY(maxAmount),
                                            barTouchData: BarTouchData(
                                              enabled: true,
                                              touchTooltipData:
                                                  BarTouchTooltipData(
                                                tooltipRoundedRadius: 8,
                                                getTooltipItem: (group,
                                                    groupIndex, rod, rodIndex) {
                                                  final label = group.x == 0
                                                      ? 'Sales'
                                                      : 'Purchase';
                                                  return BarTooltipItem(
                                                    "$label\n${_currencyCompact.format(rod.toY)}",
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            alignment:
                                                BarChartAlignment.spaceAround,
                                            borderData:
                                                FlBorderData(show: false),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              getDrawingHorizontalLine: (v) =>
                                                  FlLine(
                                                color: Colors.black12,
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            titlesData: FlTitlesData(
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 62,
                                                  getTitlesWidget:
                                                      (value, meta) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 6),
                                                    child: Text(
                                                      _formatAxisMoney(value),
                                                      style: const TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                    switch (value.toInt()) {
                                                      case 0:
                                                        return const Text(
                                                            "Sales");
                                                      case 1:
                                                        return const Text(
                                                            "Purchase");
                                                    }
                                                    return const SizedBox
                                                        .shrink();
                                                  },
                                                ),
                                              ),
                                            ),
                                            barGroups: [
                                              BarChartGroupData(
                                                x: 0,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: salesTotal,
                                                    width: 36,
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4F8EF7),
                                                        Color(0xFF246BFD)
                                                      ],
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ],
                                              ),
                                              BarChartGroupData(
                                                x: 1,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: purchaseTotal,
                                                    width: 36,
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFF2ECC71),
                                                        Color(0xFF27AE60)
                                                      ],
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : _emptyState("No sales/purchase data"),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// SALES MODE DISTRIBUTION (Pie)
                              _buildCard(
                                title: "Sales Mode Distribution",
                                trailing: salesModeTotal > 0
                                    ? Text(
                                        "Total: ${_currencyCompact.format(salesModeTotal)}",
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      )
                                    : null,
                                child: SizedBox(
                                  height: 240,
                                  child: salesModeTotal > 0
                                      ? Column(
                                          children: [
                                            Expanded(
                                              child: PieChart(
                                                PieChartData(
                                                  sectionsSpace: 4,
                                                  centerSpaceRadius: 48,
                                                  startDegreeOffset: -90,
                                                  pieTouchData: PieTouchData(
                                                      enabled: true),
                                                  sections: [
                                                    _pieSection(
                                                      value: salesCash,
                                                      total: salesModeTotal,
                                                      color: Colors.blue,
                                                      label: "Cash",
                                                    ),
                                                    _pieSection(
                                                      value: salesCredit,
                                                      total: salesModeTotal,
                                                      color: Colors.orange,
                                                      label: "Credit",
                                                    ),
                                                    _pieSection(
                                                      value: salesBank,
                                                      total: salesModeTotal,
                                                      color: Colors.purple,
                                                      label: "Bank",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 8,
                                              children: [
                                                _legendDot(Colors.blue,
                                                    "Cash: ${_currencyCompact.format(salesCash)}"),
                                                _legendDot(Colors.orange,
                                                    "Credit: ${_currencyCompact.format(salesCredit)}"),
                                                _legendDot(Colors.purple,
                                                    "Bank: ${_currencyCompact.format(salesBank)}"),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        )
                                      : _emptyState("No sales mode data"),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// PRODUCT EXPIRY TREND (Bar - real data)
                              _buildCard(
                                title: "Product Expiry Timeline",
                                trailing: vm.products.isNotEmpty
                                    ? Text(
                                        "${vm.products.length} products",
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      )
                                    : null,
                                child: SizedBox(
                                  height: 280,
                                  child: vm.products.isEmpty
                                      ? _emptyState("No expiring products")
                                      : _buildExpiryBarChart(vm),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// CUSTOMERS VS SUPPLIERS (Pie)
                              _buildCard(
                                title: "Customers vs Suppliers",
                                child: SizedBox(
                                  height: 220,
                                  child: partyTotal > 0
                                      ? Column(
                                          children: [
                                            Expanded(
                                              child: PieChart(
                                                PieChartData(
                                                  sectionsSpace: 4,
                                                  centerSpaceRadius: 48,
                                                  startDegreeOffset: -90,
                                                  sections: [
                                                    _pieSection(
                                                      value: customersCount,
                                                      total: partyTotal,
                                                      color: Colors.indigo,
                                                      label: "Customers",
                                                    ),
                                                    _pieSection(
                                                      value: suppliersCount,
                                                      total: partyTotal,
                                                      color: Colors.grey,
                                                      label: "Suppliers",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 8,
                                              children: [
                                                _legendDot(Colors.indigo,
                                                    "Customers (${customersCount.toInt()})"),
                                                _legendDot(Colors.grey,
                                                    "Suppliers (${suppliersCount.toInt()})"),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        )
                                      : _emptyState("No party data"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ---------- Helpers ----------

  double _niceMaxY(double maxVal) {
    if (maxVal <= 0) return 100;
    // Round up to a nice step (power-of-10-ish)
    final magnitude = (maxVal / 1000).ceil() * 1000;
    return magnitude * 1.2;
  }

  String _formatAxisMoney(double value) {
    if (value == 0) return '0';
    if (value >= 10000000) {
      // Crore
      return '₹ ${(value / 10000000).toStringAsFixed(1)}Cr';
    }
    if (value >= 100000) {
      // Lakh
      return '₹ ${(value / 100000).toStringAsFixed(1)}L';
    }
    // Thousands
    return '₹ ${(value / 1000).toStringAsFixed(0)}K';
  }

  PieChartSectionData _pieSection({
    required double value,
    required double total,
    required Color color,
    required String label,
  }) {
    final percent = total == 0 ? 0 : (value / total * 100);
    final showTitle = percent >= 6;
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 60,
      title: showTitle ? "${percent.toStringAsFixed(0)}%" : "",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 13,
        shadows: [
          Shadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(80),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              )),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryBarChart(DashboardViewModel vm) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    int expired = 0;
    int within7 = 0;
    int within14 = 0;
    int within30 = 0;
    int beyond30 = 0;

    for (var p in vm.products) {
      try {
        final expiry = formatter.parse(p.expiryDate);
        final diff = expiry.difference(now).inDays;
        if (diff < 0) {
          expired++;
        } else if (diff <= 7) {
          within7++;
        } else if (diff <= 14) {
          within14++;
        } else if (diff <= 30) {
          within30++;
        } else {
          beyond30++;
        }
      } catch (_) {}
    }

    final buckets = [expired, within7, within14, within30, beyond30];
    final labels = ["Expired", "0-7d", "8-14d", "15-30d", "30d+"];
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
    ];
    final maxVal = buckets.fold<int>(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxVal == 0 ? 5 : (maxVal + 1).toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "${labels[group.x]}\n${rod.toY.toInt()} products",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.black12,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble() && value >= 0) {
                  return Text(value.toInt().toString(),
                      style: const TextStyle(fontSize: 11));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[idx],
                        style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        barGroups: List.generate(buckets.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: buckets[i].toDouble(),
                width: 28,
                color: colors[i],
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTabularDashboard(
    DashboardViewModel vm,
    double salesTotal,
    double purchaseTotal,
    double salesCash,
    double salesCredit,
    double salesBank,
  ) {
    final currency = NumberFormat.currency(symbol: '₹ ', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ─── SUMMARY METRIC CARDS ───
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.trending_up_rounded,
                  iconBg: const Color(0xFF246BFD),
                  label: "Total Sales",
                  value: currency.format(salesTotal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.shopping_cart_rounded,
                  iconBg: const Color(0xFF27AE60),
                  label: "Total Purchase",
                  value: currency.format(purchaseTotal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            icon: Icons.inventory_2_rounded,
            iconBg: const Color(0xFFE67E22),
            label: "Stock Quantity",
            value: vm.stockCount,
          ),

          const SizedBox(height: 20),

          /// ─── SALES VS PURCHASE BREAKDOWN ───
          _buildCard(
            title: "Sales vs Purchase Breakdown",
            child: _buildBreakdownTable(
              salesCash: salesCash,
              salesCredit: salesCredit,
              salesBank: salesBank,
              salesTotal: salesTotal,
              purchaseCash:
                  vm.purchaseSummary.cash <= 0 ? 0.0 : vm.purchaseSummary.cash,
              purchaseCredit: vm.purchaseSummary.credit <= 0
                  ? 0.0
                  : vm.purchaseSummary.credit,
              purchaseBank:
                  vm.purchaseSummary.bank <= 0 ? 0.0 : vm.purchaseSummary.bank,
              purchaseTotal: purchaseTotal,
              currency: currency,
            ),
          ),

          const SizedBox(height: 12),

          /// ─── CUSTOMERS TABLE ───
          _buildCard(
            title: "Today's Customers",
            trailing: Text(
              "${vm.customers.length} records",
              style: const TextStyle(color: Colors.black54),
            ),
            child: vm.customers.isEmpty
                ? _emptyState("No customer data available")
                : Column(
                    children: [
                      _buildCustomerHeader(),
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: _buildCustomersTable(vm, currency),
                        ),
                      ),
                      _buildCustomerFooter(vm, currency),
                    ],
                  ),
          ),

          const SizedBox(height: 12),

          /// ─── SUPPLIERS TABLE ───
          _buildCard(
            title: "Today's Suppliers",
            trailing: Text(
              "${vm.suppliers.length} records",
              style: const TextStyle(color: Colors.black54),
            ),
            child: vm.suppliers.isEmpty
                ? _emptyState("No supplier data available")
                : Column(
                    children: [
                      _buildSupplierHeader(),
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: _buildSuppliersTable(vm, currency),
                        ),
                      ),
                      _buildSupplierFooter(vm, currency),
                    ],
                  ),
          ),

          const SizedBox(height: 12),

          /// ─── EXPIRING PRODUCTS TABLE ───
          _buildCard(
            title: "Products Nearing Expiry",
            trailing: vm.criticalProductCount > 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(50),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "${vm.criticalProductCount} expired",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
            child: vm.products.isEmpty
                ? _emptyState("No expiring products")
                : Column(
                    children: [
                      _buildProductHeader(_productHeaderScrollCtrl),
                      SizedBox(
                        height: 190,
                        child: SingleChildScrollView(
                          child:
                              _buildProductsTable(vm, _productBodyScrollCtrl),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// ─── Metric Card ───
  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iconBg.withAlpha(30), width: 1),
        boxShadow: [
          BoxShadow(
            color: iconBg.withAlpha(18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconBg.withAlpha(35), iconBg.withAlpha(18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconBg, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ─── Breakdown Data Table ───
  Widget _buildBreakdownTable({
    required double salesCash,
    required double salesCredit,
    required double salesBank,
    required double salesTotal,
    required double purchaseCash,
    required double purchaseCredit,
    required double purchaseBank,
    required double purchaseTotal,
    required NumberFormat currency,
  }) {
    Widget row(String mode, double sVal, double pVal, {bool isTotal = false}) {
      final style = TextStyle(
        fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
        color: isTotal ? Colors.black : Colors.black87,
      );
      return Container(
        decoration: BoxDecoration(
          color: isTotal ? const Color(0xFFF0F4FF) : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    child: Text(mode, style: style),
                  )),
              VerticalDivider(
                  width: 1, thickness: 0.5, color: Colors.grey.shade300),
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text(currency.format(sVal),
                      style: style, textAlign: TextAlign.right),
                ),
              ),
              VerticalDivider(
                  width: 1, thickness: 0.5, color: Colors.grey.shade300),
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text(currency.format(pVal),
                      style: style, textAlign: TextAlign.right),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF246BFD).withAlpha(20),
                  const Color(0xFF246BFD).withAlpha(8),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("Mode", style: _tableHeaderStyle()),
                      )),
                  VerticalDivider(
                      width: 1, thickness: 0.5, color: Colors.grey.shade300),
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("Sales (₹)",
                            style: _tableHeaderStyle(),
                            textAlign: TextAlign.right),
                      )),
                  VerticalDivider(
                      width: 1, thickness: 0.5, color: Colors.grey.shade300),
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("Purchase (₹)",
                            style: _tableHeaderStyle(),
                            textAlign: TextAlign.right),
                      )),
                ],
              ),
            ),
          ),
          row("Cash", salesCash, purchaseCash),
          row("Credit", salesCredit, purchaseCredit),
          row("Bank", salesBank, purchaseBank),
          row("Total", salesTotal, purchaseTotal, isTotal: true),
        ],
      ),
    );
  }

  /// ─── Customers Table ───
  /// ─── Customer Header ───
  Widget _buildCustomerHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.withAlpha(22), Colors.indigo.withAlpha(8)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
                width: 30,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text("#", style: _tableHeaderStyle()),
                )),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
                flex: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text("Customer", style: _tableHeaderStyle()),
                )),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Text("Outstanding",
                      style: _tableHeaderStyle(), textAlign: TextAlign.right),
                )),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text("Contact",
                      style: _tableHeaderStyle(), textAlign: TextAlign.right),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersTable(DashboardViewModel vm, NumberFormat currency) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
            horizontal: BorderSide.none,
            vertical: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Column(
        children: [
          // Rows
          ...vm.customers.asMap().entries.map((e) {
            final i = e.key;
            final c = e.value;
            return Container(
              decoration: BoxDecoration(
                color: i.isEven ? Colors.white : const Color(0xFFF8F9FC),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                        width: 30,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: _tableCellText("${i + 1}"),
                        )),
                    VerticalDivider(
                        width: 1, thickness: 0.5, color: Colors.grey.shade300),
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: _tableCellText(c.name),
                        )),
                    VerticalDivider(
                        width: 1, thickness: 0.5, color: Colors.grey.shade300),
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child:
                              _tableCellMoney(currency.format(c.outstanding)),
                        )),
                    VerticalDivider(
                        width: 1, thickness: 0.5, color: Colors.grey.shade300),
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: _tableCellText(c.contact ?? "—",
                              align: TextAlign.right),
                        )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// ─── Customer Footer (Total row) ───
  Widget _buildCustomerFooter(DashboardViewModel vm, NumberFormat currency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo.withAlpha(15),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
                width: 30,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: const SizedBox(),
                )),
            //VerticalDivider(
            // width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
              flex: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Text("Total",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Text(
                  currency.format(vm.totalCustomerOutstanding),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            /* VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            const Expanded(flex: 2, child: SizedBox()), */
          ],
        ),
      ),
    );
  }

  /// ─── Suppliers Table ───
  /// ─── Supplier Header ───
  Widget _buildSupplierHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.withAlpha(22), Colors.blueGrey.withAlpha(8)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
                width: 30,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text("#", style: _tableHeaderStyle()),
                )),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
                flex: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text("Supplier", style: _tableHeaderStyle()),
                )),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text("Amount (₹)",
                      style: _tableHeaderStyle(), textAlign: TextAlign.right),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliersTable(DashboardViewModel vm, NumberFormat currency) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
            horizontal: BorderSide.none,
            vertical: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Column(
        children: [
          // Rows
          ...vm.suppliers.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return Container(
              decoration: BoxDecoration(
                color: i.isEven ? Colors.white : const Color(0xFFF8F9FC),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                        width: 30,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: _tableCellText("${i + 1}"),
                        )),
                    VerticalDivider(
                        width: 1, thickness: 0.5, color: Colors.grey.shade300),
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: _tableCellText(s.name),
                        )),
                    VerticalDivider(
                        width: 1, thickness: 0.5, color: Colors.grey.shade300),
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child:
                              _tableCellMoney(currency.format(s.outstanding)),
                        )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// ─── Supplier Footer (Total row) ───
  Widget _buildSupplierFooter(DashboardViewModel vm, NumberFormat currency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.withAlpha(15),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
                width: 30,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: const SizedBox(),
                )),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
              flex: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Text("Total",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            VerticalDivider(
                width: 1, thickness: 0.5, color: Colors.grey.shade300),
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Text(
                  currency.format(vm.totalSupplierOutstanding),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─── Product Header ───
  Widget _buildProductHeader(ScrollController scrollCtrl) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_isSyncingScroll) return true;
        _isSyncingScroll = true;
        if (_productBodyScrollCtrl.hasClients) {
          _productBodyScrollCtrl.jumpTo(scrollCtrl.offset);
        }
        _isSyncingScroll = false;
        return false;
      },
      child: SingleChildScrollView(
        controller: scrollCtrl,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.withAlpha(22), Colors.red.withAlpha(8)],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                      width: 30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("#", style: _tableHeaderStyle()),
                      )),
                  VerticalDivider(
                      width: 1, thickness: 0.5, color: Colors.grey.shade300),
                  SizedBox(
                      width: 160,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("Product", style: _tableHeaderStyle()),
                      )),
                  VerticalDivider(
                      width: 1, thickness: 0.5, color: Colors.grey.shade300),
                  SizedBox(
                      width: 80,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("HSN", style: _tableHeaderStyle()),
                      )),
                  VerticalDivider(
                      width: 1, thickness: 0.5, color: Colors.grey.shade300),
                  SizedBox(
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("Batch", style: _tableHeaderStyle()),
                      )),
                  VerticalDivider(
                      width: 1, thickness: 0.5, color: Colors.grey.shade300),
                  SizedBox(
                      width: 110,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        child: Text("Expiry",
                            style: _tableHeaderStyle(),
                            textAlign: TextAlign.right),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTable(
      DashboardViewModel vm, ScrollController scrollCtrl) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final displayFormatter = DateFormat('dd MMM yyyy');

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_isSyncingScroll) return true;
        _isSyncingScroll = true;
        if (_productHeaderScrollCtrl.hasClients) {
          _productHeaderScrollCtrl.jumpTo(scrollCtrl.offset);
        }
        _isSyncingScroll = false;
        return false;
      },
      child: SingleChildScrollView(
        controller: scrollCtrl,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
          child: Container(
            decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide.none,
                  vertical:
                      BorderSide(color: Colors.grey.shade300, width: 0.5)),
            ),
            child: Column(
              children: [
                // Rows
                ...vm.products.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value;
                  bool isExpired = false;
                  String formattedDate = p.expiryDate;
                  try {
                    final expDate = dateFormatter.parse(p.expiryDate);
                    isExpired = expDate.isBefore(now);
                    formattedDate = displayFormatter.format(expDate);
                  } catch (_) {}

                  return Container(
                    decoration: BoxDecoration(
                      color: isExpired
                          ? Colors.red.shade50
                          : (i.isEven ? Colors.white : const Color(0xFFF8F9FC)),
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade300, width: 0.5),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          SizedBox(
                              width: 30,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: _tableCellText("${i + 1}"),
                              )),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: Colors.grey.shade300),
                          SizedBox(
                            width: 160,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: Text(
                                p.productName,
                                style: TextStyle(
                                  fontWeight: isExpired
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isExpired
                                      ? Colors.red.shade800
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: Colors.grey.shade300),
                          SizedBox(
                              width: 80,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: _tableCellText(p.hsnCode),
                              )),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: Colors.grey.shade300),
                          SizedBox(
                              width: 100,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: _tableCellText(p.batchNo),
                              )),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: Colors.grey.shade300),
                          SizedBox(
                            width: 110,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isExpired)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(Icons.warning_amber_rounded,
                                          size: 14, color: Colors.red.shade700),
                                    ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: isExpired
                                          ? Colors.red.shade800
                                          : Colors.black87,
                                      fontWeight: isExpired
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ─── Table helper styles ───
  TextStyle _tableHeaderStyle() {
    return TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 11.5,
      color: Colors.grey.shade700,
      letterSpacing: 0.5,
    );
  }

  Widget _tableCellText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade800,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      textAlign: align,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _tableCellMoney(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Colors.grey.shade800,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF246BFD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
