import 'dart:io';
import 'package:excel/excel.dart' as e;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/add_to_cart_purchase.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../Products/add product/modle/create_product_model.dart';
import '../Repo/purchase_repo.dart';

class BulkPurchaseUploader extends ConsumerStatefulWidget {
  const BulkPurchaseUploader({super.key});

  @override
  ConsumerState<BulkPurchaseUploader> createState() => _BulkPurchaseUploaderState();
}

class _BulkPurchaseUploaderState extends ConsumerState<BulkPurchaseUploader> {
  String? filePat;
  File? file;

  String getFileExtension(String fileName) {
    return fileName.split('/').last;
  }

  /// 1. EXCEL FILE GENERATION (Force Text Format)
  Future<void> createExcelFile() async {
    if (!await Permission.storage.request().isDenied) {
      EasyLoading.showError('Storage permission is required to create Excel file!');
      return;
    }
    EasyLoading.show();
    final List<e.CellValue> excelData = [
      e.TextCellValue('SL'),
      e.TextCellValue('Product Code*'),
      e.TextCellValue('Purchase Quantity*'),
      e.TextCellValue('Purchase Price'),
      e.TextCellValue('Profit Percent %'),
      e.TextCellValue('Sale Price'),
      e.TextCellValue('Wholesale Price'),
      e.TextCellValue('Dealer Price'),
      e.TextCellValue('Batch No'),
      e.TextCellValue('Mfg Date'),
      e.TextCellValue('Expire Date'),
      e.TextCellValue('Serial Number'), // Index 11
    ];

    // Force cells to be treated as Text so "008" doesn't become "8"
    e.CellStyle textStyle = e.CellStyle(
      bold: false,
      textWrapping: e.TextWrapping.WrapText,
      rotation: 0,
      numberFormat: e.NumFormat.standard_0,
    );

    e.CellStyle headerStyle = e.CellStyle(
      bold: true,
      textWrapping: e.TextWrapping.WrapText,
      rotation: 0,
      numberFormat: e.NumFormat.standard_0,
    );

    var excel = e.Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.appendRow(excelData);

    // Apply Header Style
    for (int i = 0; i < excelData.length; i++) {
      var cell = sheet.cell(e.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = headerStyle;
    }

    // Pre-format first 500 rows to Text to handle user input correctly
    for (int row = 1; row <= 500; row++) {
      for (int col = 0; col < excelData.length; col++) {
        var cell = sheet.cell(e.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
        cell.cellStyle = textStyle;
      }
    }

    const downloadsFolderPath = '/storage/emulated/0/Download/';
    Directory dir = Directory(downloadsFolderPath);
    final file = File('${dir.path}/${appsName}_bulk_purchase_upload.xlsx');

    if (await file.exists()) {
      EasyLoading.showSuccess('The Excel file has already been downloaded');
    } else {
      await file.writeAsBytes(excel.encode()!);
      EasyLoading.showSuccess('Downloaded successfully in download folder');
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService(ref);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: const Text('Excel Uploader'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: file != null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Card(
                      child: ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Image(image: AssetImage('images/excel.png')),
                        ),
                        title: Text(
                          getFileExtension(file?.path ?? ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              file = null;
                            });
                          },
                          child: const Text('Remove'),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: file == null,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Image(
                      height: 100,
                      width: 100,
                      image: AssetImage('images/file-upload.png'),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(kMainColor)),
                  onPressed: () async {
                    if (!permissionService.hasPermission(Permit.bulkUploadsCreate.value)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('You do not have permission to upload bulk.'),
                        ),
                      );
                      return;
                    }
                    if (file == null) {
                      await pickAndUploadFile(ref: ref);
                    } else {
                      EasyLoading.show(status: 'Uploading...');
                      await uploadProducts(ref: ref, file: file!, context: context);
                      EasyLoading.dismiss();
                    }
                  },
                  child: Text(
                    file == null ? 'Pick and Upload File' : 'Upload',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (!permissionService.hasPermission(Permit.bulkUploadsRead.value)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('You do not have permission to download file.'),
                        ),
                      );
                      return;
                    }
                    await createExcelFile();
                  },
                  child: const Text('Download Excel Format'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickAndUploadFile({required WidgetRef ref}) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Excel Files',
      extensions: ['xlsx'],
    );
    final XFile? fileResult = await openFile(acceptedTypeGroups: [typeGroup]);

