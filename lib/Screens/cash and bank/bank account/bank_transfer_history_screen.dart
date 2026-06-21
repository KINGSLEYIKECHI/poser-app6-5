// File: bank_transaction_history_screen.dart (Final Fixed Code)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- Local Imports ---
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20account/provider/bank_account_provider.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20account/provider/bank_transfers_history_provider.dart';
import '../../../widgets/deleteing_alart_dialog.dart';
import '../adjust%20bank%20balance/adjust_bank_balance_screen.dart';
import '../bank%20to%20cash%20transfer/bank_to_cash_transfer.dart';
import '../bank%20to%20bank%20transfer/bank_to_bank_transfer_screen.dart';
import '../bank%20to%20bank%20transfer/repo/bank_to_bank_transfar_repo.dart';
import '../widgets/cheques_filter_search.dart'; // Reusable Filter Widget
import 'model/bank_account_list_model.dart';
import 'model/bank_transfer_history_model.dart';

// 🔔 Filter State Model (Must match the data returned by ChequesFilterSearch)
class BankFilterState {
  final String searchQuery;
  final DateTime? fromDate;
  final DateTime? toDate;

  BankFilterState({
    required this.searchQuery,
    this.fromDate,
    this.toDate,
  });
}

class BankTransactionHistoryScreen extends ConsumerStatefulWidget {
  final num bankId;
  final String accountName;
  final String accountNumber;
  final num currentBalance;
  final BankData bank;

  const BankTransactionHistoryScreen({
    super.key,
    required this.bankId,
    required this.accountName,
    required this.accountNumber,
    required this.currentBalance,
    required this.bank,
  });

  @override
  ConsumerState<BankTransactionHistoryScreen> createState() => _BankTransactionHistoryScreenState();
}

class _BankTransactionHistoryScreenState extends ConsumerState<BankTransactionHistoryScreen> {
  // Local states to hold filter values from the child widget
  String _currentSearchQuery = '';
  DateTime? _currentFromDate;
  DateTime? _currentToDate;

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  final List<String> _timeFilterOptions = [
    'Today',
    'Yesterday',
    'Last 7 Days',
    'Last 30 Days',
    'Current Month',
    'Last Month',
    'Current Year',
    'Custom Date'
  ];

