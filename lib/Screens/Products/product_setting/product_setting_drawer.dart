import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Products/product_setting/provider/setting_provider.dart';
import 'package:mobile_pos/Screens/Products/product_setting/repo/product_setting_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import 'model/get_product_setting_model.dart';
import 'model/product_setting_model.dart';

class ProductSettingsDrawer extends ConsumerStatefulWidget {
  final VoidCallback? onSave;
  final Modules? modules;
  final Addons? addons;

  const ProductSettingsDrawer({
    super.key,
    this.onSave,
    this.modules,
    required this.addons,
  });

  @override
  ConsumerState<ProductSettingsDrawer> createState() => _ProductSettingsDrawerState();
}

class _ProductSettingsDrawerState extends ConsumerState<ProductSettingsDrawer> {
  final Map<String, bool> _switchValues = {};
  final TextEditingController _saleController = TextEditingController();
  final TextEditingController _wholesaleController = TextEditingController();
  final TextEditingController _dealerController = TextEditingController();
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final modules = widget.modules;

    _switchValues.addAll({
      'Product Code': modules?.showProductCode == '1',
      'Product Stock': modules?.showProductStock == '1',
      'Sale': modules?.showProductSalePrice == '1',
      'Dealer': modules?.showProductDealerPrice == '1',
      'Wholesale Price': modules?.showProductWholesalePrice == '1',
      'Unit': modules?.showProductUnit == '1',
      'Brand': modules?.showProductBrand == '1',
      'Category': modules?.showProductCategory == '1',
      'Manufacturer': modules?.showProductManufacturer == '1',
      'Image': modules?.showProductImage == '1',
      'Show Expire Date': modules?.showExpireDate == '1',
      'Low Stock Alert': modules?.showAlertQty == '1',
      'Vat Id': modules?.showVatId == '1',
      'Vat Type': modules?.showVatType == '1',
      'Exclusive Price': modules?.showExclusivePrice == '1',
      'Inclusive Price': modules?.showInclusivePrice == '1',
      'Profit Percent': modules?.showProfitPercent == '1',
      'Batch No': modules?.showBatchNo == '1',
      'Show Manufacture Date': modules?.showMfgDate == '1',
      'Model': modules?.showModelNo == '1',
      if (widget.addons?.serialCodeAddon == true) 'Serial Number': modules?.showSerial == '1',
      'Show Single': modules?.showProductTypeSingle == '1',
      'Show Combo': modules?.showProductTypeCombo == '1',
      'Show Variant': modules?.showProductTypeVariant == '1',
      'Show Action': modules?.showAction == '1',
      if (widget.addons?.warehouseAddon == true) 'Warehouse': modules?.showWarehouse == '1',
      'Rack': modules?.showRack == '1',
      'Shelf': modules?.showShelf == '1',
      'Guarantee': modules?.showGuaranty == '1',
      'Warranty': modules?.showWarranty == '1',
    });

