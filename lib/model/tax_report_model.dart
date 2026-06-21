// Type-safe tax report models for the new API response
// API returns separate lookup maps for tax amounts per transaction

/// Represents a VAT/Tax definition from the API
class VatModel {
  final int id;
  final String name;
  final int rate;
  final int? manageState;
  final List<SubVatModel>? subVat;
  final bool status;

  VatModel({
    required this.id,
    required this.name,
    required this.rate,
    this.manageState,
    this.subVat,
    required this.status,
  });

  factory VatModel.fromJson(Map<String, dynamic> json) {
    return VatModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      rate: json['rate'] as int? ?? 0,
      manageState: json['manage_state'] as int?,
      subVat: json['sub_vat'] == null
          ? null
          : (json['sub_vat'] as List<dynamic>).map((e) => SubVatModel.fromJson(e as Map<String, dynamic>)).toList(),
      status: json['status'] as bool? ?? true,
    );
  }

  /// Display name with rate for column headers
  String get displayName => '$name $rate%';
}

/// Sub-VAT for composite taxes
class SubVatModel {
  final int id;
  final String name;
  final int rate;

  SubVatModel({
    required this.id,
    required this.name,
    required this.rate,
  });

  factory SubVatModel.fromJson(Map<String, dynamic> json) {
    return SubVatModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      rate: json['rate'] as int? ?? 0,
    );
  }
}

/// Main tax report container with type-safe lookup maps
class TaxReportModel {
  final List<InvoiceModel> sales;
  final List<InvoiceModel> purchases;
  final List<VatModel> vats;

  // Sales tax lookups: invoiceId -> vatId -> amount
  final VatRowMap salesVatRowMap;
  final VatRowMap salesReturnVatRowMap;

  // Purchase tax lookups: invoiceId -> vatId -> amount
  final VatRowMap purchaseVatRowMap;
  final VatRowMap purchaseReturnVatRowMap;

  // Totals by VAT ID: vatId -> totalAmount
  final VatTotals salesVatTotals;
  final VatTotals salesReturnVatTotals;
  final VatTotals purchasesVatTotals;
  final VatTotals purchaseReturnVatTotals;

  TaxReportModel({
    required this.sales,
    required this.purchases,
    required this.vats,
    required this.salesVatRowMap,
    required this.salesReturnVatRowMap,
    required this.purchaseVatRowMap,
    required this.purchaseReturnVatRowMap,
    required this.salesVatTotals,
    required this.salesReturnVatTotals,
    required this.purchasesVatTotals,
    required this.purchaseReturnVatTotals,
  });

  factory TaxReportModel.fromJson(Map<String, dynamic> json) {
    return TaxReportModel(
      sales: _parseInvoiceList(json['sales']),
      purchases: _parseInvoiceList(json['purchases']),
      vats: _parseVatList(json['vats']),
      salesVatRowMap: VatRowMap.fromJson(json['saleVatRowMap']),
      salesReturnVatRowMap: VatRowMap.fromJson(json['saleReturnVatRowMap']),
      purchaseVatRowMap: VatRowMap.fromJson(json['purchaseVatRowMap']),
      purchaseReturnVatRowMap: VatRowMap.fromJson(json['purchaseReturnVatRowMap']),
      salesVatTotals: VatTotals.fromJson(json['salesVatTotals']),
      salesReturnVatTotals: VatTotals.fromJson(json['salesReturnVatTotals']),
      purchasesVatTotals: VatTotals.fromJson(json['purchasesVatTotals']),
      purchaseReturnVatTotals: VatTotals.fromJson(json['purchaseReturnVatTotals']),
    );
  }

