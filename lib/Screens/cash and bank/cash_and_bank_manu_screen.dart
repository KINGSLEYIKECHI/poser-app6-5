import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

// --- Local Imports ---
import '../../constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../service/check_user_role_permission_provider.dart';
import 'bank account/bank_account_list_screen.dart';
import 'cansh in hand/cash_in_hand_screen.dart';
import 'cheques/cheques_list_screen.dart';

class CashAndBankScreen extends ConsumerStatefulWidget {
  const CashAndBankScreen({super.key});

  @override
  ConsumerState<CashAndBankScreen> createState() => _CashAndBankScreenState();
}

class _CashAndBankScreenState extends ConsumerState<CashAndBankScreen> {
  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(_lang.cashAndBankManagement), // Updated title
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            _buildListItem(
              context,
              icon: 'assets/hrm/depertment.svg',
              title: _lang.bankAccounts,
              destination: BankAccountListScreen(),
            ),
            _buildListItem(
              context,
              icon: 'assets/hrm/depertment.svg',
              title: _lang.cashInHand,
              destination: CashInHandScreen(),
            ),
            _buildListItem(
              context,
              icon: 'assets/hrm/depertment.svg',
              title: _lang.cheque,
              destination: ChequesListScreen(),
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
}
