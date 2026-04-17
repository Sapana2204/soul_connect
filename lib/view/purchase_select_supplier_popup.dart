import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/view/purchase_mode.dart';
import 'package:provider/provider.dart';
import '../model/party_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewmodel/item_viewmodel.dart';
import '../viewmodel/purchase_invoice_viewmodel.dart';

class PurchaseSelectSupplierPopup extends StatefulWidget {
  final bool isChallan;

  final PartyModel? initialSupplier;
  final String? initialLocationId;
  final String? initialPayMode;
  final String? initialPaymentTerm;
  final String? initialTaxType;
  final bool hasItems;
  final PurchaseMode mode;

  const PurchaseSelectSupplierPopup({
    super.key,
    required this.mode,
    required this.isChallan,
    required this.hasItems,   // ✅ ADD THIS
    this.initialSupplier,
    this.initialLocationId,
    this.initialPayMode,
    this.initialPaymentTerm,
    this.initialTaxType,
  });

  @override
  State<PurchaseSelectSupplierPopup> createState() =>
      _PurchaseSelectSupplierPopupState();
}

class _PurchaseSelectSupplierPopupState extends State<PurchaseSelectSupplierPopup> {
  final TextEditingController gstController = TextEditingController();
  final TextEditingController billNoController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();

  PartyModel? selectedSupplier;
  int? selectedLedgerId;
  String? paymentTerm;
  String? selectedLocationId;

  String? selectedPayMode = Strings.payModeCash;
  final List<String> payModes = [
    Strings.payModeCash,
    Strings.payModeCredit
  ];

  String? selectedType = 'Purchase';
  bool get isFormValid =>
      selectedLocationId != null && selectedSupplier != null;

  String selectedTaxType = "E"; // E = Exclusive (default)

  final List<Map<String, String>> taxTypes = [
    {"label": Strings.taxExclusive, "value": "E"},
    {"label": Strings.taxInclusive, "value": "I"},
    {"label": Strings.taxNoTax, "value": "N"},
  ];

  final List<String> types = ['Purchase'];

