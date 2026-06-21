// File: add_new_shift.dart (Shift Name Changed back to Dropdown)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/shift/Model/shift_list_model.dart';
import 'package:mobile_pos/Screens/hrm/shift/repo/shift_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:icons_plus/icons_plus.dart';
import '../../../constant.dart';
import '../widgets/set_time.dart';
import 'package:intl/intl.dart';

class AddNewShift extends ConsumerStatefulWidget {
  const AddNewShift({super.key, this.isEdit = false, this.shift});

  final bool isEdit;
  final ShiftData? shift;

  @override
  ConsumerState<AddNewShift> createState() => _AddNewShiftState();
}

class _AddNewShiftState extends ConsumerState<AddNewShift> {
  final GlobalKey<FormState> _key = GlobalKey();

  // *** CHANGED: Shift Name is now managed by selectedShift String? ***
  String? selectedShift;
  // shiftNameController is now unnecessary for dropdown, but kept for cleanup clarity
  final TextEditingController shiftNameController = TextEditingController();

  String? selectedBreakStatus;
  String? _selectedStatus;

  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final startBreakTimeController = TextEditingController();
  final endBreakTimeController = TextEditingController();

  final List<String> _statusOptions = ['Active', 'Inactive'];
  final List<String> _shiftNameOptions = ['Morning', "Day", "Evening", 'Night']; // Fixed list for dropdown

  String formatTime(String time24) {
    try {
      DateTime parsedTime = DateFormat("HH:mm:ss", 'en_US').parse(time24);
      return DateFormat("h:mm a", 'en_US').format(parsedTime);
    } catch (e) {
      return time24;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.shift != null) {
      final data = widget.shift!;

      // *** FIX: Use Shift Name from data for selectedShift state ***
      selectedShift = data.name;

      selectedBreakStatus = data.breakStatus == 'yes' ? "Yes" : "No";
      _selectedStatus = data.status == 1 ? 'Active' : 'Inactive';

      startTimeController.text = formatTime(data.startTime ?? '');
      endTimeController.text = formatTime(data.endTime ?? '');
      startBreakTimeController.text = formatTime(data.startBreakTime ?? '');
      endBreakTimeController.text = formatTime(data.endBreakTime ?? '');
    } else {
      _selectedStatus = 'Active';
      selectedBreakStatus = 'No';
    }
  }

  @override
  void dispose() {
    // shiftNameController.dispose(); // No longer needed if using dropdown
    startTimeController.dispose();
    endTimeController.dispose();
    startBreakTimeController.dispose();
    endBreakTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveOrUpdateShift(BuildContext context) async {
    if (!_key.currentState!.validate()) return;

    // Check if the required state variables are set by the dropdowns
    if (selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Shift Name')),
      );
      return;
    }

    final repo = ShiftRepo();
    final int apiStatus = _selectedStatus == 'Active' ? 1 : 0;

    // Ensure times are in HH:mm format before sending (setTime uses HH:mm a,
    // but the repo needs to handle conversion to HH:mm:ss if necessary)

    if (widget.isEdit) {
      await repo.updateShift(
        ref: ref,
        context: context,
        id: widget.shift!.id!.round(),
        shiftName: selectedShift!,
        breakStatus: selectedBreakStatus!,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        breakStartTime: startBreakTimeController.text.isEmpty ? null : startBreakTimeController.text,
        breakEndTime: endBreakTimeController.text.isEmpty ? null : endBreakTimeController.text,
        status: apiStatus.toString(),
      );
    } else {
      await repo.createShift(
        ref: ref,
        context: context,
        shiftName: selectedShift!,
        breakStatus: selectedBreakStatus ?? "No",
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        breakStartTime: startBreakTimeController.text.isEmpty ? null : startBreakTimeController.text,
        breakEndTime: endBreakTimeController.text.isEmpty ? null : endBreakTimeController.text,
        status: apiStatus.toString(),
      );
    }
  }

