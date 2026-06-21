import '../../Screens/Due Calculation/Model/due_collection_model.dart';

String getDueStatus(DueCollection item) {
  final totalDue = item.totalDue ?? 0;
  final paid = item.payDueAmount ?? 0;
  final dueAfterPay = item.dueAmountAfterPay ?? totalDue;

  if (dueAfterPay == 0) {
    return "Paid";
  } else if (paid > 0 && dueAfterPay > 0) {
    return "Partial Paid";
  } else {
    return "Unpaid";
  }
}
