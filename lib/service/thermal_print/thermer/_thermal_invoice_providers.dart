// import '../../../../data/repository/repository.dart';

// export '../../../../data/repository/repository.dart' show SalePurchaseThermalInvoiceData;

// final purchaseThermalInvoiceProvider = FutureProvider.autoDispose.family<bool, SalePurchaseThermalInvoiceData>(
//   (ref, purchase) async {
//     final _user = ref.read(userRepositoryProvider).value;

//     final _template = PurchaseThermalInvoiceTemplate(
//       ref,
//       purchaseInvoice: purchase.copyWith(user: _user),
//     );

//     return await Future.microtask(
//       () => ref.read(thermalPrinterGeneratorProvider).printInvoice(_template),
//     );
//   },
// );

// final saleThermalInvoiceProvider =
//     FutureProvider.autoDispose.family<bool, ({SalePurchaseThermalInvoiceData sale, bool printKOT})>(
//   (ref, data) async {
//     final _user = ref.read(userRepositoryProvider).value;

//     final _template = SaleThermalInvoiceTemplate(
//       ref,
//       saleInvoice: data.sale.copyWith(user: _user),
//       printKOT: data.printKOT,
//     );

//     return await Future.microtask(
//       () => ref.read(thermalPrinterGeneratorProvider).printInvoice(_template),
//     );
//   },
// );

// final kotThermalInvoiceProvider = FutureProvider.autoDispose.family<bool, Sale>(
//   (ref, sale) async {
//     final _user = ref.read(userRepositoryProvider).value;

//     final _template = KOTTicketTemplate(
//       ref,
//       kotInvoice: SalePurchaseThermalInvoiceData.fromSale(sale).copyWith(user: _user),
//     );

//     return await Future.microtask(
//       () => ref.read(thermalPrinterGeneratorProvider).printInvoice(_template),
//     );
//   },
// );

// final dueCollectionThermalInvoiceProvider = FutureProvider.autoDispose.family<bool, DueCollectionThermalInvoiceData>(
//   (ref, dueCollect) async {
//     final _user = ref.read(userRepositoryProvider).value;

//     final _template = DueCollectionTemplate(
//       ref,
//       dueInvoice: dueCollect.copyWith(user: _user),
//     );

//     return await Future.microtask(
//       () => ref.read(thermalPrinterGeneratorProvider).printInvoice(_template),
//     );
//   },
// );

// sealed class InvoicePreviewType {
//   const InvoicePreviewType._();
// }

// class ThermalPreview extends InvoicePreviewType {
//   final ThermalPrintInvoiceData printData;
//   final bool isSale;
//   ThermalPreview(this.printData, {this.isSale = false}) : super._();
// }

// class PdfPreview extends InvoicePreviewType {
//   PdfPreview() : super._();
// }
