// File: add_new_payroll.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/widgets/multipal%20payment%20mathods/multi_payment_widget.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
// --- Local Imports ---
import '../../../constant.dart';

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/payroll/repo/payroll_repo.dart';
import 'package:mobile_pos/Screens/hrm/employee/model/employee_list_model.dart';
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart';
import 'Model/payroll_lsit_model.dart';

class AddNewPayroll extends ConsumerStatefulWidget {
  final PayrollData? payrollData;

  const AddNewPayroll({super.key, this.payrollData});

  @override
  ConsumerState<AddNewPayroll> createState() => _AddNewPayrollState();
}

class _AddNewPayrollState extends ConsumerState<AddNewPayroll> {
  // --- Form Controllers ---
  final GlobalKey<FormState> _key = GlobalKey();
  final GlobalKey<MultiPaymentWidgetState> _paymentKey = GlobalKey<MultiPaymentWidgetState>();
  final dateController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // --- Selected Values (API payload) ---
  EmployeeData? _selectedEmployee;
  String? _selectedYear;
  String? _selectedMonth;
  DateTime? _selectedDate;

  // --- UI/API Helpers ---
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd', 'en_US');
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  bool get isEditing => widget.payrollData != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final data = widget.payrollData!;
      amountController.text = data.amount?.toString() ?? '';
      noteController.text = data.note ?? '';
      _selectedYear = data.payemntYear;
      _selectedMonth = data.month != null ? data.month![0].toUpperCase() + data.month!.substring(1) : null;

      try {
        if (data.date != null) {
          _selectedDate = DateTime.parse(data.date!);
          dateController.text = _displayDateFormat.format(_selectedDate!);
        }
      } catch (e) {
        debugPrint('Error parsing date for editing: $e');
      }
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // --- Year Generation Logic ---
  List<String> _getYearOptions() {
    final currentYear = DateTime.now().year;
    List<String> years = [];
    for (int i = 0; i <= 5; i++) {
      years.add((currentYear - i).toString());
    }
    years.insert(0, (currentYear + 1).toString());
    return years.toSet().toList().reversed.toList();
  }

