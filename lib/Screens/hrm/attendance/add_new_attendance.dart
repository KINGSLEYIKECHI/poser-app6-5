// File: add_new_attendance.dart (Modified)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/hrm/attendance/repo/attendence_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
// --- Local Imports ---
import '../../../constant.dart';
import '../employee/model/employee_list_model.dart' as employee;
import '../widgets/set_time.dart'; // setTime function import

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart';
// *** CORRECT SHIFT IMPORTS ***
import 'package:mobile_pos/Screens/hrm/shift/Model/shift_list_model.dart' as shift;

import 'model/attendence_list_model.dart';

class AddNewAttendance extends ConsumerStatefulWidget {
  final AttendanceData? attendanceData;

  const AddNewAttendance({super.key, this.attendanceData});

  @override
  ConsumerState<AddNewAttendance> createState() => _AddNewAttendanceState();
}

class _AddNewAttendanceState extends ConsumerState<AddNewAttendance> {
  // --- Form Controllers ---
  final GlobalKey<FormState> _key = GlobalKey();
  final dateController = TextEditingController();
  final shiftController = TextEditingController();
  final timeInController = TextEditingController();
  final timeOutController = TextEditingController();
  final noteController = TextEditingController();

  // --- Selected Values (API payload) ---
  employee.EmployeeData? _selectedEmployee;
  DateTime? _selectedDate;
  String? _selectedMonth;

