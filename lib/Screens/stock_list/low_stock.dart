import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/Products/Providers/product_provider.dart' hide productProvider;
import 'package:mobile_pos/Screens/stock_list/stock_in_varriant.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/stock_report_pdf/stock_report_pdf.dart';
import 'package:mobile_pos/widgets/empty_widget/_empty_widget.dart';
import '../../Provider/product_provider.dart';
import '../../currency.dart';

class LowStock extends ConsumerStatefulWidget {
  const LowStock({super.key, required this.isFromReport});

  final bool isFromReport;

  @override
  ConsumerState createState() => StockListState();
}

class StockListState extends ConsumerState<LowStock> {
  String productSearch = '';
  bool _isRefreshing = false;
  // String selectedFilter = 'Low Stock';
  String selectedExpireFilter = '7 Days';

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    ref.refresh(productProvider);
    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  final _horizontalScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(productProvider);
      final totalStockValueProvider = ref.watch(productListProvider);
      final businessData = ref.watch(businessInfoProvider);
      return totalStockValueProvider.when(
          data: (stockValue) {
            return businessData.when(data: (business) {
              return providerData.when(
                data: (product) {
                  List<Product> showableProducts = [];
                  double totalStockValue = 0;

                  for (var element in product) {
                    if (element.productType == 'combo') continue;

                    final searchMatch = element.productName!.toLowerCase().contains(productSearch.toLowerCase().trim());
                    if (!searchMatch) continue;

                    final qty = element.stocksSumProductStock ?? 0;
                    final alertQty = element.alertQty ?? 0;
                    final isLowStock = qty <= alertQty;

                    if (isLowStock) {
                      showableProducts.add(element);

                      final lastStock =
                          (element.stocks != null && element.stocks!.isNotEmpty) ? element.stocks!.last : null;

                      final purchasePrice = lastStock?.productPurchasePrice ?? element.productPurchasePrice ?? 0;

                      totalStockValue += purchasePrice * qty;
                    }
                  }

                  return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(lang.S.of(context).lowStock),
                      backgroundColor: Colors.white,
                      elevation: 0.0,
                      actions: [
                        IconButton(
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (showableProducts.isNotEmpty) {
                              generateStockReportPdf(context, showableProducts, business, stockValue, true);
                            } else {
                              EasyLoading.showError(lang.S.of(context).genPdfWarn);
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedPdf01,
                            color: kSecondayColor,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      toolbarHeight: 100,
                      bottom: PreferredSize(
                        preferredSize: const Size(double.infinity, 40),
                        child: Column(
                          children: [
                            Container(
                              color: updateBorderColor.withValues(alpha: 0.5),
                              width: double.infinity,
                              height: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    productSearch = value;
                                  });
                                },
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: updateBorderColor, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.red, width: 1),
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        FeatherIcons.search,
                                        color: kNeutralColor,
                                      ),
                                    ),
                                    hintText: lang.S.of(context).searchH,
                                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: kNeutralColor,
                                        )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () => refreshData(ref),
                        child: Column(
                          children: [
                            showableProducts.isNotEmpty
                                ? LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                      final kWidth = constraints.maxWidth;
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _horizontalScroll,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: kWidth),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              dividerTheme: const DividerThemeData(color: Colors.transparent),
                                              checkboxTheme: CheckboxThemeData(),
                                            ),
                                            child: DataTable(
                                              border: const TableBorder(
                                                horizontalInside: BorderSide(
                                                  width: 1,
                                                  color: updateBorderColor,
                                                ),
                                              ),
                                              dataRowColor: const WidgetStatePropertyAll(Colors.white),
                                              headingRowColor: WidgetStateProperty.all(const Color(0xffFEF0F1)),
                                              showBottomBorder: false,
                                              dividerThickness: 0.0,
                                              headingTextStyle: theme.textTheme.titleSmall,
                                              dataTextStyle: theme.textTheme.bodyMedium,
                                              columnSpacing: 20.0,
                                              headingRowHeight: 40,
                                              dataRowMinHeight: 40,
                                              columns: [
                                                DataColumn(label: Text(lang.S.of(context).product)),
                                                DataColumn(label: Text(lang.S.of(context).qty)),
                                                DataColumn(label: Text(lang.S.of(context).cost)),
                                                DataColumn(label: Text(lang.S.of(context).sale)),
                                              ],
                                              rows: showableProducts.asMap().entries.map((entry) {
                                                final product = entry.value;
                                                final lastStock =
                                                    product.stocks?.isNotEmpty == true ? product.stocks?.last : null;
                                                bool isLowStock =
                                                    (product.stocksSumProductStock ?? 0) <= (product.alertQty ?? 0);

                                                // Find the first expired stock (if any)
                                                Stock? expiredStock;
                                                if (product.stocks != null) {
                                                  for (final stock in product.stocks!) {
                                                    if (stock.expireDate != null) {
                                                      final expiryDate = DateTime.tryParse(stock.expireDate!);
                                                      if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
                                                        expiredStock = stock;
                                                        break;
                                                      }
                                                    }
                                                  }
                                                }
                                                bool isExpired = expiredStock != null;

                                                void navigateNextScreen() {
                                                  if (product.productType == "variant" &&
                                                      product.stocks?.isNotEmpty == true) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => StockInVarriantList(product: product),
                                                      ),
                                                    );
                                                  }
                                                }

                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                        onTap: () => navigateNextScreen(),
                                                        SizedBox(
                                                          width: 150,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                product.productName ?? 'N/A',
                                                                style: theme.textTheme.bodyMedium,
                                                                textAlign: TextAlign.start,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              if (isExpired) SizedBox(height: 1),
                                                              if (isExpired)
                                                                Text.rich(
                                                                  TextSpan(
                                                                      text: '${lang.S.of(context).expired}: ',
                                                                      children: [
                                                                        TextSpan(
                                                                            text: DateFormat('dd MMM yyyy').format(
                                                                                DateTime.parse(expiredStock.expireDate
                                                                                    .toString())),
                                                                            style: TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: 12,
                                                                            ))
                                                                      ]),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: theme.textTheme.bodySmall,
                                                                )
                                                            ],
                                                          ),
                                                        )),
                                                    DataCell(
                                                        onTap: () => navigateNextScreen(),
                                                        Text(
                                                          "${product.stocksSumProductStock ?? 0}",
                                                        )),
                                                    DataCell(
                                                        onTap: () => navigateNextScreen(),
                                                        Text(
                                                            '$currency${formatPointNumber(lastStock?.productPurchasePrice ?? 0)}',
                                                            style: theme.textTheme.bodyMedium?.copyWith())),
                                                    DataCell(
                                                        onTap: () => navigateNextScreen(),
                                                        Text(
                                                          '$currency${formatPointNumber(lastStock?.productSalePrice ?? 0)}',
                                                        )),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : EmptyWidget(
                                    message: TextSpan(text: lang.S.of(context).noProductFound),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    bottomNavigationBar: Container(
                      color: const Color(0xffFEF0F1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang.S.of(context).stockValue,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$currency${formatPointNumber(totalStockValue)}',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                error: (e, stack) => Center(child: Text("Error: $e")),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            }, error: (e, stack) {
              return Text(e.toString());
            }, loading: () {
              return Center(child: CircularProgressIndicator());
            });
          },
          error: (e, stack) => Center(
                child: Text(e.toString()),
              ),
          loading: () {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    });
  }
}
