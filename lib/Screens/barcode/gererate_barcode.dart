import 'dart:async';
import 'dart:ui';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:pdf/widgets.dart' as pw;
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/product_provider.dart';
import '../../thermal priting invoices/barcode_widget.dart';
import '../../thermal priting invoices/label_print_test.dart';
import '../../thermal priting invoices/sticker_image_generation.dart';
import '../Products/Model/product_model.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'barcode_preview.dart';

class BarcodeGeneratorScreen extends StatefulWidget {
  const BarcodeGeneratorScreen({super.key});

  @override
  _BarcodeGeneratorScreenState createState() => _BarcodeGeneratorScreenState();
}

class _BarcodeGeneratorScreenState extends State<BarcodeGeneratorScreen> {
  List<Product> products = [];
  List<SelectedProduct> selectedProducts = [];
  bool showBusinessName = true;
  bool showName = true;
  bool showPrice = true;
  bool showPackageDate = true;
  bool showCode = true;

  final Map<String, TextEditingController> _controllers = {};

  String formatDateString(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final parsed = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (e) {
      return 'N/A';
    }
  }

  Future<pw.Document> _preview({required String businessName}) async {
    final pdf = pw.Document();
    List<pw.Widget> barcodeWidgets = [];

    for (var selectedProduct in selectedProducts) {
      for (int i = 0; i < selectedProduct.quantity; i++) {
        final stock = selectedProduct.product.stocks?.isNotEmpty == true ? selectedProduct.product.stocks!.first : null;

        barcodeWidgets.add(pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            if (showBusinessName)
              pw.Text(
                businessName,
                style: pw.TextStyle(
                  fontSize: double.tryParse(showNameFontSizeController.text) ?? 9,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            if (showName)
              pw.Text(
                '${selectedProduct.product.productName}',
                style: pw.TextStyle(
                  fontSize: double.tryParse(showNameFontSizeController.text) ?? 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            if (showPrice && stock != null)
              pw.RichText(
                text: pw.TextSpan(
                  text: '${lang.S.of(context).price}: ',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.normal),
                  children: [
                    pw.TextSpan(
                      text: '${stock.productSalePrice}',
                      style: pw.TextStyle(
                          fontSize: double.tryParse(showPriceFontSizeController.text) ?? 8,
                          fontWeight: pw.FontWeight.bold),
                    )
                  ],
                ),
              ),
            if (showPackageDate && stock != null)
              pw.Text(
                '${lang.S.of(context).packingDate}: ${formatDateString(stock.mfgDate)}',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: double.tryParse(showPackageDateFontSizeController.text) ?? 7,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            pw.SizedBox(height: 2),
            pw.BarcodeWidget(
              drawText: showCode,
              data: selectedProduct.product.productCode ?? 'n/a',
              barcode: pw.Barcode.code128(),
              width: 80,
              height: 30,
              textPadding: 4,
              textStyle: pw.TextStyle(fontSize: double.tryParse(showCodeFontSizeController.text) ?? 8),
            ),
          ],
        ));
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.GridView(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.68,
            children: barcodeWidgets,
          ),
        ],
      ),
    );

    return pdf;
  }

  void _toggleCheckbox(bool value, void Function(bool) updateFunction) {
    setState(() {
      updateFunction(value);
    });
  }

  //---------label print
  BluetoothDevice? _device;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;
  late StreamSubscription<Uint8List> _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  List<BluetoothDevice> _scanResults = [];

  String _selectedSize = '0';

  void _updateFontSizeControllers() {
    showCodeFontSizeController.text = getFontSize(_selectedSize, 'code');
    showPriceFontSizeController.text = getFontSize(_selectedSize, 'price');
    showNameFontSizeController.text = getFontSize(_selectedSize, 'name');
    showPackageDateFontSizeController.text = getFontSize(_selectedSize, 'packageDate');
  }

  String getFontSize(String selectedSize, String field) {
    if (selectedSize == '0') {
      switch (field) {
        case 'code':
        case 'price':
          return '8';
        case 'name':
          return '9';
        case 'businessName':
          return '8';
        case 'packageDate':
          return '7';
        default:
          return '8';
      }
    } else if (selectedSize == '1') {
      switch (field) {
        case 'code':
        case 'price':
        case 'name':
        case 'businessName':
        case 'packageDate':
          return '19.5';

        default:
          return '19.5';
      }
    } else if (selectedSize == '2') {
      switch (field) {
        case 'code':
        case 'price':
        case 'name':
        case 'businessName':
        case 'packageDate':
          return '20.0';
        default:
          return '20';
      }
    } else {
      return '20';
    }
  }

  late TextEditingController showCodeFontSizeController;
  late TextEditingController showPriceFontSizeController;
  late TextEditingController showNameFontSizeController;
  late TextEditingController showBusinessNameFontSizeController;
  late TextEditingController showPackageDateFontSizeController;

  @override
  void initState() {
    super.initState();
    initBluetoothPrintPlusListen();
    showCodeFontSizeController = TextEditingController(text: getFontSize(_selectedSize, 'code'));
    showPriceFontSizeController = TextEditingController(text: getFontSize(_selectedSize, 'price'));
    showNameFontSizeController = TextEditingController(text: getFontSize(_selectedSize, 'name'));
    showBusinessNameFontSizeController = TextEditingController(text: getFontSize(_selectedSize, 'businessName'));
    showPackageDateFontSizeController = TextEditingController(text: getFontSize(_selectedSize, 'packageDate'));
  }

  @override
  void dispose() {
    super.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
    showCodeFontSizeController.dispose();
    showPriceFontSizeController.dispose();
    showNameFontSizeController.dispose();
    showPackageDateFontSizeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, __) {
        final productData = ref.watch(productProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              titleSpacing: 0,
              centerTitle: false,
              title: Text(
                lang.S.of(context).barcodeGenerator,
              ),
              backgroundColor: Colors.white,
            ),
            body: productData.when(
              data: (snapshot) {
                products = snapshot;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //-----------------search_bar
                        TypeAheadField<Product>(
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              autofocus: false,
                              decoration: kInputDecoration.copyWith(
                                fillColor: kWhite,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kMainColor,
                                  ),
                                ),
                                hintText: lang.S.of(context).searchProduct,
                                suffixIcon: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: kMainColor,
                                  ),
                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                              ),
                            );
                          },
                          suggestionsCallback: (pattern) {
                            return products
                                .where(
                                    (product) => product.productName!.toLowerCase().startsWith(pattern.toLowerCase()))
                                .toList();
                          },
                          itemBuilder: (context, Product suggestion) {
                            return Container(
                              color: Colors.white,
                              child: ListTile(
                                  leading: suggestion.productPicture != null
                                      ? Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadiusGeometry.circular(2),
                                            border: Border.all(
                                              color: kBorderColorTextField,
                                              width: 0.3,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                '${suggestion.productPicture}',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadiusGeometry.circular(2),
                                            border: Border.all(
                                              color: CupertinoColors.systemGrey6,
                                              width: 0.3,
                                            ),
                                            color: CupertinoColors.systemGrey6,
                                          ),
                                          child: Icon(IconlyLight.image),
                                        ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          suggestion.productName ?? 'n/a',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: kTitleColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${lang.S.of(context).code}: ${suggestion.productCode?.toString() ?? '0'}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: kGreyTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  minVerticalPadding: 8,
                                  visualDensity: VisualDensity(vertical: -4),
                                  subtitle: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: suggestion.stocks?.length,
                                      itemBuilder: (context, i) {
                                        return Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${lang.S.of(context).batch}: ${suggestion.stocks?[i].batchNo?.toString() ?? 'n/a'}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: kTitleColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              suggestion.stocks?[i].productStock != 0
                                                  ? ', ${lang.S.of(context).inStock}: ${suggestion.stocks?[i].productStock?.toString() ?? 'n/a'}'
                                                  : ', ${lang.S.of(context).outOfStock}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color:
                                                    suggestion.stocks?[i].productStock != 0 ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${suggestion.stocks?.isNotEmpty == true ? ('$currency${suggestion.stocks?[i].productSalePrice ?? 0}') : null}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: kTitleColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        );
                                      })),
                            );
                          },
                          onSelected: (Product product) {
                            setState(() {
                              if (product.stocks != null && product.stocks!.isNotEmpty) {
                                if (product.stocks!.length > 1 || product.productType == 'variant') {
                                  for (var stock in product.stocks!) {
                                    final variantKey = '${product.id}_${stock.batchNo}';
                                    final initialQty = stock.productStock ?? 1;
                                    final existingIndex = selectedProducts.indexWhere(
                                        (p) => '${p.product.id}_${p.product.stocks?.first.batchNo}' == variantKey);

                                    if (existingIndex != -1) {
                                      selectedProducts[existingIndex].quantity =
                                          (selectedProducts[existingIndex].quantity + 1)
                                              .clamp(1, double.maxFinite.toInt());
                                      _controllers[variantKey]?.text =
                                          selectedProducts[existingIndex].quantity.toString();
                                    } else {
                                      selectedProducts.add(SelectedProduct(
                                        product: Product(
                                          id: product.id,
                                          productName: product.productName,
                                          productCode: product.productCode,
                                          productType: product.productType,
                                          stocksSumProductStock: stock.productStock,
                                          stocks: [stock],
                                          unit: product.unit,
                                          brand: product.brand,
                                          category: product.category,
                                        ),
                                        quantity: initialQty,
                                      ));
                                      _controllers[variantKey] = TextEditingController(text: initialQty.toString());
                                    }
                                  }
                                } else {
                                  final initialQty = product.stocks!.first.productStock ?? 1;
                                  final existingIndex = selectedProducts.indexWhere((p) => p.product.id == product.id);

                                  if (existingIndex != -1) {
                                    selectedProducts[existingIndex].quantity =
                                        (selectedProducts[existingIndex].quantity + 1)
                                            .clamp(1, double.maxFinite.toInt());
                                    _controllers[product.id.toString()]?.text =
                                        selectedProducts[existingIndex].quantity.toString();
                                  } else {
                                    selectedProducts.add(SelectedProduct(
                                      product: product,
                                      quantity: initialQty,
                                    ));
                                    _controllers[product.id.toString()] =
                                        TextEditingController(text: initialQty.toString());
                                  }
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        //-----------------check_box
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Icon(Icons.settings),
                            title: Text(
                              lang.S.of(context).informationShowInLabels,
                              style: theme.textTheme.bodyMedium?.copyWith(color: kTitleColor, fontSize: 14),
                            ),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCheckboxWithFontSize(
                                          context,
                                          value: showCode,
                                          label: lang.S.of(context).showCode,
                                          fontSizeController: showCodeFontSizeController,
                                          onChanged: (val) => _toggleCheckbox(val, (v) => showCode = v),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _buildCheckboxWithFontSize(
                                          context,
                                          value: showPrice,
                                          label: lang.S.of(context).showPrice,
                                          fontSizeController: showPriceFontSizeController,
                                          onChanged: (val) => _toggleCheckbox(val, (v) => showPrice = v),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCheckboxWithFontSize(
                                          context,
                                          value: showName,
                                          label: lang.S.of(context).showName,
                                          fontSizeController: showNameFontSizeController,
                                          onChanged: (val) => _toggleCheckbox(val, (v) => showName = v),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _buildCheckboxWithFontSize(
                                          context,
                                          value: showPackageDate,
                                          label: lang.S.of(context).packageDate,
                                          fontSizeController: showPackageDateFontSizeController,
                                          onChanged: (val) => _toggleCheckbox(val, (v) => showPackageDate = v),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 2 - 20,
                                    child: _buildCheckboxWithFontSize(
                                      context,
                                      value: showBusinessName,
                                      label: lang.S.of(context).businessName,
                                      fontSizeController: showBusinessNameFontSizeController,
                                      onChanged: (val) => _toggleCheckbox(val, (v) => showBusinessName = v),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    height: 40,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedSize,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          isDense: true,
                                          labelText: lang.S.of(context).barCodePrintLabelSetting),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedSize = value;
                                            _updateFontSizeControllers();
                                          });
                                        }
                                      },
                                      items: [
                                        DropdownMenuItem(
                                          value: '2',
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width - 72,
                                            child: Text(
                                              lang.S.of(context).labelRoleLabelSize2Inch,
                                              style:
                                                  theme.textTheme.bodySmall?.copyWith(color: kTitleColor, fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: '1',
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width - 72,
                                            child: Text(
                                              lang.S.of(context).labelRoleLabelSize1_5Inch,
                                              style:
                                                  theme.textTheme.bodySmall?.copyWith(color: kTitleColor, fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: '0',
                                          child: SizedBox(
                                            width: MediaQuery.of(context).size.width - 72,
                                            child: Text(
                                              lang.S.of(context).thirtyTwoLabelPerSheet,
                                              style:
                                                  theme.textTheme.bodySmall?.copyWith(color: kTitleColor, fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                        //-----------------data_table
                        selectedProducts.isNotEmpty
                            ? SizedBox(
                                width: double.maxFinite,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(Colors.red.shade50),
                                  showBottomBorder: true,
                                  horizontalMargin: 8,
                                  columnSpacing: 12,
                                  columns: [
                                    DataColumn(label: Text(lang.S.of(context).name)),
                                    DataColumn(label: Text(lang.S.of(context).quantity)),
                                    DataColumn(label: Text(lang.S.of(context).actions)),
                                  ],
                                  rows: selectedProducts.map((selectedProduct) {
                                    // final controllerKey = (selectedProduct.product.stocks?.length ?? 0) > 1 || selectedProduct.product.productType == 'variant'
                                    //     ? '${selectedProduct.product.id}_${selectedProduct.product.stocks?.first.batchNo}'
                                    //     : selectedProduct.product.id.toString();
                                    // final controller = _controllers[controllerKey];
                                    final controllerKey = (selectedProduct.product.stocks?.length ?? 0) > 1 ||
                                            selectedProduct.product.productType == 'variant'
                                        ? '${selectedProduct.product.id}_${selectedProduct.product.stocks?.first.batchNo}'
                                        : selectedProduct.product.id.toString();

                                    final controller = _controllers.putIfAbsent(
                                      controllerKey,
                                      () => TextEditingController(text: selectedProduct.quantity.toString()),
                                    );

                                    // Add error state for this product
                                    final hasError = ValueNotifier<bool>(false);

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                selectedProduct.product.productName ?? 'N/A',
                                                style: theme.textTheme.bodyMedium,
                                                maxLines: 1,
                                              ),
                                              Text(
                                                selectedProduct.product.productCode ?? 'N/A',
                                                style: theme.textTheme.bodySmall?.copyWith(color: kGreyTextColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            height: 38,
                                            width: 60,
                                            // child: TextFormField(
                                            //   controller: controller,
                                            //   keyboardType: TextInputType.number,
                                            //   textAlign: TextAlign.center,
                                            //   onChanged: (value) {
                                            //     setState(() {
                                            //       final newQty = (int.tryParse(value) ?? 1).clamp(1, double.maxFinite.toInt());
                                            //       selectedProduct.quantity = newQty;
                                            //       controller?.text = newQty.toString();
                                            //     });
                                            //   },
                                            //   decoration: const InputDecoration(
                                            //     border: OutlineInputBorder(),
                                            //     contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                            //   ),
                                            //   inputFormatters: [
                                            //     FilteringTextInputFormatter.digitsOnly,
                                            //   ],
                                            // ),
                                            child: TextFormField(
                                              controller: controller,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              // onChanged: (value) {
                                              //   setState(() {
                                              //     final newQty = (int.tryParse(value) ?? 1).clamp(1, double.maxFinite.toInt());
                                              //     selectedProduct.quantity = newQty;
                                              //   });
                                              // },
                                              onChanged: (value) {
                                                final newQty = int.tryParse(value) ?? 0;

                                                if (newQty < 1) {
                                                  hasError.value = true;
                                                  selectedProduct.quantity = 0;
                                                } else {
                                                  hasError.value = false;
                                                  selectedProduct.quantity = newQty;
                                                }
                                              },
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: kMainColor,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                final controllerKey = (selectedProduct.product.stocks?.length ?? 0) >
                                                            1 ||
                                                        selectedProduct.product.productType == 'variant'
                                                    ? '${selectedProduct.product.id}_${selectedProduct.product.stocks?.first.batchNo}'
                                                    : selectedProduct.product.id.toString();

                                                _controllers[controllerKey]?.dispose();
                                                _controllers.remove(controllerKey);
                                                selectedProducts.remove(selectedProduct);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              )
                            : Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 50),
                                    const Icon(
                                      IconlyLight.document,
                                      color: kMainColor,
                                      size: 70,
                                    ),
                                    Text(
                                      lang.S.of(context).noItemSelected,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
              error: (e, stack) => Center(child: Text(e.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            bottomNavigationBar: businessInfo.when(
              data: (details) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: kMainColor,
                      minimumSize: const Size(double.maxFinite, 48),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      if (!permissionService.hasPermission(Permit.barcodesCreate.value)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(lang.S.of(context).youDoNotHaveAnyPermissionToGenerateBarCode),
                          ),
                        );
                        return;
                      }
                      if (selectedProducts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(lang.S.of(context).pleaseSelectAProductFirst)),
                        );
                        return;
                      }

                      bool hasInvalidQuantity = false;
                      for (var product in selectedProducts) {
                        if (product.quantity < 1) {
                          hasInvalidQuantity = true;
                          break;
                        }
                      }

                      if (hasInvalidQuantity) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(lang.S.of(context).pleaseEnterAValidQuantity)),
                        );
                        return;
                      }

                      if (selectedProducts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(lang.S.of(context).pleaseSelectAProductFirst),
                        ));
                        return;
                      }

                      if (_selectedSize == '0') {
                        final pdfDocument = await _preview(businessName: details.data?.companyName ?? 'n/a');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PdfPreviewScreen(pdfDocument: pdfDocument),
                          ),
                        );
                        return;
                      }

                      // Check Bluetooth status
                      if (!BluetoothPrintPlus.isBlueOn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(lang.S.of(context).bluetoothIsTurnedOff)),
                        );
                        return;
                      }

                      if (!BluetoothPrintPlus.isConnected) {
                        await listOfBluDialog(context: context);
                        if (_device == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(lang.S.of(context).noBluetoothDeviceSelected)),
                          );
                          return;
                        }
                      }

                      // Begin printing loop
                      for (var selectedProduct in selectedProducts) {
                        final product = selectedProduct.product;
                        final stock = product.stocks?.isNotEmpty == true ? product.stocks!.first : null;

                        for (int i = 0; i < selectedProduct.quantity; i++) {
                          final pngBytes = await createImageFromWidget(
                            context,
                            StickerWidget(
                              data: StickerData(
                                businessName: details.data?.companyName ?? 'n/a',
                                name: product.productName ?? 'N/A',
                                price: stock?.productSalePrice ?? 0.0,
                                code: product.productCode ?? 'N/A',
                                mfg: stock?.mfgDate ?? 'N/A',
                                isTwoIch: _selectedSize == '2',
                                showBusinessName: showBusinessName,
                                showName: showName,
                                showPrice: showPrice,
                                showCode: showCode,
                                showMfg: showPackageDate,
                                nameFontSize: double.tryParse(showNameFontSizeController.text) ?? 20,
                                codeFontSize: double.tryParse(showCodeFontSizeController.text) ?? 20,
                                mfgFontSize: double.tryParse(showPackageDateFontSizeController.text) ?? 20,
                                priceFontSize: double.tryParse(showPriceFontSizeController.text) ?? 20,
                              ),
                            ),
                            logicalSize: Size(_selectedSize == '2' ? 350 : 280, 180),
                            imageSize: Size(_selectedSize == '2' ? 350 : 280, 180),
                          );

                          await printLabelTest(
                            productName: product.productName ?? 'N/A',
                            date: stock?.mfgDate ?? 'N/A',
                            price: '\$${stock?.productSalePrice ?? 0.0}',
                            barcodeData: product.productCode ?? 'N/A',
                            pngBytes: pngBytes!,
                            isTwoInch: _selectedSize == '2',
                          );
                        }
                      }
                    },
                    icon: Icon(_selectedSize == '0' ? Icons.preview : Icons.print),
                    label: Text(
                      _selectedSize == '0' ? lang.S.of(context).previewPdf : lang.S.of(context).printLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
              error: (e, stack) => Center(child: Text(e.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      },
    );
  }

  Future<void> initBluetoothPrintPlusListen() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
      if (mounted) {
        setState(() {
          _scanResults = event;
        });
      }
    });

    /// listen isScanning
    _isScanningSubscription = BluetoothPrintPlus.isScanning.listen((event) {
      print('********** isScanning: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen blue state
    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((event) {
      print('********** blueState change: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((event) async {
      print('********** connectState change: $event **********');
      switch (event) {
        case ConnectState.connected:
          setState(() {});
          break;
        case ConnectState.disconnected:
          setState(() {
            _device = null;
          });
          break;
      }
    });

    /// listen received data
    _receivedDataSubscription = BluetoothPrintPlus.receivedData.listen((data) {
      print('********** received data: $data **********');

      /// do something...
    });
  }

  Future<dynamic> listOfBluDialog({required BuildContext context}) async {
    return showCupertinoDialog(
      context: context,
      builder: (_) {
        // Start scanning when dialog is shown
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onScanPressed();
        });

        return WillPopScope(
          onWillPop: () async => false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return CupertinoAlertDialog(
                  insetAnimationCurve: Curves.bounceInOut,
                  content: Container(
                    height: 300,
                    width: double.maxFinite,
                    child: BluetoothPrintPlus.isBlueOn
                        ? StreamBuilder<List<BluetoothDevice>>(
                            stream: BluetoothPrintPlus.scanResults,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text(lang.S.of(context).caningForDevices),
                                    ],
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.bluetooth_disabled, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(lang.S.of(context).noDeviceFound),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => onScanPressed(),
                                        child: Text(lang.S.of(context).retryScan),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context1, index) {
                                    final device = snapshot.data![index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      title: Text(device.name),
                                      subtitle: Text(device.address),
                                      onTap: () async {
                                        setDialogState(() {});
                                        await BluetoothPrintPlus.connect(device);
                                        _device = device;
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${lang.S.current.connectedTo}${device.name}')),
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bluetooth_disabled, size: 40, color: Colors.red),
                                SizedBox(height: 8),
                                Text(lang.S.of(context).pleaseEnableBluetooth),
                              ],
                            ),
                          ),
                  ),
                  title: Text(lang.S.of(context).connectPrinter),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(lang.S.of(context).cancel),
                      onPressed: () {
                        BluetoothPrintPlus.stopScan();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckboxWithFontSize(
    BuildContext context, {
    required bool value,
    required String label,
    required TextEditingController fontSizeController,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                activeColor: kMainColor,
                value: value,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                onChanged: (val) => onChanged(val!),
              ),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: fontSizeController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: Color(0xffD8D8D8).withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      lang.S.of(context).size,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBlueOffWidget() {
    return Center(
        child: Text(
      "${lang.S.of(context).bluetoothIsTurnedOff}...",
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.red),
      textAlign: TextAlign.center,
    ));
  }

  Widget buildScanButton(BuildContext context) {
    if (BluetoothPrintPlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(onPressed: onScanPressed, backgroundColor: Colors.green, child: Text("SCAN"));
    }
  }

  Future onScanPressed() async {
    try {
      await BluetoothPrintPlus.startScan(timeout: Duration(seconds: 10));
      setState(() {});
    } catch (e) {
      print("onScanPressed error: $e");
    }
  }

  Future onStopPressed() async {
    try {
      BluetoothPrintPlus.stopScan();
    } catch (e) {
      print("onStopPressed error: $e");
    }
  }
}

class SelectedProduct {
  final Product product;
  num quantity;

  SelectedProduct({required this.product, required this.quantity});
}
