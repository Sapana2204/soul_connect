import 'package:flutter/material.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:flutter_soulconnect/viewModel/items_by_product_type_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_strings.dart';
import '../viewModel/sales_invoice_viewmodel.dart';


class SelectBillDetailsDialog extends StatefulWidget {
  final bool isReturn;

  const SelectBillDetailsDialog({super.key, this.isReturn = false,});

  @override
  State<SelectBillDetailsDialog> createState() => _SelectBillDetailsDialogState();
}

class _SelectBillDetailsDialogState extends State<SelectBillDetailsDialog> {

  String? selectedRateType;
  String? selectedPayMode = 'Cash'; // 🔹 Default value set here
  final List<String> payModes = ['Cash', 'Credit'];
  String? selectedLocationId;
  String? selectedBillType;
  bool _isInitialized = false;

  double? selectedCreditLimit;
  double? selectedOutstanding;
  final List<String> taxTypes = ['Exclusive', 'Inclusive', 'No Tax'];
  String? selectedTaxType = 'Exclusive'; // 🔹 Default value set here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {

      final salesVM =
      Provider.of<SalesInvoiceViewmodel>(context, listen: false);


      selectedLocationId = salesVM.selectedLocationId;
      selectedBillType = salesVM.selectedBillType;
      selectedRateType = salesVM.selectedRateType;
      selectedPayMode = salesVM.selectedPayMode ?? 'Cash';
      selectedTaxType = salesVM.selectedTaxType ?? 'Exclusive';
      final itemVM =
      Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

      // itemVM.getStockLocationsApi();

      /// ✅ Set default Bill Type
      if (salesVM.billTypeList.isNotEmpty) {
        selectedBillType ??= salesVM.billTypeList.first.billType;
      }

      /// ✅ Set default Rate Type
      if (salesVM.rateTypeList.isNotEmpty ) {
        selectedRateType ??=
            salesVM.rateTypeList[0].rateType;

        /// Auto-set PayMode based on rate
        // if (selectedRateType!
        //     .toLowerCase()
        //     .contains('credit')) {
        //   selectedPayMode = 'Credit';
        // } else {
        //   selectedPayMode = 'Cash';
        // }
      }

      _isInitialized = true;   // ✅ Will now work properly
    }
  }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemVM =
      Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

      await itemVM.getStockLocationsByUserApi();   // load locations first
       _loadSavedLocation();            // then load saved location
    });
  }

  void _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocation = prefs.getString("selected_location");

    final itemVM =
    Provider.of<ItemsByProductTypeViewmodel>(context, listen: false);

    if (savedLocation != null &&
        itemVM.stockLocationsByUserList.any(
                (loc) => loc.locationId?.toString() == savedLocation)) {
      setState(() {
        selectedLocationId = savedLocation;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final viewModel =
    Provider.of<SalesInvoiceViewmodel>(context, listen: false);

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
          Expanded(
            child: Text(
              Strings.selectBillDetails,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Consumer<ItemsByProductTypeViewmodel>(
                builder: (context, vm, _) {
                  if (vm.locationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _buildDropdown(
                    label: Strings.stockLocation,
                    value: selectedLocationId,
                    items: vm.stockLocationsByUserList
                        .map((loc) => DropdownMenuItem<String>(
                      value: loc.locationId?.toString(),
                      child: Text(loc.locationName ?? "Unknown"),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLocationId = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildDropdown(
                label: Strings.rateType,
                value: selectedRateType,
                items: viewModel.rateTypeList
                    .map((rateType) => DropdownMenuItem(
                  value: rateType.rateType,
                  child: Text(rateType.rateType ??
                      "Unknown"),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRateType = value;

                    // if (value != null &&
                    //     value.toLowerCase().contains('credit')) {
                    //   selectedPayMode = 'Credit';
                    // } else if (value != null &&
                    //     value.toLowerCase().contains('cash')) {
                    //   selectedPayMode = 'Cash';
                    // }
                  });
                },
              ),

              const SizedBox(height: 10),

              _buildDropdown(
                label: Strings.payMode,
                value: selectedPayMode,
                items: payModes
                    .map((mode) => DropdownMenuItem<String>(
                  value: mode,
                  child: Text(mode),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPayMode = value!;
                  });
                },
              ),

              if(!widget.isReturn)...[
                SizedBox(height: 10,),

                DropdownButtonFormField<String>(
                  value: selectedTaxType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: Strings.taxType,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                  ),
                  items: taxTypes.map((String mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTaxType = value!;
                    });
                  },
                ),
              ]

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
            Strings.cancel,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed:  () async {
            final salesVM =
            Provider.of<SalesInvoiceViewmodel>(context, listen: false);
            salesVM.setBillDetails(
              locationId: selectedLocationId,
              billType: selectedBillType,
              rateType: selectedRateType,
              payMode: selectedPayMode,
              taxType: selectedTaxType,
            );
            /// 🔹 Update SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final oldLocation = prefs.getString("selected_location");

            if (oldLocation != selectedLocationId) {
              await prefs.setString("selected_location", selectedLocationId ?? "");
              print("Location changed → SharedPreferences updated");
            }

            Navigator.pop(context, {
              'creditLimit': selectedCreditLimit ?? 0.0,
              'openingBal': selectedOutstanding?.toStringAsFixed(2) ?? "0.00",
              'rateType': selectedRateType,
              'payMode': selectedPayMode,
              'taxType': selectedTaxType,
              'billType': selectedBillType,
              'locationId': selectedLocationId
            });
          },

          style: ElevatedButton.styleFrom(
            elevation: 6,
            backgroundColor: primary,
            // padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                Strings.save,
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
}
