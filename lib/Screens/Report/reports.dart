import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Loss_Profit/loss_profit_screen.dart';
import 'package:mobile_pos/Screens/Report/Screens/day_book_report.dart';
import 'package:mobile_pos/Screens/Report/Screens/due_report_screen.dart';
import 'package:mobile_pos/Screens/Report/Screens/expense_report.dart';
import 'package:mobile_pos/Screens/Report/income_reports/income_report.dart';
import 'package:mobile_pos/Screens/Report/Screens/purchase_report.dart';
import 'package:mobile_pos/Screens/Report/Screens/sales_report_screen.dart';
import 'package:mobile_pos/Screens/Report/Screens/sales_return_report_screen.dart';
import 'package:mobile_pos/Screens/Report/Screens/purchase_return_report.dart';
import 'package:mobile_pos/Screens/Report/income_reports/income_categories_report.dart';
import 'package:mobile_pos/Screens/Report/party_report/party_wise_profit.dart';
import 'package:mobile_pos/Screens/Report/party_report/top_five_customer.dart';
import 'package:mobile_pos/Screens/Report/party_report/top_five_supplier.dart';
import 'package:mobile_pos/Screens/Report/product_report/combo_product_report.dart';
import 'package:mobile_pos/Screens/Report/product_report/item_purchased_report.dart';
import 'package:mobile_pos/Screens/Report/product_report/item_sale_report.dart';
import 'package:mobile_pos/Screens/Report/product_report/product_wise_loss_profit.dart';
import 'package:mobile_pos/Screens/Report/product_report/top_five_product.dart';
import 'package:mobile_pos/Screens/hrm/reports/attandence_report.dart';
import 'package:mobile_pos/Screens/hrm/reports/leave_reports.dart';
import 'package:mobile_pos/Screens/hrm/reports/payroll_reports.dart';
import 'package:mobile_pos/Screens/stock_list/low_stock.dart';
import 'package:mobile_pos/Screens/stock_list/stock_list_main.dart';
import 'package:mobile_pos/Screens/Report/Screens/expire_report.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/service/check_user_role_permission_provider.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../all_transaction/all_transaction.dart';
import 'Screens/balance_sheet_screen.dart';
import 'Screens/bill_wise_profit_screen.dart';
import '../party ledger/ledger_party_list_screen.dart';
import 'Screens/cashflow_screen.dart';
import 'Screens/product_purchase_history_report/product_purchase_history_report_list.dart';
import 'Screens/product_sale_history_report/product_sale_history_report_list.dart';
import 'Screens/subscription_report_screen.dart';
import 'Screens/tax_report.dart';

class Reports extends ConsumerStatefulWidget {
  const Reports({super.key});

  @override
  ConsumerState<Reports> createState() => _ReportsState();
}

