import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/currency.dart';
import '../../../Provider/product_provider.dart';
import '../../../constant.dart';
import 'combo_product_form.dart';

class AddOrEditComboItem extends ConsumerStatefulWidget {
  final ComboItem? existingItem;
  final Function(ComboItem) onSubmit;

  const AddOrEditComboItem({
    super.key,
    this.existingItem,
    required this.onSubmit,
  });

  @override
  ConsumerState<AddOrEditComboItem> createState() => _AddOrEditComboItemPopupState();
}

class _AddOrEditComboItemPopupState extends ConsumerState<AddOrEditComboItem> {
  Product? selectedProduct;
  Stock? selectedStock;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      selectedProduct = item.product;
      selectedStock = item.stockData;

      if (item.product.productType == 'variant' && selectedStock != null) {
        searchController.text = "${item.product.productName} - ${selectedStock?.variantName}";
      } else {
        searchController.text = item.product.productName ?? '';
      }

      qtyController.text = item.quantity.toString();
      unitController.text = item.product.unit?.unitName ?? 'Pcs';

      priceController.text = (item.manualPurchasePrice ?? selectedStock?.productPurchasePrice ?? 0).toString();

      _calculateTotal();
    }

    // if (widget.existingItem != null) {
    //   // Load existing data for Edit Mode
    //   final item = widget.existingItem!;
    //   selectedProduct = item.product;
    //   selectedStock = item.stockData;
    //   searchController.text = item.product.productName ?? '';
    //   qtyController.text = item.quantity.toString();
    //   unitController.text = item.product.unit?.unitName ?? 'Pcs';
    //   priceController.text = item.purchasePrice.toString();
    //   _calculateTotal();
    // } else {
    //   // Add Mode Defaults
    //   qtyController.text = '1';
    //   unitController.text = 'Pcs';
    // }
  }

  void _calculateTotal() {
    double qty = double.tryParse(qtyController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    totalController.text = (qty * price).toStringAsFixed(2);
  }

  late var _searchController = TextEditingController();
  // Product? selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productProvider);
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.existingItem == null ? _lang.addProduct : _lang.editProduct,
          style: _theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              size: 22,
              color: kPeraColor,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: kBottomBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.existingItem == null) ...[
              // --------------use typehead---------------------
              productListAsync.when(
                data: (products) {
                  // Filter out combos
                  final filteredProducts = products.where((p) => p.productType != 'combo').toList();

                  return TypeAheadField<Map<String, dynamic>>(
                    emptyBuilder: (context) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_lang.noItemFound),
                    ),
                    builder: (context, controller, focusNode) {
                      _searchController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          prefixIcon: Icon(AntDesign.search_outline, color: kGreyTextColor),
                          hintText: selectedProduct != null ? selectedProduct?.productName : _lang.searchProduct,
                          suffixIcon: IconButton(
                            onPressed: () {
                              controller.clear();
                              selectedProduct = null;
                              selectedStock = null;
                              setState(() {});
                            },
                            icon: Icon(Icons.close, color: kSubPeraColor),
                          ),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) {
                      final query = pattern.toLowerCase().trim();
                      final List<Map<String, dynamic>> suggestions = [];

                      for (var product in filteredProducts) {
                        // Skip combo products (already filtered above)
                        if (product.productType != 'variant') {
                          final productName = (product.productName ?? '').toLowerCase();
                          if (query.isEmpty || productName.contains(query)) {
                            suggestions.add({'type': 'single', 'product': product});
                          }
                          continue;
                        }

                        // Variant product
                        bool headerAdded = false;
                        final parentName = (product.productName ?? '').toLowerCase();

                        for (var s in product.stocks ?? []) {
                          final variantName = (s.variantName ?? '').toLowerCase();

                          // Combine parent name + variant name for searching
                          final combinedName = '$parentName $variantName';

                          if (query.isEmpty || combinedName.contains(query)) {
                            if (!headerAdded) {
                              suggestions.add({'type': 'header', 'product': product});
                              headerAdded = true;
                            }
                            suggestions.add({
                              'type': 'variant',
                              'product': product,
                              'stock': s,
                            });
                          }
                        }
                      }

                      return suggestions;
                    },
                    // suggestionsCallback: (pattern) {
                    //   final query = pattern.toLowerCase().trim();
                    //   final List<Map<String, dynamic>> suggestions = [];
                    //
                    //   for (var product in filteredProducts) {
                    //     if (product.productType != 'variant') {
                    //       // Single product is selectable
                    //       final productName = (product.productName ?? '').toLowerCase();
                    //       if (query.isEmpty || productName.contains(query)) {
                    //         suggestions.add({'type': 'single', 'product': product});
                    //       }
                    //       continue;
                    //     }
                    //
                    //     // Variant parent is only a header
                    //     bool headerAdded = false;
                    //
                    //     // Check if parent name matches
                    //     final productName = (product.productName ?? '').toLowerCase();
                    //     if (query.isEmpty || productName.contains(query)) {
                    //       suggestions.add({'type': 'header', 'product': product});
                    //       headerAdded = true;
                    //     }
                    //
                    //     // Check variant names
                    //     for (var s in product.stocks ?? []) {
                    //       final variantName = (s.variantName ?? '').toLowerCase();
                    //       if (query.isEmpty || variantName.contains(query)) {
                    //         if (!headerAdded) {
                    //           suggestions.add({'type': 'header', 'product': product});
                    //           headerAdded = true;
                    //         }
                    //         suggestions.add({
                    //           'type': 'variant',
                    //           'product': product,
                    //           'stock': s,
                    //         });
                    //       }
                    //     }
                    //   }
                    //
                    //   return suggestions;
                    // },
                    itemBuilder: (context, suggestion) {
                      final type = suggestion['type'] as String;

                      if (type == 'header') {
                        final p = suggestion['product'] as Product;
                        return InkWell(
                          onTap: () {
                            // Just close the suggestion box without selecting anything
                            FocusScope.of(context).unfocus();
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            leading: Icon(Icons.circle, color: Colors.black, size: 10),
                            title: Text(
                              p.productName ?? '',
                              style: _theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }

                      if (type == 'variant') {
                        final product = suggestion['product'] as Product;
                        final stock = suggestion['stock'] as Stock;
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          leading: Icon(Icons.subdirectory_arrow_right, color: Colors.grey, size: 18),
                          title: Text("${product.productName} (${stock.variantName ?? 'n/a'})"),
                          subtitle: Text(
                              '${_lang.stock}: ${stock.productStock}, ${_lang.price}: $currency${stock.productPurchasePrice}, ${_lang.batch}: ${stock.batchNo}'),
                        );
                      }

                      // single product
                      final product = suggestion['product'] as Product;
                      return ListTile(
                        title: Text(product.productName ?? ''),
                        subtitle: Text(
                            '${_lang.stock}: ${product.stocksSumProductStock ?? 0}, ${_lang.price}: $currency${product.productPurchasePrice}'),
                      );
                    },
                    onSelected: (suggestion) {
                      final type = suggestion['type'] as String;

                      if (type == 'variant' || type == 'single') {
                        final product = suggestion['product'] as Product;

                        setState(() {
                          selectedProduct = product;

                          if (type == 'variant') {
                            selectedStock = suggestion['stock'] as Stock;
                          } else {
                            selectedStock = product.stocks?.isNotEmpty == true ? product.stocks!.first : null;
                          }

                          _searchController.text = type == 'variant'
                              ? "${product.productName} - ${selectedStock?.variantName}"
                              : product.productName ?? '';

                          unitController.text = product.unit?.unitName ?? 'Pcs';
                          priceController.text = (selectedStock?.productPurchasePrice ?? 0).toStringAsFixed(2);

                          _calculateTotal();
                        });
                      }
                    },
                  );
                },
                loading: () => LinearProgressIndicator(),
                error: (e, _) => Text("Error: $e"),
              ),
              // productListAsync.when(
              //   data: (products) {
              //     final List<Product> filteredProducts = products.where((p) => p.productType != 'combo').toList();
              //
              //     return TypeAheadField<Map<String, dynamic>>(
              //       emptyBuilder: (context) => Padding(
              //         padding: const EdgeInsets.all(12),
              //         child: Text("No item found"),
              //       ),
              //       builder: (context, controller, focusNode) {
              //         _searchController = controller;
              //         return TextField(
              //           controller: controller,
              //           focusNode: focusNode,
              //           decoration: InputDecoration(
              //             prefixIcon: Icon(AntDesign.search_outline, color: kGreyTextColor),
              //             hintText: selectedProduct != null ? selectedProduct?.productName : 'Search product',
              //             suffixIcon: IconButton(
              //               onPressed: () {
              //                 controller.clear();
              //                 selectedProduct = null;
              //                 selectedStock = null;
              //                 setState(() {});
              //               },
              //               icon: Icon(Icons.close, color: kSubPeraColor),
              //             ),
              //           ),
              //         );
              //       },
              //       suggestionsCallback: (pattern) {
              //         final query = pattern.toLowerCase().trim();
              //         final List<Map<String, dynamic>> suggestions = [];
              //
              //         for (var product in filteredProducts) {
              //           final productName = (product.productName ?? '').toLowerCase();
              //           if (product.productType != 'variant') {
              //             if (query.isEmpty || productName.contains(query)) {
              //               suggestions.add({'type': 'single', 'product': product});
              //             }
              //             continue;
              //           }
              //
              //           bool headerAdded = false;
              //
              //           if (query.isEmpty) {
              //             suggestions.add({'type': 'header', 'product': product});
              //             headerAdded = true;
              //
              //             for (var s in product.stocks ?? []) {
              //               suggestions.add({
              //                 'type': 'variant',
              //                 'product': product,
              //                 'stock': s,
              //               });
              //             }
              //             continue;
              //           }
              //
              //           if (productName.contains(query)) {
              //             suggestions.add({'type': 'header', 'product': product});
              //             headerAdded = true;
              //           }
              //
              //           for (var s in product.stocks ?? []) {
              //             final variantName = (s.variantName ?? '').toLowerCase();
              //
              //             if (variantName.contains(query)) {
              //               if (!headerAdded) {
              //                 // Only add header once
              //                 suggestions.add({'type': 'header', 'product': product});
              //                 headerAdded = true;
              //               }
              //
              //               suggestions.add({
              //                 'type': 'variant',
              //                 'product': product,
              //                 'stock': s,
              //               });
              //             }
              //           }
              //         }
              //
              //         return suggestions;
              //       },
              //       itemBuilder: (context, suggestion) {
              //         final type = suggestion['type'] as String;
              //         if (type == 'header') {
              //           final p = suggestion['product'] as Product;
              //           return ListTile(
              //             contentPadding: EdgeInsets.symmetric(horizontal: 10),
              //             visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              //             leading: Icon(Icons.circle, color: Colors.black, size: 10),
              //             title: Text(
              //               p.productName ?? '',
              //               style: _theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              //             ),
              //             // header is not selectable, so we make it visually disabled
              //             enabled: false,
              //           );
              //         }
              //
              //         if (type == 'variant') {
              //           final product = suggestion['product'] as Product;
              //           final stock = suggestion['stock'] as Stock;
              //           return ListTile(
              //             contentPadding: EdgeInsets.symmetric(horizontal: 10),
              //             visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              //             leading: Icon(Icons.subdirectory_arrow_right, color: Colors.grey, size: 18),
              //             title: Text("${product.productName} (${stock.variantName ?? 'n/a'})"),
              //             subtitle: Text('Stock: ${stock.productStock}, Price: $currency${stock.productPurchasePrice}, Batch: ${stock.batchNo}'),
              //           );
              //         }
              //
              //         // single product
              //         final product = suggestion['product'] as Product;
              //         return ListTile(
              //           title: Text(product.productName ?? ''),
              //           subtitle: Text('Stock: ${product.stocksSumProductStock ?? 0}, Price: $currency${product.productPurchasePrice}'),
              //         );
              //       },
              //       onSelected: (suggestion) {
              //         final type = suggestion['type'] as String;
              //         // Only allow single or variant selection
              //         if (type == 'single' || type == 'variant') {
              //           final product = suggestion['product'] as Product;
              //           setState(() {
              //             selectedProduct = product;
              //
              //             if (type == 'variant') {
              //               selectedStock = suggestion['stock'] as Stock;
              //             } else {
              //               selectedStock = product.stocks?.isNotEmpty == true ? product.stocks!.first : null;
              //             }
              //
              //             // Update search field
              //             _searchController.text = type == 'variant' ? "${product.productName} - ${selectedStock?.variantName}" : product.productName ?? '';
              //
              //             // Update unit field
              //             unitController.text = product.unit?.unitName ?? 'Pcs';
              //
              //             // Update price field
              //             priceController.text = (selectedStock?.productPurchasePrice ?? 0).toStringAsFixed(2);
              //
              //             // Recalculate total
              //             _calculateTotal();
              //           });
              //         }
              //       },
              //     );
              //   },
              //   loading: () => LinearProgressIndicator(),
              //   error: (e, _) => Text("Error: $e"),
              // ),
              // --------------use typehead---------------------
            ] else ...[
              TextFormField(
                controller: searchController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: _lang.product,
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
            ],

            // --------previous code-----------------
            // if (widget.existingItem == null) ...[
            //   // --------------use typehead---------------------
            //   productListAsync.when(
            //     data: (products) {
            //       // Filter out combo products
            //       final filteredProducts = products.where((p) => p.productType != 'combo').toList();
            //
            //       return TypeAheadField<Map<String, dynamic>>(
            //         builder: (context, controller, focusNode) {
            //           return TextField(
            //             controller: _searchController,
            //             focusNode: focusNode,
            //             decoration: InputDecoration(
            //               prefixIcon: Icon(AntDesign.search_outline, color: kGreyTextColor),
            //               hintText: selectedProduct != null ? selectedProduct?.productName : 'Search product',
            //               suffixIcon: IconButton(
            //                 onPressed: () {
            //                   _searchController.clear();
            //                   selectedProduct = null;
            //                   setState(() {});
            //                 },
            //                 icon: Icon(Icons.close, color: kSubPeraColor),
            //               ),
            //             ),
            //           );
            //         },
            //         suggestionsCallback: (pattern) {
            //           final List<Map<String, dynamic>> suggestions = [];
            //
            //           for (var product in filteredProducts) {
            //             if (product.productType == 'variant') {
            //               // Show parent product as a header if it matches the search
            //               if ((product.productName ?? '').toLowerCase().contains(pattern.toLowerCase())) {
            //                 suggestions.add({'type': 'header', 'product': product});
            //               }
            //
            //               // Show variant stocks
            //               for (var stock in product.stocks ?? []) {
            //                 if ((stock.variantName ?? '').toLowerCase().contains(pattern.toLowerCase())) {
            //                   suggestions.add({'type': 'variant', 'product': product, 'stock': stock});
            //                 }
            //               }
            //             } else {
            //               // Single product
            //               if ((product.productName ?? '').toLowerCase().contains(pattern.toLowerCase())) {
            //                 suggestions.add({'type': 'single', 'product': product});
            //               }
            //             }
            //           }
            //
            //           return suggestions;
            //         },
            //         itemBuilder: (context, suggestion) {
            //           final type = suggestion['type'] as String;
            //           if (type == 'header') {
            //             final product = suggestion['product'] as Product;
            //             return ListTile(
            //               contentPadding: EdgeInsets.symmetric(horizontal: 10),
            //               visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            //               leading: Icon(
            //                 Icons.circle,
            //                 color: Colors.black,
            //                 size: 10,
            //               ),
            //               title: Text(
            //                 product.productName ?? '',
            //                 style: _theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            //               ),
            //             );
            //           } else if (type == 'variant') {
            //             final product = suggestion['product'] as Product;
            //             final stock = suggestion['stock'] as Stock;
            //             return ListTile(
            //               contentPadding: EdgeInsets.symmetric(horizontal: 10),
            //               visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            //               leading: Icon(Icons.subdirectory_arrow_right, color: Colors.grey, size: 18),
            //               title: Text("${product.productName} (${stock.variantName ?? 'n/a'})"),
            //               subtitle: Text('Stock: ${stock.productStock}, Price: $currency${stock.productPurchasePrice}, Batch: ${stock.batchNo}'),
            //             );
            //           } else {
            //             final product = suggestion['product'] as Product;
            //             return ListTile(
            //               title: Text(product.productName ?? ''),
            //               subtitle: Text('Stock: ${product.stocksSumProductStock ?? 0}, Price: $currency${product.productPurchasePrice}'),
            //             );
            //           }
            //         },
            //         onSelected: (suggestion) {
            //           setState(() {
            //             final type = suggestion['type'] as String;
            //             final product = suggestion['product'] as Product;
            //
            //             selectedProduct = product;
            //
            //             if (type == 'variant') {
            //               selectedStock = suggestion['stock'] as Stock;
            //             } else {
            //               selectedStock = product.stocks != null && product.stocks!.isNotEmpty ? product.stocks!.first : null;
            //             }
            //
            //             _searchController.text = type == 'variant' ? "${product.productName} - ${selectedStock?.variantName}" : product.productName ?? '';
            //
            //             unitController.text = product.unit?.unitName ?? 'Pcs';
            //             priceController.text = (selectedStock?.productPurchasePrice ?? 0).toString();
            //             _calculateTotal();
            //           });
            //
            //           FocusScope.of(context).unfocus();
            //         },
            //       );
            //     },
            //     loading: () => const Center(child: LinearProgressIndicator()),
            //     error: (e, stack) => Text('Error: $e'),
            //   ),
            //   // --------------use typehead---------------------
            // ] else ...[
            //   TextFormField(
            //     controller: searchController,
            //     readOnly: true,
            //     decoration: const InputDecoration(
            //       labelText: 'Product',
            //       border: OutlineInputBorder(),
            //       filled: true,
            //       fillColor: Color(0xFFF5F5F5),
            //     ),
            //   ),
            // ],
            SizedBox(height: 20),
            // --- Row 1: Quantity & Units ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: _lang.quantity,
                      hintText: 'Ex: 1',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: unitController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _lang.units,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Row 2: Purchase Price & Total ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _lang.purchasePrice,
                      hintText: 'Ex: 20',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: totalController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _lang.total,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: DAppColors.kWarning),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  _lang.cancel,
                  style: TextStyle(
                    color: DAppColors.kWarning,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // minimumSize: Size.fromHeight(48),
                  backgroundColor: const Color(0xFFB71C1C), // Red color
                ),
                onPressed: () {
                  if (selectedProduct != null && selectedStock != null) {
                    final newItem = ComboItem(
                      product: selectedProduct!,
                      stockData: selectedStock!,
                      quantity: int.tryParse(qtyController.text) ?? 1,
                      manualPurchasePrice: double.tryParse(priceController.text),
                    );
                    widget.onSubmit(newItem);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("Please select a product")));
                  }
                },
                child: Text(_lang.save, style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
