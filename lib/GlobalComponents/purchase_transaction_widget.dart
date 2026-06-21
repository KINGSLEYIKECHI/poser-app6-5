// File: purchase_transaction_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/add_to_cart_purchase.dart';
import 'package:nb_utils/nb_utils.dart';

import '../GlobalComponents/returned_tag_widget.dart';
import '../PDF Invoice/purchase_invoice_pdf.dart';
import '../PDF Invoice/tax_purchase_invoice.dart';
import '../Provider/transactions_provider.dart';
import '../Screens/Purchase/add_and_edit_purchase.dart';
import '../Screens/Purchase/Model/purchase_transaction_model.dart';
import '../Screens/Purchase/Repo/purchase_repo.dart';
import '../Screens/invoice return/invoice_return_screen.dart';
import '../Screens/invoice_details/purchase_invoice_details.dart';
import '../constant.dart';
import '../currency.dart';
import '../generated/l10n.dart' as lang;
import '../model/business_info_model.dart' as bInfo;
import '../service/check_actions_when_no_branch.dart';
import '../service/check_user_role_permission_provider.dart';
import '../widgets/deleteing_alart_dialog.dart';

/// Renders a single purchase transaction card/widget.
Widget purchaseTransactionWidget({
  required BuildContext context,
  required PurchaseTransaction purchase,
  required bInfo.BusinessInformationModel businessInfo,
  required WidgetRef ref,
  bool? showProductQTY,
  required bool advancePermission,
  num? returnAmount,
  bool? isFromPurchaseList,
}) {
  final theme = Theme.of(context);
  final _lang = lang.S.of(context);
  final permissionService = PermissionService(ref);

  return Column(
    children: [
      InkWell(
        onTap: () {
          PurchaseInvoiceDetails(
            transitionModel: purchase,
            businessInfo: businessInfo,
          ).launch(context);
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
                          ? "${_lang.totalProduct} : ${purchase.details?.length.toString()}"
                          : purchase.party?.name ?? '',
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
                    '#${purchase.invoiceNumber}',
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
                      getPurchasePaymentStatusBadge(
                        context: context,
                        dueAmount: purchase.dueAmount ?? 0,
                        totalAmount: purchase.totalAmount ?? 0,
                      ),
                      // Indicator if the purchase has returned items
                      ReturnedTagWidget(
                        show: purchase.purchaseReturns?.isNotEmpty ?? false,
                      ),
                    ],
                  ),
                  Flexible(
                    child: Text(
                      DateFormat('dd MMM, yyyy').format(
                        DateTime.tryParse(purchase.purchaseDate ?? '') ?? DateTime.now(),
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
                    '${_lang.total} : $currency${formatPointNumber(purchase.totalAmount ?? 0)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: kPeraColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if ((purchase.dueAmount?.toInt() ?? 0) != 0)
                    Text(
                      '${_lang.paid} : $currency${formatPointNumber(
                        (purchase.totalAmount?.toDouble() ?? 0) - (purchase.dueAmount?.toDouble() ?? 0),
                      )}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: kPeraColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Due/Return Amount & Action Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if ((purchase.dueAmount?.toInt() ?? 0) == 0)
                    Flexible(
                      child: Text(
                        (returnAmount != null)
                            ? '${_lang.returnAmount}: $currency${formatPointNumber(returnAmount)}'
                            : '${_lang.paid} : $currency${formatPointNumber((purchase.totalAmount?.toDouble() ?? 0) - (purchase.dueAmount?.toDouble() ?? 0))}',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 2,
                      ),
                    ),
                  if ((purchase.dueAmount?.toInt() ?? 0) != 0)
                    Flexible(
                      child: Text(
                        (returnAmount != null)
                            ? '${_lang.returnAmount}: $currency${formatPointNumber(returnAmount)}'
                            : '${_lang.due}: $currency${formatPointNumber(purchase.dueAmount ?? 0)}',
                        maxLines: 2,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Action Buttons (PDF, Print, Download, Share, More Options)
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(
                              purchase,
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
                              PurchaseInvoiceDetails(
                                transitionModel: purchase,
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
                            onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(
                              purchase,
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
                            onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(
                              purchase,
                              businessInfo,
                              context,
                              isShare: true,
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
                      if (isFromPurchaseList == true && advancePermission)
                        PopupMenuButton<String>(
                          offset: const Offset(0, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (String result) async {
                            switch (result) {
                              case 'view_payment':
                                _showPurchasePaymentDetailsDialog(context, purchase, theme, _lang);
                                break;
                              case 'delete':
                                if (!permissionService.hasPermission(Permit.purchasesDelete.value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text('You do not have permission to execute this action'),
                                    ),
                                  );
                                  return;
                                }

                                bool confirmDelete = await showDeleteConfirmationDialog(
                                  context: context,
                                  itemName: 'purchase',
                                );

                                if (confirmDelete) {
                                  EasyLoading.show(status: _lang.loading ?? 'Deleting...');
                                  PurchaseRepo repo = PurchaseRepo();
                                  await repo.deletePurchase(ref: ref, context: context, id: purchase.id.toString());
                                  EasyLoading.dismiss();
                                }
                                break;
                              case 'purchase_return':
                                bool result = await checkActionWhenNoBranch(ref: ref, context: context);
                                if (!result) return;

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InvoiceReturnScreen(purchaseTransaction: purchase),
                                  ),
                                );
                                break;
                              case 'purchase_edit':
                                ref.refresh(cartNotifierPurchaseNew); // Make sure this matches your provider name
                                AddAndUpdatePurchaseScreen(
                                  transitionModel: purchase,
                                  customerModel: null,
                                ).launch(context);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext bc) => [
                            // Return Item
                            PopupMenuItem<String>(
                              value: 'purchase_return',
                              child: Row(
                                children: [
                                  const Icon(Icons.keyboard_return_outlined, color: kGreyTextColor),
                                  const SizedBox(width: 10.0),
                                  Text(_lang.purchaseReturn, style: const TextStyle(color: kGreyTextColor)),
                                ],
                              ),
                            ),

                            // Edit Item (Hide if already returned)
                            if (!(purchase.purchaseReturns?.isNotEmpty ?? false))
                              PopupMenuItem<String>(
                                value: 'purchase_edit',
                                child: Row(
                                  children: [
                                    const Icon(FeatherIcons.edit, color: kGreyTextColor),
                                    const SizedBox(width: 10.0),
                                    Text('Edit Purchase', style: const TextStyle(color: kGreyTextColor)),
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
                                      EasyLoading.show(status: _lang.loading);
                                      final fetchedPurchaseTax =
                                          await ref.read(purchaseTaxProvider(purchase.id?.toInt() ?? 0).future);
                                      EasyLoading.dismiss();

                                      if (fetchedPurchaseTax == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(_lang.noTaxFound ?? 'No tax data available')),
                                        );
                                        return;
                                      }

                                      await TaxPurchaseInvoicePdf.generateSaleDocument(
                                        fetchedPurchaseTax,
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
                                        _lang.taxInvoice,
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
                            if (permissionService.hasPermission(Permit.purchasesDelete.value))
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
void _showPurchasePaymentDetailsDialog(BuildContext context, PurchaseTransaction purchase, ThemeData theme, var lang) {
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
            if (purchase.transactions == null || purchase.transactions!.isEmpty)
              const Center(child: Text('No payments found.', style: TextStyle(color: Colors.grey)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: purchase.transactions!.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final trans = purchase.transactions![index];

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
Widget getPurchasePaymentStatusBadge(
    {required num dueAmount, required num totalAmount, required BuildContext context}) {
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
    status = lang.S.of(context).partialPaid; // If you don't have partialPaid in lang, replace with 'Partial'
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
