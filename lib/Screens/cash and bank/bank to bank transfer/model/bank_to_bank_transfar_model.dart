// File: bank_transaction_model.dart (Simplified for create operation)

class BankTransactionData {
  // Only defining fields needed for creation/submission reference
  final String transactionType;
  final num amount;
  final String date;
  final num fromBankId;
  final num toBankId;
  final String? note;

  BankTransactionData({
    required this.transactionType,
    required this.amount,
    required this.date,
    required this.fromBankId,
    required this.toBankId,
    this.note,
  });
}