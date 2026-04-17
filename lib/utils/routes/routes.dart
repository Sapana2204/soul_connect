import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/routes/routes_names.dart';
import 'package:flutter_soulconnect/view/Expiry_report.dart';
import 'package:flutter_soulconnect/view/contra_voucher_screen.dart';
import 'package:flutter_soulconnect/view/customer_ledger_report.dart';
import 'package:flutter_soulconnect/view/customerStatementReport_screen.dart';
import 'package:flutter_soulconnect/view/day_book_report.dart';
import 'package:flutter_soulconnect/view/delivery_challan_dashboard.dart';
import 'package:flutter_soulconnect/view/expiry_voucher_dashboard.dart';
import 'package:flutter_soulconnect/view/issue_voucher_dashboard.dart';
import 'package:flutter_soulconnect/view/item_ledger_report_screen.dart';
import 'package:flutter_soulconnect/view/journal_voucher_screen.dart';
import 'package:flutter_soulconnect/view/outstanding_report.dart';
import 'package:flutter_soulconnect/view/profitLoss_report.dart';
import 'package:flutter_soulconnect/view/purchaseReturnItemwise.dart';
import 'package:flutter_soulconnect/view/purchaseReturnStatement.dart';
import 'package:flutter_soulconnect/view/purchaseReturn_dashboard_screen.dart';
import 'package:flutter_soulconnect/view/purchase_challan_dashboard.dart';
import 'package:flutter_soulconnect/view/purchase_challan_screen.dart';
import 'package:flutter_soulconnect/view/purchase_dashboard.dart';
import 'package:flutter_soulconnect/view/receiptDashboardScreen.dart';
import 'package:flutter_soulconnect/view/sales(item%20wise)_report.dart';
import 'package:flutter_soulconnect/view/sales(user%20wise)_report.dart';
import 'package:flutter_soulconnect/view/sales_dashboard.dart';
import 'package:flutter_soulconnect/view/sales_return_dashboard.dart';
import 'package:flutter_soulconnect/view/sales_return_screen.dart';
import 'package:flutter_soulconnect/view/sales_statement_report.dart';
import 'package:flutter_soulconnect/view/stock_inward_dashboard.dart';
import 'package:flutter_soulconnect/view/stock_report.dart';
import 'package:flutter_soulconnect/view/trace_product_report_screen.dart';

import '../../view/add_new_customer.dart';
import '../../view/dashboardScreen.dart';
import '../../view/homeScreen.dart';
import '../../view/ledger_report_screen.dart';
import '../../view/login_screen.dart';
import '../../view/purchase_itemwise_report.dart';
import '../../view/purchase_statement_report.dart';
import '../../view/new_purchaseinward_ui.dart';
import '../../view/new_salesinvoice_ui.dart';
import '../../view/splash_screen.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case (RouteNames.home):
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen());

      case (RouteNames.login):
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen());

      case (RouteNames.splashScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());

      case (RouteNames.dashboardScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const DashboardScreen());

      case (RouteNames.purchaseInvoice):
        return MaterialPageRoute(
            builder: (BuildContext context) => const NewPurchaseInwardUI());

      case (RouteNames.salesInvoice):
        return MaterialPageRoute(
            builder: (BuildContext context) => const NewSalesInvoiceUI());

      case (RouteNames.salesDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SalesDashboard());

      case (RouteNames.purchaseDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) => const PurchaseDashboard());

      case (RouteNames.addCustomer):
        return MaterialPageRoute(
            builder: (BuildContext context) => const AddPartyScreen());

      case (RouteNames.ledgerReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const LedgerReportScreen());

      case (RouteNames.stockReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const StockReportScreen());

      case (RouteNames.traceProductReport):
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const TraceProductReportScreen());

      case (RouteNames.itemLedgerReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ItemLedgerReportScreen());

      case (RouteNames.deliveryChallanDashboardScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const DeliveryChallanDashboard());

      case (RouteNames.outstandingReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const OutstandingReport());

      case (RouteNames.salesReturnDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SalesReturnDashboard());

      case (RouteNames.salesReturnScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SalesReturnScreen());

      case (RouteNames.issueVoucherDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) => const IssueVoucherDashboard());

      case (RouteNames.salesItemwiseReport):
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const SalesItemwiseReportScreen());

      case (RouteNames.salesStmtReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SalesStatementReport());

      case (RouteNames.profitlossReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ProfitLossReportScreen());

      case (RouteNames.stockInwardDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) => const StockInwardDashboard());

      case (RouteNames.purchaseReturnDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) => const PurchaseReturnDashboard());

      case (RouteNames.purchaseReturnStatement):
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const PurchaseReturnStatementReport());

      case (RouteNames.purchaseStatement):
        return MaterialPageRoute(
            builder: (BuildContext context) => const PurchaseStatementReport());

      case (RouteNames.dayBookReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const DayBookReportScreen());

      case (RouteNames.purchaseReturnItemwise):
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const PurchaseReturnItemwiseReport());

      case (RouteNames.purchaseItemwise):
        return MaterialPageRoute(
            builder: (BuildContext context) => const PurchaseItemwiseReport());

      case (RouteNames.expiryVoucherDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ExpiryVoucherDashboard());

      case (RouteNames.purchaseChallanDashboard):
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const PurchaseChallanDashboard());

      case (RouteNames.purchaseChallan):
        return MaterialPageRoute(
            builder: (BuildContext context) => const PurchaseChallanScreen());

      case (RouteNames.expiryReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ExpiryReport());

      case (RouteNames.receiptDashboardVoucher):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ReceiptDashboardScreen());

      case (RouteNames.customerLedgerReport):
        return MaterialPageRoute(
            builder: (BuildContext context) => CustomerLedgerReport());

      case (RouteNames.contraVoucherScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => ContraVoucherScreen());

      case (RouteNames.journalVoucherScreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => JournalVoucherScreen());

      case (RouteNames.salesReportUserWise):
        return MaterialPageRoute(
            builder: (BuildContext context) => SalesUserwiseReportScreen());

      case (RouteNames.customerStatement):
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const CustomerStatementReportScreen());

      case (RouteNames.customerStatement):
        return MaterialPageRoute(
            builder: (BuildContext context) => const CustomerStatementReportScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("No route is configured"),
            ),
          ),
        );
    }
  }
}
