import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/utils/routes/routes.dart';
import 'package:flutter_soulconnect/utils/routes/routes_names.dart';
import 'package:flutter_soulconnect/viewModel/account_report_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/item_master_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/items_by_product_type_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/login_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/payment_voucher_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/sales_report_view_model.dart';
import 'package:flutter_soulconnect/viewModel/purchase_report_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/sales_report_view_model.dart';
import 'package:flutter_soulconnect/viewmodel/contra_voucher_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/journal_voucher_viewmodel.dart';
import 'package:flutter_soulconnect/viewModel/sales_invoice_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/addPurchase_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/add_party_view_model.dart';
import 'package:flutter_soulconnect/viewmodel/add_sale_view_model.dart';
import 'package:flutter_soulconnect/viewmodel/category_master_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/dashboard_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/deliveryChallanDashboard_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/ledger_type_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/purchaseDashboard_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/purchaseItemDetails_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/purchaseReturn_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/purchase_invoice_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/sales_dashboard_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/sales_return_dashboard_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/sales_return_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/sms_dialog_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/stock_report_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/stock_vouchers_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => PurchaseDashboardViewmodel()),
        ChangeNotifierProvider(create: (_) => SalesDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewmodel()),
        ChangeNotifierProvider(create: (_) => PurchaseInvoiceViewmodel()),
        ChangeNotifierProvider(create: (_) => PurchaseItemDetailsViewmodel()),
        ChangeNotifierProvider(create: (_) => SalesInvoiceViewmodel()),
        ChangeNotifierProvider(create: (_) => ItemsByProductTypeViewmodel()),
        ChangeNotifierProvider(create: (_) => AddPartyViewModel()),
        ChangeNotifierProvider(create: (_) => LedgerTypeViewmodel()),
        ChangeNotifierProvider(create: (_) => AddSaleViewModel()),
        ChangeNotifierProvider(create: (_) => SmsDialogViewmodel()),
        ChangeNotifierProvider(create: (_) => AddPurchaseViewmodel()),
        ChangeNotifierProvider(create: (_) => PaymentVoucherViewmodel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AccountReportViewmodel()),
        ChangeNotifierProvider(create: (_) => StockViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryMasterViewmodel()),
        ChangeNotifierProvider(create: (_) => SalesReturnDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => SalesReturnViewModel()),
        ChangeNotifierProvider(create: (_) => StockVouchersViewmodel()),
        ChangeNotifierProvider(create: (_) => SalesReportViewModel()),
        ChangeNotifierProvider(
            create: (_) => DeliveryChallanDashboardViewmodel()),
        ChangeNotifierProvider(create: (_) => PurchaseReturnViewmodel()),
        ChangeNotifierProvider(create: (_) => PurchaseReportViewModel()),
        ChangeNotifierProvider(create: (_) => ItemMasterViewmodel()),
        ChangeNotifierProvider(create: (_) => ContraVoucherViewModel()),
        ChangeNotifierProvider(create: (_) => JournalVoucherViewModel()),
      ],
      child: MaterialApp(
        title: 'SoulConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primary,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: primary,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
        initialRoute: RouteNames.splashScreen,
        onGenerateRoute: Routes.generateRoutes,
      ),
    );
  }
}
