import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/Screens/hrm/attendance/attendance_screen.dart';
import 'package:mobile_pos/Screens/hrm/department/department_screen.dart';
import 'package:mobile_pos/Screens/hrm/designation/designation_list.dart';
import 'package:mobile_pos/Screens/hrm/employee/employee_list_screen.dart';
import 'package:mobile_pos/Screens/hrm/holiday/holiday_list_screen.dart';
import 'package:mobile_pos/Screens/hrm/leave_request/leave/leave_list_screen.dart';
import 'package:mobile_pos/Screens/hrm/leave_request/leave_type/leave_type_list.dart';
import 'package:mobile_pos/Screens/hrm/payroll/payroll_list.dart';
import 'package:mobile_pos/Screens/hrm/reports/attandence_report.dart';
import 'package:mobile_pos/Screens/hrm/reports/leave_reports.dart';
import 'package:mobile_pos/Screens/hrm/reports/payroll_reports.dart';
import 'package:mobile_pos/Screens/hrm/shift/shift_screen.dart';

import '../../constant.dart';
import '../../service/check_user_role_permission_provider.dart';

class HrmScreen extends ConsumerStatefulWidget {
  const HrmScreen({super.key});

  @override
  ConsumerState<HrmScreen> createState() => _HrmScreenState();
}

class _HrmScreenState extends ConsumerState<HrmScreen> {
  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final permissionService = PermissionService(ref);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(_lang.hrm),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //---------------Department--------------------
            _buildListItem(
              context,
              icon: 'assets/hrm/depertment.svg',
              title: _lang.department,
              destination: DepartmentScreen(),
            ),
            const SizedBox(height: 10),
            //-----------------Designation----------------------
            _buildListItem(
              context,
              icon: 'assets/hrm/designation.svg',
              title: _lang.designation,
              destination: DesignationListScreen(),
            ),
            const SizedBox(height: 10),
            //---------------------Shift----------------------------
            _buildListItem(
              context,
              icon: 'assets/hrm/shift.svg',
              title: _lang.shift,
              destination: const ShiftScreen(),
            ),
            SizedBox(height: 10),
            //-----------------Employee---------------------------------
            _buildListItem(
              context,
              icon: 'assets/hrm/employee.svg',
              title: _lang.employee,
              destination: const EmployeeListScreen(),
            ),
            SizedBox(height: 10),
            //-----------------Leave request-----------------------------
            _buildExpansionTile(
              context,
              icon: 'assets/hrm/leave.svg',
              title: _lang.leaveRequest,
              children: [
                _buildSubMenuItem(
                  context,
                  title: _lang.leaveType,
                  destination: const LeaveTypeList(),
                ),
                _buildSubMenuItem(
                  context,
                  title: _lang.leave,
                  destination: const LeaveListScreen(),
                ),
              ],
            ),
            SizedBox(height: 10),
            //------------------------Holiday----------------------------------
            _buildListItem(
              context,
              icon: 'assets/hrm/holiday.svg',
              title: _lang.holiday,
              destination: const HolidayList(),
            ),
            SizedBox(height: 10),
            //------------------------Attendance-------------------------------
            _buildListItem(
              context,
              icon: 'assets/hrm/attendence.svg',
              title: _lang.attendance,
              destination: const AttendanceScreen(),
            ),
            SizedBox(height: 10),
            //-------------------------payroll----------------------------------
            _buildListItem(
              context,
              icon: 'assets/hrm/payroll.svg',
              title: _lang.payroll,
              destination: const PayrollScreen(),
            ),
            SizedBox(height: 10),
            //--------------------------Reports--------------------------------
            if (permissionService.hasPermission(Permit.attendanceReportsRead.value) ||
                permissionService.hasPermission(Permit.payrollReportsRead.value) ||
                permissionService.hasPermission(Permit.leaveReportsRead.value))
              _buildExpansionTile(
                context,
                icon: 'assets/hrm/reports.svg',
                title: _lang.reports,
                children: [
                  if (permissionService.hasPermission(Permit.attendanceReportsRead.value))
                    _buildSubMenuItem(
                      context,
                      title: _lang.attendance,
                      destination: const AttendanceReports(),
                    ),
                  if (permissionService.hasPermission(Permit.payrollReportsRead.value))
                    _buildSubMenuItem(
                      context,
                      title: _lang.payroll,
                      destination: const PayrollReports(),
                    ),
                  if (permissionService.hasPermission(Permit.leaveReportsRead.value))
                    _buildSubMenuItem(
                      context,
                      title: _lang.leave,
                      destination: const LeaveReports(),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  ///-------------build menu item------------------------------
  Widget _buildListItem(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget destination,
  }) {
    final _theme = Theme.of(context);
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(6)),
      horizontalTitleGap: 15,
      contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 8),
      onTap: () {
        // expansibleController.collapse();
        // expansibleController2.collapse();
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      leading: SvgPicture.asset(
        icon,
        height: 40,
        width: 40,
      ),
      title: Text(
        title,
        style: _theme.textTheme.bodyLarge,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: kNeutral800,
      ),
    );
  }

  ///---------------------expansion tile item---------------------------------
  Widget _buildExpansionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: WidgetStateColor.transparent,
      ),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        iconColor: kNeutral800,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 50),
        leading: SvgPicture.asset(
          icon,
          height: 40,
          width: 40,
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        children: children,
      ),
    );
  }

  ///-------------------sub menu item---------------------------------------
  Widget _buildSubMenuItem(
    BuildContext context, {
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      onTap: () {
        // setState(() => selectedTitle = title);

        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      visualDensity: const VisualDensity(vertical: -4),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: kTitleColor,
            ),
      ),
    );
  }
}