  // --- UI/API Helpers ---
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy', 'en_US');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd', 'en_US');
  final DateFormat _apiTimeFormat = DateFormat('HH:mm', 'en_US');
  final DateFormat _monthFormat = DateFormat('MMMM', 'en_US');

  bool get isEditing => widget.attendanceData != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final data = widget.attendanceData!;
      noteController.text = data.note ?? '';

      try {
        if (data.date != null) {
          _selectedDate = DateTime.parse(data.date!);
          dateController.text = _displayDateFormat.format(_selectedDate!);
          _selectedMonth = data.month;
        }
        timeInController.text = data.timeIn ?? '';
        timeOutController.text = data.timeOut ?? '';
      } catch (e) {
        debugPrint('Error parsing dates/times for editing: $e');
      }
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    timeOutController.dispose();
    timeInController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      context: context,
    );
    setState(() {
      if (picked != null) {
        _selectedDate = picked;
        dateController.text = _displayDateFormat.format(picked);
        _selectedMonth = _monthFormat.format(picked).toLowerCase();
      }
    });
  }

  String? _convertDisplayTimeToAPI(String displayTime) {
    try {
      final dateTime = DateFormat('hh:mm a', 'en_US').parse(displayTime);
      return _apiTimeFormat.format(
        dateTime,
      );
    } catch (e) {
      debugPrint('Time conversion error: $e');
      return null;
    }
  }

  void _submit() async {
    print('------entry this-------');
    if (_key.currentState!.validate() && _selectedEmployee != null) {
      final repo = AttendanceRepo();

      final apiTimeIn = _convertDisplayTimeToAPI(timeInController.text);
      final apiTimeOut = _convertDisplayTimeToAPI(timeOutController.text);

      if (apiTimeIn == null || apiTimeOut == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error converting time format.')),
        );
        return;
      }

      final payload = {
        'employee_id': _selectedEmployee!.id!,
        'shift_id': _selectedEmployee!.shiftId!,
        'time_in': (apiTimeIn),
        'time_out': apiTimeOut,
        'date': _apiDateFormat.format(
          _selectedDate!,
        ),
        // 'month': _selectedMonth!,
        'note': noteController.text,
      };
      if (isEditing) {
        await repo.updateAttendance(
          ref: ref,
          context: context,
          id: widget.attendanceData!.id!,
          employeeId: payload['employee_id'] as num,
          shiftId: payload['shift_id'] as num,
          timeIn: payload['time_in'] as String,
          timeOut: payload['time_out'] as String,
          date: payload['date'] as String,
          // month: payload['month'] as String,
          note: payload['note'] as String?,
        );
      } else {
        await repo.createAttendance(
          ref: ref,
          context: context,
          employeeId: payload['employee_id'] as num,
          shiftId: payload['shift_id'] as num,
          timeIn: payload['time_in'] as String,
          timeOut: payload['time_out'] as String,
          date: payload['date'] as String,
          // month: payload['month'] as String,
          note: payload['note'] as String?,
        );
      }
    }
  }

  void _resetForm() {
    if (!isEditing) {
      setState(() {
        _key.currentState?.reset();
        dateController.clear();
        shiftController.clear();
        timeInController.clear();
        timeOutController.clear();
        noteController.clear();
        _selectedEmployee = null;
        _selectedMonth = null;
        _selectedDate = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch required providers
    final _lang = lang.S.of(context);
    final employeesAsync = ref.watch(employeeListProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEditing ? _lang.editAttendance : _lang.addNewAttendance),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 2, color: kBackgroundColor),
        ),
      ),
      body: employeesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error loading employees: $err')),
          data: (employeeModel) {
            final employees = employeeModel.employees ?? [];

            if (isEditing) {
              final data = widget.attendanceData!;

              _selectedEmployee ??= employees.firstWhere(
                (e) => e.id == data.employeeId,
                orElse: () => _selectedEmployee ?? employees.first,
              );
              shiftController.text = _selectedEmployee?.shift?.name ?? '';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    _buildEmployeeDropdown(employees),
                    const SizedBox(height: 20),
                    _buildShiftDropdown(), // Pass actual shift data
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildMonthDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDateInput()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildTimeInput(true, context)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTimeInput(false, context)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(labelText: _lang.note, hintText: _lang.enterNote),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: OutlinedButton(
                                onPressed: _resetForm, child: Text(isEditing ? _lang.cancel : _lang.resets))),
                        const SizedBox(width: 16),
                        Expanded(
                            child:
                                ElevatedButton(onPressed: _submit, child: Text(isEditing ? _lang.update : _lang.save))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  // --- Widget Builders ---

  Widget _buildEmployeeDropdown(List<employee.EmployeeData> employees) {
    final _lang = lang.S.of(context);
    return DropdownButtonFormField<employee.EmployeeData>(
      value: _selectedEmployee,
      icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
      decoration: InputDecoration(labelText: _lang.employee, hintText: _lang.selectOne),
      validator: (value) => value == null ? _lang.pleaseSelectAnEmployee : null,
      items: employees.map((entry) {
        return DropdownMenuItem<employee.EmployeeData>(
          value: entry,
          child: Text(entry.name ?? 'N/A'),
        );
      }).toList(),
      onChanged: (employee.EmployeeData? value) {
        setState(() {
          _selectedEmployee = value;
          shiftController.text = _selectedEmployee?.shift?.name ?? '';
        });
      },
    );
  }

  // *** SHIFT DROPDOWN USING ShiftData ***
  Widget _buildShiftDropdown() {
    return TextFormField(
      controller: shiftController,
      readOnly: true,
      decoration:
          InputDecoration(labelText: lang.S.of(context).shift, hintText: lang.S.of(context).selectEmployeeFirst),
    );
  }

  Widget _buildMonthDropdown() {
    final monthDisplay = _selectedMonth != null
        ? _selectedMonth![0].toUpperCase() + _selectedMonth!.substring(1)
        : lang.S.of(context).selectDateFirst;

    return TextFormField(
      // initialValue: monthDisplay,
      controller: TextEditingController(text: monthDisplay),
      readOnly: true,
      // icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
      decoration: InputDecoration(labelText: lang.S.of(context).month, hintText: lang.S.of(context).autoSelected),
      validator: (value) => _selectedDate == null ? lang.S.of(context).pleaseSelectDate : null,
      // items: [
      //   DropdownMenuItem(value: monthDisplay, child: Text(monthDisplay)),
      // ],
      onChanged: null,
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      keyboardType: TextInputType.name,
      readOnly: true,
      controller: dateController,
      decoration: InputDecoration(
        labelText: lang.S.of(context).date,
        hintText: 'DD/MM/YYYY',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onPressed: () => _selectDate(context),
          icon: const Icon(IconlyLight.calendar, size: 22),
        ),
      ),
      validator: (value) => value!.isEmpty ? lang.S.of(context).pleaseSelectDate : null,
    );
  }

  Widget _buildTimeInput(bool isTimeIn, BuildContext context) {
    final controller = isTimeIn ? timeInController : timeOutController;
    final label = isTimeIn ? lang.S.of(context).timeIn : lang.S.of(context).timeOut;

    return TextFormField(
      onTap: () => setTime(controller, context),
      readOnly: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: isTimeIn ? '09:00 AM' : '05:00 PM',
        suffixIcon: Icon(
          AntDesign.clock_circle_outline,
          size: 18,
          color: kNeutral800,
        ),
      ),
      validator: (value) => value!.isEmpty ? '${lang.S.of(context).selectDate} $label' : null,
    );
  }
}
