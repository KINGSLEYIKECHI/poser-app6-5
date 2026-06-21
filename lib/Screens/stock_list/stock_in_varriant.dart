import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import '../../constant.dart';
import '../../service/check_user_role_permission_provider.dart';

class StockInVarriantList extends ConsumerStatefulWidget {
  const StockInVarriantList({super.key, required this.product});
  final Product product;

  @override
  ConsumerState<StockInVarriantList> createState() => _StockInBatchListState();
}

class _StockInBatchListState extends ConsumerState<StockInVarriantList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final permissionService = PermissionService(ref);
    final _lang = l.S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_lang.viewStock),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xf0fef0f1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    _buildHeaderText(_lang.batch, 4, theme, TextAlign.start),
                    _buildHeaderText(_lang.stock, 4, theme, TextAlign.center),
                    if (permissionService.hasPermission(Permit.stocksPriceView.value))
                      _buildHeaderText(_lang.cost, 4, theme, TextAlign.center),
                    // _buildHeaderText('Sale', 2, theme, TextAlign.right),
                    _buildHeaderText(_lang.expiry, 4, theme, TextAlign.center),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.product.stocks!.length,
                separatorBuilder: (_, __) => Divider(color: updateBorderColor),
                itemBuilder: (_, index) {
                  final stock = widget.product.stocks![index];
                  bool isExpired = false;

                  if (stock.expireDate != null) {
                    final expiryDate = DateTime.tryParse(stock.expireDate!);
                    if (expiryDate != null && expiryDate.isBefore(now)) {
                      isExpired = true;
                    }
                  }
                  return _buildRow(theme, index, isExpired);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text, int flex, ThemeData theme, TextAlign textAlign) => Expanded(
        flex: flex,
        child: Text(
          text,
          style: theme.textTheme.titleMedium,
          textAlign: textAlign,
        ),
      );

  Widget _buildRow(ThemeData theme, int index, bool isExpired) {
    final permissionService = PermissionService(ref);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          _buildCell(
            widget.product.stocks![index].batchNo ?? 'n/a',
            4,
            theme,
            TextAlign.left,
            isExpired: isExpired,
          ),
          _buildCell(
            widget.product.stocks![index].productStock.toString(),
            4,
            theme,
            TextAlign.center,
            isExpired: isExpired,
          ),
          if (permissionService.hasPermission(Permit.stocksPriceView.value))
            _buildCell(
              widget.product.stocks![index].productPurchasePrice.toString(),
              4,
              theme,
              TextAlign.center,
              isExpired: isExpired,
            ),
          // _buildCell(
          //   widget.product.stocks![index].productSalePrice.toString(),
          //   2,
          //   theme,
          //   TextAlign.end,
          //   isExpired: isExpired,
          // ),
          _buildCell(
            widget.product.stocks![index].expireDate != null
                ? DateFormat('dd MMM yyyy').format(DateTime.parse(widget.product.stocks![index].expireDate.toString()))
                : 'n/a',
            4,
            theme,
            TextAlign.center,
            isExpired: isExpired,
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, int flex, ThemeData theme, TextAlign textAlign, {required bool isExpired}) => Expanded(
      flex: flex,
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isExpired ? Colors.red : null,
        ),
        textAlign: textAlign,
      ));
}

// class StockInBatchList extends StatefulWidget {
//   const StockInBatchList({super.key, required this.product});
//   final ProductModel product;
//
//   @override
//   State<StockInBatchList> createState() => _StockInBatchListState();
// }
//
// class _StockInBatchListState extends State<StockInBatchList> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('View Stock'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Container(
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//           child: Column(
//             children: [
//               _buildHeader(theme),
//               ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: widget.product.stocks!.length,
//                 separatorBuilder: (_, __) => Divider(color: updateBorderColor),
//                 itemBuilder: (_, index) => _buildRow(theme, index),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(ThemeData theme) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: const BoxDecoration(
//           color: Color(0xf0fef0f1),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//         ),
//         child: Row(
//           children: [
//             _buildHeaderText(
//               'Batch',
//               3,
//               theme,
//               TextAlign.left,
//             ),
//             _buildHeaderText(
//               'Stock',
//               3,
//               theme,
//               TextAlign.center,
//             ),
//             _buildHeaderText(
//               'Cost',
//               3,
//               theme,
//               TextAlign.center,
//             ),
//             _buildHeaderText('Sale', 2, theme, TextAlign.right),
//           ],
//         ),
//       );
//
//   Widget _buildHeaderText(String text, int flex, ThemeData theme, TextAlign textAlign) => Expanded(
//         flex: flex,
//         child: Text(
//           text,
//           style: theme.textTheme.titleMedium,
//           textAlign: textAlign,
//         ),
//       );
//
//   Widget _buildRow(ThemeData theme, int index) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         child: Row(
//           children: [
//             _buildCell(widget.product.stocks![index].batchNo ?? 'n/a', 3, theme, TextAlign.left),
//             _buildCell(widget.product.stocks![index].productStock.toString(), 3, theme, TextAlign.center),
//             _buildCell(widget.product.stocks![index].productPurchasePrice.toString(), 3, theme, TextAlign.center),
//             _buildCell(widget.product.stocks![index].productSalePrice.toString(), 2, theme, TextAlign.end),
//           ],
//         ),
//       );
//
//   Widget _buildCell(String text, int flex, ThemeData theme, TextAlign textAlign) => Expanded(
//       flex: flex,
//       child: Text(
//         text,
//         style: theme.textTheme.bodyMedium,
//         textAlign: textAlign,
//       ));
// }
