import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20account/provider/bank_account_provider.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20account/repo/bank_account_repo.dart';

// --- Local Imports ---
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/Screens/hrm/widgets/global_search_appbar.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../../widgets/deleteing_alart_dialog.dart';
import '../adjust bank balance/adjust_bank_balance_screen.dart';
import '../bank to bank transfer/bank_to_bank_transfer_screen.dart';
import '../bank to cash transfer/bank_to_cash_transfer.dart';
import 'add_edit_new_bank_account_screen.dart';
import 'bank_transfer_history_screen.dart';
import 'model/bank_account_list_model.dart';

class BankAccountListScreen extends ConsumerStatefulWidget {
  const BankAccountListScreen({super.key});

  @override
  ConsumerState<BankAccountListScreen> createState() => _BankAccountListScreenState();
}

class _BankAccountListScreenState extends ConsumerState<BankAccountListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearch = false;

  List<BankData> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Date Formatting Utility ---
  String _formatDateForDisplay(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd MMM, yyyy').format(dateTime);
    } catch (_) {
      return date;
    }
  }
  // --- END Date Formatting Utility ---

  void _applyFilters() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _filterBanks(List<BankData> allBanks) {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredList = allBanks;
    } else {
      _filteredList = allBanks.where((bank) {
        final name = (bank.name ?? '').toLowerCase();
        final bankName = (bank.meta?.bankName ?? '').toLowerCase();
        final accNumber = (bank.meta?.accountNumber ?? '').toLowerCase();
        final holderName = (bank.meta?.accountHolder ?? '').toLowerCase();

        return name.contains(query) ||
            bankName.contains(query) ||
            accNumber.contains(query) ||
            holderName.contains(query);
      }).toList();
    }
  }

  // --- CRITICAL FIX 1: NAVIGATION AND ACTION METHODS ---
  void _navigateToEdit(BankData bank) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditNewBank(bankData: bank)),
    );
  }

  void _navigateToTransactions(BankData bank) {
    // Placeholder for navigating to transactions screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l.S.of(context).viewingTransactionFor} ${bank.name}')),
    );
  }

  void _showDeleteConfirmationDialog(num id, String name) async {
    bool result = await showDeleteConfirmationDialog(context: context, itemName: name);
    if (result) {
      final repo = BankRepo();
      await repo.deleteBank(id: id, context: context, ref: ref);
      // Repo handles invalidate(bankListProvider)
    }
  }
  // --- END FIX 1 ---

  // --- Pull to Refresh ---
  Future<void> _refreshData() async {
    ref.invalidate(bankListProvider);
    return ref.watch(bankListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final theme = Theme.of(context);
    final bankListAsync = ref.watch(bankListProvider);
    final permissionService = PermissionService(ref); // Assuming this is defined

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalSearchAppBar(
        isSearch: _isSearch,
        onSearchToggle: () {
          setState(() {
            _isSearch = !_isSearch;
            if (!_isSearch) {
              _searchController.clear();
            }
          });
        },
        title: _lang.bankAccounts,
        controller: _searchController,
        onChanged: (query) {
          // Handled by _searchController.addListener
        },
      ),
      body: bankListAsync.when(
        data: (model) {
          // Check read permission (Assuming 'bank_read_permit' exists)
          if (!permissionService.hasPermission('bank_read_permit')) {
            return const Center(child: PermitDenyWidget()); // Assuming PermitDenyWidget exists
          }
          final allBanks = model.data ?? [];

          _filterBanks(allBanks);

          if (_filteredList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Text(
                    _searchController.text.isEmpty
                        ? _lang.noBankAccountFound
                        : '${_lang.noAccountsFoundMissing} "${_searchController.text}".',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _filteredList.length,
              itemBuilder: (_, index) => _buildBankItem(
                context: context,
                ref: ref,
                bank: _filteredList[index],
              ),
              separatorBuilder: (_, __) => const Divider(
                color: kLineColor,
                height: 1,
              ),
            ),
          );
        },
        error: (err, stack) => Center(child: Text('Failed to load bank accounts: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: permissionService.hasPermission('bank_create_permit')
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _depositPopUp(context),
                      child: Text(_lang.deposit),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditNewBank(),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(_lang.addBank),
                    ),
                  )
                ],
              ),
            )
          : null,
    );
  }

  //------Deposit/Withdraw Popup-------------------
  void _depositPopUp(BuildContext context) {
    final _lang = l.S.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentGeometry.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: kPeraColor,
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(vertical: -2, horizontal: -2),
                leading: SvgPicture.asset(
                  'assets/bank.svg',
                  height: 24,
                  width: 24,
                ),
                title: Text(_lang.bankToBankTransfer),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BankToBankTransferScreen()),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(vertical: -2, horizontal: -2),
                leading: SvgPicture.asset(
                  'assets/bank_cash.svg',
                  height: 24,
                  width: 24,
                ),
                title: Text(_lang.bankToCashTransfer),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BankToCashTransferScreen()),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(vertical: -2, horizontal: -2),
                leading: SvgPicture.asset(
                  'assets/bank_adjust.svg',
                  height: 24,
                  width: 24,
                ),
                title: Text(_lang.adjustBankBalance),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdjustBankBalanceScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // --- List Item Builder ---

  Widget _buildBankItem({
    required BuildContext context,
    required WidgetRef ref,
    required BankData bank,
  }) {
    final theme = Theme.of(context);
    final _lang = l.S.of(context);
    final bankMeta = bank.meta;
    final balanceDisplay = '$currency${bank.balance?.toStringAsFixed(2) ?? '0.00'}';
    final accountName = bank.name ?? 'N/A';
    final bankName = bankMeta?.bankName ?? 'N/A Bank';

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          _lang.accountName: accountName,
          _lang.accountNumber: bankMeta?.accountNumber ?? 'N/A',
          _lang.bankName: bankName,
          _lang.holderName: bankMeta?.accountHolder ?? 'N/A',
          _lang.openingDate: _formatDateForDisplay(bank.openingDate),
        },
        descriptionTitle: '${_lang.currentBalance}:',
        description: balanceDisplay,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: -4),
              title: Row(
                children: [
                  Text(
                    accountName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    balanceDisplay,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: kSuccessColor,
                    ),
                  )
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bankName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kGrey6,
                    ),
                  ),
                  Text(
                    bankMeta?.accountNumber ?? 'N/A',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kGrey6,
                    ),
                  ),
                ],
              ),
              trailing: _buildActionButtons(context, ref, bank),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn({
    required String time,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kNeutral800,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, BankData bank) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    final bankMeta = bank.meta;
    final balanceDisplay = '$currency${bank.balance?.toStringAsFixed(2) ?? '0.00'}';
    final accountName = bank.name ?? 'N/A';
    final bankName = bankMeta?.bankName ?? 'N/A Bank';
    final permissionService = PermissionService(ref);
    return SizedBox(
      width: 20,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        onSelected: (value) {
          if (bank.id == null) return;
          if (value == 'view') {
            if (!permissionService.hasPermission('bank_view_permit')) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_lang.permissionDeniedToViewBank)));
              return;
            }
            viewModalSheet(
              context: context,
              item: {
                _lang.accountName: accountName,
                _lang.accountNumber: bankMeta?.accountNumber ?? 'N/A',
                _lang.bankName: bankName,
                _lang.holderName: bankMeta?.accountHolder ?? 'N/A',
                _lang.openingDate: _formatDateForDisplay(bank.openingDate),
              },
              descriptionTitle: '${_lang.currentBalance}:',
              description: balanceDisplay,
            );
          } else if (value == 'edit') {
            if (!permissionService.hasPermission('bank_update_permit')) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_lang.permissionDeniedToUpdateBank)));
              return;
            }
            _navigateToEdit(bank);
          } else if (value == 'transactions') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BankTransactionHistoryScreen(
                  accountName: bank.name ?? '',
                  accountNumber: '',
                  bankId: bank.id ?? 0,
                  currentBalance: bank.balance ?? 0,
                  bank: bank,
                ),
              ),
            );
          } else if (value == 'delete') {
            if (!permissionService.hasPermission('bank_delete_permit')) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_lang.permissionDeniedToDeleteBank)));
              return;
            }
            _showDeleteConfirmationDialog(bank.id!, bank.name ?? _lang.bankAccounts);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
              value: 'view',
              child: Row(
                spacing: 8,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedView,
                    color: kPeraColor,
                    size: 20,
                  ),
                  Text(
                    _lang.view,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      color: kPeraColor,
                    ),
                  ),
                ],
              )),
          PopupMenuItem(
              value: 'transactions',
              child: Row(
                spacing: 8,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedMoneyExchange02,
                    color: kPeraColor,
                    size: 20,
                  ),
                  Text(
                    _lang.transactions,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      color: kPeraColor,
                    ),
                  ),
                ],
              )),
          PopupMenuItem(
              value: 'edit',
              child: Row(
                spacing: 8,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    color: kPeraColor,
                    size: 20,
                  ),
                  Text(
                    _lang.edit,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      color: kPeraColor,
                    ),
                  ),
                ],
              )),
          PopupMenuItem(
              value: 'delete',
              child: Row(
                spacing: 8,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete03,
                    color: kPeraColor,
                    size: 20,
                  ),
                  Text(
                    _lang.delete,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      color: kPeraColor,
                    ),
                  ),
                ],
              )),
        ],
        icon: const Icon(
          Icons.more_vert,
          color: kPeraColor,
        ),
      ),
    );
  }
}
