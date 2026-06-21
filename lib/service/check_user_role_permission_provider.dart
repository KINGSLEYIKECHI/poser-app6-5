import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Provider/profile_provider.dart';
import '../model/business_info_model.dart';

class UserPermissionNotifier extends StateNotifier<List<String>> {
  final Ref ref;
  late final ProviderSubscription<AsyncValue<BusinessInformationModel>> _subscription;

  bool _visibilityIsNull = false;

  UserPermissionNotifier(this.ref) : super([]) {
    _subscription = ref.listen<AsyncValue<BusinessInformationModel>>(
      businessInfoProvider,
      (previous, next) {
        next.whenData((businessInfo) {
          final user = businessInfo.data?.user;
          if (user != null) {
            _visibilityIsNull = user.visibilityIsNull;
            state = user.getAllPermissions();
          } else {
            _visibilityIsNull = false;
            state = [];
          }
        });
        if (next.hasError) {
          _visibilityIsNull = false;
          state = [];
        }
      },
      fireImmediately: true,
    );
  }

  bool get visibilityIsNull => _visibilityIsNull;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }

  bool has(String permission) => state.contains(permission);
}

final userPermissionProvider = StateNotifierProvider<UserPermissionNotifier, List<String>>(
  (ref) => UserPermissionNotifier(ref),
);

class PermissionService {
  final WidgetRef ref;
  PermissionService(this.ref);

  bool hasPermission(String permission, {BuildContext? context}) {
    final permissions = ref.read(userPermissionProvider);
    final visibilityIsNull = ref.read(userPermissionProvider.notifier).visibilityIsNull;

    if (visibilityIsNull) {
      return true;
    }

    if (permissions.isEmpty) {
      return false;
    }

    final result = permissions.contains(permission);
    return result;
  }

  bool hasAnyPermission(List<String> permissions) {
    final userPermissions = ref.read(userPermissionProvider);
    final visibilityIsNull = ref.read(userPermissionProvider.notifier).visibilityIsNull;

    if (visibilityIsNull) {
      return true;
    }

    if (userPermissions.isEmpty) {
      return false;
    }

    return permissions.any((permission) => userPermissions.contains(permission));
  }
}

