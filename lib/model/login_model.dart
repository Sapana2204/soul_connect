import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginModel {
  String? token;
  Map<String, List<String>>? permissionsMap;
  String? roleName; // ✅ Add this
  String? firmName; // ✅ Add this
  int? userId; // ✅ Add this
  bool isCustomerLogin = false;

  LoginModel({this.token});

  LoginModel.fromJson(Map<String, dynamic> json) {
    token = json['message'];

    if (token != null && token!.isNotEmpty) {
      final decoded = JwtDecoder.decode(token!);

      // 👇 Print decoded token & fields
      debugPrint("🧾 Full Decoded Token: $decoded");
      debugPrint("👤 UserId: ${decoded['UserId']}");
      debugPrint("👨‍💻 UserName: ${decoded['UserName']}");
      debugPrint("📛 RoleName: ${decoded['RoleName']}");
      debugPrint("👤 FullName: ${decoded['UserFullName']}");
      debugPrint("👤 FirmName: ${decoded['FirmName']}");

      roleName = decoded['RoleName'];
      firmName = decoded['FirmName'];   // ✅ ADD THIS

      userId = int.tryParse(decoded['UserId'].toString());

      isCustomerLogin = decoded['IsCustomerLogin']?.toString().toLowerCase() == 'true';

      final rawPermissions = decoded['Permissions'];

      if (rawPermissions != null) {
        try {
          Map<String, dynamic> parsed;

          if (rawPermissions is String) {
            parsed = jsonDecode(rawPermissions);
          } else if (rawPermissions is Map) {
            parsed = Map<String, dynamic>.from(rawPermissions);
          } else {
            parsed = {};
          }

          permissionsMap = parsed.map((key, value) {
            return MapEntry(key.toString(), List<String>.from(value));
          });
          debugPrint("✅ Parsed PermissionsMap: $permissionsMap");
        } catch (e) {
          debugPrint("❌ Failed to parse permissions: $e");
          permissionsMap = {};
        }
      } else {
        debugPrint("❗ Permissions field is null");
        permissionsMap = {};
      }
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'message': token,
    };
  }

  /// 🔍 Extract view permissions based on Modules list
  List<String> get permissions {
    if (token == null) return [];
    try {
      final decoded = JwtDecoder.decode(token!);
      final modulesRaw = decoded['Modules'];
      final modules = modulesRaw is String
          ? List<String>.from(jsonDecode(modulesRaw))
          : List<String>.from(modulesRaw ?? []);

      debugPrint("✅ Extracted Modules: $modules");

      final viewPermissions = modules.map((m) => m.toLowerCase() + "_view").toList();
      return viewPermissions;
    } catch (e) {
      debugPrint("❌ Error parsing module view permissions: $e");
      return [];
    }
  }

  /// ✅ Check if user has specific permission for a module
  bool hasPermission(String module, String action) {
    final modulePermissions = permissionsMap?.entries.firstWhere(
          (entry) => entry.key.toLowerCase() == module.toLowerCase(),
      orElse: () => const MapEntry("", []),
    ).value;

    return modulePermissions?.any(
          (perm) => perm.toLowerCase() == action.toLowerCase(),
    ) ?? false;
  }




}
