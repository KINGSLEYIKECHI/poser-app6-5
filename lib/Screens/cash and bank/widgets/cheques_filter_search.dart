// File: widgets/cheques_filter_search.dart (Update this file content)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/constant.dart';

class CashFilterState {
  final String searchQuery;
  final DateTime? fromDate;
  final DateTime? toDate;

  CashFilterState({
    required this.searchQuery,
    this.fromDate,
    this.toDate,
  });
}

class ChequesFilterSearch extends ConsumerStatefulWidget {
  final Function(dynamic) onFilterChanged; // Use dynamic if model name differs
  final DateFormat displayFormat;
  final List<String> timeOptions;

  const ChequesFilterSearch({
    super.key,
    required this.onFilterChanged,
    required this.displayFormat,
    required this.timeOptions,
  });

  @override
  ConsumerState<ChequesFilterSearch> createState() => _ChequesFilterSearchState();
}

class _ChequesFilterSearchState extends ConsumerState<ChequesFilterSearch> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedTimeFilter;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // default filter
    _selectedTimeFilter = widget.timeOptions.contains('Today') ? 'Today' : widget.timeOptions.first;
    _updateDateRange(_selectedTimeFilter!, notify: false);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onFilterChanged(
      CashFilterState(
        searchQuery: _searchQuery,
        fromDate: _fromDate,
        toDate: _toDate,
      ),
    );
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _notifyParent();
  }

  void _updateDateRange(String range, {bool notify = true}) {
    final now = DateTime.now();
    DateTime newFromDate;

    setState(() {
      _selectedTimeFilter = range;

      if (range == 'Custom Date') {
        _fromDate = null;
        _toDate = null;
        if (notify) _notifyParent();
        return;
      }

      final today = DateTime(now.year, now.month, now.day);
      _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      switch (range) {
        case 'Today':
          newFromDate = today;
          break;
        case 'Yesterday':
          newFromDate = today.subtract(const Duration(days: 1));
          _toDate = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
          break;
        case 'Last 7 Days':
          newFromDate = today.subtract(const Duration(days: 6));
          break;
        case 'Last 30 Days':
          newFromDate = today.subtract(const Duration(days: 29));
          break;
        case 'Current Month':
          newFromDate = DateTime(now.year, now.month, 1);
          break;
        case 'Last Month':
          newFromDate = DateTime(now.year, now.month - 1, 1);
          _toDate = DateTime(now.year, now.month, 0, 23, 59, 59);
          break;
        case 'Current Year':
        default:
          newFromDate = DateTime(now.year, 1, 1);
          break;
      }
      _fromDate = newFromDate;
    });
    if (notify) _notifyParent();
  }

  String? _tempSelectedFilter; // used when opening sheet

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l.S.of(context).searchTransaction,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                  color: Color(0xffFEF0F1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  )),
              child: IconButton(
                icon: Icon(
                  IconlyLight.filter,
                  color: kMainColor,
                ),
                onPressed: () => _openTimeFilterSheet(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openTimeFilterSheet(BuildContext context) {
    // initialize temp values from current parent state
    _tempSelectedFilter = _selectedTimeFilter;
    DateTime? tempFrom = _fromDate;
    DateTime? tempTo = _toDate;
    final _theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // use StatefulBuilder so we can update sheet-local state
        return StatefulBuilder(builder: (context, setModalState) {
          final showCustomDates = _tempSelectedFilter == 'Custom Date';

          Future<void> pickDateLocal(bool isFrom) async {
            final initial = isFrom ? (tempFrom ?? DateTime.now()) : (tempTo ?? tempFrom ?? DateTime.now());
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setModalState(() {
                if (isFrom) {
                  tempFrom = DateTime(picked.year, picked.month, picked.day);
                  // ensure tempTo >= tempFrom
                  if (tempTo != null && tempTo!.isBefore(tempFrom!)) {
                    tempTo = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
                  }
                } else {
                  tempTo = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
                  if (tempFrom != null && tempFrom!.isAfter(tempTo!)) {
                    tempFrom = DateTime(picked.year, picked.month, picked.day);
                  }
                }
                // if user picked any date, ensure filter is Custom Date
                _tempSelectedFilter = 'Custom Date';
              });
            }
          }

          String formatSafe(DateTime? d) => d == null ? '' : widget.displayFormat.format(d);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                    l.S.of(context).filterByDate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ]),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _tempSelectedFilter,
                      decoration: InputDecoration(
                        labelText: l.S.of(context).filterByDate,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      // items: widget.timeOptions.map((item) {
                      //   return DropdownMenuItem(
                      //     value: item,
                      //     child: Text(
                      //       item,
                      //       style: _theme.textTheme.bodyLarge,
                      //     ),
                      //   );
                      // }).toList(),
                      // List of filter options needed for the reusable widget
                      //     final List<String> _timeFilterOptions = [
                      // 'Today',
                      // 'Yesterday',
                      // 'Last 7 Days',
                      // 'Last 30 Days',
                      // 'Current Month',
                      // 'Last Month',
                      // 'Current Year',
                      // 'Custom Date'
                      // ];
                      items: [
                        DropdownMenuItem(
                          value: 'Today',
                          child: Text(l.S.of(context).today),
                        ),
                        DropdownMenuItem(
                          value: 'Yesterday',
                          child: Text(l.S.of(context).yesterday),
                        ),
                        DropdownMenuItem(
                          value: 'Last 7 Days',
                          child: Text(l.S.of(context).last7Days),
                        ),
                        DropdownMenuItem(
                          value: 'Last 30 Days',
                          child: Text(l.S.of(context).last30Days),
                        ),
                        DropdownMenuItem(
                          value: 'Current Month',
                          child: Text(l.S.of(context).currentMonth),
                        ),
                        DropdownMenuItem(
                          value: 'Last Month',
                          child: Text(l.S.of(context).lastMonth),
                        ),
                        DropdownMenuItem(
                          value: 'Current Year',
                          child: Text(l.S.of(context).currentYear),
                        ),
                        DropdownMenuItem(
                          value: 'Custom Date',
                          child: Text(l.S.of(context).customDate),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          _tempSelectedFilter = value;
                          // if selecting a pre-defined range, clear temp custom dates
                          if (_tempSelectedFilter != 'Custom Date') {
                            tempFrom = null;
                            tempTo = null;
                          } else {
                            // keep current parent's dates as starting point if available
                            tempFrom ??= _fromDate;
                            tempTo ??= _toDate;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Custom Date Fields
                    if (showCustomDates)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => pickDateLocal(true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: l.S.of(context).fromDate,
                                  suffixIcon: Icon(IconlyLight.calendar),
                                  border: OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                ),
                                child: Text(
                                  formatSafe(tempFrom),
                                  style: _theme.textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () => pickDateLocal(false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: l.S.of(context).toDate,
                                  suffixIcon: Icon(IconlyLight.calendar),
                                  border: OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                ),
                                child: Text(
                                  formatSafe(tempTo),
                                  style: _theme.textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(l.S.of(context).cancel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: kMainColor),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                if (_tempSelectedFilter == 'Custom Date') {
                                  // commit custom dates (if any)
                                  _selectedTimeFilter = 'Custom Date';
                                  _fromDate = tempFrom;
                                  _toDate = tempTo;
                                  // ensure to normalize times if needed
                                  if (_fromDate != null && _toDate == null) {
                                    _toDate = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day, 23, 59, 59);
                                  }
                                } else if (_tempSelectedFilter != null) {
                                  _updateDateRange(_tempSelectedFilter!);
                                }
                              });

                              _notifyParent();
                            },
                            child: Text(l.S.of(context).apply, style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }
}
