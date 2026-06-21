import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/cheques/repo/cheque_repository.dart';

// --- Local Imports ---
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/currency.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../widgets/cheques_filter_search.dart';
import 'cheques_deposit_screen.dart';
import 'model/cheques_list_model.dart';

class ChequesListScreen extends ConsumerStatefulWidget {
  const ChequesListScreen({super.key});

  @override
  ConsumerState<ChequesListScreen> createState() => _ChequesListScreenState();
}

class _ChequesListScreenState extends ConsumerState<ChequesListScreen> {
  String _currentSearchQuery = '';
  DateTime? _currentFromDate;
  DateTime? _currentToDate;

  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentFromDate = DateTime(now.year, 1, 1);
    _currentToDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  void _navigateToDepositScreen(ChequeTransactionData cheque) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferChequeDepositScreen(cheque: cheque),
      ),
    );
  }

  //------------ Re Open dialog -----------------------------------
  void _showOpenDialog(ChequeTransactionData cheque) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final _theme = Theme.of(context);
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close),
                    ),
                  ),
                  Center(
                    child: Text(
                      l.S.of(context).doYouWantToRellyReOpenThisCheque,
                      textAlign: TextAlign.center,
                      style: _theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                          ),
                          child: Text(l.S.of(context).cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // --- IMPLEMENTATION HERE ---
                            if (cheque.id != null) {
                              final repo = ChequeRepository();
                              await repo.reOpenCheque(
                                ref: ref,
                                context: context,
                                chequeTransactionId: cheque.id!,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                            backgroundColor: const Color(0xFFB71C1C),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l.S.of(context).okay),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  // --- LOCAL FILTERING FUNCTION ---
  List<ChequeTransactionData> _filterTransactionsLocally(List<ChequeTransactionData> transactions) {
    Iterable<ChequeTransactionData> dateFiltered = transactions.where((t) {
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

    final query = _currentSearchQuery.toLowerCase();
    if (query.isEmpty) {
      return dateFiltered.toList();
    }

    return dateFiltered.where((c) {
      return (c.user?.name ?? '').toLowerCase().contains(query) ||
          (c.meta?.chequeNumber ?? '').contains(query) ||
          (c.amount?.toString() ?? '').contains(query) ||
          (c.invoiceNo ?? '').toLowerCase().contains(query);
    }).toList();
  }

  // --- Filter Callback Handler ---
  void _handleFilterChange(CashFilterState filterState) {
    setState(() {
      _currentSearchQuery = filterState.searchQuery;
      _currentFromDate = filterState.fromDate;
      _currentToDate = filterState.toDate;
    });
  }

  Widget _buildChequeListTile(ThemeData theme, ChequeTransactionData cheque) {
    final status = cheque.type ?? 'N/A';
    final isDepositable = status == 'pending';
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            cheque.user?.name ?? 'n/a',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: () {
              isDepositable ? _navigateToDepositScreen(cheque) : _showOpenDialog(cheque);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity(vertical: -4),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                  horizontal: 12,
                ),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(4),
                ),
              ),
              foregroundColor: WidgetStatePropertyAll(
                isDepositable
                    ? DAppColors.kWarning.withValues(
                        alpha: 0.5,
                      )
                    : kSuccessColor.withValues(
                        alpha: 0.5,
                      ),
              ),
              backgroundColor: WidgetStatePropertyAll(isDepositable
                  ? kSuccessColor.withValues(
                      alpha: 0.1,
                    )
                  : DAppColors.kWarning.withValues(
                      alpha: 0.1,
                    )),
            ),
            child: Text(
              isDepositable ? l.S.of(context).deposit : l.S.of(context).reOpen,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDepositable ? kSuccessColor : DAppColors.kWarning,
              ),
            ),
          )
        ],
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM, yyyy').format(
                  DateTime.parse(cheque.date ?? 'n/a'),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kGrey6,
                ),
              ),
              Text(
                '$currency${cheque.amount?.toStringAsFixed(2) ?? '0.00'}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: '${l.S.of(context).type}: ',
                  style: TextStyle(color: kGreyTextColor),
                  children: [
                    TextSpan(
                      text: cheque.platform.capitalizeFirstLetter(),
                      style: TextStyle(
                        color: kTitleColor,
                      ),
                    ),
                  ],
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kTitleColor,
                ),
              ),
              Text(
                isDepositable
                    ? l.S.of(context).open
                    : 'Deposit to ${cheque.paymentType == null ? l.S.of(context).cash : cheque.paymentType?.name ?? 'n/a'}',
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final theme = Theme.of(context);
    final chequesAsync = ref.watch(chequeListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_lang.chequeList),
          centerTitle: true,
          toolbarHeight: 100,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Column(
              children: [
                Divider(
                  color: kLineColor,
                  height: 1,
                ),
                TabBar(
                  dividerColor: kLineColor,
                  dividerHeight: 0.1,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: theme.textTheme.titleMedium?.copyWith(
                    color: kMainColor,
                  ),
                  unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
                    color: kGreyTextColor,
                  ),
                  tabs: [
                    Tab(
                      text: _lang.all,
                    ),
                    Tab(
                      text: _lang.open,
                    ),
                    Tab(
                      text: _lang.closed,
                    ),
                  ],
                ),
                Divider(
                  color: kLineColor,
                  height: 1,
                )
              ],
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(chequeListProvider.future),
                child: chequesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error loading cheques: ${err.toString()}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (model) {
                    final allCheques = model.data ?? [];
                    final filteredCheques = _filterTransactionsLocally(allCheques);

                    return TabBarView(
                      children: [
                        _buildChequeList(theme, filteredCheques),
                        _buildChequeList(
                          theme,
                          filteredCheques.where((c) => (c.type ?? '').toLowerCase() == 'pending').toList(),
                        ),
                        _buildChequeList(
                          theme,
                          filteredCheques.where((c) => (c.type ?? '').toLowerCase() == 'deposit').toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChequeList(ThemeData theme, List<ChequeTransactionData> cheques) {
    if (cheques.isEmpty) {
      return Center(child: Text(l.S.of(context).noChequeFound));
    }

    return ListView.separated(
      itemCount: cheques.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: kBackgroundColor),
      itemBuilder: (_, index) {
        final cheque = cheques[index];
        return _buildChequeListTile(theme, cheque);
      },
    );
  }
}
