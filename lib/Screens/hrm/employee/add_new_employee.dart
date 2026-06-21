import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/hrm/employee/repo/employee_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
// Assuming these imports are correct based on your previous code
import '../../../constant.dart';
import '../department/provider/department_list_provider.dart';
import '../designation/provider/designation_list_provider.dart';
import '../shift/provider/shift_list_provider.dart';
import 'model/employee_list_model.dart';

class AddNewEmployee extends ConsumerStatefulWidget {
  const AddNewEmployee({super.key, this.isEdit = false, this.employeeToEdit});

  final bool isEdit;
  final EmployeeData? employeeToEdit; // Assume you pass the data here

  @override
  ConsumerState<AddNewEmployee> createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends ConsumerState<AddNewEmployee> {
  // Assuming 'status' is num (1 for active) or string ('Active')
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

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final salaryController = TextEditingController();
  final birthDateController = TextEditingController();
  final joinDateController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();

  // Storing IDs for API submission
  int? selectedDesignationId;
  int? selectedDepartmentId;
  int? selectShiftId;

  // Storing names for Dropdown display (if initial value is set)
  String? selectedDesignationName;
  String? selectedDepartmentName;
  String? selectedShiftName;

  String? selectedGender;
  String? selectedStatus;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;

  // Repositories for API calls
  final _employeeCrudRepo = EmployeeRepo();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.employeeToEdit != null) {
      _loadInitialData(widget.employeeToEdit!);
    }
  }

  void _loadInitialData(EmployeeData employee) {
    nameController.text = employee.name ?? '';
    emailController.text = employee.email ?? '';
    phoneController.text = employee.phone ?? '';
    countryController.text = employee.country ?? '';
    salaryController.text = employee.amount?.toString() ?? '';
    birthDateController.text = _formatDateForDisplay(employee.birthDate);
    joinDateController.text = _formatDateForDisplay(employee.joinDate);

    // Set initial values for dropdowns (using IDs for submission)
    selectedDesignationId = employee.designationId?.toInt();
    selectedDesignationName = employee.designation?.name;

    selectedDepartmentId = employee.departmentId?.toInt();
    selectedDepartmentName = employee.department?.name;

    selectShiftId = employee.shiftId?.toInt();
    selectedShiftName = employee.shift?.name;

    selectedGender = employee.gender;
    selectedStatus = employee.status;

    // Note: Image needs a separate logic if you want to load the existing one from URL
  }

  String _formatDateForDisplay(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy', 'en_US').format(dateTime);
    } catch (_) {
      return date; // return as is if parsing fails
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    salaryController.dispose();
    birthDateController.dispose();
    joinDateController.dispose();
    super.dispose();
  }

  // --- API Submission Logic ---
  Future<void> _submitForm() async {
    if (!_key.currentState!.validate()) return;

    final isEdit = widget.isEdit;
    final employeeId = widget.employeeToEdit?.id?.toString();

    // Prepare formData for API (using form-data structure from Postman)
    final Map<String, String> formData = {
      if (isEdit) '_method': 'put',
      'name': nameController.text,
      'designation_id': selectedDesignationId?.toString() ?? "",
      'department_id': selectedDepartmentId?.toString() ?? "",
      'shift_id': selectShiftId?.toString() ?? "",
      'amount': salaryController.text,
      'phone': phoneController.text,
      'email': emailController.text,
      'gender': selectedGender?.toLowerCase() ?? "",
      'country': countryController.text,
      // Date formatting to YYYY-MM-DD for API
      'birth_date': _formatDateForAPI(birthDateController.text) ?? "",
      'join_date': _formatDateForAPI(joinDateController.text) ?? "",
      'status': selectedStatus?.toLowerCase() ?? "", // active | terminate | suspended
    };

    await _employeeCrudRepo.saveEmployee(
      ref: ref,
      context: context,
      formData: formData,
      isEdit: isEdit,
      image: pickedImage != null ? File(pickedImage!.path) : null,
      employeeId: employeeId,
    );
  }

  String? _formatDateForAPI(String dateDisplay) {
    // Converts display format (dd/MM/yyyy) to API format (YYYY-MM-DD)
    if (dateDisplay.isEmpty) return null;
    try {
      final dateTime = DateFormat('dd/MM/yyyy', 'en_US').parse(dateDisplay);
      return DateFormat('yyyy-MM-dd', 'en_US').format(dateTime);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the three provider
    final _lang = lang.S.of(context);
    final designationAsync = ref.watch(designationListProvider);
    final departmentAsync = ref.watch(departmentListProvider);
    final shiftAsync = ref.watch(shiftListProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEdit ? _lang.editEmployee : _lang.addNewEmployee,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Name ---
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: _lang.name,
                  hintText: _lang.enterYourFullName,
                ),
                validator: (value) => value!.isEmpty ? _lang.enterFullName : null,
              ),
              const SizedBox(height: 20),

              // --- Designation Dropdown (Dynamic) ---
              designationAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => Text('Designation Error: $err'),
                data: (model) {
                  final items = (model.data ?? []).where(_isActive).toList();
                  return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: _lang.designation,
                      hintText: _lang.selectOne,
                    ),
                    // Use ID for value, Name for display
                    value: selectedDesignationId,
                    validator: (value) => value == null ? _lang.pleaseSelectDesignation : null,
                    items: items.map((data) {
                      return DropdownMenuItem<int>(
                        value: data.id?.toInt(),
                        child: Text(data.name ?? 'N/A'),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        selectedDesignationId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // --- Department Dropdown (Dynamic) ---
              departmentAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, stack) => Text('Department Error: $err'),
                data: (model) {
                  final items = (model.data ?? []).where(_isActive).toList();
                  return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: _lang.department,
                      hintText: _lang.selectOne,
                    ),
                    value: selectedDepartmentId,
                    validator: (value) => value == null ? _lang.pleaseSelectDepartment : null,
                    items: items.map((data) {
                      return DropdownMenuItem<int>(
                        value: data.id?.toInt(),
                        child: Text(data.name ?? 'N/A'),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        selectedDepartmentId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // --- Email ---
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _lang.email,
                  hintText: _lang.enterYourEmailAddress,
                ),
              ),
              const SizedBox(height: 20),

              // --- Phone ---
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _lang.phone,
                  hintText: _lang.enterYourPhoneNumber,
                ),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterYourPhoneNumber : null,
              ),
              const SizedBox(height: 20),

              // --- Country ---
              TextFormField(
                controller: countryController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: _lang.countryName,
                  hintText: _lang.enterYourCountry,
                ),
              ),
              const SizedBox(height: 20),

              // --- Salary ---
              TextFormField(
                controller: salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _lang.salary,
                  hintText: 'Ex: \$500',
                ),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterYourSalary : null,
              ),
              const SizedBox(height: 20),

              // --- Gender & Shift (Dynamic) ---
              Row(
                children: [
                  // --- Gender ---
                  Expanded(
                    child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _lang.gender,
                          hintText: _lang.selectOne,
                        ),
                        value: selectedGender,
                        validator: (value) => value == null ? _lang.pleaseSelectYourGender : null,
                        // items: ['Male', 'Female', 'Others'].map((entry) {
                        //   return DropdownMenuItem<String>(
                        //       value: entry.toLowerCase(),
                        //       child: Text(
                        //         entry,
                        //         maxLines: 1,
                        //         overflow: TextOverflow.ellipsis,
                        //       ));
                        // }).toList(),
                        items: [
                          DropdownMenuItem(
                              value: 'male',
                              child: Text(
                                _lang.male,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                          DropdownMenuItem(
                              value: 'female',
                              child: Text(
                                _lang.female,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                          DropdownMenuItem(
                              value: 'others',
                              child: Text(
                                _lang.others,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            selectedGender = value;
                          });
                        }),
                  ),
                  const SizedBox(width: 16),

                  // --- Shift Dropdown (Dynamic) ---
                  Expanded(
                    child: shiftAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => Text('Shift Error: $err'),
                      data: (model) {
                        final items = (model.data ?? []).where(_isActive).toList();
                        return DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: _lang.shift,
                            hintText: _lang.selectOne,
                          ),
                          initialValue: selectShiftId,
                          validator: (value) => value == null ? _lang.pleaseSelectYourShift : null,
                          items: items.map((data) {
                            return DropdownMenuItem<int>(
                              value: data.id?.toInt(),
                              child: Text(
                                data.name ?? 'N/A',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              selectShiftId = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Birth Date & Join Date ---
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      readOnly: true,
                      controller: birthDateController,
                      decoration: InputDecoration(
                        labelText: _lang.birthDate,
                        hintText: '06/02/2025',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              context: context,
                            );
                            if (picked != null) {
                              birthDateController.text = DateFormat('dd/MM/yyyy', 'en_US').format(picked);
                            }
                          },
                          icon: const Icon(IconlyLight.calendar, size: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      readOnly: true,
                      controller: joinDateController,
                      decoration: InputDecoration(
                        labelText: _lang.joinDate,
                        hintText: '06/02/2025',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              context: context,
                            );
                            if (picked != null) {
                              joinDateController.text = DateFormat('dd/MM/yyyy', 'en_US').format(picked);
                            }
                          },
                          icon: const Icon(IconlyLight.calendar, size: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Status ---
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _lang.status,
                          hintText: _lang.selectOne,
                        ),
                        value: selectedStatus,
                        validator: (value) => value == null ? _lang.pleaseSelectAStatus : null,
                        // items: ['Active', 'Terminated', 'Suspended'].map((entry) {
                        //   return DropdownMenuItem<String>(value: entry.toLowerCase(), child: Text(entry));
                        // }).toList(),
                        items: [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text(_lang.active),
                          ),
                          DropdownMenuItem(
                            value: 'terminated',
                            child: Text(_lang.terminated),
                          ),
                          DropdownMenuItem(
                            value: 'suspended',
                            child: Text(_lang.suspended),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox())
                ],
              ),
              const SizedBox(height: 20),

              // --- Image Picker UI (Your existing code) ---
              Text(
                _lang.image,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width - 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _imageOption(
                                  icon: Icons.photo_library_rounded,
                                  label: _lang.gallery,
                                  color: kMainColor,
                                  source: ImageSource.gallery,
                                ),
                                const SizedBox(width: 40),
                                _imageOption(
                                  icon: Icons.camera,
                                  label: _lang.camera,
                                  color: kGreyTextColor,
                                  source: ImageSource.camera,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(120),
                              image: DecorationImage(
                                image: pickedImage != null
                                    ? FileImage(File(pickedImage!.path))
                                    : widget.employeeToEdit?.image != null
                                        ? NetworkImage('${widget.employeeToEdit?.image}')
                                        : const AssetImage('assets/hrm/image_icon.jpg') as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: kMainColor,
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(120),
                              ),
                              child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Save/Update & Reset Buttons ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reset logic remains the same
                        setState(() {
                          _key.currentState?.reset();
                          nameController.clear();
                          emailController.clear();
                          phoneController.clear();
                          countryController.clear();
                          salaryController.clear();
                          birthDateController.clear();
                          joinDateController.clear();
                          selectedDesignationId = null;
                          selectedDepartmentId = null;
                          selectShiftId = null;
                          selectedGender = null;
                          selectedStatus = null;
                          pickedImage = null; // Reset image
                        });
                      },
                      child: Text(_lang.resets),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm, // Call the submit function
                      child: Text(widget.isEdit ? _lang.update : _lang.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper Widget
  Widget _imageOption({
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        pickedImage = await _picker.pickImage(source: source);
        setState(() {});
        Future.delayed(
          const Duration(milliseconds: 100),
          () => navigator.pop(),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: color),
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: kGreyTextColor)),
        ],
      ),
    );
  }
}
