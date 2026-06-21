class TransferCartItem {
  final String productId;
  final String productName;
  final String productCode;
  final num quantity;
  final num purchasePrice;
  final int stockId;
  final num currentStock;
  final List<dynamic>? serialNumber;

  TransferCartItem({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.purchasePrice,
    required this.stockId,
    required this.currentStock,
    this.serialNumber,
  });

  TransferCartItem copyWith({num? quantity, List<dynamic>? serialNumber}) {
    return TransferCartItem(
      productId: productId,
      productName: productName,
      productCode: productCode,
      purchasePrice: purchasePrice,
      stockId: stockId,
      currentStock: currentStock,
      quantity: quantity ?? this.quantity,
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }
}
