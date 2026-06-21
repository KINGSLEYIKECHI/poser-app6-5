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
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../../PDF Invoice/warehouse_invoice_pdf.dart';
import '../../Provider/profile_provider.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';

class BranchTransferListScreen extends ConsumerStatefulWidget {
  const BranchTransferListScreen({super.key});

  @override
  ConsumerState<BranchTransferListScreen> createState() => _BranchTransferListScreenState();
}

class _BranchTransferListScreenState extends ConsumerState<BranchTransferListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = l.S.of(context);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(_lang.transferList ?? 'Branch Transfer List'),
        centerTitle: true,
        backgroundColor: kWhite,
        elevation: 0,
        surfaceTintColor: kWhite,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: kBackgroundColor),
        ),
      ),
      body: _buildTransferListBody(context: context, ref: ref, theme: theme),
      floatingActionButton: _buildFAB(theme, _lang),
    );
  }

  // --- Transfer List Body ---
  Widget _buildTransferListBody({required BuildContext context, required WidgetRef ref, required ThemeData theme}) {
    final transferAsync = ref.watch(fetchTransferListProvider);

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
            padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer Deleted')));
                    }
                  }
                },
              );
            },
          );
        },
        error: (e, stack) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // --- Floating Action Button ---
  Widget _buildFAB(ThemeData theme, l.S lang) {
    return Container(
      height: 48,
      width: 190,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC52127).withOpacity(0.2),
            offset: const Offset(0, 11),
            blurRadius: 14,
          ),
        ],
      ),
      child: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: kMainColor,
        onPressed: () {
          // Navigate to Add Transfer Screen
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewTransferScreen()));
        },
        child: Text(
          '+ ${lang.addTransfer ?? 'Add Transfer'}',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

// ==========================================
// Reusable Transfer List Item Widget
// ==========================================
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
        final transferData = ref.watch(transferDetailsProvider(id));
        final businessData = ref.watch(businessInfoProvider);
        final printerData = ref.watch(thermalPrinterProvider);

        return transferData.when(
          data: (transfer) {
            return businessData.when(
              data: (business) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Invoice, Status, Date & Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice: #$invoiceNumber',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                            mainAxisSize: MainAxisSize.min,
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
                                  PrintWhTransferTransactionModel model = PrintWhTransferTransactionModel(
                                      transfer: transfer, personalInformationModel: business);
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
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                onSelected: (value) async {
                                  if (value == 'view') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TransferInvoiceScreen(transferId: id.toString()),
                                      ),
                                    );
                                  } else if (value == 'edit') {
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
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      EasyLoading.dismiss();
                                      EasyLoading.showError('Failed to load: $e');
                                    }
                                  } else if (value == 'delete') {
                                    bool confirmDelete = await showDeleteConfirmationDialog(
                                      context: context,
                                      itemName: 'transfer',
                                    );
                                    if (confirmDelete) {
                                      onDelete();
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'view', child: Text('View')),
                                  if (status.toLowerCase() == 'pending')
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                                child: const Icon(
                                  Icons.more_vert,
                                  color: kPeraColor,
                                  size: 22,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Details: From / To / Qty / Value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13),
                                ),
                                Text(from,
                                    style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Text(
                                  'Quantity',
                                  style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13),
                                ),
                                Text(quantity, style: theme.textTheme.titleSmall),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'To',
                                  style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13),
                                ),
                                Text(to,
                                    style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Text(
                                  'Stock Value',
                                  style: theme.textTheme.bodySmall?.copyWith(color: kPeraColor, fontSize: 13),
                                ),
                                Text(
                                  stockValue,
                                  textAlign: TextAlign.end,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              error: (e, stack) => Center(child: Text(e.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
          error: (e, stack) => Center(child: Text(e.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
