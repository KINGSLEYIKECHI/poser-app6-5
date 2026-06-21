import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class GridItems {
  final String title, icon, route;

  GridItems({required this.title, required this.icon, required this.route});
}

List<GridItems> getFreeIcons(
    {required BuildContext context, bool? brunchPermission, bool? hrmPermission, bool? warehousePermission}) {
  List<GridItems> freeIcons = [
    GridItems(
      title: lang.S.of(context).sale,
      icon: 'assets/sales.svg',
      route: 'Sales',
    ),
    GridItems(
      title: lang.S.of(context).posSale,
      icon: 'images/dash_pos.svg',
      route: 'Pos Sale',
    ),
    GridItems(
      title: lang.S.of(context).parties,
      icon: 'assets/parties.svg',
      route: 'Parties',
    ),
    GridItems(
      title: lang.S.of(context).purchase,
      icon: 'assets/purchase.svg',
      route: 'Purchase',
    ),
    GridItems(
      title: lang.S.of(context).product,
      icon: 'assets/products.svg',
      route: 'Products',
    ),
    GridItems(
      title: lang.S.of(context).dueList,
      icon: 'assets/duelist.svg',
      route: 'Due List',
    ),
    GridItems(
      title: lang.S.of(context).stockList,
      icon: 'assets/h_stock.svg',
      route: 'Stock',
    ),
    GridItems(
      title: lang.S.of(context).reports,
      icon: 'assets/reports.svg',
      route: 'Reports',
    ),
    GridItems(
      title: lang.S.of(context).saleList,
      icon: 'assets/salelist.svg',
      route: 'Sales List',
    ),
    GridItems(
      title: lang.S.of(context).purchaseList,
      icon: 'assets/purchaseLisst.svg',
      route: 'Purchase List',
    ),
    GridItems(
      // TODO: Shakil change this to `Profit & Loss`
      title: lang.S.of(context).profitAndLoss,
      icon: 'assets/h_lossProfit.svg',
      route: 'Loss/Profit',
    ),
    GridItems(
      title: lang.S.of(context).ledger,
      icon: 'assets/ledger.svg',
      route: 'ledger',
    ),
    GridItems(
      title: lang.S.of(context).income,
      icon: 'assets/h_income.svg',
      route: 'Income',
    ),
    GridItems(
      title: lang.S.of(context).expense,
      icon: 'assets/expense.svg',
      route: 'Expense',
    ),
    GridItems(
      title: lang.S.of(context).vatAndTax,
      icon: 'assets/tax.svg',
      route: 'tax',
    ),
    if (warehousePermission ?? false)
      GridItems(
        title: lang.S.of(context).warehouse,
        icon: 'assets/warehouse.svg',
        route: 'warehouse',
      ),
    GridItems(
      title: lang.S.of(context).customPrint,
      icon: 'assets/printer.svg',
      route: 'customPrint',
    ),
    if (brunchPermission == true)
      GridItems(
        title: lang.S.of(context).branch,
        icon: 'assets/branch.svg',
        route: 'branch',
      ),
    if (hrmPermission ?? false)
      GridItems(
        title: lang.S.of(context).hrms,
        icon: 'assets/hrm/hrm.svg',
        route: 'hrm',
      ),
  ];

  return freeIcons;
}
