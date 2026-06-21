import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/invoice_constant.dart' hide kMainColor;
import '../../../Provider/product_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'add_edit_comboItem.dart';
import 'modle/create_product_model.dart';

// Updated Helper Model to support manual price override
class ComboItem {
  final Product product;
  final Stock stockData;
  int quantity;
  double? manualPurchasePrice; // Added this field

  ComboItem({
    required this.product,
    required this.stockData,
    this.quantity = 1,
    this.manualPurchasePrice,
  });

  // Use manual price if set, otherwise stock price
  double get purchasePrice => manualPurchasePrice ?? (stockData.productPurchasePrice ?? 0).toDouble();
  double get totalAmount => purchasePrice * quantity;
}

class ComboProductForm extends ConsumerStatefulWidget {
  final TextEditingController profitController;
  final TextEditingController saleController;
  final TextEditingController purchasePriceController;
  final List<ComboProductModel>? initialComboList;
  final Function(List<ComboProductModel>) onComboListChanged;

  const ComboProductForm({
    super.key,
    required this.profitController,
    required this.saleController,
    required this.purchasePriceController,
    this.initialComboList,
    required this.onComboListChanged,
  });

  @override
  ConsumerState<ComboProductForm> createState() => _ComboProductFormState();
}

class _ComboProductFormState extends ConsumerState<ComboProductForm> {
  List<ComboItem> selectedComboItems = [];
  bool _isDataLoaded = false;

  // --- Calculation Logic (Same as before) ---
  void _calculateValues({String? source}) {
    double totalPurchase = 0;
    for (var item in selectedComboItems) {
      totalPurchase += item.totalAmount;
    }

    if (widget.purchasePriceController.text != totalPurchase.toStringAsFixed(2)) {
      widget.purchasePriceController.text = totalPurchase.toStringAsFixed(2);
    }

    double purchase = totalPurchase;
    double profit = double.tryParse(widget.profitController.text) ?? 0;
    double sale = double.tryParse(widget.saleController.text) ?? 0;

    if (source == 'margin') {
      sale = purchase + (purchase * profit / 100);
      widget.saleController.text = sale.toStringAsFixed(2);
    } else if (source == 'sale') {
      if (purchase > 0) {
        profit = ((sale - purchase) / purchase) * 100;
        widget.profitController.text = profit.toStringAsFixed(2);
      }
    } else {
      sale = purchase + (purchase * profit / 100);
      widget.saleController.text = sale.toStringAsFixed(2);
    }

    List<ComboProductModel> finalApiList = selectedComboItems.map((item) {
      return ComboProductModel(
        stockId: item.stockData.id.toString(),
        quantity: item.quantity.toString(),
        purchasePrice: item.purchasePrice.toString(),
      );
    }).toList();

    widget.onComboListChanged(finalApiList);
  }

  // --- Open the Popup for Add or Edit ---
  void openProductForm({ComboItem? item, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrEditComboItem(
          existingItem: item,
          onSubmit: (newItem) {
            setState(() {
              if (index != null) {
                // Edit Mode: Replace item
                selectedComboItems[index] = newItem;
              } else {
                // Add Mode: Check duplicate or add new
                bool exists = false;
                for (int i = 0; i < selectedComboItems.length; i++) {
                  if (selectedComboItems[i].stockData.id == newItem.stockData.id) {
                    // If same product exists, just update that entry
                    selectedComboItems[i] = newItem;
                    exists = true;
                    break;
                  }
                }
                if (!exists) selectedComboItems.add(newItem);
              }
              _calculateValues(source: 'item_updated');
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productProvider);
    final _theme = Theme.of(context);

    // Load Initial Data Logic
    productListAsync.whenData((products) {
      if (!_isDataLoaded && widget.initialComboList != null && widget.initialComboList!.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          List<ComboItem> tempLoadedItems = [];
          for (var initialItem in widget.initialComboList!) {
            for (var product in products) {
              if (product.stocks != null) {
                try {
                  var matchingStock =
                      product.stocks!.firstWhere((s) => s.id.toString() == initialItem.stockId.toString());
                  tempLoadedItems.add(ComboItem(
                    product: product,
                    stockData: matchingStock,
                    quantity: int.tryParse(initialItem.quantity.toString()) ?? 1,
                    manualPurchasePrice: double.tryParse(initialItem.purchasePrice.toString()),
                  ));
                  break;
                } catch (_) {}
              }
            }
          }
          if (mounted) {
            setState(() {
              selectedComboItems = tempLoadedItems;
              _isDataLoaded = true;
            });
            _calculateValues(source: 'init');
          }
        });
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Add Product Button
        ElevatedButton(
          onPressed: () => openProductForm(),
          style: ElevatedButton.styleFrom(
            backgroundColor: kMainColor50, // Light reddish background
            minimumSize: Size(131, 36),
            elevation: 0,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          child: Text(
            "+ ${l.S.of(context).addProduct}",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: kMainColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),

        // 2. List of Items (Matching Screenshot 1)
        if (selectedComboItems.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: selectedComboItems.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: kLineColor,
            ),
            itemBuilder: (context, index) {
              final item = selectedComboItems[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -4, vertical: 0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.product.productType == 'single'
                            ? item.product.productName ?? 'n/a'
                            : ('${item.product.productName ?? ''} (${item.product.stocks?[index].variantName ?? 'n/a'})'),
                        style: _theme.textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${l.S.of(context).qty}: ${item.quantity}',
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        color: kPeraColor,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${l.S.of(context).code} : ${item.product.productCode ?? 'n/a'}, ${l.S.of(context).batchNo}: ${item.stockData.batchNo ?? 'n/a'}',
                        style: _theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$currency${item.totalAmount ?? 'n/a'}',
                      style: _theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 30,
                  child: PopupMenuButton<String>(
                    iconColor: kPeraColor,
                    onSelected: (value) {
                      if (value == 'edit') {
                        openProductForm(item: item, index: index);
                      } else if (value == 'delete') {
                        setState(() {
                          selectedComboItems.removeAt(index);
                          _calculateValues(source: 'item_removed');
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(value: 'edit', child: Text(l.S.of(context).edit)),
                      PopupMenuItem(
                          value: 'delete', child: Text(l.S.of(context).delete, style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              );
            },
          ),

        if (selectedComboItems.isNotEmpty)
          const Divider(
            height: 1,
            color: kLineColor,
          ),
        SizedBox(height: 13),
        // 3. Footer: Net Total, Profit, Sale Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${l.S.of(context).netTotalAmount}:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("\$${widget.purchasePriceController.text}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.profitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${l.S.of(context).profitMargin} (%)',
                  hintText: 'Ex: 25%',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) => _calculateValues(source: 'margin'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: widget.saleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l.S.of(context).defaultSellingPrice,
                  hintText: 'Ex: 150',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) => _calculateValues(source: 'sale'),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
