import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/sale_transaction_model.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../Products/add product/modle/create_product_model.dart';

class SingleLossProfitScreen extends ConsumerStatefulWidget {
  const SingleLossProfitScreen({
    super.key,
    required this.transactionModel,
  });

  final SalesTransactionModel transactionModel;

  @override
  ConsumerState<SingleLossProfitScreen> createState() => _SingleLossProfitScreenState();
}

class _SingleLossProfitScreenState extends ConsumerState<SingleLossProfitScreen> {
  // Safely calculate Total Profit (Ignoring nulls and negative values)
  double getTotalProfit() {
    double totalProfit = 0;
    for (var element in widget.transactionModel.salesDetails ?? []) {
      double lp = element.lossProfit?.toDouble() ?? 0.0;
      if (lp > 0) {
        totalProfit += lp;
      }
    }
    return totalProfit;
  }

  // Safely calculate Total Loss (Ignoring nulls and positive values)
  double getTotalLoss() {
    double totalLoss = 0;
    for (var element in widget.transactionModel.salesDetails ?? []) {
      double lp = element.lossProfit?.toDouble() ?? 0.0;
      if (lp < 0) {
        totalLoss += lp.abs();
      }
    }
    return totalLoss;
  }

  // Safely calculate Total Quantity
  num getTotalQuantity() {
    num total = 0;
    for (var element in widget.transactionModel.salesDetails ?? []) {
      total += element.quantities ?? 0;
    }
    return total;
  }

  // Calculate Net Profit or Loss accounting for Invoice Discount
  double getNetProfitOrLoss() {
    double grossProfit = getTotalProfit();
    double grossLoss = getTotalLoss();
    double discount = widget.transactionModel.discountAmount?.toDouble() ?? 0.0;

    // Formula: (Total Profit - Total Loss) - Discount
    return (grossProfit - grossLoss) - discount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissionService = PermissionService(ref);

    final salesDetails = widget.transactionModel.salesDetails ?? [];

    // Calculate final Net Profit/Loss values
    double netValue = getNetProfitOrLoss();
    bool isNetLoss = netValue < 0;

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(lang.S.of(context).lpDetails),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (permissionService.hasPermission(Permit.lossProfitsDetailsRead.value)) ...[
                  Text('${lang.S.of(context).invoice} #${widget.transactionModel.invoiceNumber ?? ''}'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          child: Text(
                        widget.transactionModel.party?.name ?? 'Guest',
                        maxLines: 2,
                      )),
                      Text(
                        "${lang.S.of(context).dates} ${widget.transactionModel.saleDate != null ? DateFormat.yMMMd().format(DateTime.parse(widget.transactionModel.saleDate!)) : ''}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${lang.S.of(context).mobile}: ${widget.transactionModel.party?.phone ?? 'N/A'}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        widget.transactionModel.saleDate != null
                            ? DateFormat.jm().format(DateTime.parse(widget.transactionModel.saleDate!))
                            : '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: kMainColor.withOpacity(0.2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(lang.S.of(context).product, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                              child: Text(lang.S.of(context).quantity,
                                  style: const TextStyle(fontWeight: FontWeight.bold))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                              child:
                                  Text(lang.S.of(context).profit, style: const TextStyle(fontWeight: FontWeight.bold))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                              child:
                                  Text(lang.S.of(context).loss, style: const TextStyle(fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ),
                  ),

                  // Table Body (List of Items)
                  ListView.builder(
                      itemCount: salesDetails.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = salesDetails[index];
                        final isVariant = item.product?.productType == ProductType.variant.name;
                        final productName =
                            '${item.product?.productName ?? ''}${isVariant ? ' [${item.stock?.batchNo ?? ''}]' : ''}';

                        final lossProfitVal = item.lossProfit?.toDouble() ?? 0.0;
                        final isLoss = lossProfitVal < 0;

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(productName, textAlign: TextAlign.start),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(child: Text(item.quantities?.toString() ?? '0')),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Text(!isLoss ? "$currency${lossProfitVal.abs().toStringAsFixed(2)}" : '0'),
                                  )),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(isLoss ? "$currency${lossProfitVal.abs().toStringAsFixed(2)}" : '0'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ] else ...[
                  const Center(child: PermitDenyWidget()),
                ],
              ],
            ),
          ),
        ),

        // Bottom Totals Section
        bottomNavigationBar: Visibility(
          visible: permissionService.hasPermission(Permit.lossProfitsDetailsRead.value),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Gross Totals
                Container(
                  decoration: BoxDecoration(
                      color: kMainColor.withOpacity(0.2),
                      border: const Border(bottom: BorderSide(width: 1, color: Colors.grey))),
                  padding: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            lang.S.of(context).total,
                            textAlign: TextAlign.start,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: Text(formatPointNumber(getTotalQuantity()))),
                        ),
                        Expanded(
                            flex: 2, child: Center(child: Text("$currency${getTotalProfit().toStringAsFixed(2)}"))),
                        Expanded(flex: 2, child: Center(child: Text("$currency${getTotalLoss().toStringAsFixed(2)}"))),
                      ],
                    ),
                  ),
                ),

                // Row 2: Discount
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: kMainColor.withOpacity(0.2),
                      border: const Border(bottom: BorderSide(width: 1, color: Colors.grey))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang.S.of(context).discount,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text("$currency${(widget.transactionModel.discountAmount ?? 0).toStringAsFixed(2)}"),
                      ],
                    ),
                  ),
                ),

                // Row 3: Final Net Profit / Loss
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kMainColor.withOpacity(0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isNetLoss ? lang.S.of(context).totalLoss : lang.S.of(context).totalProfit,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          "$currency${netValue.abs().toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