  void _resetForm() {
    _key.currentState?.reset();
    setState(() {
      selectedShift = null; // Reset dropdown selection
      selectedBreakStatus = 'No';
      _selectedStatus = 'Active';

      // Reset time controllers
      startTimeController.clear();
      endTimeController.clear();
      startBreakTimeController.clear();
      endBreakTimeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEdit ? _lang.editShift : _lang.addNewShift,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 2, color: kBackgroundColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            children: [
              // 1. Shift Name (FIXED: Changed back to Dropdown)
              DropdownButtonFormField<String>(
                value: selectedShift,
                icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: InputDecoration(labelText: _lang.shiftName, hintText: _lang.selectOne),
                // 'Morning', "Day", "Evening", 'Night'
                // items: _shiftNameOptions
                //     .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                //     .toList(),
                items: [
                  DropdownMenuItem(value: 'Morning', child: Text(_lang.morning)),
                  DropdownMenuItem(value: 'Day', child: Text(_lang.day)),
                  DropdownMenuItem(value: 'Evening', child: Text(_lang.evening)),
                  DropdownMenuItem(value: 'Night', child: Text(_lang.night)),
                ],
                onChanged: (String? newValue) => setState(() => selectedShift = newValue),
                validator: (value) => value == null ? _lang.pleaseSelectAShift : null,
              ),
              const SizedBox(height: 20),

              // 2. Break Status Dropdown
              DropdownButtonFormField<String>(
                value: selectedBreakStatus,
                icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: InputDecoration(
                  labelText: _lang.breakStatus,
                  hintText: _lang.selectOne,
                ),
                // items: const ['Yes', 'No']
                //     .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                //     .toList(),
                items: [
                  DropdownMenuItem(value: 'Yes', child: Text(_lang.yes)),
                  DropdownMenuItem(value: 'No', child: Text(_lang.no)),
                ],
                onChanged: (String? newValue) => setState(() => selectedBreakStatus = newValue),
                validator: (value) => value == null ? _lang.pleaseSelectBreakStatus : null,
              ),
              const SizedBox(height: 20),

              // 3. Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: InputDecoration(
                  labelText: _lang.status,
                  hintText: _lang.selectOne,
                ),
                // items:
                //     _statusOptions.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                items: [
                  DropdownMenuItem(value: 'Active', child: Text(_lang.active)),
                  DropdownMenuItem(value: 'Inactive', child: Text(_lang.inactive)),
                ],
                onChanged: (String? newValue) => setState(() => _selectedStatus = newValue),
                validator: (value) => value == null ? _lang.pleaseSelectAStatus : null,
              ),
              const SizedBox(height: 20),

              // 4. Start Time & End Time
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onTap: () => setTime(startTimeController, context),
                      readOnly: true,
                      controller: startTimeController,
                      validator: (value) => value.isNullOrEmpty() ? _lang.startTimeIsRequired : null,
                      decoration: InputDecoration(
                        labelText: _lang.startTime,
                        hintText: _lang.enterStartTime,
                        suffixIcon: Icon(
                          AntDesign.clock_circle_outline,
                          size: 18,
                          color: kNeutral800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: endTimeController,
                      onTap: () => setTime(endTimeController, context),
                      validator: (value) => value.isNullOrEmpty() ? _lang.endTimeIsRequired : null,
                      decoration: InputDecoration(
                        labelText: _lang.endTime,
                        hintText: _lang.enterEndTime,
                        suffixIcon: Icon(
                          AntDesign.clock_circle_outline,
                          size: 18,
                          color: kNeutral800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Break Time (Conditional)
              if (selectedBreakStatus == 'Yes')
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onTap: () => setTime(startBreakTimeController, context),
                        readOnly: true,
                        controller: startBreakTimeController,
                        decoration: InputDecoration(
                          labelText: _lang.startBreakTime,
                          hintText: _lang.enterBreakTime,
                          suffixIcon: Icon(
                            AntDesign.clock_circle_outline,
                            size: 18,
                            color: kNeutral800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: endBreakTimeController,
                        onTap: () => setTime(endBreakTimeController, context),
                        decoration: InputDecoration(
                          labelText: _lang.endBreakTime,
                          hintText: _lang.enterBreakTime,
                          suffixIcon: Icon(
                            AntDesign.clock_circle_outline,
                            size: 18,
                            color: kNeutral800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // 6. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: _resetForm, child: Text(_lang.resets)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => _saveOrUpdateShift(context),
                        child: Text(widget.isEdit ? _lang.update : _lang.save)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to help with simple validation checks
extension on String? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}
