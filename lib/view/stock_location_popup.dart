import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_soulconnect/viewModel/items_by_product_type_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_strings.dart';
import '../viewModel/sales_invoice_viewmodel.dart';

class StockLocationDialog extends StatefulWidget {
  const StockLocationDialog({super.key});

  @override
  _StockLocationDialogState createState() => _StockLocationDialogState();
}

class _StockLocationDialogState extends State<StockLocationDialog> {
  String? selectedLocationId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemVM = context.read<ItemsByProductTypeViewmodel>();
      // final salesVM = context.read<SalesInvoiceViewmodel>();

      itemVM.getStockLocationsByUserApi();
      // salesVM.getBillTypeApi();
    });
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ItemsByProductTypeViewmodel>(context);
    final salesInvoiceViewModel = Provider.of<SalesInvoiceViewmodel>(context);

    // Auto select first location
    if (selectedLocationId == null && viewModel.stockLocationsByUserList.isNotEmpty) {
      selectedLocationId =
          viewModel.stockLocationsByUserList.first.locationId?.toString();
    }
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              Strings.stockLocHeading,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Select Stock Location Title
            const Row(
              children: [
                Icon(Icons.location_pin, color: Colors.pink, size: 20),
                SizedBox(width: 6),
                Text(
                  Strings.stockLocSubHeading,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              Strings.stockLocSubHead2,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Column(
              children: [
                // 🔄 Stock Location Dropdown / Loader
                viewModel.locationsLoading
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                )
                    : DropdownButtonFormField<String>(
                  value: selectedLocationId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: Strings.stockLocation,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  items: viewModel.stockLocationsByUserList.map((loc) {
                    return DropdownMenuItem(
                      value: loc.locationId?.toString(),
                      child: Text(loc.locationName ?? "Unknown"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLocationId = value;
                    });
                  },
                ),

              ],
            ),

            const SizedBox(height: 12),

            Text(
             Strings.stickLocSubHead3,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(Strings.cancel),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
    onPressed: () async {
    if (selectedLocationId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text(Strings.stickLocSnackText)),
    );
    return;
    }

    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now();
    final todayString =
    "${today.year}-${today.month}-${today.day}";

    // ✅ Save location + bill type + date
    await prefs.setString("selected_location", selectedLocationId!);
    await prefs.setString("location_selected_date", todayString);

    print("Saved to SharedPreferences - Location ID: $selectedLocationId, Date: $todayString");

    Navigator.pop(context, [selectedLocationId]);
    },
                  child: Text(Strings.started, style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
