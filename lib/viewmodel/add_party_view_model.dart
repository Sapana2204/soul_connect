

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/states_model.dart';
import '../repository/add_party_repository.dart';

class AddPartyViewModel with ChangeNotifier {
  final _partyRepo = AddPartyRepository();

  List<StatesModel> _statesList = [];
  List<StatesModel> get statesList => _statesList;

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> getStates() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statesList = await _partyRepo.fetchStates();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 🆕 Add Party function
  Future<bool> addParty(Map<String, dynamic> data, BuildContext context) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _partyRepo.addParty(data);

      if (response != null) {
        // Success: API returned PartyId
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Party added successfully")),
        );
        return true;
      } else {
        _errorMessage = "Failed to add party";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $_errorMessage")),
      );
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

}
