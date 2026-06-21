import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/invoice_details/components/common_image_builder.dart';
import 'package:mobile_pos/Screens/transfer/provider/transfer_provider.dart';
import 'package:mobile_pos/constant.dart' as mainConstant;
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/widgets/dotted_border/global_dotted_border.dart';
import 'package:mobile_pos/widgets/universal_image.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../../Const/api_config.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';

class TransferInvoiceScreen extends ConsumerStatefulWidget {
  final String transferId;

  const TransferInvoiceScreen({super.key, required this.transferId});

  @override
  ConsumerState<TransferInvoiceScreen> createState() => _TransferInvoiceScreenState();
}

class _TransferInvoiceScreenState extends ConsumerState<TransferInvoiceScreen> {
  double fontSizeForPrinter(String? size) {
    if (size == "3_inch_80mm") return 13.0;
    return 11.0; // Default small size
  }

  @override
  Widget build(BuildContext context) {
    final transferDetailsAsync = ref.watch(transferDetailsProvider(widget.transferId));
    final businessInfoAsync = ref.watch(businessInfoProvider);
    final printerData = ref.watch(thermalPrinterProvider);
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);

    return SafeArea(
      child: GlobalPopup(
        child: transferDetailsAsync.when(
          data: (detailsModel) {
            final data = detailsModel.data;
            if (data == null) return const Center(child: Text("No Data Found"));

            return businessInfoAsync.when(
              data: (businessInfo) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: 374,
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ///------------ Header (Logo & Business Info) -------------------
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center, // Center Alignment
                                children: [
                                  // Logo Logic
                                  if (businessInfo.data?.showThermalInvoiceLogo == 1)
                                    Builder(builder: (context) {
                                      final isSvg = businessInfo.data?.thermalInvoiceLogo?.endsWith('.svg');
                                      final imageUrl = '${businessInfo.data?.thermalInvoiceLogo}';
                                      const placeholder = AssetImage(mainConstant.logo);

                                      return (businessInfo.data?.thermalInvoiceLogo?.isEmptyOrNull ?? true)
                                          ? buildInvoiceLogo(image: placeholder)
                                          : (isSvg ?? false)
                                              ? SvgPicture.network(
                                                  imageUrl,
                                                  height: 120,
                                                  width: 120,
                                                  fit: BoxFit.contain,
                                                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                )
                                              : buildInvoiceLogo(image: NetworkImage(imageUrl));
                                    }),
                                  const SizedBox(height: 10),

                                  // Company Name
                                  if (businessInfo.data?.meta?.showCompanyName == 1)
                                    Text(
                                      '${businessInfo.data?.companyName}',
                                      textAlign: TextAlign.center, // Strictly Centered
                                      style: _theme.textTheme.titleLarge?.copyWith(
                                          // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize) + 4,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                    ),

                                  // Address
                                  if (businessInfo.data?.meta?.showCompanyName == 1)
                                    Text(
                                      businessInfo.data?.address ?? '',
                                      textAlign: TextAlign.center, // Strictly Centered
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),

                                  // Phone
                                  if (businessInfo.data?.meta?.showPhoneNumber == 1)
                                    Text(
                                      '${_lang.mobiles}: ${businessInfo.data?.phoneNumber ?? 'n/a'}',
                                      textAlign: TextAlign.center, // Strictly Centered
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),

                                  // Email
                                  if (businessInfo.data?.meta?.showEmail == 1)
                                    Text(
                                      '${_lang.email}: ${businessInfo.data?.user?.email ?? ''}',
                                      textAlign: TextAlign.center, // Strictly Centered
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),

                                  const SizedBox(height: 10),
                                  Text(
                                    _lang.transferInvoice,
                                    textAlign: TextAlign.center,
                                    style: _theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize) + 2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),

                              ///------------ Transfer Meta Data -------------------
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Side (Invoice No)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildMetaText('${_lang.invoice}: ${data.invoiceNo}', businessInfo, isBold: true),
                                      _buildMetaText(
                                          '${_lang.status}: ${data.status?.capitalizeFirstLetter()}', businessInfo),
                                    ],
                                  ),
                                  // Right Side (Date & Time)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildMetaText(
                                          '${_lang.date}: ${DateFormat.yMMMd().format(DateTime.parse(data.transferDate.toString()))}',
                                          businessInfo),
                                      _buildMetaText(
                                          '${_lang.time}: ${DateFormat.jm().format(DateTime.parse(data.transferDate.toString()))}',
                                          businessInfo),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              ///------------ From & To Section -------------------
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FROM
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildMetaText('${_lang.from}:', businessInfo, isBold: true),
                                        // From Branch
                                        if (data.fromBranch != null) ...[
                                          _buildMetaText(data.fromBranch?.name ?? '', businessInfo, isBold: true),
                                          _buildMetaText(data.fromBranch?.phone ?? '', businessInfo),
                                          _buildMetaText(data.fromBranch?.address ?? '', businessInfo),
                                        ],
                                        // From Warehouse
                                        if (data.fromWarehouse != null) ...[
                                          SizedBox(height: data.fromBranch != null ? 4 : 0),
                                          _buildMetaText('${_lang.WH}: ${data.fromWarehouse?.name}', businessInfo,
                                              isBold: true), // Bold for visibility
                                          if (data.fromWarehouse?.phone != null &&
                                              data.fromWarehouse!.phone!.isNotEmpty)
                                            _buildMetaText(data.fromWarehouse?.phone ?? '', businessInfo),
                                          if (data.fromWarehouse?.address != null &&
                                              data.fromWarehouse!.address!.isNotEmpty)
                                            _buildMetaText(data.fromWarehouse?.address ?? '', businessInfo),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // TO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _buildMetaText('${_lang.to}:', businessInfo, isBold: true),
                                        // To Branch
                                        if (data.toBranch != null) ...[
                                          _buildMetaText(data.toBranch?.name ?? '', businessInfo,
                                              isBold: true, align: TextAlign.end),
                                          _buildMetaText(data.toBranch?.phone ?? '', businessInfo,
                                              align: TextAlign.end),
                                          _buildMetaText(data.toBranch?.address ?? '', businessInfo,
                                              align: TextAlign.end),
                                        ],
                                        // To Warehouse
                                        if (data.toWarehouse != null) ...[
                                          SizedBox(height: data.toBranch != null ? 4 : 0),
                                          _buildMetaText('${_lang.WH}: ${data.toWarehouse?.name}', businessInfo,
                                              isBold: true, align: TextAlign.end), // Bold for visibility
                                          if (data.toWarehouse?.phone != null && data.toWarehouse!.phone!.isNotEmpty)
                                            _buildMetaText(data.toWarehouse?.phone ?? '', businessInfo,
                                                align: TextAlign.end),
                                          if (data.toWarehouse?.address != null &&
                                              data.toWarehouse!.address!.isNotEmpty)
                                            _buildMetaText(data.toWarehouse?.address ?? '', businessInfo,
                                                align: TextAlign.end),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              ///------------------- Product List ------------------------
                              globalDottedLine(borderColor: Colors.black54, height: 1, generatedLine: 60),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Expanded(flex: 1, child: _buildHeader(_lang.sl, businessInfo)),
                                    Expanded(flex: 3, child: _buildHeader(_lang.product, businessInfo)),
                                    Expanded(
                                        flex: 1, child: _buildHeader(_lang.qty, businessInfo, align: TextAlign.center)),
                                    Expanded(
                                        flex: 2, child: _buildHeader(_lang.price, businessInfo, align: TextAlign.end)),
                                    Expanded(
                                        flex: 2, child: _buildHeader(_lang.total, businessInfo, align: TextAlign.end)),
                                  ],
                                ),
                              ),
                              globalDottedLine(borderColor: Colors.black54, height: 1, generatedLine: 60),

                              if (data.transferProducts != null)
                                ...data.transferProducts!.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final product = entry.value;
                                  final total = (product.quantity ?? 0) * (product.unitPrice ?? 0);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(flex: 1, child: _buildItemText((index + 1).toString(), businessInfo)),
                                        Expanded(
                                            flex: 3,
                                            child: _buildItemText(product.product?.productName ?? '', businessInfo)),
                                        Expanded(
                                            flex: 1,
                                            child: _buildItemText(product.quantity.toString(), businessInfo,
                                                align: TextAlign.center)),
                                        Expanded(
                                            flex: 2,
                                            child: _buildItemText('$currency${product.unitPrice}', businessInfo,
                                                align: TextAlign.end)),
                                        Expanded(
                                            flex: 2,
                                            child:
                                                _buildItemText('$currency$total', businessInfo, align: TextAlign.end)),
                                      ],
                                    ),
                                  );
                                }),

                              const SizedBox(height: 7),
                              globalDottedLine(borderColor: Colors.black54, height: 1, generatedLine: 60),
                              const SizedBox(height: 12),

                              ///----------- Calculations ----------------------------
                              _buildCalculationRow(_lang.subTotal,
                                  '$currency${mainConstant.formatPointNumber(data.subTotal ?? 0)}', businessInfo),
                              const SizedBox(height: 4),
                              _buildCalculationRow(_lang.tax,
                                  '$currency${mainConstant.formatPointNumber(data.totalTax ?? 0)}', businessInfo),
                              const SizedBox(height: 4),
                              _buildCalculationRow(_lang.discount,
                                  '$currency${mainConstant.formatPointNumber(data.totalDiscount ?? 0)}', businessInfo),
                              const SizedBox(height: 4),
                              _buildCalculationRow(_lang.shippingCharge,
                                  '$currency${mainConstant.formatPointNumber(data.shippingCharge ?? 0)}', businessInfo),

                              const SizedBox(height: 6),
                              globalDottedLine(borderColor: Colors.black54, height: 1, generatedLine: 60),
                              const SizedBox(height: 6),

                              _buildCalculationRow(_lang.totalPayable,
                                  '$currency${mainConstant.formatPointNumber(data.grandTotal ?? 0)}', businessInfo,
                                  isBold: true),

                              const SizedBox(height: 20),

                              ///----------- Footer Info ----------------------------
                              if (data.note != null && data.note!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_lang.note}:",
                                      style: _theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                                      ),
                                    ),
                                    Text(
                                      data.note!,
                                      style: _theme.textTheme.bodyMedium?.copyWith(
                                          // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),

                              if (businessInfo.data?.gratitudeMessage != null &&
                                  businessInfo.data?.showGratitudeMsg == 1)
                                Center(
                                  child: Text(
                                    businessInfo.data?.gratitudeMessage ?? '',
                                    textAlign: TextAlign.center,
                                    style: _theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // Scanner Logo
                              if (businessInfo.data?.showInvoiceScannerLogo == 1)
                                Center(
                                  child: UniversalImage(
                                    imagePath: '${businessInfo.data?.invoiceScannerLogo}',
                                    height: 80,
                                    width: 80,
                                  ),
                                ),

                              const SizedBox(height: 10),
                              if (businessInfo.data?.developByLevel != null || businessInfo.data?.developBy != null)
                                Center(
                                  child: Text(
                                    '${businessInfo.data?.developByLevel ?? ''} ${businessInfo.data?.developBy ?? ''}',
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                        // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize) - 2,
                                        color: Colors.grey),
                                  ),
                                ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom Navigation Buttons
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Text(_lang.cancel),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                PrintWhTransferTransactionModel model = PrintWhTransferTransactionModel(
                                    transfer: detailsModel, personalInformationModel: businessInfo);
                                await printerData.printWhTransferThermalInvoice(
                                  transaction: model,
                                  context: context,
                                  invoiceSize: businessInfo.data?.invoiceSize ?? '',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainConstant.kMainColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Text(_lang.print, style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              error: (e, s) => Center(child: Text("Error: $e")),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          },
          error: (e, stack) => Center(child: Text('Error: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildMetaText(String text, dynamic businessInfo, {bool isBold = false, TextAlign align = TextAlign.start}) {
    return Text(
      text,
      textAlign: align,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
    );
  }

  Widget _buildHeader(String text, dynamic businessInfo, {TextAlign align = TextAlign.start}) {
    return Text(
      text,
      textAlign: align,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold, // Only Bold, standard font size
            // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
            color: Colors.black,
          ),
    );
  }

  Widget _buildItemText(String text, dynamic businessInfo, {TextAlign align = TextAlign.start}) {
    return Text(
      text,
      textAlign: align,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize), // Uniform font size
            color: Colors.black,
          ),
    );
  }

  Widget _buildCalculationRow(String label, String value, dynamic businessInfo, {bool isBold = false}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text.rich(
        TextSpan(
          text: '$label : ',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                color: Colors.black,
              ),
          children: [
            TextSpan(
                text: value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      // fontSize: fontSizeForPrinter(businessInfo.data?.invoiceSize),
                      color: Colors.black,
                    )),
          ],
        ),
      ),
    );
  }
}
