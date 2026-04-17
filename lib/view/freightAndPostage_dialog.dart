import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewmodel/ledger_type_viewmodel.dart';


class FreightAndPostageDialog extends StatefulWidget {
  final List<Map<String, dynamic>> initialCharges;

  const FreightAndPostageDialog({
    super.key,
    required this.initialCharges,
  });

  @override
  State<FreightAndPostageDialog> createState() =>
      _FreightAndPostageDialogState();
}


class _FreightAndPostageDialogState extends State<FreightAndPostageDialog> {
  // final List<Map<String, dynamic>> chargesList = [];
  late List<Map<String, dynamic>> chargesList;

  final TextEditingController chargeController = TextEditingController();
  String? selectedLedger;
  int? selectedLedgerId;

  @override
  void initState() {
    super.initState();
    // 👇 Restore already selected charges
    chargesList = List<Map<String, dynamic>>.from(widget.initialCharges);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LedgerTypeViewmodel>(context, listen: false)
          .loadFreightPostageLedger();
    });
  }

  void addCharge() {
    if (selectedLedger != null && chargeController.text.isNotEmpty) {
      setState(() {
        chargesList.add({
          "ledgerId": selectedLedgerId,
          "ledger": selectedLedger??"",
          "charge": double.tryParse(chargeController.text) ?? 0,
        });
        chargeController.clear();
        selectedLedger = null;
      });
    }
  }

  void removeCharge(int index) {
    setState(() => chargesList.removeAt(index));
  }

  double get total =>
      chargesList.fold(0, (sum, item) => sum + (item["charge"] as double));

  @override
  Widget build(BuildContext context) {
    final ledgerVM = Provider.of<LedgerTypeViewmodel>(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 4,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      Strings.freightPostageTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Flexible(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ledger Dropdown
                    ledgerVM.isLoading
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child:
                        CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                        : DropdownButtonFormField<String>(
                      value: selectedLedger,
                      hint: const Text(Strings.selectLedger),
                      items: ledgerVM.freightPostageLedger
                          .map((ledger) => DropdownMenuItem<String>(
                        value: ledger.ledgerName,
                        child: Text(ledger.ledgerName ?? ""),
                      ))
                          .toList(),
                      onChanged: (value) {
                        final selected = ledgerVM.freightPostageLedger
                            .firstWhere((e) => e.ledgerName == value);

                        setState(() {
                          selectedLedger = value;
                          selectedLedgerId = selected.ledgerId; // ✅ capture ledgerId
                        });
                      },
                      decoration: InputDecoration(
                        labelText: Strings.ledger,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Charge input field
                    TextField(
                      controller: chargeController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: Strings.chargeAmount,                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Add button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: addCharge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                        icon: const Icon(Icons.add_circle_outline,color: Colors.white,),
                        label: const Text(Strings.addCharge),                      ),
                    ),

                    const SizedBox(height: 16),

                    // Charges list section (scrollable)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:
                        Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: chargesList.isEmpty
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            Strings.noChargesAdded,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                          : Scrollbar(
                        thumbVisibility: true,
                        radius: const Radius.circular(12),
                        child: ListView.builder(
                          itemCount: chargesList.length,
                          padding: const EdgeInsets.all(4),
                          itemBuilder: (context, index) {
                            final item = chargesList[index];
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  item["ledger"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                    "${Strings.chargeLabel}: ₹${item["charge"].toStringAsFixed(2)}",                                  style: const TextStyle(
                                      color: Colors.black54),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                  onPressed: () => removeCharge(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const Divider(height: 30, thickness: 1),

                    // Total amount
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${Strings.totalLabel}: ₹${total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close,color: primary,),
                    label: Text(Strings.close,style: TextStyle(color: primary),),                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, {
                        "chargesList": chargesList,
                        "total": total,
                      });
                    },
                    icon: const Icon(Icons.check_circle_outline,color: Colors.white,),
                    label: const Text(Strings.apply),                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
