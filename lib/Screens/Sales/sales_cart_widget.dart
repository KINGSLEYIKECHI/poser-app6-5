import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/Sales/provider/sales_cart_provider.dart';
import 'package:mobile_pos/Screens/Sales/sales_add_to_cart_sales_widget.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class SalesCartListWidget extends ConsumerWidget {
  const SalesCartListWidget({super.key});

  // --- Helper Method for Floating-Point Precision Fix ---
  double _round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerData = ref.watch(cartNotifier);
    final s = lang.S.of(context);
    final theme = Theme.of(context);

    if (providerData.cartItemList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          collapsedBackgroundColor: kMainColor2,
          backgroundColor: kMainColor2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: kLineColor,
              width: 1,
            ),
          ),
          title: Text(
            lang.S.of(context).itemAdded,
            style: theme.textTheme.titleMedium,
          ),
          children: [
            Container(
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: providerData.cartItemList.length,
                itemBuilder: (context, index) {
                  final item = providerData.cartItemList[index];

                  // Check if item has serial numbers
                  final bool hasSerial = item.serialNumber != null && item.serialNumber!.isNotEmpty;

                  // --- Calculate values with Rounding Fix ---
                  final double quantity = item.quantity.toDouble();
                  final double unitPrice = _round((item.unitPrice ?? 0).toDouble());
                  final double discountPerUnit = _round((item.discountAmount ?? 0).toDouble());

                  final double totalDiscount = _round(quantity * discountPerUnit);
                  final double subTotal = _round(quantity * unitPrice);
                  final double finalTotal = _round(subTotal - totalDiscount);

                  return ListTile(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                    onTap: () => showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context2) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    s.updateProduct,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const CloseButton()
                                ],
                              ),
                            ),
                            const Divider(thickness: 1, color: kBorderColorTextField),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SalesAddToCartForm(
                                itemIndex: index, // --- Added this line ---
                                batchWiseStockModel: item,
                                previousContext: context2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    title: Text(
                      item.productName.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              // Qty X Price
                              TextSpan(
                                text: '${formatPointNumber(quantity)} X ${formatPointNumber(unitPrice)} ',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: kPeraColor,
                                ),
                              ),
                              // Show Discount if exists
                              if (totalDiscount > 0)
                                TextSpan(
                                  text: '- ${formatPointNumber(totalDiscount)} (Disc) ',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: kPeraColor,
                                  ),
                                ),
                              // Final Total
                              TextSpan(
                                text: '= ${formatPointNumber(finalTotal)} ',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: kTitleColor,
                                ),
                              ),
                              // Batch Info
                              if (item.productType == 'variant')
                                TextSpan(
                                  text: '[${item.batchName}]',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ),
                        // Display Serial Numbers if present
                        if (hasSerial)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Serial: ${item.serialNumber!.join(", ")}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Decrease Button
                              GestureDetector(
                                onTap: hasSerial
                                    ? () {
                                        EasyLoading.showInfo("Modify serials to change quantity");
                                      }
                                    : () => providerData.quantityDecrease(index),
                                child: Container(
                                  height: 18,
                                  width: 18,
                                  decoration: BoxDecoration(
                                    color: hasSerial ? Colors.grey : kMainColor,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.remove, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),

                              // Quantity Text
                              SizedBox(
                                width: 40,
                                child: Center(
                                  child: Text(
                                    formatPointNumber(item.quantity),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: kGreyTextColor,
                                        ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Increase Button
                              GestureDetector(
                                onTap: hasSerial
                                    ? () {
                                        EasyLoading.showInfo("Modify serials to change quantity");
                                      }
                                    : () => providerData.quantityIncrease(index),
                                child: Container(
                                  height: 18,
                                  width: 18,
                                  decoration: BoxDecoration(
                                    color: hasSerial ? Colors.grey : kMainColor,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Delete Button
                        GestureDetector(
                          onTap: () => providerData.deleteToCart(index),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete03,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
