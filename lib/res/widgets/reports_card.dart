import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

class ReportCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, String> fields; // label → key mapping
  final String? title;
  final String? dateKey;
  final String? dateLabel;
  final Color? accentColor;

  const ReportCard({
    Key? key,
    required this.data,
    required this.fields,
    this.title,
    this.dateKey,
    this.dateLabel,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Colors.blue;

    String _formatDate(dynamic dateValue) {
      if (dateValue == null) return '-';
      try {
        // If already a DateTime object
        DateTime date = dateValue is DateTime
            ? dateValue
            : DateTime.parse(dateValue.toString());
        return DateFormat('dd-MM-yyyy').format(date); // Change format as needed
      } catch (e) {
        return dateValue.toString(); // fallback if parsing fails
      }
    }

    // Split fields into chunks of 2 for rows
    List<List<MapEntry<String, String>>> fieldRows = [];
    List<MapEntry<String, String>> temp = [];
    int count = 0;
    fields.entries.forEach((entry) {
      temp.add(entry);
      count++;
      if (count % 2 == 0) {
        fieldRows.add(temp);
        temp = [];
      }
    });
    if (temp.isNotEmpty) fieldRows.add(temp);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shadowColor: Colors.black12,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // pure white
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6EAF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Row — Title & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (dateKey != null && (data[dateKey]?.toString().isNotEmpty ?? false))
                  Text(
                    '${dateLabel ?? 'Date'}: ${_formatDate(data[dateKey])}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(height: 10),

            // 🔹 Info Fields in rows
            Column(
              children: fieldRows.map((rowEntries) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: rowEntries.map((entry) {
                      final label = entry.key;
                      final key = entry.value;
                      final value = data[key];

                      return Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: '$label: ',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.5,
                                ),
                              ),
                              TextSpan(
                                text: value?.toString() ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
