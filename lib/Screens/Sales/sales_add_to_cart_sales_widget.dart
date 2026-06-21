import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Sales/provider/sales_cart_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/Screens/Sales/model/sale_add_to_cart_model.dart';
import 'package:nb_utils/nb_utils.dart'; // For styles

import '../../constant.dart';

class SalesAddToCartForm extends StatefulWidget {
  const SalesAddToCartForm({
    super.key,
    required this.batchWiseStockModel,
    required this.previousContext,
    required this.itemIndex, // Added this
  });

  final SaleCartModel batchWiseStockModel;
  final BuildContext previousContext;
  final int itemIndex; // Added this

  @override
  ProductAddToCartFormState createState() => ProductAddToCartFormState();
}

class ProductAddToCartFormState extends State<SalesAddToCartForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController productQuantityController;
  late TextEditingController discountController;
  late TextEditingController salePriceController;

  // Serial Management
  List<String> _selectedSerials = [];
  bool _hasSerial = false;

  bool isClicked = false;

  @override
  void initState() {
    super.initState();

    // --- 1. Serial Initialization ---
    if (widget.batchWiseStockModel.serialNumber != null && widget.batchWiseStockModel.serialNumber!.isNotEmpty) {
      _hasSerial = true;
      _selectedSerials = List.from(widget.batchWiseStockModel.serialNumber!);
    }

    // Initialize controllers with existing data
    salePriceController = TextEditingController(
      text: widget.batchWiseStockModel.unitPrice.toString(),
    );
    // Note: Quantity text is set here based on _hasSerial,
    // but ReadOnly/Editable behavior will be controlled in build method based on Addon status.
    productQuantityController = TextEditingController(
      text: formatPointNumber(widget.batchWiseStockModel.quantity),
    );
    discountController = TextEditingController(
      text: widget.batchWiseStockModel.discountAmount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    productQuantityController.dispose();
    discountController.dispose();
    salePriceController.dispose();
    super.dispose();
  }

  // --- Serial Remove Function ---
  void _removeSerial(String serial) {
    setState(() {
      _selectedSerials.remove(serial);
      productQuantityController.text = _selectedSerials.length.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final lang = l.S.of(context);

      // --- 2. Check Addon Status ---
      final businessInfo = ref.watch(businessInfoProvider);
      final bool serialAddonEnabled = businessInfo.value?.data?.addons?.serialCodeAddon ?? false;

      // --- 3. Determine if Serial Logic Should be Active ---
      final bool isSerialActive = _hasSerial && serialAddonEnabled;

      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Quantity and Price Row ---
            Row(
              children: [
                // Quantity Field
                Expanded(
                  child: TextFormField(
                    controller: productQuantityController,
                    // --- 4. Control ReadOnly based on Addon ---
                    readOnly: isSerialActive,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      final qty = num.tryParse(value ?? '') ?? 0;

                      // Check for basic valid quantity
                      if (value == null || value.isEmpty || qty <= 0) {
                        return lang.enterQuantity;
                      }

                      // Check Stock (Skip check if it is a Combo product)
                      final isCombo = widget.batchWiseStockModel.productType?.toLowerCase().contains('combo') ?? false;
                      final currentStock = widget.batchWiseStockModel.stock ?? 0;

                      if (!isCombo && qty > currentStock) {
                        return lang.outOfStock;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Text(lang.quantity),
                      hintText: lang.enterQuantity,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      // Visual Feedback
                      fillColor: isSerialActive ? Colors.grey.shade200 : null,
                      filled: isSerialActive,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Sale Price Field
                Expanded(
                  child: TextFormField(
                    controller: salePriceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return lang.pleaseEnterAValidSalePrice;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Text(lang.salePrice),
                      hintText: lang.enterAmount,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // --- Discount Field ---
            TextFormField(
              controller: discountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final discount = num.tryParse(value) ?? 0;
                  final price = num.tryParse(salePriceController.text) ?? 0;

                  if (discount < 0) {
                    return lang.enterAValidDiscount;
                  }
                  if (discount > price) {
                    return '${lang.discount} > ${lang.salePrice}';
                  }
                }
                return null;
              },
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                label: Text(lang.discount),
                hintText: lang.enterAValidDiscount,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
            ),

            // --- 5. Serial List Display Section (Controlled by isSerialActive) ---
            if (isSerialActive && _selectedSerials.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text('Selected Serials:', style: boldTextStyle(size: 14)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _selectedSerials.map((serial) {
                    return Chip(
                      label: Text(serial, style: const TextStyle(fontSize: 12)),
                      backgroundColor: kMainColor.withOpacity(0.1),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onDeleted: () => _removeSerial(serial),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 29),

            // --- Save Button ---
            GestureDetector(
              onTap: () async {
                if (isClicked) return;

                if (_formKey.currentState?.validate() ?? false) {
                  setState(() {
                    isClicked = true;
                  });

                  // --- 6. Update Model Logic ---
                  ref.read(cartNotifier).updateProduct(
                        index: widget.itemIndex, // Update using index
                        price: salePriceController.text,
                        qty: productQuantityController.text,
                        discount: num.tryParse(discountController.text) ?? 0,
                        serials: isSerialActive ? _selectedSerials : null, // Pass updated serials
                      );

                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 48,
                decoration: const BoxDecoration(
                  color: kMainColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    lang.save,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            )
          ],
        ),
      );
    });
  }
}
