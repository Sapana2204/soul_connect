import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/view/paymentDashboardScreen.dart';
import 'package:flutter_soulconnect/view/purchase_dashboard.dart';
import 'package:flutter_soulconnect/view/new_purchaseinward_ui.dart';
import 'package:flutter_soulconnect/view/receiptDashboardScreen.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/view/sales_dashboard.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_soulconnect/view/new_salesinvoice_ui.dart';
import 'package:flutter_soulconnect/view/stock_location_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/accounts_model.dart';
import '../res/widgets/bottomCurvePainter.dart';
import '../utils/accessible_pages_constant.dart';
import '../utils/app_strings.dart';
import '../utils/routes/routes_names.dart';
import '../utils/routes/utils.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/payment_voucher_viewmodel.dart';
import '../viewmodel/purchaseDashboard_viewmodel.dart';
import '../viewmodel/sales_dashboard_viewmodel.dart';
import 'add_payment_voucher_dialog.dart';
import 'add_receipt_voucher_dialog.dart';
import 'dashboardScreen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 2});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  final expansionTileControllerTransactions = ExpansionTileController();
  final expansionTileControllerAccounts = ExpansionTileController();
  final expansionTileControllerReports = ExpansionTileController();
  final expansionTileControllerSalesReports = ExpansionTileController();
  final expansionTileControllerPurchaseReports = ExpansionTileController();
  final expansionTileControllerAccountReports = ExpansionTileController();
  final expansionTileControllerStockReports = ExpansionTileController();
  final expansionTileControllerDC = ExpansionTileController();
  final expansionTileControllerVouchers = ExpansionTileController();
  final expansionTileControllerStockVouchers = ExpansionTileController();

  bool isTransactionExpanded = false;
  bool isVoucherExpanded = false;

  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    Future.delayed(Duration.zero, () async {
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);

      await loginVM.loadUserFromPrefs(context);

      checkTokenExpiry();

      // check every 60 seconds
      Stream.periodic(const Duration(minutes: 1)).listen((_) {
        checkTokenExpiry();
      });
    });
  }

  void checkTokenExpiry() async {
    if (!mounted) return;

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    final user = await loginVM.getUser();

    if (user != null && user.token != null) {
      try {
        bool isExpired = JwtDecoder.isExpired(user.token!);

        if (isExpired) {
          if (!mounted) return;

          Utils.toastMessage("Your session has expired. Please login again.");
          await loginVM.logout(context);
        }
      } catch (e) {
        // Invalid token format
        await loginVM.logout(context);
      }
    }
  }

  // 👇 ADD METHOD HERE
  void _openVoucherDialog({
    required int voucherTypeId,
    required Widget dialog,
    dynamic existingVoucher,
  }) async {
    final vm = Provider.of<PaymentVoucherViewmodel>(
      context,
      listen: false,
    );

    // await vm.loadAllLedgersOnce();
    await vm.loadAllLedgersOnce(groupId: 25);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => dialog,
    );

    if (result == true) {
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);

      final model = AccountsModel(
        voucherId: null,
        vchTypeId: voucherTypeId,
        vchDate: null,
        userId: loginVM.userId ?? "0",
        createdBy: 0,
        updatedBy: 0,
      );

      vm.getAllVouchers(model.toJson());
    }
  }

  final List<Widget> _pages = const [
    SalesDashboard(), // 0 ✅ Sales
    PurchaseDashboard(), // 1 ✅ Purchase
    DashboardScreen(), // 2 ✅ Center
    PaymentDashboardScreen(), // 3 ✅ Payment
    ReceiptDashboardScreen(), // 4 ✅ Receipt
  ];

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? Colors.black : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<LoginViewModel>(
            builder: (context, loginVM, child) {
              return
                  // _buildDrawerHeader(loginVM);
                  UserAccountsDrawerHeader(
                accountName: Text(
                  loginVM.firmName ?? "Firm",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                accountEmail: Text(
                  loginVM.roleName ?? "Role",
                  style: const TextStyle(color: Colors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: lightYellow,
                  child: Image.asset('assets/images/soulconnect_logo.png'),
                ),
                decoration: BoxDecoration(color: primary),
              );
            },
          ),

          /// Dashboard
          drawerItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.dashboard),
          //   iconColor: primary,
          //   title: Text(Strings.navDashboard,style: TextStyle(color: primary,fontWeight: FontWeight.bold),),
          //   onTap: () {
          //     Navigator.pop(context); // close drawer
          //     setState(() {
          //       _currentIndex = 2; // DashboardScreen
          //     });
          //   },
          // ),

          /// Sales
          // 🔹 Transactions
          Column(
            children: [
              /// SALES
              if (loginVM.canAccess(AccessPages.salesDashboard) ||
                  loginVM.canAccess("SalesReturn"))
                // ExpansionTile(
                // leading: Icon(Icons.point_of_sale_sharp, color: primary),
                // title: Text(
                // "Sales",
                // style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                // ),
                drawerExpansion(
                  icon: Icons.point_of_sale,
                  title: "Sales",
                  // childrenPadding: const EdgeInsets.only(left: 20),
                  children: [
                    if (loginVM.canAccess(AccessPages.salesDashboard))
                      ListTile(
                        leading: const Icon(Icons.sell),
                        title: const Text("Sales"),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 0);
                        },
                      ),
                    if (loginVM.canAccess("SalesReturn"))
                      ListTile(
                        leading: const Icon(Icons.assignment_return),
                        title: const Text("Sales Return"),
                        onTap: () {
                          Navigator.pushNamed(
                              context, RouteNames.salesReturnDashboard);
                        },
                      ),
                  ],
                ),

              /// PURCHASE
              if (loginVM.canAccess(AccessPages.purchaseDashboard))
                // ExpansionTile(
                // leading: Icon(Icons.shopping_cart, color: primary),
                // title: Text(
                // "Purchase",
                // style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                // ),
                // childrenPadding: const EdgeInsets.only(left: 20),
                drawerExpansion(
                  icon: Icons.shopping_cart,
                  title: "Purchase",
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: const Text("Purchase"),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 1);
                      },
                    ),
                    if (loginVM.canAccess("PurchaseReturn"))
                      ListTile(
                        leading: const Icon(Icons.assignment_return),
                        title: const Text("Purchase Return"),
                        onTap: () {
                          Navigator.pushNamed(
                              context, RouteNames.purchaseReturnDashboard);
                        },
                      ),
                  ],
                ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.query_stats_sharp),
            title: Text(
              "Outstanding Report",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.outstandingReport);
            },
          ),
          // 🔹 Transactions
          // ExpansionTile(
          //   controller: expansionTileControllerDC,
          //   leading: const Icon(Icons.delivery_dining),
          //   iconColor: primary,
          //   title: Text(
          //     'Delivery Challan',
          //     style: TextStyle(color: primary, fontWeight: FontWeight.bold),
          //   ),
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(left: 18.0),
          //       child: Column(
          //         children: [
          //
          //           ListTile(
          //             leading: const Icon(Icons.chalet),
          //             title: const Text("Delivery Challan"),
          //             onTap: () {
          //               Navigator.pushNamed(
          //                   context, RouteNames.deliveryChallanDashboardScreen);
          //             },
          //           ),
          //
          //         ],
          //       ),
          //     ),
          //   ],
          // ),

          // 🔹 Accounts
          // ExpansionTile(
          //   // controller: expansionTileControllerVouchers,
          //   initiallyExpanded: isVoucherExpanded,
          //   onExpansionChanged: (value) {
          //     setState(() {
          //       isVoucherExpanded = value;
          //     });
          //   },
          //   leading: const Icon(Icons.account_balance_wallet_outlined),
          //   iconColor: primary,
          //   title: Text(
          //     'Vouchers',
          //     style: TextStyle(color: primary, fontWeight: FontWeight.bold),
          //   ),
          drawerExpansion(
            icon: Icons.account_balance_wallet_outlined,
            title: "Vouchers",
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Column(
                  children: [
                    // Account Vouchers
                    ExpansionTile(
                      leading:
                          const Icon(Icons.account_balance_wallet_outlined),
                      title: const Text("Account Vouchers"),
                      // drawerExpansion(
                      //   icon: Icons.point_of_sale,
                      //   title: "Account Vouchers",
                      children: [
                        if (loginVM.canAccess("ReceiptVoucher"))
                          ListTile(
                            leading: const Icon(Icons.payment),
                            title: const Text("Receipt Voucher"),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const HomeScreen(initialIndex: 4),
                                ),
                              );
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.payment),
                          title: const Text("Contra Voucher"),
                          onTap: () {
                            Navigator.pushNamed(
                                context, RouteNames.contraVoucherScreen);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.payment),
                          title: const Text("Journal Voucher"),
                          onTap: () {
                            Navigator.pushNamed(
                                context, RouteNames.journalVoucherScreen);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 🔹 Reports
          // ExpansionTile(
          //   controller: expansionTileControllerReports,
          //   leading: const Icon(Icons.report),
          //   iconColor: primary,
          //   title: Text(
          //     'Reports',
          //     style: TextStyle(color: primary, fontWeight: FontWeight.bold),
          //   ),
          drawerExpansion(
            icon: Icons.point_of_sale,
            title: 'Reports',
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Column(
                  children: [
                    ExpansionTile(
                      controller: expansionTileControllerSalesReports,
                      leading: const Icon(Icons.account_balance),
                      iconColor: primary,
                      title: Text(
                        'Sales',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.landscape_sharp),
                                title: const Text("Sales Report(Item wise)"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.salesItemwiseReport);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.query_stats_sharp),
                                title: const Text("Sales Statement"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.salesStmtReport);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.fireplace_outlined),
                                title: const Text("Customer Report"),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RouteNames.customerStatement);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.person_sharp),
                                title: const Text("Customer Ledger"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.customerLedgerReport);
                                },
                              ),

                              // ListTile(
                              //   leading: const Icon(Icons.query_stats_sharp),
                              //   title: const Text("Sales Report (User-Wise)"),
                              //   onTap: () {
                              //     Navigator.pushNamed(context, RouteNames.salesReportUserWise);
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      controller: expansionTileControllerPurchaseReports,
                      leading: const Icon(Icons.padding),
                      iconColor: primary,
                      title: Text(
                        'Purchase',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.wallet),
                                title: const Text("Purchase Statement"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.purchaseStatement);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.wallet_giftcard),
                                title: const Text("Purchase (Item wise)"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.purchaseItemwise);
                                },
                              ),
                              // ListTile(
                              //   leading: const Icon(Icons.wallet),
                              //   title: const Text("Purchase Return Statement"),
                              //   onTap: () {
                              //     // Navigator.pop(context);
                              //     Navigator.pushNamed(context,
                              //      RouteNames.purchaseReturnStatement);
                              //   },
                              // ),
                              // ListTile(
                              //   leading: const Icon(Icons.wallet_giftcard),
                              //   title:
                              const Text("Purchase Return (Item wise)"),
                              //   onTap: () {
                              //     // Navigator.pop(context);
                              //     Navigator.pushNamed(context,
                              //  RouteNames.purchaseReturnItemwise);
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      controller: expansionTileControllerAccountReports,
                      leading: const Icon(Icons.account_balance_wallet_sharp),
                      iconColor: primary,
                      title: Text(
                        'Account',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.landscape_sharp),
                                title: const Text("Ledger Report"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.ledgerReport);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.propane_rounded),
                                title: const Text("Profit Loss"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.profitlossReport);
                                },
                              ),
                              // ListTile(
                              //   leading: const Icon(
                              //  Icons.center_focus_weak_outlined),
                              //   title: const Text("Day Book Report"),
                              //   onTap: () {
                              //     // Navigator.pop(context);
                              //     Navigator.pushNamed(
                              //  context, RouteNames.dayBookReport);
                              //   },
                              // ),
                              // ListTile(
                              //   leading: const Icon(Icons.query_stats_sharp),
                              //   title: const Text("Outstanding Report"),
                              //   onTap: () {
                              //     // Navigator.pop(context);
                              //     Navigator.pushNamed(context, RouteNames.outstandingReport);
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      controller: expansionTileControllerStockReports,
                      leading: const Icon(Icons.join_full_outlined),
                      iconColor: primary,
                      title: Text(
                        'Stock',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading:
                                    const Icon(Icons.satellite_alt_rounded),
                                title: const Text("Stock Report"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.stockReport);
                                },
                              ),
                              // ListTile(
                              //   leading: const Icon(Icons.satellite_alt_rounded),
                              //   title: const Text("Expiry Report"),
                              //   onTap: () {
                              //     // Navigator.pop(context);
                              //     Navigator.pushNamed(context, RouteNames.expiryReport);
                              //   },
                              // ),
                              ListTile(
                                leading:
                                    const Icon(Icons.temple_hindu_outlined),
                                title: const Text("Item Ledger"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.itemLedgerReport);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.track_changes),
                                title: const Text("Trace Product"),
                                onTap: () {
                                  // Navigator.pop(context);
                                  Navigator.pushNamed(
                                      context, RouteNames.traceProductReport);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 🔹 Logout
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            iconColor: Colors.red,
            title: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            textColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Logout Confirmation"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primary,
                        ),
                        child: const Text("NO"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primary,
                        ),
                        child: const Text("YES"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Icon Tile
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15), // light green
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 30,
            ),
          ),

          const SizedBox(height: 8),

          /// Text
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, // bigger
              fontWeight: FontWeight.bold, // bold
              color: black,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Heading
              Row(
                children: [
                  Text(
                    "Quick Access",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3, // ✅ 3 tiles per row
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 1.1,
                children: [
                  _quickItem(Icons.point_of_sale, "Sales", () {
                    Navigator.pushNamed(context, RouteNames.salesInvoice);
                  }),
                  _quickItem(Icons.assignment_return, "Sales Return", () {
                    Navigator.pushNamed(context, RouteNames.salesReturnScreen);
                  }),
                  _quickItem(Icons.shopping_cart, "Purchase", () {
                    Navigator.pushNamed(context, RouteNames.purchaseInvoice);
                  }),
                  _quickItem(Icons.undo, "Purchase Return", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const NewPurchaseInwardUI(isReturn: true),
                      ),
                    );
                  }),
                  _quickItem(Icons.inventory, "Stock Inward", () {
                    Navigator.pushNamed(
                        context, RouteNames.stockInwardDashboard);
                  }),
                  _quickItem(Icons.bar_chart, "Sales Report", () {
                    Navigator.pushNamed(
                        context, RouteNames.salesItemwiseReport);
                  }),
                  _quickItem(Icons.analytics, "Sales Statement", () {
                    Navigator.pushNamed(context, RouteNames.salesStmtReport);
                  }),
                  _quickItem(Icons.assignment_return, "Purchase Return Report",
                      () {
                    Navigator.pushNamed(
                        context, RouteNames.purchaseReturnItemwise);
                  }),
                  _quickItem(Icons.storage, "Stock Report", () {
                    Navigator.pushNamed(context, RouteNames.stockReport);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: _currentIndex == 2
            ? const Text(
                Strings.appName,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
        actions: [
          if (_currentIndex == 2)
            IconButton(
              icon: const Icon(Icons.widgets_outlined, color: Colors.white),
              onPressed: () {
                _showQuickActions(context);
              },
            ),
          if (_currentIndex == 1) // Purchase
            TextButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  RouteNames.purchaseInvoice,
                );

                if (result == true) {
                  final dashboardVM = Provider.of<PurchaseDashboardViewmodel>(
                      context,
                      listen: false);

                  final loginVM =
                      Provider.of<LoginViewModel>(context, listen: false);

                  final String fromDate = DateFormat('yyyy-MM-dd')
                      .format(startDate ?? DateTime.now());

                  final String toDate = DateFormat('yyyy-MM-dd')
                      .format(endDate ?? DateTime.now());

                  await dashboardVM.fetchPurchasesByFilter(
                    fromDate: fromDate,
                    toDate: toDate,
                    // userId: int.parse(userIdString ?? '0'),
                  );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Strings.createPurchase,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentIndex == 3) // Payment
            TextButton(
              onPressed: () {
                _openVoucherDialog(
                  voucherTypeId: 4,
                  dialog: const AddPaymentVoucherDialog(existingVoucher: null),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Strings.createPayment,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentIndex == 4) // Receipt
            TextButton(
              onPressed: () {
                _openVoucherDialog(
                  voucherTypeId: 3,
                  dialog: const AddReceiptVoucherDialog(existingVoucher: null),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Strings.createReceipt,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentIndex == 0) // Sales
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                final today = DateTime.now();
                final todayString = "${today.year}-${today.month}-${today.day}";

                final savedDate = prefs.getString("location_selected_date");
                final savedLocation = prefs.getString("selected_location");

                String? selectedLocationId;

                // ✅ If already selected today → skip popup
                if (savedDate == todayString &&
                    savedLocation != null &&
                    savedLocation.isNotEmpty) {
                  selectedLocationId = savedLocation;
                } else {
                  // Show location popup
                  final result = await showDialog<List<String?>>(
                    context: context,
                    builder: (context) => const StockLocationDialog(),
                  );

                  if (result == null || result.length != 2) return;

                  selectedLocationId = result[0];
                }

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewSalesInvoiceUI(),
                    settings: RouteSettings(
                      arguments: {
                        'locationId': selectedLocationId,
                      },
                    ),
                  ),
                );

                final saleDashboardVM = Provider.of<SalesDashboardViewModel>(
                    context,
                    listen: false);

                if (result == true) {
                  // Refresh dashboard data
                  saleDashboardVM.getSalesByDate(
                    fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    userId: int.tryParse(
                            Provider.of<LoginViewModel>(context, listen: false)
                                    .userId ??
                                '0') ??
                        0,
                  );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Strings.createSales,
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),

      drawer: _buildDrawer(),

      body: _pages[_currentIndex],

      /// Curved Bottom Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          height: 80, // ✅ increased height
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              /// BACKGROUND BAR
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  /// NAV ITEMS
                  child: Row(
                    children: [
                      /// LEFT
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (Provider.of<LoginViewModel>(context)
                                .canAccess(AccessPages.salesDashboard))
                              _modernNavItem(Icons.show_chart, "Sales", 0),
                            if (Provider.of<LoginViewModel>(context)
                                .canAccess(AccessPages.purchaseDashboard))
                              _modernNavItem(Icons.shopping_bag, "Purchase", 1),
                          ],
                        ),
                      ),

                      const SizedBox(width: 60),

                      /// RIGHT
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (Provider.of<LoginViewModel>(context)
                                .canAccess(AccessPages.paymentVoucher))
                              _modernNavItem(Icons.payments, "Payment", 3),
                            if (Provider.of<LoginViewModel>(context)
                                .canAccess(AccessPages.receiptVoucher))
                              _modernNavItem(Icons.receipt_long, "Receipt", 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// CENTER FAB (FIXED)
              Positioned(
                top: -15, // ✅ reduced (no cut now)
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = 2);
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.grid_view_rounded,
                        color: Colors.white, size: 26),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(LoginViewModel loginVM) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0E7C7B),
            Color(0xFF15A5A3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          /// Logo
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/images/soulconnect_logo.png'),
          ),

          const SizedBox(width: 15),

          /// Firm Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loginVM.firmName ?? "Firm Name",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  loginVM.roleName ?? "Role",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget drawerExpansion({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: primary),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 10, bottom: 10),
          iconColor: primary,
          collapsedIconColor: Colors.grey,
          children: children,
        ),
      ),
    );
  }

  Widget _modernNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return Expanded(
      // ✅ VERY IMPORTANT (prevents overflow)
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? primary : Colors.grey,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                overflow: TextOverflow.ellipsis, // ✅ prevents overflow
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? primary : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