enum Permit {
  dashboardRead('dashboard.read'),
  salesRead('sales.read'),
  salesCreate('sales.create'),
  salesUpdate('sales.update'),
  salesDelete('sales.delete'),
  salesPriceView('sales.price'),
  inventoryRead('inventory.read'),
  inventoryCreate('inventory.create'),
  inventoryPriceView('inventory.price'),
  saleReturnsRead('sale-returns.read'),
  saleReturnsCreate('sale-returns.create'),
  saleReturnsPriceView('sale-returns.price'),
  purchasesRead('purchases.read'),
  purchasesCreate('purchases.create'),
  purchasesUpdate('purchases.update'),
  purchasesDelete('purchases.delete'),
  purchasesPriceView('purchases.price'),
  purchaseReturnsRead('purchase-returns.read'),
  purchaseReturnsCreate('purchase-returns.create'),
  purchaseReturnPriceView('purchase-returns.price'),
  productsRead('products.read'),
  productsCreate('products.create'),
  productsUpdate('products.update'),
  productsDelete('products.delete'),
  productsPriceView('products.price'),
  branchesRead('branches.read'),
  branchesCreate('branches.create'),
  branchesUpdate('branches.update'),
  branchesDelete('branches.delete'),
  productsExpiredRead('products-expired.read'),
  barcodesRead('barcodes.read'),
  barcodesCreate('barcodes.create'),
  bulkUploadsRead('bulk-uploads.read'),
  bulkUploadsCreate('bulk-uploads.create'),
  categoriesRead('categories.read'),
  categoriesCreate('categories.create'),
  categoriesUpdate('categories.update'),
  categoriesDelete('categories.delete'),
  brandsRead('brands.read'),
  brandsCreate('brands.create'),
  brandsUpdate('brands.update'),
  brandsDelete('brands.delete'),
  unitsRead('units.read'),
  unitsCreate('units.create'),
  unitsUpdate('units.update'),
  unitsDelete('units.delete'),
  productModelsRead('product-models.read'),
  productModelsCreate('product-models.create'),
  productModelsUpdate('product-models.update'),
  productModelsDelete('product-models.delete'),
  stocksRead('stocks.read'),
  stocksPriceView('stocks.price'),
  expiredProductsRead('expired-products.read'),
  partiesRead('parties.read'),
  partiesCreate('parties.create'),
  partiesUpdate('parties.update'),
  partiesDelete('parties.delete'),
  partiesPriceView('parties.price'),
  incomesRead('incomes.read'),
  incomesCreate('incomes.create'),
  incomesUpdate('incomes.update'),
  incomesDelete('incomes.delete'),
  incomesPriceView('incomes.price'),
  incomeCategoriesRead('income-categories.read'),
  incomeCategoriesCreate('income-categories.create'),
  incomeCategoriesUpdate('income-categories.update'),
  incomeCategoriesDelete('income-categories.delete'),
  expensesRead('expenses.read'),
  expensesCreate('expenses.create'),
  expensesUpdate('expenses.update'),
  expensesDelete('expenses.delete'),
  expensesPriceView('expenses.price'),
  expenseCategoriesRead('expense-categories.read'),
  expenseCategoriesCreate('expense-categories.create'),
  expenseCategoriesUpdate('expense-categories.update'),
  expenseCategoriesDelete('expense-categories.delete'),
  vatsRead('vats.read'),
  vatsCreate('vats.create'),
  vatsUpdate('vats.update'),
  vatsDelete('vats.delete'),
  duesRead('dues.read'),
  subscriptionsRead('subscriptions.read'),
  lossProfitsRead('loss-profits.read'),
  paymentTypesRead('payment-types.read'),
  paymentTypesCreate('payment-types.create'),
  paymentTypesUpdate('payment-types.update'),
  paymentTypesDelete('payment-types.delete'),
  rolesRead('roles.read'),
  rolesCreate('roles.create'),
  rolesUpdate('roles.update'),
  rolesDelete('roles.delete'),
  departmentRead('department.read'),
  departmentCreate('department.create'),
  departmentUpdate('department.update'),
  departmentDelete('department.delete'),
  designationsRead('designations.read'),
  designationsCreate('designations.create'),
  designationsUpdate('designations.update'),
  designationsDelete('designations.delete'),
  shiftsRead('shifts.read'),
  shiftsCreate('shifts.create'),
  shiftsUpdate('shifts.update'),
  shiftsDelete('shifts.delete'),
  employeesRead('employees.read'),
  employeesCreate('employees.create'),
  employeesUpdate('employees.update'),
  employeesDelete('employees.delete'),
  leaveTypesRead('leave-types.read'),
  leaveTypesCreate('leave-types.create'),
  leaveTypesUpdate('leave-types.update'),
  leaveTypesDelete('leave-types.delete'),
  leavesRead('leaves.read'),
  leavesCreate('leaves.create'),
  leavesUpdate('leaves.update'),
  leavesDelete('leaves.delete'),
  holidaysRead('holidays.read'),
  holidaysCreate('holidays.create'),
  holidaysUpdate('holidays.update'),
  holidaysDelete('holidays.delete'),
  attendancesRead('attendances.read'),
  attendancesCreate('attendances.create'),
  attendancesUpdate('attendances.update'),
  attendancesDelete('attendances.delete'),
  payrollsRead('payrolls.read'),
  payrollsCreate('payrolls.create'),
  payrollsUpdate('payrolls.update'),
  payrollsDelete('payrolls.delete'),
  attendanceReportsRead('attendance-reports.read'),
  payrollReportsRead('payroll-reports.read'),
  leaveReportsRead('leave-reports.read'),
  warehousesRead('warehouses.read'),
  warehousesCreate('warehouses.create'),
  warehousesUpdate('warehouses.update'),
  warehousesDelete('warehouses.delete'),
  transfersRead('transfers.read'),
  transfersCreate('transfers.create'),
  transfersUpdate('transfers.update'),
  transfersDelete('transfers.delete'),
  racksRead('racks.read'),
  racksCreate('racks.create'),
  racksUpdate('racks.update'),
  racksDelete('racks.delete'),
  shelfsRead('shelfs.read'),
  shelfsCreate('shelfs.create'),
  shelfsUpdate('shelfs.update'),
  shelfsDelete('shelfs.delete'),
  manageSettingsRead('manage-settings.read'),
  manageSettingsUpdate('manage-settings.update'),
  downloadApkRead('download-apk.read'),
  saleReportsRead('sale-reports.read'),
  saleReturnReportsRead('sale-return-reports.read'),
  purchaseReportsRead('purchase-reports.read'),
  purchaseReturnReportsRead('purchase-return-reports.read'),
  vatReportsRead('vat-reports.read'),
  incomeReportsRead('income-reports.read'),
  expenseReportsRead('expense-reports.read'),
  lossProfitsDetailsRead('loss-profits-details.read'),
  stockReportsRead('stock-reports.read'),
  dueReportsRead('due-reports.read'),
  supplierDueReportsRead('supplier-due-reports.read'),
  lossProfitReportsRead('loss-profit-reports.read'),
  transactionHistoryReportsRead('transaction-history-reports.read'),
  subscriptionReportsRead('subscription-reports.read'),
  expiredProductReportsRead('expired-product-reports.read'),
  dayBookReportsRead('day-book-reports.read'),
  billWiseProfitRead('bill-wise-profit.read'),
  cashflowRead('cashflow.read'),
  balanceSheetRead('balance-sheet.read'),
  taxReportRead('tax-report.read'),
  customerLedgerRead('customer-ledger.read'),
  supplierLedgerRead('supplier-ledger.read'),
  parityWiseProfitRead('parity-wise-profit.read'),
  top5CustomerRead('top-5-customer.read'),
  top5SupplierRead('top-5-supplier.read'),
  comboReportRead('combo-report.read'),
  top5ProductRead('top-5-product.read'),
  productWiseProfitLossRead('product-wise-profit-loss.read'),
  productPurchaseReportRead('product-purchase-report.read'),
  productSalesReportRead('product-sales-report.read'),
  productPurchaseHistoryRead('product-purchase-history.read'),
  productSaleHistoryRead('product-sale-history.read');

  final String value;
  const Permit(this.value);
}
