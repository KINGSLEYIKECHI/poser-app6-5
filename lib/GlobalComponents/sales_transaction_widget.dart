// File: salesTransactionWidget

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/GlobalComponents/returned_tag_widget.dart';
import 'package:mobile_pos/model/sale_transaction_model.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../PDF Invoice/sales_invoice_pdf.dart';
import '../PDF Invoice/tax_sale_invoice.dart';
import '../Provider/transactions_provider.dart';
import '../Screens/Loss_Profit/single_loss_profit_screen.dart';
import '../Screens/Sales/add_sales.dart';
import '../Screens/Sales/provider/sales_cart_provider.dart';
import '../Screens/Sales/Repo/sales_repo.dart';
import '../Screens/invoice return/invoice_return_screen.dart';
import '../Screens/invoice_details/sales_invoice_details_screen.dart';
import '../constant.dart';
import '../currency.dart';
import '../generated/l10n.dart' as lang;
import '../model/business_info_model.dart' as bInfo;
import '../service/check_actions_when_no_branch.dart';
import '../service/check_user_role_permission_provider.dart';

/// Renders a single sales transaction card/widget.
Widget salesTransactionWidget({
  required BuildContext context,
  required SalesTransactionModel sale,
  required bInfo.BusinessInformationModel businessInfo,
  required WidgetRef ref,
  bool? showProductQTY,
  required bool advancePermission,
  bool? fromLossProfit,
  num? returnAmount,
  bool? isFromSaleList,
}) {
  final theme = Theme.of(context);
  final _lang = l.S.of(context);
  final permissionService = PermissionService(ref);

  return Column(
    children: [
      InkWell(
        onTap: () {
          // Navigate to respective details screen based on the origin screen
          if (fromLossProfit ?? false) {
            SingleLossProfitScreen(transactionModel: sale).launch(context);
          } else {
            SalesInvoiceDetails(
              saleTransaction: sale,
              businessInfo: businessInfo,
            ).launch(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Party Name / Total Products & Invoice Number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      (showProductQTY ?? false)
                          ? "${lang.S.of(context).totalProduct} : ${sale.salesDetails?.length.toString()}"
                          : sale.party?.name ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '#${sale.invoiceNumber}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Status Badges & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Payment Status Badge (Paid/Unpaid/Partial)
                      getPaymentStatusBadge(
                        context: context,
                        dueAmount: sale.dueAmount ?? 0,
                        totalAmount: sale.totalAmount ?? 0,
                      ),
                      // Indicator if the sale has returned items
                      ReturnedTagWidget(
                        show: sale.salesReturns?.isNotEmpty ?? false,
                      ),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      DateFormat('dd MMM, yyyy').format(
                        DateTime.tryParse(sale.saleDate ?? '') ?? DateTime.now(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: kPeragrapColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Total Amount & Paid Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lang.S.of(context).total} : $currency${formatPointNumber(sale.totalAmount ?? 0)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: kPeraColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if ((sale.dueAmount?.toInt() ?? 0) != 0)
                    Text(
                      '${lang.S.of(context).paid} : $currency${formatPointNumber(
                        (sale.totalAmount?.toDouble() ?? 0) - (sale.dueAmount?.toDouble() ?? 0),
                      )}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: kPeraColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Profit/Loss or Due/Return Amount & Action Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Conditional Display based on origin screen (Loss/Profit vs Standard List)
                  if (fromLossProfit ?? false) ...[
                    Flexible(
                      child: Text(
                        '${lang.S.of(context).profit} : $currency ${formatPointNumber(sale.detailsSumLossProfit ?? 0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ).visible(!(sale.detailsSumLossProfit?.isNegative ?? true)),
                    ),
                    Flexible(
                      child: Text(
                        '${lang.S.of(context).loss}: $currency ${formatPointNumber((sale.detailsSumLossProfit ?? 0).abs())}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ).visible(sale.detailsSumLossProfit?.isNegative ?? false),
                    ),
                  ] else ...[
                    if ((sale.dueAmount?.toInt() ?? 0) == 0)
                      Flexible(
                        child: Text(
                          (returnAmount != null)
                              ? '${_lang.returnedAmount}: $currency${formatPointNumber(returnAmount)}'
                              : '${lang.S.of(context).paid} : $currency${formatPointNumber((sale.totalAmount?.toDouble() ?? 0) - (sale.dueAmount?.toDouble() ?? 0))}',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 2,
                        ),
                      ),
                    if ((sale.dueAmount?.toInt() ?? 0) != 0)
                      Flexible(
                        child: Text(
                          (returnAmount != null)
                              ? '${_lang.returnedAmount}: $currency${formatPointNumber(returnAmount)}'
                              : '${lang.S.of(context).due}: $currency${formatPointNumber(sale.dueAmount ?? 0)}',
                          maxLines: 2,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],

                  // Action Buttons (PDF, Print, Excel, Download, Share, More Options)
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () => SaleInvoicePdf.generateSaleDocument(
                              sale,
                              businessInfo,
                              context,
                              showPreview: true,
                            ),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedPdf02,
                              size: 22,
                              color: kPeraColor,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () {
                              SalesInvoiceDetails(
                                saleTransaction: sale,
                                businessInfo: businessInfo,
                              ).launch(context);
                            },
                            icon: const Icon(
                              FeatherIcons.printer,
                              color: kPeraColor,
                              size: 22,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () => SalesInvoiceExcel.generateSaleDocument(
                              sale,
                              businessInfo,
                              context,
                            ),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedXls02,
                              size: 22,
                              color: kPeraColor,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () => SaleInvoicePdf.generateSaleDocument(
                              sale,
                              businessInfo,
                              context,
                              download: true,
                            ),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedDownload01,
                              size: 22,
                              color: kPeraColor,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () => SaleInvoicePdf.generateSaleDocument(
                              sale,
                              businessInfo,
                              context,
                              share: true,
                            ),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedShare08,
                              size: 22,
                              color: kPeraColor,
                            ),
                          ),
                        ],
                      ),

                      // Popup Menu (More Options)
                      if (isFromSaleList == true && advancePermission)
                        PopupMenuButton<String>(
                          offset: const Offset(0, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (String result) async {
                            switch (result) {
                              case 'view_payment':
                                _showPaymentDetailsDialog(context, sale, theme, _lang);
                                break;
                              case 'delete':
                                if (!permissionService.hasPermission(Permit.salesDelete.value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text('You do not have permission to execute this action'),
                                    ),
                                  );
                                  return;
                                }

                                bool confirmDelete = await showDeleteConfirmationDialog(
                                  context: context,
                                  itemName: 'sale',
                                );

                                if (confirmDelete) {
                                  EasyLoading.show(status: _lang.loading ?? 'Deleting...');
                                  SaleRepo repo = SaleRepo();
                                  await repo.deleteSale(ref: ref, context: context, id: sale.id ?? 0);
                                  EasyLoading.dismiss();
                                }
                                break;
                              case 'sale_return':
                                bool result = await checkActionWhenNoBranch(ref: ref, context: context);
                                if (!result) return;

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InvoiceReturnScreen(saleTransactionModel: sale),
                                  ),
                                );
                                break;
                              case 'sale_edit':
                                ref.refresh(cartNotifier);
                                AddSalesScreen(
                                  transitionModel: sale,
                                  customerModel: null,
                                ).launch(context);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext bc) => [
                            // Return Item
                            PopupMenuItem<String>(
                              value: 'sale_return',
                              child: Row(
                                children: [
                                  const Icon(Icons.keyboard_return_outlined, color: kGreyTextColor),
                                  const SizedBox(width: 10.0),
                                  Text(_lang.saleReturn, style: const TextStyle(color: kGreyTextColor)),
                                ],
                              ),
                            ),

                            // Edit Item
                            PopupMenuItem<String>(
                              value: 'sale_edit',
                              child: Row(
                                children: [
                                  const Icon(FeatherIcons.edit, color: kGreyTextColor),
                                  const SizedBox(width: 10.0),
                                  Text(_lang.saleEdit, style: const TextStyle(color: kGreyTextColor)),
                                ],
                              ),
                            ),

                            // Tax Invoice Document
                            if (businessInfo.data?.addons?.taxInvoicePdf == true)
                              PopupMenuItem<String>(
                                value: 'tax_invoice',
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(bc);
                                    try {
                                      EasyLoading.show(status: lang.S.of(context).loading);
                                      final fetchedSaleTax =
                                          await ref.read(saleTaxProvider(sale.id?.toInt() ?? 0).future);
                                      EasyLoading.dismiss();

                                      if (fetchedSaleTax == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(lang.S.of(context).listIsEmpty ?? 'List is empty')),
                                        );
                                        return;
                                      }

                                      await TaxSaleInvoicePdf.generateSaleDocument(
                                        fetchedSaleTax,
                                        businessInfo,
                                        context,
                                        showPreview: true,
                                      );
                                    } catch (e) {
                                      EasyLoading.dismiss();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      const HugeIcon(
                                        icon: HugeIcons.strokeRoundedPdf02,
                                        size: 22,
                                        color: kGreyTextColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        lang.S.of(context).taxInvoice,
                                        style: const TextStyle(color: kGreyTextColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // View Payment Details
                            const PopupMenuItem<String>(
                              value: 'view_payment',
                              child: Row(
                                children: [
                                  Icon(Icons.remove_red_eye_outlined, color: kGreyTextColor),
                                  SizedBox(width: 10.0),
                                  Text('View Payment', style: TextStyle(color: kGreyTextColor)),
                                ],
                              ),
                            ),

                            // Delete Item (Requires Permission)
                            if (permissionService.hasPermission(Permit.salesDelete.value))
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline, color: kGreyTextColor),
                                    const SizedBox(width: 10.0),
                                    Text(_lang.delete, style: const TextStyle(color: kGreyTextColor)),
                                  ],
                                ),
                              ),
                          ],
                          child: const Icon(FeatherIcons.moreVertical, color: kPeraColor),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const Divider(height: 1, color: kLineColor),
    ],
  );
}

// ----------------------------------------------------
// View Payment Bottom Sheet / Dialog Function
// ----------------------------------------------------
void _showPaymentDetailsDialog(BuildContext context, SalesTransactionModel sale, ThemeData theme, var lang) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment List',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Payment List Rendering
            if (sale.transactions == null || sale.transactions!.isEmpty)
              const Center(child: Text('No payments found.', style: TextStyle(color: Colors.grey)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sale.transactions!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final trans = sale.transactions![index];

                  // Safely format the date string
                  String formattedDate = trans.date ?? '';
                  if (formattedDate.isNotEmpty) {
                    try {
                      formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(formattedDate));
                    } catch (e) {
                      // Silently fallback to raw date string if parsing fails
                    }
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trans.transactionType ?? 'Unknown Method',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),

                          // Displays the associated receipt tracking number
                          Text(
                            'Receipt No. ${trans.id ?? 'N/A'}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                          ),
                          const SizedBox(height: 2),

                          Text(
                            formattedDate,
                            style: theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                          ),
                        ],
                      ),
                      Text(
                        '$currency${formatPointNumber(trans.amount ?? 0)}',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

// ----------------------------------------------------
// Payment Status Badge Builder
// ----------------------------------------------------
Widget getPaymentStatusBadge({required num dueAmount, required num totalAmount, required BuildContext context}) {
  String status;
  Color textColor;
  Color bgColor;

  // Determine styling based on outstanding balance
  if (dueAmount <= 0) {
    status = lang.S.of(context).paid;
    textColor = const Color(0xff0dbf7d);
    bgColor = const Color(0xff0dbf7d).withOpacity(0.1);
  } else if (dueAmount >= totalAmount) {
    status = lang.S.of(context).unPaid;
    textColor = const Color(0xFFED1A3B);
    bgColor = const Color(0xFFED1A3B).withOpacity(0.1);
  } else {
    status = lang.S.of(context).partialPaid;
    textColor = const Color(0xFFFFA500);
    bgColor = const Color(0xFFFFA500).withOpacity(0.1);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
    ),
    child: Text(
      status,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
    ),
  );
}
