import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../repository/add_sale_repository.dart';

class AddSaleViewModel with ChangeNotifier {
  final AddSaleRepository _repo = AddSaleRepository();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<int?> addSale(BuildContext context, Map<String, dynamic> requestBody) async {
    setLoading(true);
    try {
      final response = await _repo.addSaleApi(requestBody);
      setLoading(false);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Sale added successfully!")),
      // );

      final salesId = response['billDetails']?['SalesId'] ?? 0;

      print("Extracted SalesId: $salesId");

      print("Add Sale Response: $response");
      return salesId;
    } catch (e) {
      setLoading(false);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("❌ Failed to add sale: $e")),
      // );
      Fluttertoast.showToast(
        msg: ("Something went wrong: $e"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );    }
  }

  // Future<void> updateSale(BuildContext context, Map<String, dynamic> requestBody) async {
  //   setLoading(true);
  //   try {
  //     final response = await _repo.updateSaleApi(requestBody);
  //     setLoading(false);
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Sale Updated successfully!")),
  //     );
  //
  //     print("Update Sale Response: $response");
  //   } catch (e) {
  //     setLoading(false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("❌ Failed to Update sale: $e")),
  //     );
  //   }
  // }
  Future<int?> updateSale(
      BuildContext context,
      Map<String, dynamic> requestBody,
      ) async {
    setLoading(true);

    try {
      final response = await _repo.updateSaleApi(requestBody);
      setLoading(false);

      final updatedSalesId = response['salesId'];

      print("UPDATED SALES ID: $updatedSalesId");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Sale updated")),
      );

      return updatedSalesId;
    } catch (e) {
      setLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update sale: $e")),
      );
    }
    return null;
  }
}
