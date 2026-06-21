import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/cansh%20in%20hand/provider/cash_in_hand_provider.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/cansh%20in%20hand/repo/cash_in_hand_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../widgets/cheques_filter_search.dart';
import 'adjust_cash_screen.dart';
import 'cash_to_bank_transfer_screen.dart';
import 'model/cash_transaction_list_model.dart';

class CashInHandScreen extends ConsumerStatefulWidget {
  const CashInHandScreen({super.key});

  @override
  ConsumerState<CashInHandScreen> createState() => _CashInHandScreenState();
}

class _CashInHandScreenState extends ConsumerState<CashInHandScreen> {
  String _currentSearchQuery = '';
  DateTime? _currentFromDate;
  DateTime? _currentToDate;

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  // List of filter options needed for the reusable widget
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

  final Map<String, String> timeFilterBn = {
    'Today': l.S.current.today,
    'Yesterday': l.S.current.yesterday,
    'Last 7 Days': l.S.current.last7Days,
    'Last 30 Days': l.S.current.last30Days,
    'Current Month': l.S.current.currentMonth,
    'Last Month': l.S.current.lastMonth,
    'Current Year': l.S.current.currentYear,
    'Custom Date': l.S.current.customDate,
  };

  @override
  void initState() {
    super.initState();

    // Initialize default date range for local filtering (e.g., Current Year)
    final now = DateTime.now();
    _currentFromDate = DateTime(now.year, 1, 1);
    _currentToDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
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

  // --- DELETE Logic (Unchanged) ---
  Future<void> _confirmAndDeleteTransaction(CashTransactionData transaction) async {
    final transactionId = transaction.id;
    if (transactionId == null) return;

    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      itemName: 'cash transaction',
    );

    if (confirmed == true) {
      final repo = CashTransactionRepo();
      await repo.deleteCashTransaction(
        ref: ref,
        context: context,
        transactionId: transactionId,
      );
    }
  }

  // --- Logic Helpers (Unchanged) ---

  String _getListName(CashTransactionData t) {
    final nameFromUser = t.user?.name ?? 'System';

    if (t.transactionType == 'cash_to_bank') {
      return 'To: Bank (ID: ${t.toBank})';
    } else if (t.transactionType == 'bank_to_cash') {
      return 'From: Bank (ID: ${t.fromBank})';
    } else if (t.transactionType == 'adjust_cash') {
      return t.type == 'credit' ? 'Adjustment (Credit)' : 'Adjustment (Debit)';
    }
    return nameFromUser;
  }

  Map<String, dynamic> _getAmountDetails(CashTransactionData t) {
    bool isOutgoing = false;

    if (t.transactionType == 'adjust_cash') {
      isOutgoing = t.type == 'debit';
    } else if (t.transactionType == 'cash_to_bank') {
      isOutgoing = true;
    } else if (t.transactionType == 'bank_to_cash') {
      isOutgoing = false;
    }

    final color = isOutgoing ? Colors.red.shade700 : Colors.green.shade700;
    final sign = isOutgoing ? '-' : '+';

    return {'sign': sign, 'color': color};
  }

  // --- Filter Callback Handler ---
  // 🔔 FIX: Callback now uses the defined CashFilterState type
  void _handleFilterChange(CashFilterState filterState) {
    setState(() {
      _currentSearchQuery = filterState.searchQuery;
      _currentFromDate = filterState.fromDate;
      _currentToDate = filterState.toDate;
    });
  }

