import 'package:mobile_pos/model/sale_transaction_model.dart';

import '../../Screens/Due Calculation/Model/due_collection_model.dart';
import '../../Screens/Purchase/Model/purchase_transaction_model.dart';
import '../../Screens/transfer/model/transfer_details_model.dart';
import '../../model/business_info_model.dart';

class PrintSalesTransactionModel {
  PrintSalesTransactionModel({required this.transitionModel, required this.personalInformationModel});

  BusinessInformationModel personalInformationModel;
  SalesTransactionModel? transitionModel;
}

class PrintPurchaseTransactionModel {
  PrintPurchaseTransactionModel({required this.purchaseTransitionModel, required this.personalInformationModel});

  BusinessInformationModel personalInformationModel;
  PurchaseTransaction? purchaseTransitionModel;
}

class PrintDueTransactionModel {
  PrintDueTransactionModel({required this.dueTransactionModel, required this.personalInformationModel});

  DueCollection? dueTransactionModel;
  BusinessInformationModel personalInformationModel;
}

//Print warehouse transfer model
class PrintWhTransferTransactionModel {
  PrintWhTransferTransactionModel({required this.transfer, required this.personalInformationModel});

  TransferDetailsModel? transfer;
  BusinessInformationModel personalInformationModel;
}
