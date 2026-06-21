import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/transfer/add_new_transfer_screen.dart';
import 'package:mobile_pos/Screens/transfer/repo/transfer_repo.dart';
import 'package:mobile_pos/Screens/transfer/transfer_invoice_screen.dart';
import 'package:mobile_pos/Screens/transfer/provider/transfer_provider.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/thermal%20priting%20invoices/model/print_transaction_model.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/widgets/empty_warehouse_widget/empty_warehouse.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:shimmer/shimmer.dart';

import '../../PDF Invoice/warehouse_invoice_pdf.dart';
import '../../Provider/profile_provider.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';

// Transfer Tab Builder
Widget buildTransferTab({required BuildContext context, required WidgetRef ref}) {
  final transferAsync = ref.watch(fetchTransferListProvider);
  final theme = Theme.of(context);
  final _lang = lang.S.of(context);

  return RefreshIndicator(
    onRefresh: () async => ref.refresh(fetchTransferListProvider),
    child: transferAsync.when(
      data: (snapshot) {
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: emptyWidget(theme, context),
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 2),
          itemBuilder: (context, index) {
            final data = list[index];
            return TransferWidget(
              ref: ref,
              id: data.id.toString(),
              invoiceNumber: data.invoiceNo ?? 'n/a',
              date: data.transferDate ?? 'n/a',
              stockValue: "$currency${data.stockValue ?? 0}",
              quantity: data.qty?.toString() ?? '0',
              from: data.fromWarehouse ?? data.fromBranch ?? 'n/a',
              to: data.toWarehouse ?? data.toBranch ?? 'n/a',
              status: data.status ?? 'pending',
              context: context,
              onDelete: () async {
                bool success = await TransferRepo().deleteTransfer(
                  id: data.id.toString(),
                  context: context,
                  ref: ref,
                );
                if (success) {
                  ref.refresh(fetchTransferListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transfer Deleted')));
                  }
                }
              },
            );
          },
        );
      },
      error: (e, stack) => Center(child: Text(e.toString())),
      loading: () => ListView.separated(
        itemCount: 6,
        separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 2),
        itemBuilder: (_, __) => const TransferItemShimmer(),
      ),
    ),
  );
}

// Reusable Transfer List Item Widget
class TransferWidget extends StatelessWidget {
  final String invoiceNumber;
  final String id;
  final String date;
  final String from;
  final String to;
  final String quantity;
  final String stockValue;
  final String status;
  final BuildContext context;
  final VoidCallback onDelete;
  final WidgetRef ref;

  const TransferWidget({
    super.key,
    required this.invoiceNumber,
    required this.id,
    required this.date,
    required this.from,
    required this.to,
    required this.quantity,
    required this.stockValue,
    required this.status,
    required this.context,
    required this.onDelete,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = lang.S.of(context);

    // Status Color Logic
    Color statusColor;
    if (status.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'sent') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return Consumer(
      builder: (context, ref, __) {
        final transferDataAsync = ref.watch(transferDetailsProvider(id));
        final businessDataAsync = ref.watch(businessInfoProvider);
        final printerData = ref.watch(thermalPrinterProvider);

        // --- Handle combined loading states ---
        if (transferDataAsync.isLoading || businessDataAsync.isLoading) {
          return const TransferItemShimmer();
        }

        // --- Handle combined error states ---
        if (transferDataAsync.hasError || businessDataAsync.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("Failed to load details")),
          );
        }

        final transfer = transferDataAsync.value;
        final business = businessDataAsync.value;

        if (transfer == null || business == null) return const SizedBox.shrink();

        // --- Main UI ---
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_lang.invoice}: #$invoiceNumber',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: statusColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kPeraColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed: () {
                          generateWarehouseTransferInvoice(context, transfer, business);
                        },
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedPdf02,
                          color: kPeraColor,
                          size: 22,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed: () async {
                          PrintWhTransferTransactionModel model =
                              PrintWhTransferTransactionModel(transfer: transfer, personalInformationModel: business);
                          await printerData.printWhTransferThermalInvoice(
                            transaction: model,
                            context: context,
                            invoiceSize: business.data?.invoiceSize ?? '',
                          );
                        },
                        icon: const Icon(
                          FeatherIcons.printer,
                          color: kPeraColor,
                          size: 22,
                        ),
                      ),
                      SizedBox(
                        width: 16,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (value) async {
                            if (value == 'view') {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => TransferInvoiceScreen(transferId: id.toString())));
                            }

                            if (value == 'edit') {
                              try {
                                EasyLoading.show(status: 'Loading Data...');
                                final transferDetailsData = await ref.read(transferDetailsProvider(id).future);
                                EasyLoading.dismiss();

                                if (context.mounted) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AddNewTransferScreen(
                                                editTransferData: transferDetailsData.data,
                                              )));
                                }
                              } catch (e) {
                                EasyLoading.dismiss();
                                EasyLoading.showError('Failed to load: $e');
                              }
                            }

                            if (value == 'delete') {
                              bool confirmDelete =
                                  await showDeleteConfirmationDialog(context: context, itemName: 'transfer');
                              if (confirmDelete) {
                                onDelete();
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'view', child: Text(_lang.view)),
                            if (status.toLowerCase() == 'pending')
                              PopupMenuItem(value: 'edit', child: Text(_lang.edit)),
                            PopupMenuItem(value: 'delete', child: Text(_lang.delete)),
                          ],
                          child: const Icon(Icons.more_vert, color: kPeraColor, size: 22),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_lang.from, style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13)),
                      Text(from, style: theme.textTheme.titleSmall)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_lang.to, style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13)),
                      Text(to, style: theme.textTheme.titleSmall)
                    ],
                  )
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_lang.quantity, style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13)),
                      Text(quantity, style: theme.textTheme.titleSmall)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_lang.stockValue,
                          style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13)),
                      Text(stockValue, textAlign: TextAlign.end, style: theme.textTheme.titleSmall)
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Item Level Shimmer Loading ---
class TransferItemShimmer extends StatelessWidget {
  const TransferItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 120, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 80, color: Colors.white),
                  ],
                ),
                Container(height: 24, width: 60, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 30, width: 80, color: Colors.white),
                Container(height: 30, width: 80, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