  @override
  void initState() {
    super.initState();

    selectedSupplier = widget.initialSupplier;
    selectedLocationId = widget.initialLocationId;
    selectedPayMode = widget.initialPayMode ?? "Cash";
    paymentTerm = widget.initialPaymentTerm;
    selectedTaxType = widget.initialTaxType ?? "E";

    if (selectedSupplier != null) {
      selectedLedgerId = selectedSupplier!.ledgerId;
      supplierController.text = selectedSupplier!.partyName ?? '';
      gstController.text =
      selectedSupplier!.gSTIN?.isNotEmpty == true
          ? selectedSupplier!.gSTIN!
          : '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemVM = Provider.of<ItemViewmodel>(context, listen: false);

      await itemVM.getStockLocationsApi();

      // ✅ Set first location if not already selected
      if (selectedLocationId == null &&
          itemVM.stockLocationsList.isNotEmpty) {
        setState(() {
          selectedLocationId =
              itemVM.stockLocationsList.first.locationId?.toString();
        });
      }

      Provider.of<PurchaseInvoiceViewmodel>(context, listen: false)
          .getPurchasePartyApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stklocviewModel = Provider.of<ItemViewmodel>(context);
    final purchaseInvoiceViewmodel =
    Provider.of<PurchaseInvoiceViewmodel>(context, listen: true);

    InputDecoration inputDecoration(String label, {IconData? icon}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: primary) : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔷 Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.mode == PurchaseMode.purchase
                          ? Icons.receipt_long
                          : Icons.assignment_return,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.mode == PurchaseMode.purchase
                        ? Strings.supplierDetails
                        : "Purchase Return Details",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 📍 Location Dropdown
              DropdownButtonFormField<String>(
                value: selectedLocationId,
                decoration: inputDecoration(Strings.selectLocation, icon: Icons.location_on),
                isExpanded: true,
                items: stklocviewModel.stockLocationsList.map((location) {
                  return DropdownMenuItem<String>(
                    value: location.locationId?.toString(),
                    child: Text(location.locationName ?? Strings.unknown),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocationId = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              /// 🏢 Supplier (Searchable)
              _buildSearchableDropdown(
                Strings.selectSupplier,
                selectedLocationId == null
                    ? []
                    : purchaseInvoiceViewmodel.partyList
                    .map((party) => party.partyName ?? "")
                    .toList(),
                selectedSupplier?.partyName,
                    (String? value) {
                  if (value != null) {
                    final supplier = purchaseInvoiceViewmodel.partyList
                        .firstWhere((p) => p.partyName == value);

                    setState(() {
                      selectedSupplier = supplier;
                      selectedLedgerId = supplier.ledgerId;

                      supplierController.text = supplier.partyName ?? "";
                      gstController.text =
                      supplier.gSTIN?.isNotEmpty == true ? supplier.gSTIN! : '';
                    });
                  }
                },
                isLoading: purchaseInvoiceViewmodel.isLoading,
                icon: Icons.business,
                // ✅ same icon as before

              ),

              const SizedBox(height: 18),

              // /// GST
              TextField(
                controller: gstController,
                decoration: inputDecoration("GST No", icon: Icons.confirmation_number),
              ),

              const SizedBox(height: 18),

              // /// Vehicle
              // TextField(
              //   controller: vehicleController,
              //   decoration: inputDecoration("Vehicle No", icon: Icons.local_shipping),
              // ),
              //
              // const SizedBox(height: 18),

              /// 💳 Pay Mode
              if (widget.mode == PurchaseMode.purchase) ...[
                /// 💳 Pay Mode
                DropdownButtonFormField<String>(
                  value: selectedPayMode,
                  decoration: inputDecoration(Strings.payMode, icon: Icons.payment),
                  items: payModes.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPayMode = value;
                    });

                    if (value == Strings.payModeCredit) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController paymentTermController =
                          TextEditingController();

                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            title: const Text(Strings.paymentTerm),
                            content: TextField(
                              controller: paymentTermController,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration(Strings.enterPaymentTerm),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(Strings.cancel,
                                    style: TextStyle(color: primary)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    paymentTerm = paymentTermController.text;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  Strings.save,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),

                const SizedBox(height: 18),
              ],

              if (widget.mode == PurchaseMode.purchase) ...[
                DropdownButtonFormField<String>(
                  value: selectedTaxType,
                  decoration: inputDecoration(Strings.taxType, icon: Icons.percent),
                  items: taxTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type["value"],
                      child: Text(type["label"]!),
                    );
                  }).toList(),
                  onChanged: widget.hasItems
                      ? null
                      : (value) {
                    setState(() {
                      selectedTaxType = value ?? "E";
                    });
                  },
                ),

                const SizedBox(height: 18),
              ],

              /// Bill
              if (widget.mode == PurchaseMode.purchase) ...[
                /// Bill
                TextField(
                  controller: billNoController,
                  decoration: inputDecoration(
                    'Bill No',
                    icon: Icons.description,
                  ),
                ),

                const SizedBox(height: 30),
              ]
              else
                const SizedBox(height: 30),

              /// 🚀 Next Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isFormValid
                        ? LinearGradient(
                      colors: [primary, primary.withOpacity(0.8)],
                    )
                        : LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade400],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: isFormValid
                        ? () {
                      Navigator.pop(context, {
                        'supplier': selectedSupplier,
                        'supplierId': selectedSupplier?.partyId,
                        'ledgerId': selectedSupplier?.ledgerId,
                        'vehicle': vehicleController.text,
                        'billNo': billNoController.text,
                        'gstIn': gstController.text,
                        'locationId': selectedLocationId,
                        'payMode': selectedPayMode,
                        'paymentTerm': paymentTerm,
                        'taxType': selectedTaxType, // ✅ ADD THIS

                      });
                    }
                        : null, // 👈 Disabled if not valid
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      Strings.next,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown(
      String label,
      List<String> items,
      String? value,
      Function(String?) onChanged, {
        bool isLoading = false,
        IconData? icon,
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

            prefixIcon: icon != null ? Icon(icon, color: primary) : null, // ✅ primary color
            suffixIcon: const Icon(Icons.arrow_drop_down),

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
            focusNode.requestFocus();
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
              width: MediaQuery.of(context).size.width * 0.7,
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

}