    _saleController.text = modules?.defaultSalePrice ?? '';
    _wholesaleController.text = modules?.defaultWholesalePrice ?? '';
    _dealerController.text = modules?.defaultDealerPrice ?? '';
  }

  @override
  void dispose() {
    _saleController.dispose();
    _wholesaleController.dispose();
    _dealerController.dispose();
    super.dispose();
  }

  String getStringFromBool(Map<String, bool> map, String key) {
    return map[key] == true ? '1' : '0';
  }

  // --- Localization Map ---
  String _label(BuildContext context, String key) {
    final s = lang.S.of(context);
    final Map<String, String Function(lang.S)> labelMap = {
      'Product Code': (s) => s.productCode,
      'Product Stock': (s) => s.productStock,
      'Sale': (s) => s.salePrice,
      'Dealer': (s) => s.dealerPrice,
      'Wholesale Price': (s) => s.wholeSalePrice,
      'Unit': (s) => s.unit,
      'Brand': (s) => s.brand,
      'Category': (s) => s.category,
      'Manufacturer': (s) => s.manufacturer,
      'Image': (s) => s.image,
      'Show Expire Date': (s) => s.showExpireDate,
      'Low Stock Alert': (s) => s.lowStockAlert,
      'Vat Id': (s) => s.vatId,
      'Vat Type': (s) => s.vatType,
      'Exclusive Price': (s) => s.exclusivePrice,
      'Inclusive Price': (s) => s.inclusivePrice,
      'Profit Percent': (s) => s.profitPercent,
      'Batch No': (s) => s.batchNo,
      'Show Manufacture Date': (s) => s.manufactureDate,
      'Model': (s) => s.model,
      'Show Single': (s) => s.showSingle,
      'Show Combo': (s) => s.showCombo,
      'Show Variant': (s) => s.showVariant,
      'Show Action': (s) => s.showAction,
      'Warehouse': (s) => s.warehouse,
      'Rack': (s) => s.rack,
      'Shelf': (s) => s.shelf,
      'Guarantee': (s) => s.guarantee,
      'Warranty': (s) => s.warranty,
      'Serial Number': (s) => s.serialNumber,
    };
    return labelMap[key]?.call(s) ?? key;
  }

  // --- Select All Logic ---
  bool get _isAllSelected {
    if (_switchValues.isEmpty) return false;
    return _switchValues.values.every((value) => value == true);
  }

  void _toggleAll(bool value) {
    setState(() {
      _switchValues.updateAll((key, _) => value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 4, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.S.of(context).productSetting,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kTitleColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xffE6E6E6), height: 1),

            // --- Select All Switch ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  lang.S.of(context).selectAll,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.7,
                  child: SizedBox(
                    height: 20,
                    width: 40,
                    child: CupertinoSwitch(
                      applyTheme: true,
                      value: _isAllSelected,
                      onChanged: _toggleAll,
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: const Color(0xff999999),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(color: Color(0xffE6E6E6), height: 1),

            // --- Individual Switches (Scrollable Area) ---
            Expanded(
              child: Form(
                key: globalKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  children: _switchValues.entries.map(_buildSwitchTile).toList(),
                ),
              ),
            ),

            // --- Save Button (Fixed at Bottom) ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: Text(lang.S.of(context).saveSetting),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(MapEntry<String, bool> entry) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      contentPadding: EdgeInsets.zero,
      title: Text(_label(context, entry.key)),
      trailing: Transform.scale(
        scale: 0.7,
        child: SizedBox(
          height: 20,
          width: 40,
          child: CupertinoSwitch(
            applyTheme: true,
            value: entry.value,
            onChanged: (value) => setState(() => _switchValues[entry.key] = value),
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: const Color(0xff999999),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if ((globalKey.currentState?.validate() ?? false)) {
      final single = _switchValues['Show Single'] ?? false;
      final variant = _switchValues['Show Variant'] ?? false;
      final combo = _switchValues['Show Combo'] ?? false;

      if (!single && !variant && !combo) {
        EasyLoading.showError('Please enable at least one: Single, Variant or Combo');
        return;
      }

      ProductSettingRepo setting = ProductSettingRepo();

      UpdateProductSettingModel data = UpdateProductSettingModel(
        productCode: getStringFromBool(_switchValues, 'Product Code'),
        productStock: getStringFromBool(_switchValues, 'Product Stock'),
        salePrice: getStringFromBool(_switchValues, 'Sale'),
        dealerPrice: getStringFromBool(_switchValues, 'Dealer'),
        wholesalePrice: getStringFromBool(_switchValues, 'Wholesale Price'),
        unit: getStringFromBool(_switchValues, 'Unit'),
        brand: getStringFromBool(_switchValues, 'Brand'),
        category: getStringFromBool(_switchValues, 'Category'),
        manufacturer: getStringFromBool(_switchValues, 'Manufacturer'),
        image: getStringFromBool(_switchValues, 'Image'),
        showExpireDate: getStringFromBool(_switchValues, 'Show Expire Date'),
        alertQty: getStringFromBool(_switchValues, 'Low Stock Alert'),
        vatId: getStringFromBool(_switchValues, 'Vat Id'),
        vatType: getStringFromBool(_switchValues, 'Vat Type'),
        exclusivePrice: getStringFromBool(_switchValues, 'Exclusive Price'),
        inclusivePrice: getStringFromBool(_switchValues, 'Inclusive Price'),
        profitPercent: getStringFromBool(_switchValues, 'Profit Percent'),
        batchNo: getStringFromBool(_switchValues, 'Batch No'),
        showManufactureDate: getStringFromBool(_switchValues, 'Show Manufacture Date'),
        model: getStringFromBool(_switchValues, 'Model'),
        showWarehouse: widget.addons?.warehouseAddon == true ? getStringFromBool(_switchValues, 'Warehouse') : '0',
        showRack: getStringFromBool(_switchValues, 'Rack'),
        showShelf: getStringFromBool(_switchValues, 'Shelf'),
        showSingle: getStringFromBool(_switchValues, 'Show Single'),
        showProductTypeCombo: getStringFromBool(_switchValues, 'Show Combo'),
        showVariant: getStringFromBool(_switchValues, 'Show Variant'),
        showAction: getStringFromBool(_switchValues, 'Show Action'),
        defaultExpireDate: getStringFromBool(_switchValues, 'Default ExpireDate'),
        defaultManufactureDate: getStringFromBool(_switchValues, 'Default Manufacture Date'),
        expireDateType: getStringFromBool(_switchValues, 'ExpireDate type'),
        manufactureDateType: getStringFromBool(_switchValues, 'ManufactureDate type'),
        showBatchNo: getStringFromBool(_switchValues, 'Show batch no.'),
        showWarranty: getStringFromBool(_switchValues, 'Warranty'),
        showGuaranty: getStringFromBool(_switchValues, 'Guarantee'),
        showSerial: widget.addons?.serialCodeAddon == true ? getStringFromBool(_switchValues, 'Serial Number') : '0',
      );

      bool success = await setting.updateProductSetting(data: data);

      if (success) {
        EasyLoading.showSuccess(lang.S.of(context).updateSuccessfully);
        ref.refresh(fetchSettingProvider);
        widget.onSave?.call();
      }
      // Removed the generic error here as the repo already shows detailed errors
      // (including the demo account message).
    }
  }

  // (Optional) _buildPriceField
  Widget _buildPriceField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}
