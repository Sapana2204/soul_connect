import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soulconnect/utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../model/states_model.dart';
import '../viewModel/sales_invoice_viewmodel.dart';
import '../viewmodel/add_party_view_model.dart';

class AddPartyScreen extends StatefulWidget {
  const AddPartyScreen({super.key});

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController creditLimitController =
      TextEditingController(text: "0");
  final TextEditingController openingBalanceController =
      TextEditingController(text: "0");

  // Dropdown values
  String? selectedPartyType = "Customer";
  StatesModel? selectedState;
  String? selectedDrCr = "DR";
  bool isActive = true;

  final List<String> partyTypes = ["Customer", "Supplier"];
  final List<String> drcrOptions = ["DR", "CR"];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AddPartyViewModel>(context, listen: false).getStates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statesViewModel = Provider.of<AddPartyViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Add Party"),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: partyNameController,
                label: "Party Name *",
                validator: (value) =>
                    value!.isEmpty ? "Enter Party Name" : null,
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: "Party Type *",
                value: selectedPartyType,
                items: partyTypes,
                onChanged: (value) => setState(() => selectedPartyType = value),
              ),
              const SizedBox(height: 15),

              _buildTextField(
                controller: addressController,
                label: "Address",
                maxLines: 2,
              ),
              const SizedBox(height: 15),

              // 🔽 Dynamic State + Mobile Row
              _buildStateDropdown(statesViewModel),
              const SizedBox(height: 16),
              _buildTextField(
                controller: mobileController,
                label: "Mobile *",
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // allow only numbers
                  LengthLimitingTextInputFormatter(10), // max 10 digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Mobile Number";
                  } else if (value.length != 10) {
                    return "Mobile number must be 10 digits";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Other fields (unchanged)
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: gstinController,
                      label: "GSTIN",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: panController,
                      label: "PAN Number",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: aadhaarController,
                      label: "Aadhaar Number",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: contactPersonController,
                      label: "Contact Person",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: creditLimitController,
                      label: "Credit Limit",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: openingBalanceController,
                      label: "Opening Balance",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: "DR/CR",
                      value: selectedDrCr,
                      items: drcrOptions,
                      onChanged: (value) =>
                          setState(() => selectedDrCr = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Text("Is Active", style: TextStyle(fontSize: 16)),
                      Checkbox(
                        value: isActive,
                        activeColor: primary,
                        onChanged: (value) => setState(() => isActive = value!),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final viewModel = Provider.of<AddPartyViewModel>(
                            context,
                            listen: false);

                        // Prepare request body
                        final partyData = {
                          "PartyId": 0,
                          "PartyName": partyNameController.text.trim().isEmpty
                              ? "NA"
                              : partyNameController.text.trim(),
                          "PartyType":
                              selectedPartyType == "Customer" ? "C" : "S",
                          "Address": addressController.text.trim().isEmpty
                              ? "NA"
                              : addressController.text.trim(),
                          "ContactPerson":
                              contactPersonController.text.trim().isEmpty
                                  ? "NA"
                                  : contactPersonController.text.trim(),
                          "Phone": mobileController.text.trim().isEmpty
                              ? "0000000000"
                              : mobileController.text.trim(),
                          "Mobile": mobileController.text.trim().isEmpty
                              ? "0000000000"
                              : mobileController.text.trim(),
                          "Email": " ",
                          "IsActive": isActive,
                          "Notes": "NA",
                          "GSTIN": gstinController.text.trim().isEmpty
                              ? "NA"
                              : gstinController.text.trim(),
                          "PAN": panController.text.trim().isEmpty
                              ? "NA"
                              : panController.text.trim(),
                          "DealerCode": "NA",
                          "GSTStateCode": selectedState?.gSTStateCode ?? 0,
                          "CreatedBy": 1,
                          "CreatedOn": DateTime.now().toUtc().toIso8601String(),
                          "UpdatedBy": 1,
                          "UpdatedOn": DateTime.now().toUtc().toIso8601String(),
                          "LedgerId": 0,
                          "Misc1": "NA",
                          "Misc2": "NA",
                          "Misc3": "NA",
                          "Misc4": "NA",
                          "Misc5": "NA",
                          "CreditLimit":
                              double.tryParse(creditLimitController.text) ?? 0,
                          "Opening":
                              double.tryParse(openingBalanceController.text) ??
                                  0,
                          "DrCrType": selectedDrCr ?? "DR",
                        };

                        bool success =
                            await viewModel.addParty(partyData, context);

                        if (success) {
                          await Provider.of<SalesInvoiceViewmodel>(context,
                                  listen: false)
                              .getPartyApi();

                          Navigator.pop(context); //  Close screen after success
                        }
                      }
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Dynamic State Dropdown
  Widget _buildStateDropdown(AddPartyViewModel viewModel) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null) {
      return Text("Error: ${viewModel.errorMessage}");
    } else if (viewModel.statesList.isEmpty) {
      return const Text("No states found");
    }

    return Autocomplete<StatesModel>(
      displayStringForOption: (state) => state.stateName ?? "",

      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return viewModel.statesList;
        }

        return viewModel.statesList.where((state) => state.stateName!
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
      },

      onSelected: (StatesModel state) {
        setState(() {
          selectedState = state;
        });
      },

      /// TEXT FIELD
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        controller.text = selectedState?.stateName ?? "";

        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: "State *",
            hintText: "Search State",
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(21),
            ),
          ),
        );
      },

      /// DROPDOWN LIST UI
      optionsViewBuilder: (context, onSelected, options) {
        final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: fieldWidth,
                maxHeight: 250,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final state = options.elementAt(index);

                  return ListTile(
                    title: Text(state.stateName ?? ""),
                    onTap: () => onSelected(state),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Custom TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters, // ✅ Added parameter
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters, // ✅ Applied here
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(21),
        ),
      ),
      validator: validator,
    );
  }

  // Custom Dropdown
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(21),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
