import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../viewmodel/sms_dialog_viewmodel.dart';

class SendBillMessageDialog extends StatefulWidget {
  final int salesId;

  const SendBillMessageDialog({
    super.key,
    required this.salesId,
  });

  @override
  State<SendBillMessageDialog> createState() => _SendBillMessageDialogState();
}

class _SendBillMessageDialogState extends State<SendBillMessageDialog> {
  bool isSmsSelected = false;
  bool isWhatsappSelected = false;

  @override
  Widget build(BuildContext context) {
    final smsVM = Provider.of<SmsDialogViewmodel>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Send Bill Message',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Choose how to send the bill:",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 15),

          // SMS / WhatsApp buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectButton(
                label: "SMS",
                icon: Icons.sms_outlined,
                selected: isSmsSelected,
                onTap: () => setState(() => isSmsSelected = !isSmsSelected),
              ),
              const SizedBox(width: 10),
              _buildSelectButton(
                label: "WhatsApp",
                icon: Icons.chat,
                selected: isWhatsappSelected,
                onTap: () => setState(() => isWhatsappSelected = !isWhatsappSelected),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Info text
          if (isSmsSelected || isWhatsappSelected)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 18),
                const SizedBox(width: 6),
                Text(
                  "Will send via "
                      "${isSmsSelected ? "SMS" : ""}"
                      "${(isSmsSelected && isWhatsappSelected) ? " & " : ""}"
                      "${isWhatsappSelected ? "WhatsApp" : ""}",
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            const Text(
              "No option selected",
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: smsVM.loading
              ? null
              : () async {
            if (!isSmsSelected && !isWhatsappSelected) {
              Fluttertoast.showToast(
                msg: "Please select at least one option",
                gravity: ToastGravity.BOTTOM,
              );
              return;
            }

            isSmsSent: isSmsSelected;
            isWpSent: isWhatsappSelected;

            await smsVM.sendBillNotification(
              context: context,

              salesId: widget.salesId,
              // isSmsSent: isSms,
              // isWpSent: isWp,
              isSmsSent: false,
              isWpSent: false,
              onSuccess: (message) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Message Sent Successfully"),
                    content: SingleChildScrollView(child: Text(message)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed: $error")),
                );
              },
            );
          },
          child: smsVM.loading
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Text(
            "Send Messages",
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey.shade800,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: smsVM.loading ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSelectButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: selected ? Colors.green.shade100 : Colors.white,
            border: Border.all(
              color: selected ? Colors.green : Colors.grey.shade300,
              width: 1.3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.green.shade700 : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.green.shade700 : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
