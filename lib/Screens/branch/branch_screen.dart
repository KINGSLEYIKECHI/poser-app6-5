import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/User%20Roles/user_role_screen.dart';
import 'package:mobile_pos/Screens/branch/brunch_transfer_list_screen.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_details_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../transfer/transfer_list_tab_screen.dart';
import 'branch_list.dart';

class BranchScreen extends ConsumerStatefulWidget {
  const BranchScreen({super.key});

  @override
  ConsumerState<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends ConsumerState<BranchScreen> {
  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          _lang.branch,
          style: _theme.textTheme.bodyMedium?.copyWith(
            color: kTitleColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Color(0xFFE8E9F2),
            height: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          children: [
            ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BranchListScreen(),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(
                'assets/branch_list.svg',
                height: 36,
                width: 36,
              ),
              title: Text(
                _lang.branchList,
                style: _theme.textTheme.bodyMedium?.copyWith(
                  color: kTitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Color(0xff4B5563),
              ),
            ),
            Divider(
              color: Color(0xffE6E6E6),
            ),
            ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserRoleScreen(),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(
                'assets/role_permission.svg',
                height: 36,
                width: 36,
              ),
              title: Text(
                _lang.roleAndPermission,
                style: _theme.textTheme.bodyMedium?.copyWith(
                  color: kTitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Color(0xff4B5563),
              ),
            ),
            Divider(
              color: Color(0xffE6E6E6),
            ),
            ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Reports(),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(
                'assets/report.svg',
                height: 36,
                width: 36,
              ),
              title: Text(
                _lang.reports,
                style: _theme.textTheme.bodyMedium?.copyWith(
                  color: kTitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Color(0xff4B5563),
              ),
            ),
            Divider(
              color: Color(0xffE6E6E6),
            ),
            ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BranchTransferListScreen(),
                ),
              ),
              contentPadding: EdgeInsets.zero,
              leading: SvgPicture.asset(
                'assets/branch_list.svg',
                height: 36,
                width: 36,
              ),
              title: Text(
                _lang.branchTransfer,
                style: _theme.textTheme.bodyMedium?.copyWith(
                  color: kTitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Color(0xff4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