  // --- LOCAL FILTERING FUNCTION (Unchanged) ---
  List<CashTransactionData> _filterTransactionsLocally(List<CashTransactionData> transactions) {
    // 1. Filter by Date Range
    Iterable<CashTransactionData> dateFiltered = transactions.where((t) {
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

    return dateFiltered.where((c) {
      return (c.transactionType ?? '').toLowerCase().contains(query) ||
          (c.user?.name ?? '').toLowerCase().contains(query) ||
          (c.amount?.toString() ?? '').contains(query) ||
          (c.invoiceNo ?? '').toLowerCase().contains(query);
    }).toList();
  }
  // --- END LOCAL FILTERING FUNCTION ---

  // --- Navigation Helpers for App Bar Menu (Unchanged) ---
  void _navigateToTransfer() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CashToBankTransferScreen()));
  }

  void _navigateToAdjust() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdjustCashBalanceScreen()));
  }

  // --- UI Builders (Only _buildBalanceCard and _buildActionMenu shown for brevity) ---

  Widget _buildBalanceCard(ThemeData theme, num balance) {
    return Container(
      width: double.infinity,
      color: kMainColor.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.S.of(context).cashInHand,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),

          // Balance Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currency${balance.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(l.S.of(context).currentCashBalance,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(CashTransactionData transaction, BuildContext context) {
    final _lang = l.S.of(context);
    // ... (Implementation unchanged) ...
    Map<String, String> _compileDetails() {
      final details = <String, String>{};
      details[_lang.transactionType] = (transaction.transactionType ?? 'N/A').replaceAll('_', ' ').toUpperCase();
      details[_lang.date] = _formatDate(transaction.date);
      details[_lang.amount] = '$currency${transaction.amount?.toStringAsFixed(2) ?? '0.00'}';
      details[_lang.user] = transaction.user?.name ?? 'System';
      details[_lang.invoiceNumber] = transaction.invoiceNo ?? 'N/A';
      details[_lang.note] = transaction.note ?? 'No Note';

      if (transaction.transactionType == 'cash_to_bank') {
        details[_lang.toAccount] = 'Bank ID ${transaction.toBank}';
      } else if (transaction.transactionType == 'bank_to_cash') {
        details[_lang.fromAccount] = 'Bank ID ${transaction.fromBank}';
      }

      return details;
    }

    return SizedBox(
      width: 30,
      child: PopupMenuButton<String>(
        onSelected: (value) {
          if (transaction.id == null) return;

          if (value == 'view') {
            viewModalSheet(
              context: context,
              item: _compileDetails(),
              descriptionTitle: '${_lang.description}:',
              description: transaction.note ?? 'N/A',
            );
          } else if (value == 'edit') {
            if (transaction.transactionType != 'adjust_cash') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CashToBankTransferScreen(
                      transaction: transaction,
                    ),
                  ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdjustCashBalanceScreen(
                      transaction: transaction,
                    ),
                  ));
            }
          } else if (value == 'delete') {
            _confirmAndDeleteTransaction(transaction);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'view', child: Text(l.S.of(context).view)),
          if ((transaction.transactionType == 'cash_to_bank') || (transaction.transactionType == 'adjust_cash'))
            PopupMenuItem(value: 'edit', child: Text(l.S.of(context).edit)),
          PopupMenuItem(value: 'delete', child: Text(l.S.of(context).delete, style: TextStyle(color: Colors.red))),
        ],
        icon: const Icon(Icons.more_vert, color: kNeutral800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final theme = Theme.of(context);
    final historyAsync = ref.watch(cashTransactionHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_lang.cashInHand),
        centerTitle: true,
        toolbarHeight: 80,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            children: [
              ChequesFilterSearch(
                displayFormat: _displayFormat,
                timeOptions: _timeFilterOptions,
                onFilterChanged: (filterState) {
                  // Cast the dynamic output to the expected CashFilterState
                  _handleFilterChange(filterState as CashFilterState);
                },
              ),
              Divider(thickness: 1, color: kLineColor),
            ],
          ),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
        data: (model) {
          final allTransactions = model.data ?? [];

          // Apply local date and search filtering
          final filteredTransactions = _filterTransactionsLocally(allTransactions);

          return RefreshIndicator(
            onRefresh: () => ref.refresh(cashTransactionHistoryProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Balance and Account Info Card
                  // _buildBalanceCard(theme, model.totalBalance ?? 0),

                  // 2. Filters and Search (Using Reusable Widget)
                  // 🔔 FIX: Using ChequesFilterSearch from external file

                  // 3. Transaction List
                  if (filteredTransactions.isEmpty)
                    Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text(
                              _lang.noTransactionFoundForThisFilter,
                              textAlign: TextAlign.center,
                            )))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, __) => const Divider(color: kBackgroundColor),
                      itemBuilder: (_, index) {
                        final transaction = filteredTransactions[index];
                        final amountDetails = _getAmountDetails(transaction);
                        return ListTile(
                          visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
                          trailing: _buildActionMenu(transaction, context),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToTransfer(),
                child: Text(_lang.transfer),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMainColor,
                ),
                onPressed: () => _navigateToAdjust(),
                child: Text(_lang.adjustCash, style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
