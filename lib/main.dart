import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Authentication/forgot_password.dart';
import 'package:mobile_pos/Screens/Authentication/login_form.dart';
import 'package:mobile_pos/Screens/Authentication/register_screen.dart';
import 'package:mobile_pos/Screens/Customers/party_list_screen.dart';
import 'package:mobile_pos/Screens/Home/home.dart';
import 'package:mobile_pos/Screens/Products/add%20product/add_product.dart';
import 'package:mobile_pos/Screens/Products/product_list_screen.dart';
import 'package:mobile_pos/Screens/Report/Screens/expense_report.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/SplashScreen/on_board.dart';
import 'package:mobile_pos/Screens/SplashScreen/splash_screen.dart';
import 'package:mobile_pos/Screens/Sales/pos_sale/pos_sale.dart';
import 'package:mobile_pos/Screens/vat_&_tax/tax_report.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_list_screen.dart';
import 'package:provider/provider.dart' as pro;
import 'Screens/Due Calculation/due_list_screen.dart';
import 'Screens/Loss_Profit/loss_profit_screen.dart';
import 'Screens/Purchase List/purchase_list_screen.dart';
import 'Screens/Purchase/choose_supplier_screen.dart';
import 'Screens/Report/income_reports/income_report.dart';
import 'Screens/Sales List/sales_list_screen.dart';
import 'Screens/branch/branch_screen.dart';
import 'Screens/custom_print/custom_print.dart';
import 'Screens/hrm/hrm_manu_screen.dart';
import 'Screens/language/language_provider.dart';
import 'Screens/party ledger/ledger_party_list_screen.dart';
import 'Screens/stock_list/stock_list_main.dart';
import 'core/theme/theme.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return pro.ChangeNotifierProvider<LanguageChangeProvider>(
      create: (context) => LanguageChangeProvider(),
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: pro.Provider.of<LanguageChangeProvider>(context, listen: true).currentLocale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          title: 'POSPro',
          initialRoute: '/',
          builder: (context, child) {
            return SafeArea(
              top: false,
              bottom: true,
              child: EasyLoading.init()(context, child),
            );
          },
          routes: {
            '/': (context) => const SplashScreen(),
            '/onBoard': (context) => const OnBoard(),
            '/loginForm': (context) => const LoginForm(isEmailLogin: true),
            '/signup': (context) => const RegisterScreen(),
            '/forgotPassword': (context) => const ForgotPassword(),
            '/home': (context) => const Home(),
            '/AddProducts': (context) => const AddProduct(),
            '/Products': (context) => const ProductList(),
            '/salesCustomer': (context) => const PartyListScreen(isSelectionMode: true),
            '/customPrint': (context) => const CustomPrintScreen(),
            '/Sales': (context) => PartyListScreen(isSelectionMode: true),
            '/Parties': (context) => const PartyListScreen(isSelectionMode: false),
            '/Expense': (context) => const ExpenseReport(),
            '/Income': (context) => const IncomeReport(),
            '/tax': (context) => const TaxReport(),
            '/Stock': (context) => const StockList(isFromReport: false),
            '/Purchase': (context) => const PurchaseContacts(),
            '/Reports': (context) => const Reports(),
            '/Due List': (context) => const DueCalculationContactScreen(),
            '/Sales List': (context) => const SalesListScreen(),
            '/Purchase List': (context) => const PurchaseListScreen(),
            '/Loss/Profit': (context) => const LossProfitScreen(),
            '/Pos Sale': (context) => const PosSaleScreen(),
            '/branch': (context) => const BranchScreen(),
            '/hrm': (context) => const HrmScreen(),
            '/ledger': (context) => const LedgerPartyListScreen(),
            // '/cash_and_bank': (context) => const CashAndBankScreen(),
            '/warehouse': (context) => const WarehouseListScreen(),
          },
          theme: AcnooTheme.kLightTheme(context),
        ),
      ),
    );
  }
}
