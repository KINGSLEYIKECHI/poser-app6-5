import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'constant.dart';

void globalReportFilterBottomSheet(
  BuildContext context, {
  String? selectedTime = 'today',
  required TextEditingController fromDateController,
  required TextEditingController toDateController,
  required String? errorMessage,
  required Function() onClearFilters,
  required Function() onApplyFilters,
  required Function() onSelectFromDate,
  required Function() onSelectToDate,
  DateTime? fromDate,
  DateTime? toDate,
  required Map<String, String> dateOptions,
  required Function(String) onSelectedTimeApplied,
}) {
  final theme = Theme.of(context);
  final _lang = l.S.of(context);

  String tempSelectedTime = selectedTime!;
  DateTime? tempFromDate = fromDate;
  DateTime? tempToDate = toDate;

  if (tempSelectedTime == 'custom_date' && (tempFromDate == null || tempToDate == null)) {
    tempToDate = DateTime.now();
    tempFromDate = tempToDate.subtract(const Duration(days: 7));
    fromDateController.text = DateFormat('yyyy-MM-dd').format(tempFromDate);
    toDateController.text = DateFormat('yyyy-MM-dd').format(tempToDate);
  }

  bool _showCustomDatePickers = tempSelectedTime == 'custom_date';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (_, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _lang.filter,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                    )
                  ],
                ),
              ),
              const Divider(color: kBorderColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: tempSelectedTime,
                      items: dateOptions.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          tempSelectedTime = value!;
                          _showCustomDatePickers = value == 'custom_date';
                          if (_showCustomDatePickers) {
                            if (tempFromDate == null || tempToDate == null) {
                              tempToDate = DateTime.now();
                              tempFromDate = tempToDate!.subtract(const Duration(days: 7));
                              fromDateController.text = DateFormat('yyyy-MM-dd').format(tempFromDate!);
                              toDateController.text = DateFormat('yyyy-MM-dd').format(tempToDate!);
                            }
                          } else {
                            fromDateController.clear();
                            toDateController.clear();
                          }
                        });
                      },
                    ),
                    if (_showCustomDatePickers) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: fromDateController,
                              enabled: false,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: _lang.fromDate,
                                suffixIcon: GestureDetector(
                                    onTap: () async {
                                      await onSelectFromDate();
                                      setState(() {});
                                    },
                                    child: Icon(Icons.calendar_month_rounded)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: toDateController,
                              enabled: false,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: _lang.toDate,
                                suffixIcon: GestureDetector(
                                  onTap: () async {
                                    await onSelectToDate();
                                    setState(() {});
                                  },
                                  child: Icon(Icons.calendar_month_rounded),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onClearFilters,
                            child: Text(_lang.clear),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // update parent selectedTime only when Apply is clicked
                              onSelectedTimeApplied(tempSelectedTime);
                              onApplyFilters(); // refresh data
                            },
                            child: Text(_lang.apply),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
