class SalesSummary {
  final double total;
  final double cash;
  final double credit;
  final double bank;

  SalesSummary({
    required this.total,
    required this.cash,
    required this.credit,
    required this.bank,
  });
}

class PurchaseSummary {
  final double total;
  final double cash;
  final double credit;
  final double bank;

  PurchaseSummary({
    required this.total,
    required this.cash,
    required this.credit,
    required this.bank,
  });
}

class Party {
  final String name;
  final double outstanding;
  final String? contact; // Contact can be null

  Party({
    required this.name,
    required this.outstanding,
    this.contact,
  });
}
class Product {
  final String productName;
  final String hsnCode;
  final String batchNo;
  final String expiryDate; // Contact can be null

  Product({
    required this.productName,
    required this.hsnCode,
    required this.batchNo,
    required this.expiryDate,
  });
}