import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/viewModel/items_by_product_type_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/routes/routes_names.dart';
import '../viewModel/sales_invoice_viewmodel.dart';
import '../viewmodel/sales_return_viewmodel.dart';


class SelectCustomerDialog extends StatefulWidget {
  final bool isReturn;

  const SelectCustomerDialog({super.key, this.isReturn = false});

  @override
  State<SelectCustomerDialog> createState() => _SelectCustomerDialogState();
}

class _SelectCustomerDialogState extends State<SelectCustomerDialog> {
  String? selectedCustomer;
  String? CustomerAddress;
  int? selectedCustomerId;
  String? selectedRateType;
  String? selectedPayMode = 'Cash'; // 🔹 Default value set here
  final List<String> payModes = ['Cash', 'Credit'];
  String? selectedLocationId;
  String? selectedBillType;
  bool _isInitialized = false;

  double? selectedCreditLimit;
  double? selectedOutstanding;
  Map<String, dynamic>? selectedCustomerData;
  final List<String> taxTypes = ['Exclusive', 'Inclusive', 'No Tax'];
  String? selectedTaxType = 'Exclusive'; // 🔹 Default value set here

  final TextEditingController byHandController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final salesVM =
      Provider.of<SalesInvoiceViewmodel>(context, listen: false);

      final itemVM =
      Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

      /// ✅ LOAD SAVED CUSTOMER DATA
      selectedCustomer = salesVM.selectedCustomer;
      byHandController.text = salesVM.selectedByHand ?? '';
      itemVM.getStockLocationsByUserApi();
      salesVM.getBillTypeApi();

      salesVM.getRateTypeApi().then((_) {
        if (salesVM.rateTypeList.isNotEmpty) {
          setState(() {
            selectedRateType =
                salesVM.rateTypeList.first.rateType;
          });
        }
      });

      _isInitialized = true;   // ✅ Will now work properly
    }
  }
  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  void _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLocation = prefs.getString("selected_location");
    final savedBillType = prefs.getString("selected_bill_type");

    if (savedLocation != null) {
      setState(() {
        selectedLocationId = savedLocation;
        selectedBillType = savedBillType;
      });
    }
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

  // Widget _buildSearchableDropdown(
  //     String label,
  //     List<String> items,
  //     String? value,
  //     Function(String?) onChanged, {
  //       bool isLoading = false,
  //     }) {
  //   if (isLoading) {
  //     return const Center(child: CircularProgressIndicator());
  //   }
  //
  //   return Autocomplete<String>(
  //     initialValue: TextEditingValue(text: value ?? ""),
  //     optionsBuilder: (TextEditingValue textEditingValue) {
  //       if (textEditingValue.text.isEmpty) {
  //         return items;
  //       }
  //
  //       return items.where((item) => item
  //           .toLowerCase()
  //           .contains(textEditingValue.text.toLowerCase()));
  //     },
  //     onSelected: (selection) {
  //       onChanged(selection);
  //     },
  //     fieldViewBuilder:
  //         (context, textEditingController, focusNode, onFieldSubmitted) {
  //       return TextField(
  //         controller: textEditingController,
  //         focusNode: focusNode,
  //         decoration: InputDecoration(
  //           labelText: label,
  //           hintText: "Search $label",
  //           suffixIcon: const Icon(Icons.arrow_drop_down),
  //           filled: true,
  //           fillColor: Colors.grey.shade100,
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           contentPadding:
  //           const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  //         ),
  //       );
  //     },
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final viewModel =
    Provider.of<SalesInvoiceViewmodel>(context, listen: false);
    final itemsByprodTypeVm =
    Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
      title: Row(
        children: [
          Icon(Icons.person, color: primary, size: 26),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "Select Customer",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (!widget.isReturn)
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Colors.green,
                size: 28,
              ),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  RouteNames.addCustomer,
                );

                if (result == true) {
                  Provider.of<SalesInvoiceViewmodel>(context, listen: false)
                      .getPartyApi();
                }
              },
            ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Consumer<SalesInvoiceViewmodel>(
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
                      setState(() {
                        selectedCustomer = value;
                      });

                      final selectedParty = vm.partyList.firstWhere(
                            (p) => p.partyName == value,
                        orElse: () => vm.partyList.first,
                      );

                      contactController.text = selectedParty.mobile ?? "";
                      selectedCreditLimit = selectedParty.creditLimit ?? 0.0;
                      selectedCustomerId = selectedParty.partyId ?? 0;
                      CustomerAddress = selectedParty.address ?? "";

                      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      final ledgerId = selectedParty.ledgerId ?? 0;

                      await viewModel.getLedgerBalanceApi(
                        ledgerId: ledgerId,
                        balanceAsOn: today,
                        balanceType: "T",
                      );

                      setState(() {
                        selectedOutstanding =
                            (viewModel.ledgerBalance?.balance ?? 0.0).toDouble();
                      });

                      /// 🔥 SALES RETURN STOCK API
                      if (widget.isReturn) {
                        final stockVM =
                        Provider.of<SalesReturnViewModel>(context, listen: false);

                        final items = await stockVM.fetchItemDetails(
                          // stockDate: today,
                          locationId: int.tryParse(selectedLocationId!)??0,
                          customerId: selectedCustomerId ?? 0,
                        );
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildTextField(
                controller: byHandController,
                label: "By Hand",
                icon: Icons.edit,
              ),
            ],
          ),
        ),
      ),

      /// 🔹 ACTION BUTTONS
      actionsPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          label: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isFormValid ? () {
            final salesVM =
            Provider.of<SalesInvoiceViewmodel>(context, listen: false);
            salesVM.setCustomerDetails(
              customer: selectedCustomer,
              byHand: byHandController.text,
            );
            Navigator.pop(context, {
              'customerId': selectedCustomerId ?? 0,
              'customer': selectedCustomer,
              'address': CustomerAddress ?? "",
              'byHand': byHandController.text,
              'contact': contactController.text,
              'creditLimit': selectedCreditLimit ?? 0.0,
              'openingBal': selectedOutstanding?.toStringAsFixed(2) ?? "0.00",
            });
          } : null,

          style: ElevatedButton.styleFrom(
            elevation: 6,
            backgroundColor: isFormValid ? primary : Colors.grey.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Save",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  bool get isFormValid {
    return selectedCustomer != null &&
        selectedCustomer!.isNotEmpty;
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