    if (fileResult != null) {
      final File files = File(fileResult.path);
      setState(() {
        file = files;
      });
    }
  }

  Future<void> uploadProducts({
    required File file,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      final purchaseCart = ref.watch(cartNotifierPurchaseNew);
      e.Excel excel = e.Excel.decodeBytes(file.readAsBytesSync());
      var sheet = excel.sheets.keys.first;
      var table = excel.tables[sheet]!;
      int successCount = 0;

      for (var row in table.rows) {
        CartProductModelPurchase? data = await createProductModelFromExcelData(row: row, ref: ref);

        if (data != null) {
          purchaseCart.addToCartRiverPod(
            cartItem: data,
            isVariation: data.productType == ProductType.variant.name,
          );
          successCount++;
        }
      }

      Future.delayed(const Duration(seconds: 1), () {
        EasyLoading.showSuccess('Upload Done. Added $successCount items.');
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 1;
        });
      });
    } catch (e) {
      EasyLoading.showError(e.toString());
      return;
    }
  }

  /// 2. PARSING LOGIC
  Future<CartProductModelPurchase?> createProductModelFromExcelData(
      {required List<e.Data?> row, required WidgetRef ref}) async {
    if (row.isEmpty) return null;

    // Local function to find product in DB
    Future<CartProductModelPurchase?> getProductFromDatabase(
        {required WidgetRef ref, required String givenProductCode}) async {
      final products = await ref.read(productProvider.future);
      CartProductModelPurchase? cartProductModel;

      for (var element in products) {
        if (element.productCode?.toLowerCase().trim() == givenProductCode.toLowerCase().trim()) {
          cartProductModel = CartProductModelPurchase(
            isSerialEnabled: element.hasSerial.toString() == '1' || element.hasSerial == true,
            productId: element.id ?? 0,
            vatRate: element.vat?.rate ?? 0,
            productName: element.productName ?? '',
            vatAmount: element.vatAmount ?? 0,
            vatType: element.vatType ?? '',
            productWholeSalePrice: 0,
            productDealerPrice: 0,
            productPurchasePrice: 0,
            productSalePrice: 0,
            productType: element.productType ?? 'single',
            quantities: 0,
            stock: 0,
            brandName: '',
            profitPercent: 0,
            mfgDate: '',
            expireDate: '',
            batchNumber: '',
            serialNumber: [], // Initialize empty
          );
          return cartProductModel;
        }
      }
      return cartProductModel;
    }

    CartProductModelPurchase? productModel;

    for (var element in row) {
      if (element?.rowIndex == 0) {
        // Skip header row
        return null;
      }

      String cellValue = element?.value?.toString() ?? '';

      switch (element?.columnIndex) {
        case 1: // Product code
          if (cellValue.isEmpty) return null;
          productModel = await getProductFromDatabase(ref: ref, givenProductCode: cellValue);
          if (productModel == null) return null;
          break;

        case 2: // Product quantity
          productModel?.quantities = num.tryParse(cellValue) ?? 0;
          break;

        case 3: // purchase price
          productModel?.productPurchasePrice = num.tryParse(cellValue) ?? 0;
          break;
        case 4: // profit percent
          productModel?.profitPercent = num.tryParse(cellValue) ?? 0;
          break;
        case 5: // sales price
          productModel?.productSalePrice = num.tryParse(cellValue) ?? 0;
          break;
        case 6: // wholesale price
          productModel?.productWholeSalePrice = num.tryParse(cellValue) ?? 0;
          break;
        case 7: // dealer price
          if (cellValue.isNotEmpty) {
            productModel?.productDealerPrice = num.tryParse(cellValue) ?? 0;
          }
          break;
        case 8: // Batch
          if (cellValue.isNotEmpty) {
            productModel?.batchNumber = cellValue;
          }
          break;
        case 9: // mfg date
          if (cellValue.isNotEmpty) {
            productModel?.mfgDate = cellValue;
          }
          break;
        case 10: // expire date
          if (cellValue.isNotEmpty) {
            productModel?.expireDate = cellValue;
          }
          break;

        // [Serial Number Logic]
        case 11:
          if (cellValue.isNotEmpty && (productModel?.isSerialEnabled ?? false)) {
            // Split by comma for multiple serials
            List<String> parsedSerials = cellValue.split(',').map((e) => e.trim()).toList();
            // Remove empty strings
            parsedSerials.removeWhere((s) => s.isEmpty);
            productModel?.serialNumber = parsedSerials;
          }
          break;
      }
    }

    // Return null if required fields are missing
    if (productModel?.productName == null || productModel?.quantities == null || productModel?.quantities == 0) {
      return null;
    }

    return productModel;
  }
}
