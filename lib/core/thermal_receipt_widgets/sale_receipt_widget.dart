import 'package:flutter/material.dart';

import '../../thermal priting invoices/model/print_transaction_model.dart';

final GlobalKey screenshotGlobalKey = GlobalKey();

class SaleReceiptWidget extends StatelessWidget {
  const SaleReceiptWidget({super.key, required this.paperSize, required this.model});
  final String paperSize;
  final PrintSalesTransactionModel model;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: screenshotGlobalKey,
      child: Container(
        color: Colors.white,
        width: paperSize == "58 mm" ? 384 : 576,
        child: Column(
          children: [
            Text(model.personalInformationModel.data?.companyName ?? "", style: Theme.of(context).textTheme.titleLarge),
            Text(model.personalInformationModel.data?.address ?? "", style: Theme.of(context).textTheme.bodyLarge),
            Text(model.personalInformationModel.data?.phoneNumber ?? "", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
