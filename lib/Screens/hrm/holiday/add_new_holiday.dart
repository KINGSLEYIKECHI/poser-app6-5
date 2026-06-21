import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../../constant.dart';

// --- Riverpod Imports (Assuming these paths are correct) ---
import 'package:mobile_pos/Screens/hrm/holiday/model/holiday_list_model.dart';
import 'package:mobile_pos/Screens/hrm/holiday/repo/holiday_repo.dart';
// -----------------------------------------------------------

// Accept optional HolidayData for editing (renamed from isEdit)
class AddNewHoliday extends ConsumerStatefulWidget {
  final HolidayData? holidayData;
  // Changed constructor to use key and remove isEdit
  const AddNewHoliday({super.key, this.holidayData});

  @override
  ConsumerState<AddNewHoliday> createState() => _AddNewHolidayState();
}

class _AddNewHolidayState extends ConsumerState<AddNewHoliday> {
  final nameController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();

  // Variables to hold parsed dates for comparison/API formatting
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  bool get isEditing => widget.holidayData != null;
  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy', 'en_US');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd', 'en_US'); // API typically needs YYYY-MM-DD

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final holiday = widget.holidayData!;
      nameController.text = holiday.name ?? '';
      descriptionController.text = holiday.description ?? '';

      try {
        if (holiday.startDate != null) {
          _selectedStartDate = DateTime.parse(holiday.startDate!);
          startDateController.text = _displayFormat.format(_selectedStartDate!);
        }
        if (holiday.endDate != null) {
          _selectedEndDate = DateTime.parse(holiday.endDate!);
          endDateController.text = _displayFormat.format(_selectedEndDate!);
        }
      } catch (e) {
        // Handle date parsing failure if API format is inconsistent
        debugPrint('Error parsing date for editing: $e');
        startDateController.text = holiday.startDate ?? '';
        endDateController.text = holiday.endDate ?? '';
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isStart) async {
    DateTime initialDate = DateTime.now();
    if (isStart) {
      initialDate = _selectedStartDate ?? initialDate;
    } else {
      initialDate = _selectedEndDate ?? _selectedStartDate ?? initialDate;
    }

    final DateTime? picked = await showDatePicker(
      initialDate: initialDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      context: context,
    );

    if (picked != null) {
      setState(() {
        controller.text = _displayFormat.format(picked);
        if (isStart) {
          _selectedStartDate = picked;
          // Auto-adjust end date if it is before the new start date
          if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
            _selectedEndDate = picked;
            endDateController.text = _displayFormat.format(picked);
          }
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_key.currentState!.validate()) {
      // Validate that dates are not null and end date is not before start date
      if (_selectedStartDate == null || _selectedEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.S.of(context).pleaseSelectValidStartAndEndDates)),
        );
        return;
      }

      if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.S.of(context).endDateCannotBeBeforeStartDate)),
        );
        return;
      }

      final repo = HolidayRepo();
      final String apiStartDate = _apiFormat.format(_selectedStartDate!);
      final String apiEndDate = _apiFormat.format(_selectedEndDate!);

      if (isEditing) {
        // --- UPDATE HOLIDAY ---
        await repo.updateHolidays(
          ref: ref,
          context: context,
          id: widget.holidayData!.id!.toInt(),
          name: nameController.text,
          startDate: apiStartDate,
          endDate: apiEndDate,
          description: descriptionController.text,
        );
      } else {
        // --- CREATE HOLIDAY ---
        await repo.createHolidays(
          ref: ref,
          context: context,
          name: nameController.text,
          startDate: apiStartDate,
          endDate: apiEndDate,
          description: descriptionController.text,
        );
      }
      // Note: The repo functions already handle Navigator.pop(context) and SnackBar
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? _lang.editHoliday : _lang.addNewHoliday,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 2,
            color: kBackgroundColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _key,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: _lang.name,
                    hintText: _lang.enterHolidayName,
                  ),
                  validator: (value) => value!.isEmpty ? _lang.pleaseEnterHolidayName : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        readOnly: true,
                        controller: startDateController,
                        decoration: InputDecoration(
                          labelText: _lang.startDate,
                          hintText: _lang.pleaseEnterDate,
                          suffixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () => _selectDate(context, startDateController, true),
                            icon: const Icon(IconlyLight.calendar, size: 22),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? _lang.pleaseSelectStartDate : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        readOnly: true,
                        controller: endDateController,
                        decoration: InputDecoration(
                          labelText: _lang.endDate,
                          hintText: _lang.pleaseEnterDate,
                          suffixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () => _selectDate(context, endDateController, false),
                            icon: const Icon(IconlyLight.calendar, size: 22),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return _lang.pleaseEnterEndDate;
                          }
                          if (_selectedStartDate != null &&
                              _selectedEndDate != null &&
                              _selectedEndDate!.isBefore(_selectedStartDate!)) {
                            return _lang.endDateBeforeStartDate;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: _lang.description,
                    hintText: '${_lang.enterDescription}...',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Reset functionality
                          setState(() {
                            _key.currentState?.reset();
                            nameController.clear();
                            descriptionController.clear();
                            startDateController.clear();
                            endDateController.clear();
                            _selectedStartDate = null;
                            _selectedEndDate = null;
                          });
                        },
                        child: Text(_lang.resets),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit, // Call the submission function
                        child: Text(
                          isEditing ? _lang.update : _lang.save,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
