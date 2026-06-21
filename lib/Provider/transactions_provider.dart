import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/Screens/Purchase/Repo/purchase_repo.dart';
import 'package:mobile_pos/Screens/Sales/Repo/sales_repo.dart';
import 'package:mobile_pos/model/sale_transaction_model.dart';

import '../model/purchase_tax_model.dart';
import '../model/sale_tax_model.dart';
import '../model/balance_sheet_model.dart' as bs;
import '../model/bill_wise_loss_profit_report_model.dart' as bwlprm;
import '../model/cashflow_model.dart' as cf;
import '../model/loss_profit_model.dart' as lpmodel;
import '../model/product_history_model.dart' as phlm;
import '../model/subscription_report_model.dart' as srm;
import '../model/tax_report_model.dart' as trm;

//------------sales-------------------------------------
final saleRepo = Provider<SaleRepo>((ref) => SaleRepo());

///-----------sale tax provider-----------------------------
final saleTaxProvider = FutureProvider.family<TaxSaleData?, int>((ref, id) async {
  final repo = SaleRepo();
  return repo.getTaxSale(id);
});

///-----------purchase tax provider-----------------------------
final purchaseTaxProvider = FutureProvider.family<TaxPurchaseData?, int>((ref, id) async {
  final repo = SaleRepo();
  return repo.getTaxPurchase(id);
});

final saleProvider = FutureProvider.autoDispose<List<SalesTransactionModel>>((ref) {
  final repo = ref.read(saleRepo);
  return repo.fetchSalesList();
});

final salesTransactionProvider = FutureProvider.autoDispose<List<SalesTransactionModel>>((ref) {
  final repo = ref.read(saleRepo);
  return repo.fetchSalesList();
});

final filteredSaleProvider = FutureProvider.family.autoDispose<List<SalesTransactionModel>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.fetchSalesList(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredSaleReturnedProvider = FutureProvider.family.autoDispose<List<SalesTransactionModel>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.fetchSalesList(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
      salesReturn: true,
    );
  },
);

//------------------purchase----------------------------------------
final purchaseRepo = Provider<PurchaseRepo>((ref) => PurchaseRepo());

final purchaseTransactionProvider = FutureProvider.autoDispose<List<PurchaseTransaction>>((ref) {
  final repo = ref.read(purchaseRepo);
  return repo.fetchPurchaseList();
});

final filterPurchaseProvider = FutureProvider.family.autoDispose<List<PurchaseTransaction>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(purchaseRepo);
    return repo.fetchPurchaseList(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filterPurchaseReturnProvider = FutureProvider.family.autoDispose<List<PurchaseTransaction>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(purchaseRepo);
    return repo.fetchPurchaseList(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
      salesReturn: true,
    );
  },
);

final filteredLossProfitProvider = FutureProvider.family.autoDispose<lpmodel.LossProfitModel, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.getLossProfit(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredCashflowProvider = FutureProvider.family.autoDispose<cf.CashflowModel, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.getCashflow(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredBalanceSheetProvider = FutureProvider.family.autoDispose<bs.BalanceSheetModel, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.getBalanceSheet(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredSubscriptionReportProvider =
    FutureProvider.family.autoDispose<List<srm.SubscriptionReportModel>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.getSubscriptionReport(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredTaxReportReportProvider = FutureProvider.family.autoDispose<trm.TaxReportModel, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.getTaxReport(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredBillWiseLossProfitReportProvider =
    FutureProvider.family.autoDispose<bwlprm.BillWiseLossProfitReportModel, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.getBillWiseLossProfitReport(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredProductSaleHistoryReportProvider =
    FutureProvider.family.autoDispose<phlm.ProductHistoryListModel, FilterModel>(
  (ref, filter) {
    final repo = ref.read(saleRepo);
    return repo.getProductSaleHistoryReport(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

final filteredProductSaleHistoryReportDetailsProvider =
    FutureProvider.family.autoDispose<phlm.ProductHistoryDetailsModel, ({int productId, FilterModel filter})>(
  (ref, arg) {
    final repo = ref.read(saleRepo);
    return repo.getProductSaleHistoryReportDetails(
      productId: arg.productId,
      type: arg.filter.duration,
      fromDate: arg.filter.fromDate,
      toDate: arg.filter.toDate,
    );
  },
);

final filteredProductPurchaseHistoryReportDetailsProvider =
    FutureProvider.family.autoDispose<phlm.ProductHistoryDetailsModel, ({int productId, FilterModel filter})>(
  (ref, arg) {
    final repo = ref.read(saleRepo);
    return repo.getProductPurchaseHistoryReportDetails(
      productId: arg.productId,
      type: arg.filter.duration,
      fromDate: arg.filter.fromDate,
      toDate: arg.filter.toDate,
    );
  },
);

class FilterModel {
  final String? duration;
  final String? fromDate;
  final String? toDate;

  FilterModel({
    this.duration,
    this.fromDate,
    this.toDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterModel && other.duration == duration && other.fromDate == fromDate && other.toDate == toDate;
  }

  @override
  int get hashCode => duration.hashCode ^ fromDate.hashCode ^ toDate.hashCode;
}