  static List<InvoiceModel> _parseInvoiceList(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>).map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<VatModel> _parseVatList(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>).map((e) => VatModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get active VATs for column display (sorted by ID for consistent ordering)
  List<VatModel> get activeVats {
    return vats.where((v) => v.status).toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  /// Get VAT column IDs in display order
  List<int> get vatColumnIds => activeVats.map((v) => v.id).toList();
}

/// Invoice/Sale/Purchase transaction model
/// Note: Tax amounts are now looked up via VatRowMap using invoice ID
/// Plus invoice-level VAT (vatId/vatAmount) for when entire invoice has a tax
class InvoiceModel {
  final int id;
  final String? partyName;
  final String? invoiceNumber;
  final DateTime? transactionDate;
  final num? amount;
  final num? discountAmount;
  final String? paymentType;
  final int? vatId; // Invoice-level VAT ID
  final num? vatAmount; // Invoice-level VAT amount

  InvoiceModel({
    required this.id,
    this.partyName,
    this.invoiceNumber,
    this.transactionDate,
    this.amount,
    this.discountAmount,
    this.paymentType,
    this.vatId,
    this.vatAmount,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final dateKey = json['saleDate'] ?? json['purchaseDate'];

    return InvoiceModel(
      id: json['id'] as int,
      partyName: json['party']?['name'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      transactionDate: dateKey == null ? null : DateTime.tryParse(dateKey as String),
      amount: json['totalAmount'] as num?,
      discountAmount: json['discountAmount'] as num?,
      paymentType: (json['payment_type']?['name'] as String?) ?? (json['paymentType']?['name'] as String?),
      vatId: json['vat_id'] as int?,
      vatAmount: json['vat_amount'] as num?,
    );
  }

  /// Calculate total VAT for this invoice following web logic:
  /// totalVat = productVat + invoiceVat - returnVat
  /// where invoiceVat = vatAmount if this invoice's vatId matches the given vatId
  num calculateVatAmount(int vatId, VatRowMap rowMap, VatRowMap returnRowMap) {
    final productVat = rowMap.getAmount(id, vatId);
    final returnVat = returnRowMap.getAmount(id, vatId);
    final invoiceVat = (this.vatId == vatId) ? (vatAmount ?? 0) : 0;
    return productVat + invoiceVat - returnVat;
  }
}

/// Type-safe wrapper for VAT row maps
/// Structure: Map<invoiceId, Map<vatId, amount>>
class VatRowMap {
  final Map<int, Map<int, num>> _data;

  const VatRowMap._(this._data);

  factory VatRowMap.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return const VatRowMap._({});
    }

    final Map<int, Map<int, num>> parsed = {};

    json.forEach((key, value) {
      final invoiceId = int.tryParse(key);
      if (invoiceId == null || value is! Map<String, dynamic>) return;

      final vatMap = <int, num>{};
      value.forEach((vatKey, vatValue) {
        final vatId = int.tryParse(vatKey);
        if (vatId != null && vatValue is num) {
          vatMap[vatId] = vatValue;
        }
      });

      if (vatMap.isNotEmpty) {
        parsed[invoiceId] = vatMap;
      }
    });

    return VatRowMap._(parsed);
  }

  /// Get all VAT amounts for a specific invoice
  Map<int, num> operator [](int invoiceId) => _data[invoiceId] ?? {};

  /// Get specific VAT amount for an invoice
  num getAmount(int invoiceId, int vatId) {
    return _data[invoiceId]?[vatId] ?? 0;
  }

  /// Check if invoice has any VAT entries
  bool hasVat(int invoiceId) => _data.containsKey(invoiceId);

  /// Get all invoice IDs in this map
  Iterable<int> get invoiceIds => _data.keys;

  /// Raw access to underlying data (for iteration)
  Map<int, Map<int, num>> get data => Map.unmodifiable(_data);
}

/// Type-safe wrapper for VAT totals
/// Structure: Map<vatId, totalAmount>
class VatTotals {
  final Map<int, num> _data;

  const VatTotals._(this._data);

  factory VatTotals.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return const VatTotals._({});
    }

    final Map<int, num> parsed = {};
    json.forEach((key, value) {
      final vatId = int.tryParse(key);
      if (vatId != null && value is num) {
        parsed[vatId] = value;
      }
    });

    return VatTotals._(parsed);
  }

  /// Get total for a specific VAT ID
  num operator [](int vatId) => _data[vatId] ?? 0;

  /// Check if total exists for VAT ID
  bool containsKey(int vatId) => _data.containsKey(vatId);

  /// Get all VAT IDs
  Iterable<int> get vatIds => _data.keys;

  /// Raw access to underlying data
  Map<int, num> get data => Map.unmodifiable(_data);
}

/// Extension methods for calculating totals from invoice lists
extension InvoiceModelListExt on List<InvoiceModel> {
  /// Calculate total of all invoice amounts
  num get totalAmount => fold<num>(0, (sum, inv) => sum + (inv.amount ?? 0));

  /// Calculate total of all discounts
  num get totalDiscountAmount => fold<num>(0, (sum, inv) => sum + (inv.discountAmount ?? 0));

  /// Calculate totals per VAT ID using the provided row map
  /// Returns Map<vatId, totalAmount>
  Map<int, num> calculateVatTotals(VatRowMap rowMap) {
    final totals = <int, num>{};

    for (final invoice in this) {
      final vatAmounts = rowMap[invoice.id];
      for (final entry in vatAmounts.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
      }
    }

    return totals;
  }
}

/// Extension for looking up VAT amounts on individual invoices
extension InvoiceModelVatExt on InvoiceModel {
  /// Get all VAT amounts for this invoice from a row map
  Map<int, num> getVatAmounts(VatRowMap rowMap) => rowMap[id];

  /// Get specific VAT amount for this invoice
  num getVatAmount(VatRowMap rowMap, int vatId) => rowMap.getAmount(id, vatId);

  /// Check if this invoice has any VAT entries in the row map
  bool hasVat(VatRowMap rowMap) => rowMap.hasVat(id);
}

/// Helper extension for building DataTable/PDF rows
extension TaxReportModelExt on TaxReportModel {
  /// Get the appropriate VAT row map based on tab type
  VatRowMap getRowMap({required bool isPurchase, bool isReturn = false}) {
    if (isPurchase) {
      return isReturn ? purchaseReturnVatRowMap : purchaseVatRowMap;
    }
    return isReturn ? salesReturnVatRowMap : salesVatRowMap;
  }

  /// Get the appropriate VAT totals based on tab type
  VatTotals getTotals({required bool isPurchase, bool isReturn = false}) {
    if (isPurchase) {
      return isReturn ? purchaseReturnVatTotals : purchasesVatTotals;
    }
    return isReturn ? salesReturnVatTotals : salesVatTotals;
  }

  /// Get invoices based on tab type
  List<InvoiceModel> getInvoices({required bool isPurchase}) {
    return isPurchase ? purchases : sales;
  }

  /// Calculate grand total for a VAT ID following web logic:
  /// grandVatTotal = (vatTotals[vatId] - returnVatTotals[vatId]) + sum of invoice.vatAmount where invoice.vatId == vatId
  num calculateGrandVatTotal({
    required int vatId,
    required bool isPurchase,
  }) {
    final vatTotals = getTotals(isPurchase: isPurchase);
    final returnVatTotals = getTotals(isPurchase: isPurchase, isReturn: true);
    final invoices = getInvoices(isPurchase: isPurchase);

    final productTotal = vatTotals[vatId];
    final returnTotal = returnVatTotals[vatId];
    final invoiceLevelTotal = invoices
        .where((inv) => inv.vatId == vatId)
        .fold<num>(0, (sum, inv) => sum + (inv.vatAmount ?? 0));

    return (productTotal - returnTotal) + invoiceLevelTotal;
  }
}
