// File: add_new_leave.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/hrm/leave_request/leave/repo/leave_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
// --- Local Imports ---
import '../../../../constant.dart';
import '../../employee/model/employee_list_model.dart';
import '../../employee/provider/emplpyee_list_provider.dart';
import '../leave_type/model/leave_type_list_model.dart';
import '../leave_type/provider/leave_type_list_provider.dart';
import 'model/leave_list_model.dart';

class AddNewLeave extends ConsumerStatefulWidget {
  final LeaveRequestData? leaveRequestData;

  const AddNewLeave({super.key, this.leaveRequestData});

  @override
  ConsumerState<AddNewLeave> createState() => _AddNewLeaveState();
}

class _AddNewLeaveState extends ConsumerState<AddNewLeave> {
  bool _isActive(dynamic item) {
    if (item == null) return false;
    if (item.status is num) {
      return item.status == 1;
    }
    if (item.status is String) {
      return item.status.toLowerCase() == 'active';
    }
    // Default to true if status is missing or unknown (for safety)
    return true;
  }

  // --- Form Controllers ---
  final GlobalKey<FormState> _key = GlobalKey();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final leaveDurationController = TextEditingController();
  final noteController = TextEditingController();

  // --- Selected Values (API payload) ---
  EmployeeData? _selectedEmployee;
  LeaveTypeData? _selectedLeaveType;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedMonth;
  String _selectedStatus = 'pending';

  // --- UI/API Helpers ---
  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd', 'en_US');
  final DateFormat _monthFormat = DateFormat('MMMM');

  // UI state for Department (Auto-filled)
  final TextEditingController _currentEmployeeDepartmentName = TextEditingController(text: 'Select an employee');

  bool get isEditing => widget.leaveRequestData != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final data = widget.leaveRequestData!;
      noteController.text = data.description ?? '';
      leaveDurationController.text = data.leaveDuration?.toString() ?? '';
      _selectedStatus = data.status ?? 'pending';

