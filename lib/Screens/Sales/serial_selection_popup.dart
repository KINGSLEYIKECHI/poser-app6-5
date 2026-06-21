import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../constant.dart';
import 'model/sale_add_to_cart_model.dart';
import 'provider/sales_cart_provider.dart';

class SerialSelectionPopup extends ConsumerStatefulWidget {
  final Product product;
  final num price;

  const SerialSelectionPopup({
    super.key,
    required this.product,
    required this.price,
  });

  @override
  ConsumerState<SerialSelectionPopup> createState() => _SerialSelectionPopupState();
}

class _SerialSelectionPopupState extends ConsumerState<SerialSelectionPopup> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> allSerials = [];
  List<dynamic> filteredSerials = [];
  List<dynamic> selectedSerials = [];

  @override
  void initState() {
    super.initState();

    allSerials = List<dynamic>.from(widget.product.stocks?.firstOrNull?.serialNumbers ?? []);

    final List<dynamic> alreadyInCart = ref
        .read(cartNotifier)
        .cartItemList
        .where((item) => item.productId == widget.product.id && item.serialNumber != null)
        .expand((item) => item.serialNumber!)
        .toList();

    allSerials.removeWhere((s) => alreadyInCart.contains(s));
    filteredSerials = allSerials;
  }

  void toggleSelection(dynamic serial) {
    setState(() {
      if (selectedSerials.contains(serial)) {
        selectedSerials.remove(serial);
      } else {
        selectedSerials.add(serial);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      height: context.height() * 0.85, // উচ্চতা একটু বাড়ানো হয়েছে বাটন দেখানোর জন্য
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Serial Number', style: boldTextStyle(size: 18)),
              const CloseButton(),
            ],
          ),
          5.height,
          Text(widget.product.productName ?? '', style: secondaryTextStyle()),
          const Divider(),

          // --- Search Bar ---
          AppTextField(
            controller: searchController,
            textFieldType: TextFieldType.NAME,
            decoration: InputDecoration(
              hintText: 'Search serial/IMEI...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
            onChanged: (value) {
              setState(() {
                filteredSerials =
                    allSerials.where((s) => s.toString().toLowerCase().contains(value.toLowerCase())).toList();
              });
            },
          ),
          10.height,

          // --- Select All / Count Info ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Selected: ${selectedSerials.length}", style: boldTextStyle(color: kMainColor)),
              if (filteredSerials.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (selectedSerials.length == filteredSerials.length) {
                        selectedSerials.clear();
                      } else {
                        selectedSerials = List.from(filteredSerials);
                      }
                    });
                  },
                  child: Text(
                    selectedSerials.length == filteredSerials.length ? "Unselect All" : "Select All",
                  ),
                ),
            ],
          ),

          // --- Serial List ---
          Expanded(
            child: filteredSerials.isEmpty
                ? const Center(child: Text("No available serials in stock"))
                : ListView.builder(
                    itemCount: filteredSerials.length,
                    itemBuilder: (context, index) {
                      final serial = filteredSerials[index];
                      final isSelected = selectedSerials.contains(serial);

                      return Card(
                        elevation: 0,
                        color: isSelected ? kMainColor.withOpacity(0.1) : Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSelected ? kMainColor : Colors.grey.shade200),
                        ),
                        child: ListTile(
                          title: Text(serial.toString(), style: boldTextStyle(size: 14)),
                          trailing: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? kMainColor : Colors.grey,
                          ),
                          onTap: () => toggleSelection(serial),
                        ),
                      );
                    },
                  ),
          ),

          // --- Add Button ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMainColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: selectedSerials.isEmpty
                    ? null
                    : () {
                        final stock = widget.product.stocks?.firstOrNull;

                        SaleCartModel cartItem = SaleCartModel(
                          productName: widget.product.productName,
                          batchName: '',
                          stockId: stock?.id ?? 0,
                          unitPrice: widget.price,
                          productCode: widget.product.productCode,
                          productPurchasePrice: stock?.productPurchasePrice,
                          stock: stock?.productStock,
                          productType: widget.product.productType,
                          productId: widget.product.id ?? 0,
                          quantity: selectedSerials.length,
                          serialNumber: List<String>.from(selectedSerials),
                        );

                        ref.read(cartNotifier).addToCartRiverPod(
                              cartItem: cartItem,
                              fromEditSales: false,
                              isVariant: false,
                            );

                        // Close Popup
                        finish(context);
                      },
                child: Text(
                  'Add ${selectedSerials.length} Items to Cart',
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