  // FIX: Helper to initialize filter dates
  void _updateInitialDateRange() {
    final now = DateTime.now();
    // Default to Current Year
    _currentFromDate = DateTime(now.year, 1, 1);
    // End of today for inclusive filtering
    _currentToDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @override
  void initState() {
    super.initState();
    // 🔔 FIX: Initialize filter date range right away
    _updateInitialDateRange();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  // --- DELETE Logic ---

  Future<void> _confirmAndDeleteTransaction(TransactionData transaction) async {
    final transactionId = transaction.id;
    if (transactionId == null) return;

    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      itemName: 'transaction',
    );

    if (confirmed == true) {
      final repo = BankTransactionRepo();
      await repo.deleteBankTransaction(
        ref: ref,
        context: context,
        transactionId: transactionId,
      );
    }
  }

  // --- Filter Callback Handler ---
  void _handleFilterChange(BankFilterState filterState) {
    setState(() {
      _currentSearchQuery = filterState.searchQuery;
      _currentFromDate = filterState.fromDate;
      _currentToDate = filterState.toDate;
    });
  }

  // --- LOCAL FILTERING FUNCTION (with robust date checks) ---
  List<TransactionData> _filterTransactionsLocally(List<TransactionData> transactions) {
    // 1. Filter by Date Range
    Iterable<TransactionData> dateFiltered = transactions.where((t) {
      if (_currentFromDate == null && _currentToDate == null) return true;
      if (t.date == null) return false;

      try {
        final transactionDate = DateTime.parse(t.date!);

        final start = _currentFromDate;
        final end = _currentToDate;

        bool afterStart = start == null || transactionDate.isAfter(start) || transactionDate.isAtSameMomentAs(start);
        bool beforeEnd = end == null || transactionDate.isBefore(end) || transactionDate.isAtSameMomentAs(end);

        return afterStart && beforeEnd;
      } catch (e) {
        return false;
      }
    });

    // 2. Filter by Search Query
    final query = _currentSearchQuery.toLowerCase();
    if (query.isEmpty) {
      return dateFiltered.toList();
    }

    return dateFiltered.where((t) {
      return (t.transactionType ?? '').toLowerCase().contains(query) ||
          (t.user?.name ?? '').toLowerCase().contains(query) ||
          (t.amount?.toString() ?? '').contains(query) ||
          (t.invoiceNo ?? '').toLowerCase().contains(query);
    }).toList();
  }
  // --- END LOCAL FILTERING FUNCTION ---

  // --- Core Logic Helpers (Unchanged) ---

  String _getBankNameById(num? id, List<BankData> banks) {
    if (id == null) return 'Cash/System';
    final bank = banks.firstWhere((b) => b.id == id, orElse: () => BankData(name: 'Bank ID $id', id: id));
    return bank.name ?? 'Bank ID $id';
  }

  String _getListName(TransactionData t, List<BankData> banks) {
    final nameFromUser = t.user?.name ?? 'System';

    if (t.transactionType == 'bank_to_bank') {
      if (t.fromBankId != widget.bankId) {
        return 'From: ${_getBankNameById(t.fromBankId, banks)}';
      } else if (t.toBankId != widget.bankId) {
        return 'To: ${_getBankNameById(t.toBankId, banks)}';
      }
      return 'Internal Transfer';
    } else if (t.transactionType == 'bank_to_cash') {
      return 'To: Cash';
    } else if (t.transactionType == 'adjust_bank') {
      return t.type == 'credit' ? 'Adjustment (Credit)' : 'Adjustment (Debit)';
    }
    return nameFromUser;
  }

  Map<String, dynamic> _getAmountDetails(TransactionData t) {
    bool isOutgoing = false;

    if (t.transactionType == 'adjust_bank') {
      isOutgoing = t.type == 'debit';
    } else if (t.transactionType == 'bank_to_bank' || t.transactionType == 'bank_to_cash') {
      isOutgoing = t.fromBankId == widget.bankId;
    }

    final color = isOutgoing ? Colors.red.shade700 : Colors.green.shade700;
    final sign = isOutgoing ? '-' : '+';

    return {'sign': sign, 'color': color};
  }

  // --- UI Builders ---

  Widget _buildBalanceCard(ThemeData theme) {
    final _lang = l.S.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 77,
        width: double.infinity,
        color: kSuccessColor.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$currency${widget.currentBalance.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _lang.balance,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: kSubPeraColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(TransactionData transaction, List<BankData> allBanks) {
    // Helper to compile details for the view modal
    Map<String, String> _compileDetails() {
      final details = <String, String>{};
      details['Transaction Type'] = (transaction.transactionType ?? 'N/A').replaceAll('_', ' ').toUpperCase();
      details['Date'] = _formatDate(transaction.date);
      details['Amount'] = '$currency${transaction.amount?.toStringAsFixed(2) ?? '0.00'}';
      details['User'] = transaction.user?.name ?? 'System';
      details['Invoice No'] = transaction.invoiceNo ?? 'N/A';
      details['Note'] = transaction.note ?? 'No Note';

      if (transaction.transactionType == 'bank_to_bank') {
        details['From Account'] = _getBankNameById(transaction.fromBankId, allBanks);
        details['To Account'] = _getBankNameById(transaction.toBankId, allBanks);
      } else if (transaction.transactionType == 'bank_to_cash') {
        details['From Account'] = _getBankNameById(transaction.fromBankId, allBanks);
        details['To'] = 'Cash';
      }

      return details;
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (transaction.id == null) return;

        if (value == 'view') {
          // *** VIEW IMPLEMENTATION ***
          viewModalSheet(
            context: context,
            item: _compileDetails(),
            descriptionTitle: '${l.S.of(context).description}:',
            description: transaction.note ?? 'N/A',
          );
        } else if (value == 'edit') {
          // --- Determine the Destination Screen based on transaction_type ---
          Widget destinationScreen;

          switch (transaction.transactionType) {
            case 'bank_to_bank':
              destinationScreen = BankToBankTransferScreen(transaction: transaction);
              break;
            case 'bank_to_cash':
              destinationScreen = BankToCashTransferScreen(transaction: transaction);
              break;
            case 'adjust_bank':
              destinationScreen = AdjustBankBalanceScreen(
                transaction: transaction,
              );
              break;
            default:
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.S.of(context).canNotEditThisTransactionType)));
              return;
          }

          Navigator.push(context, MaterialPageRoute(builder: (context) => destinationScreen));
        } else if (value == 'delete') {
          // *** DELETE IMPLEMENTATION - Call the confirmation dialog ***
          _confirmAndDeleteTransaction(transaction);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'view', child: Text(l.S.of(context).view)),
        PopupMenuItem(value: 'edit', child: Text(l.S.of(context).edit)),
        PopupMenuItem(value: 'delete', child: Text(l.S.of(context).delete, style: TextStyle(color: Colors.red))),
      ],
      icon: const Icon(Icons.more_vert, color: kNeutral800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final bankMeta = widget.bank.meta;
    final bankName = bankMeta?.bankName ?? 'N/A ${_lang.bank}';
    final theme = Theme.of(context);
    final historyAsync = ref.watch(bankTransactionHistoryProvider(widget.bankId));
    final banksListAsync = ref.watch(bankListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          title: Text(
            widget.accountName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            bankName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: kGrey6,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(bankTransactionHistoryProvider(widget.bankId).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Balance and Account Info Card
              _buildBalanceCard(theme),
              // // 2. Filters and Search (Using Reusable Widget)
              // ChequesFilterSearch(
              //   displayFormat: _displayFormat, // Use local display format
              //   timeOptions: _timeFilterOptions,
              //   onFilterChanged: (filterState) {
              //     // Cast the dynamic output to the expected BankFilterState
              //     _handleFilterChange(filterState as BankFilterState);
              //   },
              // ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 42,
                width: double.infinity,
                color: kBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _lang.transactions,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _lang.amount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Transaction List
              banksListAsync.when(
                  loading: () =>
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                  error: (e, s) => Center(child: Text('Error loading bank data: ${e.toString()}')),
                  data: (bankModel) {
                    final allBanks = bankModel.data ?? []; // List for lookup

                    return historyAsync.when(
                      loading: () =>
                          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                      error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
                      data: (model) {
                        final allTransactions = model.data ?? [];

                        // Apply local date and search filtering
                        final filteredTransactions = _filterTransactionsLocally(allTransactions);

                        if (filteredTransactions.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                _lang.noTransactionFoundForThisFilter,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (_, __) => const Divider(color: kLineColor, height: 1),
                          itemBuilder: (_, index) {
                            final transaction = filteredTransactions[index];
                            final amountDetails = _getAmountDetails(transaction);

                            return ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (transaction.transactionType ?? 'N/A').replaceAll('_', ' ').toUpperCase(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$currency${transaction.amount?.toStringAsFixed(2) ?? '0.00'}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: amountDetails['color'],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(transaction.date),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: kGrey6,
                                    ),
                                  ),
                                  Text(
                                    transaction.platform.toString(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: kGrey6,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