      try {
        if (data.startDate != null) {
          _selectedStartDate = DateTime.parse(data.startDate!);
          startDateController.text = _displayFormat.format(_selectedStartDate!);
        }
        if (data.endDate != null) {
          _selectedEndDate = DateTime.parse(data.endDate!);
          endDateController.text = _displayFormat.format(_selectedEndDate!);
        }
        _selectedMonth = data.month;
      } catch (e) {
        debugPrint('Error parsing dates for editing: $e');
      }
      _currentEmployeeDepartmentName.text = data.department?.name ?? '';
    }
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    leaveDurationController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final controller = isStart ? startDateController : endDateController;

    DateTime initialDate =
        isStart ? _selectedStartDate ?? DateTime.now() : _selectedEndDate ?? _selectedStartDate ?? DateTime.now();

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
        } else {
          _selectedEndDate = picked;
        }

        _updateCalculatedFields();
      });
    }
  }

  void _updateCalculatedFields() {
    // 1. Month
    if (_selectedStartDate != null) {
      _selectedMonth = _monthFormat.format(_selectedStartDate!).toLowerCase();
    }

    // 2. Duration
    if (_selectedStartDate != null && _selectedEndDate != null) {
      final duration = _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;
      leaveDurationController.text = duration.toString();
    } else {
      leaveDurationController.clear();
    }
  }

  void _submit() async {
    if (_key.currentState!.validate() && _selectedEmployee != null && _selectedLeaveType != null) {
      final repo = LeaveRepo();

      final String apiStartDate = _apiFormat.format(_selectedStartDate!);
      final String apiEndDate = _apiFormat.format(_selectedEndDate!);

      final payload = {
        'employee_id': _selectedEmployee!.id!,
        'leave_type_id': _selectedLeaveType!.id!,
        'start_date': apiStartDate,
        'end_date': apiEndDate,
        'leave_duration': leaveDurationController.text,
        'month': _selectedMonth!,
        'description': noteController.text,
        'status': _selectedStatus.toLowerCase(),
      };

      if (isEditing) {
        await repo.updateLeaveRequest(
          ref: ref,
          context: context,
          id: widget.leaveRequestData!.id!,
          employeeId: payload['employee_id'] as num,
          leaveTypeId: payload['leave_type_id'] as num,
          startDate: payload['start_date'] as String,
          endDate: payload['end_date'] as String,
          leaveDuration: payload['leave_duration'],
          month: payload['month'] as String,
          description: payload['description'] as String,
          status: payload['status'] as String,
        );
      } else {
        await repo.createLeaveRequest(
          ref: ref,
          context: context,
          employeeId: payload['employee_id'] as num,
          leaveTypeId: payload['leave_type_id'] as num,
          startDate: payload['start_date'] as String,
          endDate: payload['end_date'] as String,
          leaveDuration: payload['leave_duration'],
          month: payload['month'] as String,
          description: payload['description'] as String,
          status: payload['status'] as String,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeListProvider);
    final leaveTypesAsync = ref.watch(leaveTypeListProvider);
    final _lang = lang.S.of(context);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? _lang.editLeave : _lang.addNewLeave,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 2,
            color: kBackgroundColor,
          ),
        ),
      ),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading employees: $err')),
        data: (employeeModel) => leaveTypesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error loading leave types: $err')),
          data: (leaveTypeModel) {
            final employees = employeeModel.employees ?? [];
            final leaveTypes = (leaveTypeModel.data ?? []).where(_isActive).toList();

            if (isEditing) {
              final data = widget.leaveRequestData!;

              if (_selectedEmployee == null) {
                _selectedEmployee = employees.firstWhere(
                  (e) => e.id == data.employeeId,
                  orElse: () => _selectedEmployee ?? employees.first,
                );
                _currentEmployeeDepartmentName.text = data.department?.name ?? '';
              }

              _selectedLeaveType ??= leaveTypes.firstWhere(
                (lt) => lt.id == data.leaveTypeId,
                orElse: () => _selectedLeaveType ?? leaveTypes.first,
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    _buildEmployeeDropdown(employees),
                    const SizedBox(height: 20),

                    // 2. Department Field (Auto-filled and Read-only)
                    _buildDepartmentDisplay(),
                    const SizedBox(height: 20),

                    _buildLeaveTypeDropdown(leaveTypes),
                    const SizedBox(height: 20),

                    _buildMonthDropdown(),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: _buildDateInput(true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDateInput(false)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: _buildDurationInput()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatusDropdown()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: _lang.note,
                        hintText: _lang.enterNote,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetForm,
                            child: Text(isEditing ? _lang.cancel : _lang.resets),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(isEditing ? _lang.update : _lang.save),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildEmployeeDropdown(List<EmployeeData> employees) {
    return DropdownButtonFormField<EmployeeData>(
      value: _selectedEmployee,
      icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
      decoration: InputDecoration(
        labelText: lang.S.of(context).employee,
        hintText: lang.S.of(context).selectOne,
      ),
      validator: (value) => value == null ? lang.S.of(context).pleaseSelectAnEmployee : null,
      items: employees.map((entry) {
        return DropdownMenuItem<EmployeeData>(
          value: entry,
          child: Text(entry.name ?? 'N/A'),
        );
      }).toList(),
      onChanged: (EmployeeData? value) {
        setState(() {
          _selectedEmployee = value;
          // Auto-set department for display
          _currentEmployeeDepartmentName.text = value?.department?.name ?? '';
          print('Name: ${_currentEmployeeDepartmentName.text}');
        });
      },
    );
  }

  // --- Department Display (TextFormField equivalent) ---
  Widget _buildDepartmentDisplay() {
    return TextFormField(
      readOnly: true,
      controller: _currentEmployeeDepartmentName,
      // initialValue: _selectedEmployee?.department?.name ?? 'Select an employee',
      decoration: InputDecoration(
        labelText: lang.S.of(context).department,
        hintText: lang.S.of(context).autoSelected,
      ),
    );
  }

  // --- (Other builders remain the same) ---

  Widget _buildLeaveTypeDropdown(List<LeaveTypeData> leaveTypes) {
    return DropdownButtonFormField<LeaveTypeData>(
      value: _selectedLeaveType,
      icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
      decoration: InputDecoration(
        labelText: lang.S.of(context).leaveType,
        hintText: lang.S.of(context).selectOne,
      ),
      validator: (value) => value == null ? lang.S.of(context).pleaseSelectALeaveType : null,
      items: leaveTypes.map((entry) {
        return DropdownMenuItem<LeaveTypeData>(
          value: entry,
          child: Text(entry.name ?? 'N/A'),
        );
      }).toList(),
      onChanged: (LeaveTypeData? value) {
        setState(() {
          _selectedLeaveType = value;
        });
      },
    );
  }

  Widget _buildMonthDropdown() {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _selectedMonth),
      decoration: InputDecoration(
        labelText: lang.S.of(context).month,
        hintText: lang.S.of(context).autoSelected,
      ),
      validator: (value) => value == null ? lang.S.of(context).pleaseSelectAStartDate : null,
      onChanged: null,
    );
  }

  Widget _buildDateInput(bool isStart) {
    final controller = isStart ? startDateController : endDateController;
    final label = isStart ? lang.S.of(context).startDate : lang.S.of(context).endDate;

    return TextFormField(
      keyboardType: TextInputType.name,
      readOnly: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'DD/MM/YYYY',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onPressed: () => _selectDate(isStart),
          icon: const Icon(IconlyLight.calendar, size: 22),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Please enter $label';

        if (!isStart &&
            _selectedStartDate != null &&
            _selectedEndDate != null &&
            _selectedEndDate!.isBefore(_selectedStartDate!)) {
          return lang.S.of(context).endDateCannotBeBeforeStartDate;
        }
        return null;
      },
    );
  }

  Widget _buildDurationInput() {
    return TextFormField(
      controller: leaveDurationController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: lang.S.of(context).leaveDuration,
        hintText: lang.S.of(context).autoCalculatedDays,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    final List<String> statusOptions = ['Pending', 'Approved', 'Rejected'];

    return DropdownButtonFormField<String>(
        isExpanded: true,
        value: _selectedStatus.isNotEmpty ? _selectedStatus[0].toUpperCase() + _selectedStatus.substring(1) : null,
        icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
        decoration: InputDecoration(labelText: lang.S.of(context).status, hintText: lang.S.of(context).selectOne),
        validator: (value) => value == null ? lang.S.of(context).pleaseSelectStatus : null,
        // items: statusOptions.map((entry) {
        //   return DropdownMenuItem(value: entry, child: Text(entry));
        // }).toList(),
        // ['Pending', 'Approved', 'Rejected'];
        items: [
          DropdownMenuItem(value: 'Pending', child: Text(lang.S.of(context).pending)),
          DropdownMenuItem(value: 'Approved', child: Text(lang.S.of(context).approved)),
          DropdownMenuItem(value: 'Rejected', child: Text(lang.S.of(context).rejected)),
        ],
        onChanged: (String? value) {
          setState(() {
            _selectedStatus = value!.toLowerCase();
          });
        });
  }

  void _resetForm() {
    if (!isEditing) {
      setState(() {
        _key.currentState?.reset();
        startDateController.clear();
        endDateController.clear();
        leaveDurationController.clear();
        noteController.clear();
        _selectedEmployee = null;
        _currentEmployeeDepartmentName.clear(); // Clear department name
        _selectedLeaveType = null;
        _selectedMonth = null;
        _selectedStartDate = null;
        _selectedEndDate = null;
        _selectedStatus = 'pending';
      });
    } else {
      Navigator.pop(context);
    }
  }
}
