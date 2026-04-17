import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/party_model.dart';
import '../model/stock_locations_model.dart';

import '../utils/app_colors.dart';

import 'package:flutter_soulconnect/viewmodel/item_viewmodel.dart';
import '../utils/routes/routes_names.dart';
import '../viewModel/sales_invoice_viewmodel.dart';
import 'package:flutter_soulconnect/viewmodel/deliveryChallanDashboard_viewmodel.dart';

class DeliveryChallanInfoPopup extends StatefulWidget {
  final SalesInvoiceViewmodel partyVM;
  final ItemViewmodel itemVM;
  final PartyModel? initialCustomer;
  final StockLocationsModel? initialLocation;
  final String? initialContact;
  final String? initialAddress;
  final String? initialVehicle;
  final String? initialByHand;

  const DeliveryChallanInfoPopup({
    super.key,
    required this.partyVM,
    required this.itemVM,
    this.initialCustomer,
    this.initialLocation,
    this.initialContact,
    this.initialAddress,
    this.initialVehicle,
    this.initialByHand,
  });

  @override
  State<DeliveryChallanInfoPopup> createState() =>
      _DeliveryChallanInfoPopupState();
}


class _DeliveryChallanInfoPopupState
    extends State<DeliveryChallanInfoPopup> {
  final _formKey = GlobalKey<FormState>();

  PartyModel? selectedCustomer;
  StockLocationsModel? selectedLocation;
  String? selectedContact;
  List<String> contactList = [];

  bool get isFormValid {
    return selectedCustomer != null &&
        selectedLocation != null &&
        (
            (selectedContact != null && selectedContact!.isNotEmpty) ||
                contactController.text.isNotEmpty
        );
  }



  final TextEditingController challanNoController =
  TextEditingController(text: "Challan No");
  final TextEditingController challanDateController =
  TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController byHandController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }


  @override
  void initState() {
    super.initState();

    widget.partyVM.getPartyApi();
    widget.itemVM.getStockLocationsApi();

    /// 🔥 Prefill values
    selectedCustomer = widget.initialCustomer;
    selectedLocation = widget.initialLocation;
    selectedContact = widget.initialContact;

    addressController.text = widget.initialAddress ?? '';
    vehicleNoController.text = widget.initialVehicle ?? '';
    byHandController.text = widget.initialByHand ?? '';

    /// rebuild contact list
    if (selectedCustomer != null) {
      if (selectedCustomer!.mobile?.isNotEmpty ?? false) {
        contactList.add(selectedCustomer!.mobile!);
      }
      if (selectedCustomer!.phone?.isNotEmpty ?? false) {
        contactList.add(selectedCustomer!.phone!);
      }
    }
    if (contactList.isNotEmpty && selectedContact == null) {
      selectedContact = contactList.first;
      contactController.text = selectedContact!;
    }
  }

  @override
  Widget build(BuildContext context) {
    PartyModel? safeCustomer;

    try {
      safeCustomer = widget.partyVM.partyList.firstWhere(
            (c) => c.partyId == selectedCustomer?.partyId,
      );
    } catch (e) {
      safeCustomer = null;
    }
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // ✅ wider dialog
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Title
              Row(
                children: const [
                  Icon(Icons.local_shipping, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    "Delivery Challan Info",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// 🔹 Form
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// Customer
                        AnimatedBuilder(
                          animation: widget.partyVM,
                          builder: (context, _) {
                            if (widget.partyVM.partyList.isEmpty) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// 🔥 ADD CUSTOMER BUTTON (TOP)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    TextButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.pushNamed(
                                          context,
                                          RouteNames.addCustomer,
                                        );

                                        if (result == true) {
                                          await widget.partyVM.getPartyApi();

                                          /// ✅ Auto select newly added customer
                                          final updatedList = widget.partyVM.partyList;
                                          if (updatedList.isNotEmpty) {
                                            final lastCustomer = updatedList.last;

                                            setState(() {
                                              final updatedList = widget.partyVM.partyList;

                                              final matchedCustomer = updatedList.firstWhere(
                                                    (c) => c.partyId == lastCustomer.partyId,
                                                orElse: () => updatedList.first,
                                              );


                                                selectedCustomer = matchedCustomer;


                                              contactList = [];

                                              if (lastCustomer.mobile?.isNotEmpty ?? false) {
                                                contactList.add(lastCustomer.mobile!);
                                              }
                                              if (lastCustomer.phone?.isNotEmpty ?? false) {
                                                contactList.add(lastCustomer.phone!);
                                              }

                                              /// ✅ REMOVE DUPLICATES
                                              contactList = contactList.toSet().toList();

                                              /// ✅ VALIDATE selectedContact
                                              if (!contactList.contains(selectedContact)) {
                                                selectedContact = null;
                                              }

                                              /// ✅ ASSIGN DEFAULT
                                              if (contactList.isNotEmpty && selectedContact == null) {
                                                selectedContact = contactList.first;
                                                contactController.text = selectedContact!;
                                              }


                                            });
                                          }
                                        }
                                      },
                                      icon: Icon(Icons.add, size: 18, color: primary),
                                      label: const Text("Add Customer"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: primary,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// 🔽 CUSTOMER DROPDOWN
                                _buildPartySearchableDropdown(

                                  label: "Customer Name *",
                                  items: widget.partyVM.partyList,
                                  value: safeCustomer,
                                  onChanged: (v) {
                                    setState(() {
                                      selectedCustomer = v;
                                      selectedContact = null;
                                      contactList = [];

                                      if (v != null) {
                                        if (v.mobile?.isNotEmpty ?? false) {
                                          contactList.add(v.mobile!);
                                        }
                                        if (v.phone?.isNotEmpty ?? false) {
                                          contactList.add(v.phone!);
                                        }

                                        /// ✅ REMOVE DUPLICATES
                                        contactList = contactList.toSet().toList();

                                        /// ✅ VALIDATE selectedContact
                                        if (!contactList.contains(selectedContact)) {
                                          selectedContact = null;
                                        }

                                        /// ✅ ASSIGN DEFAULT
                                        if (contactList.isNotEmpty && selectedContact == null) {
                                          selectedContact = contactList.first;
                                          contactController.text = selectedContact!;
                                        }
                                      }
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),




                        const SizedBox(height: 14),

                        /// Location
                        AnimatedBuilder(
                          animation: widget.itemVM,
                          builder: (context, _) {
                            if (widget.itemVM.stockLocationsList.isEmpty) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            return DropdownButtonFormField<StockLocationsModel>(
                              decoration: _inputDecoration("Select Location *"),

                              value: widget.itemVM.stockLocationsList
                                  .where((loc) =>
                              loc.locationId == selectedLocation?.locationId)
                                  .isNotEmpty
                                  ? widget.itemVM.stockLocationsList.firstWhere(
                                      (loc) =>
                                  loc.locationId == selectedLocation?.locationId)
                                  : null,

                              items: widget.itemVM.stockLocationsList.map((loc) {
                                return DropdownMenuItem<StockLocationsModel>(
                                  value: loc,
                                  child: Text(loc.locationName ?? ''),
                                );
                              }).toList(),

                              validator: (v) =>
                              v == null ? "Location is required" : null,

                              onChanged: (v) {
                                if (v == null) return;

                                setState(() {
                                  selectedLocation = v;
                                });

                                context
                                    .read<DeliveryChallanDashboardViewmodel>()
                                    .clearItemsForLocationChange();
                              },
                            );
                          },
                        ),



                        const SizedBox(height: 14),

                        /// Date & Challan No (Row)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: challanDateController,
                                readOnly: true,
                                decoration:
                                _inputDecoration("Challan Date"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: challanNoController,
                                readOnly: true,
                                decoration:
                                _inputDecoration("Challan No"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// Contact
                        contactList.isEmpty
                            ? TextFormField(
                          controller: contactController,
                          decoration: _inputDecoration("Contact *"),
                          readOnly: true,
                          validator: (v) =>
                          v == null || v.isEmpty ? "Select customer first" : null,
                        )
                            : DropdownButtonFormField<String>(
                          decoration: _inputDecoration("Contact *"),

                          value: contactList.contains(selectedContact)
                              ? selectedContact
                              : null, // ✅ IMPORTANT FIX

                          items: contactList
                              .map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ))
                              .toList(),

                          onChanged: (v) {
                            setState(() {
                              selectedContact = v;
                              contactController.text = v ?? '';
                            });
                          },
                        ),


                        const SizedBox(height: 14),

                        /// Address
                        TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          decoration:
                          _inputDecoration("Consignment Address"),
                        ),

                        const SizedBox(height: 14),

                        /// By Hand & Vehicle No
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: byHandController,
                                decoration: _inputDecoration("By Hand"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: vehicleNoController,
                                decoration: _inputDecoration("Vehicle No"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                    Text("Cancel", style: TextStyle(color: primary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid ? primary : Colors.grey, // 👈 disabled color
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isFormValid
                        ? () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'customerId': selectedCustomer?.partyId,
                          'customerName': selectedCustomer?.partyName,
                          'locationId': selectedLocation?.locationId,
                          'locationName': selectedLocation?.locationName,
                          'challanNo': challanNoController.text,
                          'date': DateTime.now(),
                          'vehicle': vehicleNoController.text,
                          'contact': selectedContact,
                          'address': addressController.text,
                          'byHand': byHandController.text,
                        });
                      }
                    }
                        : null, // 👈 disables button
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  )

                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartySearchableDropdown({
    required String label,
    required List<PartyModel> items,
    required PartyModel? value,
    required Function(PartyModel?) onChanged,
  }) {
    return Autocomplete<PartyModel>(
      initialValue: TextEditingValue(text: value?.partyName ?? ""),

      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return items;
        }

        return items.where((party) =>
            (party.partyName ?? "")
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
      },

      displayStringForOption: (PartyModel option) =>
      option.partyName ?? "",

      onSelected: (selection) {
        onChanged(selection);
      },

      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Select $label",
            suffixIcon: const Icon(Icons.arrow_drop_down),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (v) =>
          (value == null) ? "Customer Name is required" : null,
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
              width: MediaQuery.of(context).size.width * 0.9,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final party = options.elementAt(index);

                  return ListTile(
                    title: Text(party.partyName ?? ''),
                    onTap: () => onSelected(party),
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