class _ReportsState extends ConsumerState<Reports> {
  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = lang.S.of(context);
    final _profileDetails = ref.watch(businessInfoProvider);
    final permissionService = PermissionService(ref);

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: Text(_lang.reports),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// ---------------- TRANSACTION SECTION ----------------
              if (permissionService.hasAnyPermission(
                [
                  Permit.saleReportsRead.value,
                  Permit.saleReturnReportsRead.value,
                  Permit.purchaseReportsRead.value,
                  Permit.purchaseReturnReportsRead.value,
                  Permit.dueReportsRead.value,
                  Permit.dayBookReportsRead.value,
                  Permit.transactionHistoryReportsRead.value,
                  Permit.billWiseProfitRead.value,
                  Permit.lossProfitReportsRead.value,
                  Permit.cashflowRead.value,
                  Permit.balanceSheetRead.value,
                  Permit.taxReportRead.value,
                  Permit.attendanceReportsRead.value,
                  Permit.payrollReportsRead.value,
                  Permit.leaveReportsRead.value,
                ],
              )) ...[
                _buildSection(
                  title: _lang.transactions,
                  theme: _theme,
                  items: [
                    if (permissionService.hasPermission(Permit.saleReportsRead.value))
                      _tile(title: _lang.salesReport, page: () => SalesReportScreen()),
                    if (permissionService.hasPermission(Permit.saleReturnReportsRead.value))
                      _tile(title: _lang.salesReturnReport, page: () => SalesReturnReportScreen()),
                    if (permissionService.hasPermission(Permit.purchaseReportsRead.value))
                      _tile(title: _lang.purchaseReport, page: () => PurchaseReportScreen()),
                    if (permissionService.hasPermission(Permit.purchaseReturnReportsRead.value))
                      _tile(title: _lang.purchaseReturnReport, page: () => PurchaseReturnReportScreen()),
                    if (permissionService.hasPermission(Permit.dueReportsRead.value))
                      _tile(title: _lang.dueReport, page: () => DueReportScreen()),
                    if (permissionService.hasPermission(Permit.dayBookReportsRead.value))
                      _tile(title: _lang.dayBook, page: () => DayBookReport()),
                    if (permissionService.hasPermission(Permit.transactionHistoryReportsRead.value))
                      _tile(title: _lang.allTransaction, page: () => AllTransactionReport()),
                    if (permissionService.hasPermission(Permit.billWiseProfitRead.value))
                      _tile(title: _lang.billWiseProfit, page: () => BillWiseProfitScreen()),
                    if (permissionService.hasPermission(Permit.lossProfitReportsRead.value))
                      _tile(title: _lang.profitAndLoss, page: () => LossProfitScreen()),
                    if (permissionService.hasPermission(Permit.cashflowRead.value))
                      _tile(title: _lang.cashFlow, page: () => CashflowScreen()),
                    if (permissionService.hasPermission(Permit.balanceSheetRead.value))
                      _tile(title: _lang.balanceSheet, page: () => BalanceSheetScreen()),
                    if (permissionService.hasPermission(Permit.taxReportRead.value))
                      _tile(title: _lang.taxReport, page: () => TaxReportScreen()),
                    if (_profileDetails.value?.data?.addons?.hrmAddon == true) ...[
                      if (permissionService.hasPermission(Permit.attendanceReportsRead.value))
                        _tile(title: _lang.attendance, page: () => AttendanceReports()),
                      if (permissionService.hasPermission(Permit.payrollReportsRead.value))
                        _tile(title: _lang.payroll, page: () => PayrollReports()),
                      if (permissionService.hasPermission(Permit.leaveReportsRead.value))
                        _tile(title: _lang.leave, page: () => LeaveReports()),
                    ],
                    if (permissionService.hasPermission(Permit.incomeReportsRead.value))
                      _tile(title: _lang.income, page: () => IncomeReport(fromIncomeReport: true)),
                    if (permissionService.hasPermission(Permit.incomeCategoriesRead.value))
                      _tile(title: _lang.incomeCategories, page: () => IncomeCategoryReport()),
                    if (permissionService.hasPermission(Permit.expenseReportsRead.value))
                      _tile(title: _lang.expense, page: () => ExpenseReport(isFromExpense: true)),
                    if (permissionService.hasPermission(Permit.productSaleHistoryRead.value))
                      _tile(title: _lang.productSaleHistory, page: () => ProductSaleHistoryReportList()),
                    if (permissionService.hasPermission(Permit.productPurchaseHistoryRead.value))
                      _tile(title: _lang.productPurchaseHistory, page: () => ProductPurchaseHistoryReportList()),
                    if (permissionService.hasPermission(Permit.subscriptionReportsRead.value))
                      _tile(title: _lang.subscription, page: () => SubscriptionReportScreen()),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              /// ---------------- PARTY REPORTS ----------------
              if (permissionService.hasAnyPermission(
                [
                  Permit.customerLedgerRead.value,
                  Permit.supplierLedgerRead.value,
                  Permit.parityWiseProfitRead.value,
                  Permit.top5CustomerRead.value,
                  Permit.top5SupplierRead.value,
                ],
              )) ...[
                _buildSection(
                  title: _lang.partyReports,
                  theme: _theme,
                  items: [
                    if (permissionService.hasPermission(Permit.customerLedgerRead.value))
                      _tile(
                          title: _lang.customerLedger,
                          page: () => LedgerPartyListScreen(isReport: true, type: 'customer')),
                    if (permissionService.hasPermission(Permit.supplierLedgerRead.value))
                      _tile(
                          title: _lang.supplierLedger,
                          page: () => LedgerPartyListScreen(isReport: true, type: 'supplier')),
                    if (permissionService.hasPermission(Permit.parityWiseProfitRead.value))
                      _tile(title: _lang.partyWiseProfit, page: () => PartyWiseProfitAndLoss()),
                    if (permissionService.hasPermission(Permit.top5CustomerRead.value))
                      _tile(title: _lang.top5Customer, page: () => TopFiveCustomer()),
                    if (permissionService.hasPermission(Permit.top5SupplierRead.value))
                      _tile(title: _lang.top5Supplier, page: () => TopFiveSupplier()),
                  ],
                ),
                SizedBox(height: 16),
              ],

              /// ---------------- PRODUCT REPORTS ----------------
              if (permissionService.hasAnyPermission(
                [
                  Permit.stockReportsRead.value,
                  Permit.comboReportRead.value,
                  Permit.stockReportsRead.value,
                  Permit.expiredProductReportsRead.value,
                  Permit.top5ProductRead.value,
                  Permit.productPurchaseReportRead.value,
                  Permit.productPurchaseReportRead.value,
                  Permit.productSalesReportRead.value,
                ],
              )) ...[
                const SizedBox(height: 16),
                _buildSection(
                  title: _lang.productReports,
                  theme: _theme,
                  items: [
                    if (permissionService.hasPermission(Permit.stockReportsRead.value))
                      _tile(title: _lang.stockReport, page: () => StockList(isFromReport: true)),
                    if (permissionService.hasPermission(Permit.comboReportRead.value))
                      _tile(title: _lang.comboReport, page: () => ComboProductReport()),
                    if (permissionService.hasPermission(Permit.stockReportsRead.value))
                      _tile(title: _lang.lowStockReport, page: () => LowStock(isFromReport: true)),
                    if (permissionService.hasPermission(Permit.expiredProductReportsRead.value))
                      _tile(title: _lang.expiredItemReport, page: () => ExpiredList()),
                    if (permissionService.hasPermission(Permit.top5ProductRead.value))
                      _tile(title: _lang.top5Product, page: () => TopFiveProduct()),
                    if (permissionService.hasPermission(Permit.productPurchaseReportRead.value))
                      _tile(title: _lang.productWiseProfitAndLoss, page: () => ProductWiseProfitAndLoss()),
                    if (permissionService.hasPermission(Permit.productPurchaseReportRead.value))
                      _tile(title: _lang.productWisePurchase, page: () => ItemPurchaseReport()),
                    if (permissionService.hasPermission(Permit.productSalesReportRead.value))
                      _tile(title: _lang.productWiseSale, page: () => ItemSaleReport()),
                    // _tile(title: "Item Wise Discount"),
                  ],
                ),
              ],

              if (!permissionService.hasAnyPermission([
                Permit.saleReportsRead.value,
                Permit.saleReturnReportsRead.value,
                Permit.purchaseReportsRead.value,
                Permit.purchaseReturnReportsRead.value,
                Permit.dueReportsRead.value,
                Permit.dayBookReportsRead.value,
                Permit.transactionHistoryReportsRead.value,
                Permit.billWiseProfitRead.value,
                Permit.lossProfitReportsRead.value,
                Permit.cashflowRead.value,
                Permit.balanceSheetRead.value,
                Permit.taxReportRead.value,
                Permit.attendanceReportsRead.value,
                Permit.payrollReportsRead.value,
                Permit.leaveReportsRead.value,
                Permit.customerLedgerRead.value,
                Permit.supplierLedgerRead.value,
                Permit.parityWiseProfitRead.value,
                Permit.top5CustomerRead.value,
                Permit.top5SupplierRead.value,
                Permit.stockReportsRead.value,
                Permit.comboReportRead.value,
                Permit.stockReportsRead.value,
                Permit.expiredProductReportsRead.value,
                Permit.top5ProductRead.value,
                Permit.productPurchaseReportRead.value,
                Permit.productPurchaseReportRead.value,
                Permit.productSalesReportRead.value,
              ])) ...[Center(child: PermitDenyWidget())],
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE SECTION BUILDER
  // -------------------------------------------------------------
  Widget _buildSection({
    required String title,
    required ThemeData theme,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // REUSABLE TILE BUILDER (Named parameters supported)
  // -------------------------------------------------------------
  Widget _tile({required String title, Widget Function()? page}) {
    return ListTile(
      onTap: page == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page()),
              ),
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -4),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