  // --- Date Picker Logic ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(2101),
      context: context,
    );
    setState(() {
      if (picked != null) {
        _selectedDate = picked;
        dateController.text = _displayDateFormat.format(picked);
      }
    });
  }

  // --- Submission Logic ---
  void _submit() async {
    if (_key.currentState!.validate() && _selectedEmployee != null && _selectedDate != null) {
      // Get Payments from the MultiPaymentWidget
      List<PaymentEntry> payments = _paymentKey.currentState?.getPaymentEntries() ?? [];

      // Validation: Ensure payments are added
      if (payments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a payment method')));
        return;
      }

      final repo = PayrollRepo();

      // Convert payments to JSON list for API
      final paymentListJson = payments.map((e) => e.toJson()).toList();

      final payload = {
        'employee_id': _selectedEmployee!.id!,
        'month': _selectedMonth!.toLowerCase(),
        'date': _apiFormat.format(_selectedDate!),
        'amount': amountController.text,
        'payemnt_year': _selectedYear!,
        'note': noteController.text,
        'payments': paymentListJson,
      };

      if (isEditing) {
        await repo.updatePayroll(
          ref: ref,
          context: context,
          id: widget.payrollData!.id!,
          employeeId: payload['employee_id'] as num,
          month: payload['month'] as String,
          date: payload['date'] as String,
          amount: payload['amount'] as String,
          paymentYear: payload['payemnt_year'] as String,
          note: payload['note'] as String?,
          payments: paymentListJson,
        );
      } else {
        await repo.createPayroll(
          ref: ref,
          context: context,
          employeeId: payload['employee_id'] as num,
          month: payload['month'] as String,
          date: payload['date'] as String,
          amount: payload['amount'] as String,
          paymentYear: payload['payemnt_year'] as String,
          note: payload['note'] as String?,
          payments: paymentListJson,
        );
      }
    }
  }

  void _resetForm() {
    if (!isEditing) {
      setState(() {
        _key.currentState?.reset();
        dateController.clear();
        amountController.clear();
        noteController.clear();
        _selectedEmployee = null;
        _selectedYear = null;
        _selectedMonth = null;
        _selectedDate = null;
        // _paymentKey state resets automatically on rebuild or you can clear manually if needed
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch required providers
    final employeesAsync = ref.watch(employeeListProvider);
    final _lang = lang.S.of(context);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEditing ? _lang.editPayroll : _lang.addNewPayroll),
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
            final data = widget.payrollData!;
            _selectedEmployee = employees.firstWhere(
              (e) => e.id == data.employeeId,
              orElse: () => _selectedEmployee ?? employees.first,
            );
            amountController.text = _selectedEmployee?.amount.toString() ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  // 1. Employee Dropdown
                  _buildEmployeeDropdown(employees),
                  const SizedBox(height: 20),

                  // 2. Payment Year Dropdown
                  _buildYearDropdown(),
                  const SizedBox(height: 20),

                  // 3. Month & Date
                  Row(
                    children: [
                      Expanded(child: _buildMonthDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDateInput()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Amount Field (Read Only - Based on Employee)
                  _buildAmountInput(),
                  const SizedBox(height: 20),

                  // 5. Payment Methods
                  MultiPaymentWidget(
                    key: _paymentKey,
                    hideAddButton: true,
                    disableDropdown: widget.payrollData != null,
                    showWalletOption: false,
                    showChequeOption: false,
                    totalAmountController: amountController,
                    initialTransactions: widget.payrollData?.transactions, // <--- Passing data for Edit
                  ),
                  const SizedBox(height: 20),

                  // 6. Note
                  _buildNoteInput(),
                  const SizedBox(height: 20),

                  // 7. Action Buttons
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
        },
      ),
    );
  }

  // --- Widget Builder Helpers ---

  Widget _buildEmployeeDropdown(List<EmployeeData> employees) {
    return DropdownButtonFormField<EmployeeData>(
      value: _selectedEmployee,
      icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
      decoration: InputDecoration(labelText: lang.S.of(context).employee, hintText: lang.S.of(context).selectOne),
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
          amountController.text = _selectedEmployee?.amount.toString() ?? '0';
        });
      },
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedYear,
      icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
      decoration: InputDecoration(labelText: lang.S.of(context).paymentYear, hintText: lang.S.of(context).selectOne),
      validator: (value) => value == null ? lang.S.of(context).pleaseSelectPaymentYear : null,
      items: _getYearOptions().map((entry) {
        return DropdownMenuItem(value: entry, child: Text(entry));
      }).toList(),
      onChanged: (String? value) {
        setState(() => _selectedYear = value);
      },
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _selectedMonth,
      icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
      decoration: InputDecoration(labelText: lang.S.of(context).month, hintText: lang.S.of(context).selectOne),
      validator: (value) => value == null ? lang.S.of(context).pleaseSelectAnMonth : null,
      // 'January',
      // 'February',
      // 'March',
      // 'April',
      // 'May',
      // 'June',
      // 'July',
      // 'August',
      // 'September',
      // 'October',
      // 'November',
      // 'December'
      // items: _months.map((entry) {
      //   return DropdownMenuItem(value: entry, child: Text(entry));
      // }).toList(),
      items: [
        DropdownMenuItem(value: 'January', child: Text(lang.S.of(context).january)),
        DropdownMenuItem(value: 'February', child: Text(lang.S.of(context).february)),
        DropdownMenuItem(value: 'March', child: Text(lang.S.of(context).march)),
        DropdownMenuItem(value: 'April', child: Text(lang.S.of(context).april)),
        DropdownMenuItem(value: 'May', child: Text(lang.S.of(context).may)),
        DropdownMenuItem(value: 'June', child: Text(lang.S.of(context).june)),
        DropdownMenuItem(value: 'July', child: Text(lang.S.of(context).july)),
        DropdownMenuItem(value: 'August', child: Text(lang.S.of(context).august)),
        DropdownMenuItem(value: 'September', child: Text(lang.S.of(context).september)),
        DropdownMenuItem(value: 'October', child: Text(lang.S.of(context).october)),
        DropdownMenuItem(value: 'November', child: Text(lang.S.of(context).november)),
        DropdownMenuItem(value: 'December', child: Text(lang.S.of(context).december)),
      ],
      onChanged: (String? value) {
        setState(() => _selectedMonth = value);
      },
    );
  }

  Widget _buildDateInput() {
    return TextFormField(
      keyboardType: TextInputType.name,
      readOnly: true,
      controller: dateController,
      decoration: InputDecoration(
        labelText: lang.S.of(context).month,
        hintText: 'DD/MM/YYYY',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onPressed: () => _selectDate(context),
          icon: const Icon(IconlyLight.calendar, size: 22),
        ),
      ),
      validator: (value) => value!.isEmpty ? lang.S.of(context).pleaseEnterADate : null,
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      readOnly: true,
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: lang.S.of(context).totalSalaryAmount,
        hintText: lang.S.of(context).selectEmployeeFirst,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextFormField(
      controller: noteController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: lang.S.of(context).note,
        hintText: lang.S.of(context).enterNote,
        border: OutlineInputBorder(),
      ),
    );
  }
}
