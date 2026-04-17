import 'package:flutter/material.dart';

import '../repository/sms_dialog_repository.dart';

class SmsDialogViewmodel with ChangeNotifier {
  final _repo = SmsDialogRepository();

  bool _loading = false;
  bool get loading => _loading;

  String? _responseMessage;
  String? get responseMessage => _responseMessage;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> sendBillNotification({
    required BuildContext context,
    required int salesId,
    required bool isSmsSent,
    required bool isWpSent,
    Function(String)? onSuccess,
    Function(Object)? onError,
  }) async {
    setLoading(true);
    try {
      final message = await _repo.sendBillSMSAndWPNotification(
        salesId: salesId,
        isSmsSent: isSmsSent,
        isWpSent: isWpSent,
      );

      _responseMessage = message;
      notifyListeners();


      onSuccess?.call(message);
    } catch (e) {
      // ❌ Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to send SMS/WP notification: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      onError?.call(e);
    } finally {
      setLoading(false);
    }
  }
}
