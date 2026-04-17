import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/outstanding_report_model.dart';
import '../res/widgets/gif_loader.dart';
import '../utils/app_colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/app_strings.dart';
import '../viewModel/login_viewmodel.dart';
import '../viewModel/account_report_viewmodel.dart';

class OutstandingReport extends StatefulWidget {
  const OutstandingReport({super.key});

  @override
  State<OutstandingReport> createState() => _OutstandingReportState();
}

class _OutstandingReportState extends State<OutstandingReport> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now().toString().substring(0, 10);
      Provider.of<AccountReportViewmodel>(context, listen: false)
          .fetchAllOutstanding(today);
    });
  }

  // UI Helper for Card List
  Widget customerOutstandingCard(
      OutstandingModel item,
      String firmName,
      ) {
    final message = buildOutstandingMessage(item, firmName);
    final phone = cleanPhone(item.contact ?? "");

    final bool isCR = item.drCr == "CR";
    final Color accentColor = isCR ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          /// Left Accent Line
          Container(
            width: 4,
            height: 120,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),

          /// Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name + DR/CR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.ledgerName ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        item.drCr ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// Address
                  if ((item.address ?? "").isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.address ?? "",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  /// Contact
                  if (phone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          phone,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),

                  const Divider(height: 18),

                  /// Balance + Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹ ${item.closing?.toStringAsFixed(2) ?? "0.00"}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: accentColor,
                        ),
                      ),
                      Row(
                        children: [
                          /// Call
                          InkWell(
                            onTap: () => makeCall(phone),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.call,
                                  color: Colors.green, size: 20),
                            ),
                          ),

                          /// SMS
                          InkWell(
                            onTap: () => sendSMS(phone, message),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child:
                              Icon(Icons.sms, color: Colors.blue, size: 20),
                            ),
                          ),

                          /// WhatsApp
                          InkWell(
                            onTap: () => sendWhatsapp(phone, message),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String cleanPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.length == 11 && phone.startsWith("0")) {
      phone = phone.substring(1);
    }

    return phone;
  }

  Future<void> makeCall(String phone) async {
    final clean = cleanPhone(phone);
    final Uri url = Uri.parse("tel:$clean");

    await launchUrl(url);
  }

  Future<void> sendSMS(String phone, String message) async {
    final clean = cleanPhone(phone);

    final Uri uri = Uri(
      scheme: 'sms',
      path: clean,
      queryParameters: {'body': message},
    );

    await launchUrl(uri);
  }

  Future<void> sendWhatsapp(String phone, String message) async {
    final clean = cleanPhone(phone);

    final Uri uri = Uri.parse(
        "https://wa.me/91$clean?text=${Uri.encodeComponent(message)}");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String buildOutstandingMessage(OutstandingModel item, String firmName) {
    return """
${Strings.messageDear} ${item.ledgerName},

${Strings.messageReminder} ₹${item.closing?.toStringAsFixed(2) ?? "0.00"} ${Strings.messagePending}

${Strings.messageArrangePayment}

${Strings.messageRegards},
$firmName
""";
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountReportViewmodel>(context);
    final loginVM = Provider.of<LoginViewModel>(context);
    final firmName = loginVM.firmName ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            Strings.outstandingReportTitle,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            Builder(
              builder: (childContext) => IconButton(
                onPressed: () => _generateAndSaveOutstandingPDF(childContext,
                    isPrint: false),
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: Strings.savePdfReport,
              ),
            ),
            // Builder(
            //   builder: (childContext) => IconButton(
            //     onPressed: () =>
            //         _generateAndSaveOutstandingPDF(childContext, isPrint: true),
            //     icon: const Icon(Icons.print),
            //     tooltip: Strings.printReport,
            //   ),
            // ),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(color: primary),
          ),
          bottom: const TabBar(
            isScrollable: false,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Colors.white70,
            dividerHeight: 1,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 4,
            labelColor: Colors.white70,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: Strings.supplier),
              Tab(text: Strings.customer),
            ],
          ),
        ),
        body: viewModel.loading
            ? const Center(child: GifLoader())
            : Column(
          children: [
            _buildDateHeader(),
            Expanded(
                child: TabBarView(
                  children: [
                    /// Supplier (old card)
                    cardsListBuilder(viewModel.supplierList),

                    /// Customer (new UI with actions)
                    ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: viewModel.customerList.length,
                      itemBuilder: (context, index) {
                        final item = viewModel.customerList[index];

                        return customerOutstandingCard(
                          item,
                          loginVM.userData?.firmName ?? "",
                        );
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  //PDF Logic for both Sharing and Printing
  Future<void> _generateAndSaveOutstandingPDF(BuildContext context,
      {bool isPrint = false}) async {
    final pdf = pw.Document();
    final viewModel = context.read<AccountReportViewmodel>();

    final int currentIndex = DefaultTabController.of(context).index;
    final List<OutstandingModel> reportData =
    currentIndex == 0 ? viewModel.supplierList : viewModel.customerList;
    final String reportTitle = currentIndex == 0
        ? Strings.supplierOutstanding
        : Strings.customerOutstanding;
    if (reportData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.noDataToExport)),
      );
      return;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(reportTitle,
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: ${DateTime.now().toString().substring(0, 10)}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration:
            const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellHeight: 30,
            headers: ['Ledger Name', 'Address', 'Contact', 'Balance', 'Type'],
            data: reportData.map((item) {
              return [
                item.ledgerName ?? '',
                item.address ?? '',
                item.contact ?? '',
                item.closing?.toStringAsFixed(2) ?? '0.00',
                item.drCr ?? '',
              ];
            }).toList(),
          ),
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 20), child: pw.Divider()),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text("Total Records: ${reportData.length}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );

    try {
      if (isPrint) {
        // Direct Print
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: '${reportTitle}_Report',
        );
      } else {
        // Share/Save PDF
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: '${reportTitle}_Report.pdf',
        );
      }
    } catch (e) {
      debugPrint("PDF Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget cardsListBuilder(List<OutstandingModel> dataList) {
    if (dataList.isEmpty) {
      return const Center(
        child: Text(
          Strings.noRecordsFound,
          style: TextStyle(fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];

        final bool isCr = item.drCr == "CR";

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                /// Left Indicator Line
                Container(
                  width: 4,
                  height: 70,
                  color: isCr ? Colors.red : Colors.green,
                ),

                const SizedBox(width: 10),

                /// Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Ledger Name
                      Text(
                        item.ledgerName ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Address
                      if ((item.address ?? "").isNotEmpty)
                        Text(
                          item.address!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),

                      const SizedBox(height: 4),

                      /// Contact
                      if ((item.contact ?? "").isNotEmpty)
                        Text(
                          "${Strings.contact}: ${item.contact}",
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),

                /// Balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹ ${item.closing ?? 0}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCr ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      item.drCr ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        color: isCr ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateHeader() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
            "${Strings.date}: ${DateTime.now().toString().substring(0, 10)}"),
      ),
    );
  }
}
