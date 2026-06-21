import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/invoice_details/components/common_image_builder.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart' as pro;
import 'package:screenshot/screenshot.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart' as mainConstant;
import '../../constant.dart';
import '../../currency.dart';
import '../../model/business_info_model.dart' as binfo;
import '../../model/sale_transaction_model.dart';
import '../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../widgets/dotted_border/global_dotted_border.dart';
import '../../widgets/universal_image.dart';
import '../Products/add product/modle/create_product_model.dart';
import '../language/language_provider.dart';

class SalesInvoiceDetails extends StatefulWidget {
  const SalesInvoiceDetails({
    super.key,
    required this.saleTransaction,
    required this.businessInfo,
    this.fromSale,
    this.saleId,
  });

  final SalesTransactionModel saleTransaction;
  final binfo.BusinessInformationModel businessInfo;
  final bool? fromSale;
  final int? saleId;

  @override
  State<SalesInvoiceDetails> createState() => _SalesInvoiceDetailsState();
}

class _SalesInvoiceDetailsState extends State<SalesInvoiceDetails> {
  ScreenshotController controller = ScreenshotController();
  final GlobalKey _screenshotKey = GlobalKey();

  String productName({required num detailsId}) {
    final details = widget.saleTransaction
        .salesDetails?[widget.saleTransaction.salesDetails!.indexWhere((element) => element.id == detailsId)];
    return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ""}]' : ''}";
  }

  num productPrice({required num detailsId}) {
    return widget.saleTransaction.salesDetails!.where((element) => element.id == detailsId).first.price ?? 0;
  }

  num getTotalReturndAmount() {
    num totalReturn = 0;
    if (widget.saleTransaction.salesReturns?.isNotEmpty ?? false) {
      for (var returns in widget.saleTransaction.salesReturns!) {
        if (returns.salesReturnDetails?.isNotEmpty ?? false) {
          for (var details in returns.salesReturnDetails!) {
            totalReturn += details.returnAmount ?? 0;
          }
        }
      }
    }
    return totalReturn;
  }

  int serialNumber = 1;

  num getReturndDiscountAmount() {
    num totalReturnDiscount = 0;
    if (widget.saleTransaction.salesReturns?.isNotEmpty ?? false) {
      for (var returns in widget.saleTransaction.salesReturns!) {
        if (returns.salesReturnDetails?.isNotEmpty ?? false) {
          for (var details in returns.salesReturnDetails!) {
            totalReturnDiscount += ((productPrice(detailsId: details.saleDetailId ?? 0) * (details.returnQty ?? 0)) -
                ((details.returnAmount ?? 0)));
          }
        }
      }
    }
    return totalReturnDiscount;
  }

  num getTotalForOldInvoice() {
    num total = 0;
    for (var element in widget.saleTransaction.salesDetails!) {
      total += ((element.price ?? 0) * getProductQuantity(detailsId: element.id ?? 0) -
          (element.discount ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
    }

    return total;
  }

  num getTotalForOldInvoiceWithoutTax() {
    num total = 0;
    for (var element in widget.saleTransaction.salesDetails!) {
      total += ((element.priceWithoutTax ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
    }

    return total;
  }

  num getTotalForOldInvoiceVat() {
    num total = 0;
    for (var element in widget.saleTransaction.salesDetails!) {
      total += (((element.price ?? 0) - (element.discount ?? 0)) * getProductQuantity(detailsId: element.id ?? 0)) -
          ((element.priceWithoutTax ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
    }

    return total;
  }

  num getProductQuantity({required num detailsId}) {
    num totalQuantity =
        widget.saleTransaction.salesDetails?.where((element) => element.id == detailsId).first.quantities ?? 0;
    if (widget.saleTransaction.salesReturns?.isNotEmpty ?? false) {
      for (var returns in widget.saleTransaction.salesReturns!) {
        if (returns.salesReturnDetails?.isNotEmpty ?? false) {
          for (var details in returns.salesReturnDetails!) {
            if (details.saleDetailId == detailsId) {
              totalQuantity += details.returnQty ?? 0;
            }
          }
        }
      }
    }

    return totalQuantity;
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final _theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Consumer(builder: (context, ref, __) {
      final printerData = ref.watch(thermalPrinterProvider);
      final businessSettingData = ref.watch(businessInfoProvider);

      return SafeArea(
        child: GlobalPopup(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                  child: RepaintBoundary(
                key: _screenshotKey,
                child: SizedBox(
                  width: 374,
                  child: Container(
                    width: 374,
                    color: Colors.white,
                    // Reduced horizontal padding to free up space on both sides
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                    child:
                        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ///------------header -------------------
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //----------Invoice Logo------------------------
                          if (widget.businessInfo.data?.showThermalInvoiceLogo == 1)
                            businessSettingData.when(
                              data: (business) {
                                final isSvg = business.data?.thermalInvoiceLogo?.endsWith('.svg');
                                final imageUrl = '${business.data?.thermalInvoiceLogo}';
                                const placeholder = AssetImage(mainConstant.logo);
                                return (business.data?.thermalInvoiceLogo?.isEmptyOrNull ?? true)
                                    ? buildInvoiceLogo(image: placeholder)
                                    : (isSvg ?? false)
                                        ? SvgPicture.network(
                                            imageUrl,
                                            height: 46,
                                            width: 44,
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                          )
                                        : buildInvoiceLogo(
                                            image: NetworkImage(imageUrl),
                                          );
                              },
                              error: (e, stack) => Text(e.toString()),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          //----------company name---------------------------
                          if (widget.businessInfo.data?.meta?.showCompanyName == 1)
                            Text(
                              '${widget.businessInfo.data?.companyName}',
                              style: _theme.textTheme.titleLarge?.copyWith(
                                fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          //-------------company Branch---------------------------------
                          if (widget.saleTransaction.branch?.name?.isNotEmpty ?? false)
                            Text.rich(
                              TextSpan(
                                text: '${_lang.branch} : ',
                                children: [
                                  TextSpan(
                                    text: widget.saleTransaction.branch?.name.toString() ?? 'n/a',
                                    style: _theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                      color: mainConstant.kTextColor,
                                    ),
                                  ),
                                ],
                                style: _theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  color: mainConstant.kTextColor,
                                ),
                              ),
                            ),
                          //----------------Address----------------------------------
                          if (widget.businessInfo.data?.meta?.showCompanyName == 1)
                            Text(
                              '${_lang.address}: ${widget.businessInfo.data?.address ?? ''}',
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                color: mainConstant.kTextColor,
                              ),
                            ),
                          //---------------Phone-------------------------------------------
                          if (widget.businessInfo.data?.meta?.showPhoneNumber == 1)
                            Text(
                              '${_lang.mobile} ${(widget.saleTransaction.branch?.phone?.isNotEmpty ?? false) ? widget.saleTransaction.branch?.phone ?? 'n/a' : widget.businessInfo.data?.phoneNumber?.toString() ?? 'n/a'}',
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                color: mainConstant.kTextColor,
                              ),
                            ),
                          //-----------------email----------------------------
                          if (widget.businessInfo.data?.meta?.showEmail == 1)
                            Text(
                              '${_lang.email}: ${widget.businessInfo.data?.user?.email ?? ''}',
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                color: mainConstant.kTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          SizedBox(height: 8),
                          //-----------------Invoice-------------------
                          Text(
                            _lang.invoice.toUpperCase(),
                            style: _theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(height: 32),

                          ///--------header data-----------------
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Invoice
                                    Text.rich(
                                      TextSpan(
                                          text: '${lang.S.of(context).invoice} : ',
                                          children: [
                                            TextSpan(
                                                text: widget.saleTransaction.invoiceNumber ?? '',
                                                style: _theme.textTheme.bodyMedium?.copyWith(
                                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                                  fontWeight: FontWeight.w500,
                                                ))
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          )),
                                    ),
                                    //name
                                    Text.rich(
                                      TextSpan(
                                        text: '${lang.S.of(context).name} : ',
                                        children: [
                                          TextSpan(
                                            text: widget.saleTransaction.party?.name ?? '',
                                          )
                                        ],
                                        style: _theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                          color: mainConstant.kTextColor,
                                        ),
                                      ),
                                    ),
                                    //mobile
                                    Text.rich(
                                      TextSpan(
                                        text: '${lang.S.of(context).mobile} ',
                                        children: [
                                          TextSpan(
                                            text: widget.saleTransaction.party?.phone ??
                                                (widget.saleTransaction.meta?.customerPhone ?? 'N/A'),
                                          ),
                                        ],
                                        style: _theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                          color: mainConstant.kTextColor,
                                        ),
                                      ),
                                    ),
                                    if (widget.businessInfo.data?.invoiceSize != "3_inch_80mm") ...[
                                      //date----------------
                                      Text.rich(
                                        TextSpan(
                                          text: '${lang.S.of(context).date} : ',
                                          children: [
                                            TextSpan(
                                              text: DateFormat.yMMMd().format(DateTime.parse(
                                                  widget.saleTransaction.saleDate ?? DateTime.now().toString())),
                                            ),
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      //Time
                                      Text.rich(
                                        textAlign: TextAlign.end,
                                        TextSpan(
                                          text: '${locale == "en" ? 'Time' : lang.S.of(context).allTime}: ',
                                          children: [
                                            TextSpan(
                                              text: DateFormat.jm().format(DateTime.parse(
                                                  widget.saleTransaction.saleDate ?? DateTime.now().toString())),
                                            )
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      //Sales by
                                      Text.rich(
                                        TextSpan(
                                          text: '${lang.S.of(context).salesBy} ',
                                          children: [
                                            TextSpan(
                                              text: widget.saleTransaction.user?.name ?? '',
                                            )
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      //Vat Number
                                      Visibility(
                                        visible: widget.businessInfo.data?.vatNo != null &&
                                            widget.businessInfo.data?.meta?.showVat == 1,
                                        child: Text.rich(
                                          TextSpan(
                                            text: '${widget.businessInfo.data?.vatName ?? _lang.vatNumber} : ',
                                            children: [
                                              TextSpan(
                                                text: widget.businessInfo.data?.vatNo ?? '',
                                              )
                                            ],
                                            style: _theme.textTheme.bodyLarge?.copyWith(
                                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                              color: mainConstant.kTextColor,
                                            ),
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (widget.businessInfo.data?.invoiceSize == "3_inch_80mm") ...[
                                SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      //date----------------
                                      Text.rich(
                                        TextSpan(
                                          text: '${lang.S.of(context).date} : ',
                                          children: [
                                            TextSpan(
                                              text: DateFormat.yMMMd().format(DateTime.parse(
                                                  widget.saleTransaction.saleDate ?? DateTime.now().toString())),
                                            ),
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      //Time
                                      Text.rich(
                                        textAlign: TextAlign.end,
                                        TextSpan(
                                          text: '${locale == "en" ? 'Time' : lang.S.of(context).allTime}: ',
                                          children: [
                                            TextSpan(
                                              text: DateFormat.jm().format(DateTime.parse(
                                                  widget.saleTransaction.saleDate ?? DateTime.now().toString())),
                                            )
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      //Sales by
                                      Text.rich(
                                        TextSpan(
                                          text: '${lang.S.of(context).salesBy} ',
                                          children: [
                                            TextSpan(
                                              text: widget.saleTransaction.user?.name ?? '',
                                            )
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      //Vat Number
                                      Visibility(
                                        visible: widget.businessInfo.data?.vatNo != null &&
                                            widget.businessInfo.data?.meta?.showVat == 1,
                                        child: Text.rich(
                                          TextSpan(
                                            text: '${widget.businessInfo.data?.vatName ?? _lang.vatNumber} : ',
                                            children: [
                                              TextSpan(
                                                text: widget.businessInfo.data?.vatNo ?? '',
                                              )
                                            ],
                                            style: _theme.textTheme.bodyLarge?.copyWith(
                                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                              color: mainConstant.kTextColor,
                                            ),
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      ///-------------------Product list data------------------------
                      globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            //SL
                            Expanded(
                              flex: 1,
                              child: Text(
                                _lang.sl,
                                textAlign: TextAlign.start,
                                style: _theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                ),
                              ),
                            ),
                            //Product
                            Expanded(
                              flex: 2,
                              child: Text(
                                _lang.product,
                                textAlign: TextAlign.start,
                                style: _theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                ),
                              ),
                            ),
                            //Quantity
                            Expanded(
                              flex: 2,
                              child: Text(
                                lang.S.of(context).qty,
                                textAlign: TextAlign.center,
                                style: _theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                ),
                              ),
                            ),
                            if (widget.businessInfo.data?.invoiceSize == "3_inch_80mm") ...[
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lang.S.of(context).price,
                                  textAlign: TextAlign.center,
                                  style: _theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                ),
                              ),
                            ],
                            // Check setting and printer size for rendering Discount header
                            if (widget.businessInfo.data?.allowProductDiscount == 1 &&
                                widget.businessInfo.data?.invoiceSize == "3_inch_80mm") ...[
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Dis.',
                                  textAlign: TextAlign.center,
                                  style: _theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                ),
                              ),
                            ],
                            //Amount
                            Expanded(
                              flex: 2,
                              child: Text(
                                lang.S.of(context).amount,
                                textAlign: TextAlign.end,
                                style: _theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                      ...widget.saleTransaction.salesDetails!.asMap().entries.map((entry) {
                        final i = entry.key; // This is the index
                        final saleDetail = entry.value; // This is the saleDetail object

                        final quantity = getProductQuantity(detailsId: saleDetail.id ?? 0);
                        final totalPrice =
                            ((saleDetail.price ?? 0) * quantity) - ((saleDetail.discount ?? 0) * quantity);
                        return Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  (widget.saleTransaction.salesDetails!.indexOf(saleDetail) + 1).toString(),
                                  style: _theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      saleDetail.product?.productName ?? '',
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    // -------------- Added Serial Number Display Here -----------------
                                    if (saleDetail.serialNumbers != null && saleDetail.serialNumbers!.isNotEmpty)
                                      Text(
                                        '${_lang.serial}: ${saleDetail.serialNumbers!.join(", ")}',
                                        style: _theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: (fontSizeForPrinter(widget.businessInfo.data?.invoiceSize) - 2),
                                          color: Colors.black87,
                                        ),
                                      ),
                                    // -----------------------------------------------------------------
                                    if (saleDetail.warrantyInfo?.warrantyDuration != null &&
                                        saleDetail.warrantyInfo?.warrantyUnit != null)
                                      Text(
                                        '${_lang.warranty} : ${saleDetail.warrantyInfo?.warrantyDuration} ${saleDetail.warrantyInfo?.warrantyUnit}',
                                        style: _theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize) - 6,
                                        ),
                                      ),
                                    if (saleDetail.warrantyInfo?.guaranteeDuration != null &&
                                        saleDetail.warrantyInfo?.guaranteeUnit != null)
                                      Text(
                                        '${_lang.guarantee} : ${saleDetail.warrantyInfo?.guaranteeDuration} ${saleDetail.warrantyInfo?.guaranteeUnit}',
                                        style: _theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize) - 6,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  mainConstant.formatPointNumber(quantity),
                                  style: _theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (widget.businessInfo.data?.invoiceSize == "3_inch_80mm") ...[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '$currency${mainConstant.formatPointNumber(saleDetail.price ?? 0, addComma: true)}',
                                    textAlign: TextAlign.center,
                                    style: _theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                    ),
                                  ),
                                ),
                              ],
                              // Check setting and printer size for rendering Discount cell
                              if (widget.businessInfo.data?.allowProductDiscount == 1 &&
                                  widget.businessInfo.data?.invoiceSize == "3_inch_80mm") ...[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '$currency${mainConstant.formatPointNumber(saleDetail.discount ?? 0)}',
                                    textAlign: TextAlign.center,
                                    style: _theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                    ),
                                  ),
                                ),
                              ],
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$currency${mainConstant.formatPointNumber(totalPrice, addComma: true)}',
                                  style: _theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 7),
                      globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                      SizedBox(height: 12),

                      ///-----------total----------------------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            text: '${lang.S.of(context).total} : ',
                            children: [
                              TextSpan(
                                text: '$currency${mainConstant.formatPointNumber(getTotalForOldInvoiceWithoutTax())}',
                              ),
                            ],
                          ),
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                      ),

                      ///-----------vat----------------------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            text: '${widget.businessInfo.data?.vatName ?? lang.S.of(context).vat} : ',
                            children: [
                              TextSpan(
                                text:
                                    '$currency${mainConstant.formatPointNumber(getTotalForOldInvoiceVat() + (widget.saleTransaction.vatAmount ?? 0))}',
                              ),
                            ],
                          ),
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                      ),

                      ///__________discount______________________
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            text: '${lang.S.of(context).discount} : ',
                            style: _theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                            ),
                            children: [
                              TextSpan(
                                text: '$currency${mainConstant.formatPointNumber(
                                  (widget.saleTransaction.discountAmount ?? 0) + getReturndDiscountAmount(),
                                )}',
                              ),
                            ],
                          ),
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      ///__________shipping_charge______________
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            text: '${lang.S.of(context).shippingCharge} : ',
                            style: _theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                            ),
                            children: [
                              TextSpan(
                                text:
                                    '$currency${mainConstant.formatPointNumber(widget.saleTransaction.shippingCharge ?? 0)}',
                              ),
                            ],
                          ),
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      ///______Rounded_amount__________________________________
                      Visibility(
                        visible: widget.saleTransaction.roundingAmount != 0,
                        child: Column(
                          children: [
                            ///------------Total Amount----------------
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text.rich(
                                TextSpan(
                                  text: '${_lang.total} :',
                                  style: _theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '$currency${mainConstant.formatPointNumber(widget.saleTransaction.actualTotalAmount ?? 0)}',
                                    ),
                                  ],
                                ),
                                style: _theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            ///------------rounding amount----------------
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text.rich(
                                TextSpan(
                                  text: '${_lang.rounding} : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          '$currency${!(widget.saleTransaction.roundingAmount?.isNegative ?? true) ? '+' : ''}${mainConstant.formatPointNumber(widget.saleTransaction.roundingAmount ?? 0)}',
                                    ),
                                  ],
                                ),
                                style: _theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),

                      ///------------total amount----------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            text: '${lang.S.of(context).totalAmount} : ',
                            children: [
                              TextSpan(
                                text:
                                    '$currency${mainConstant.formatPointNumber(getTotalReturndAmount() + (widget.saleTransaction.totalAmount ?? 0))}',
                              ),
                            ],
                          ),
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                      ),

                      ///______________Returned_Product_______________________________
                      if (widget.saleTransaction.salesReturns!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              //SL
                              Expanded(
                                flex: 1,
                                child: Text(
                                  _lang.sl,
                                  textAlign: TextAlign.start,
                                  style: _theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                ),
                              ),
                              //Quantity
                              Expanded(
                                flex: 2,
                                child: Text(
                                  locale == 'en' ? 'R.Item' : _lang.returnedItem,
                                  textAlign: TextAlign.start,
                                  style: _theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                ),
                              ),
                              //Product
                              Expanded(
                                flex: 3,
                                child: Text(
                                  _lang.returnedDate,
                                  textAlign: TextAlign.start,
                                  style: _theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                ),
                              ),
                              //Unit Price
                              Expanded(
                                flex: 1,
                                child: Text(
                                  _lang.qty,
                                  textAlign: TextAlign.center,
                                  style: _theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                ),
                              ),
                              //Amount
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lang.S.of(context).totalPrice,
                                  textAlign: TextAlign.end,
                                  style: _theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                        for (var i = 0; i < (widget.saleTransaction.salesReturns?.length ?? 0); i++)
                          for (var detailIndex = 0;
                              detailIndex < (widget.saleTransaction.salesReturns?[i].salesReturnDetails?.length ?? 0);
                              detailIndex++)
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      (serialNumber++).toString(),
                                      textAlign: TextAlign.start,
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName(
                                              detailsId: widget.saleTransaction.salesReturns?[i]
                                                      .salesReturnDetails?[detailIndex].saleDetailId ??
                                                  0),
                                          textAlign: TextAlign.start,
                                          style: _theme.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                          ),
                                        ),
                                        if (widget.saleTransaction.salesReturns![i].salesReturnDetails![detailIndex]
                                                    .serialNumbers !=
                                                null &&
                                            widget.saleTransaction.salesReturns![i].salesReturnDetails![detailIndex]
                                                .serialNumbers!.isNotEmpty)
                                          Text(
                                            '${_lang.serial}: ${widget.saleTransaction.salesReturns![i].salesReturnDetails![detailIndex].serialNumbers!.join(", ")}',
                                          )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Text(
                                          DateFormat.yMMMd().format(DateTime.parse(
                                              widget.saleTransaction.salesReturns?[i].returnDate ??
                                                  DateTime.now().toString())),
                                          textAlign: TextAlign.start,
                                          style: _theme.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      mainConstant.formatPointNumber(widget.saleTransaction.salesReturns?[i]
                                              .salesReturnDetails?[detailIndex].returnQty ??
                                          0),
                                      textAlign: TextAlign.center,
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '$currency${mainConstant.formatPointNumber((widget.saleTransaction.salesReturns?[i].salesReturnDetails?[detailIndex].returnAmount ?? 0), addComma: true)}',
                                      textAlign: TextAlign.end,
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        SizedBox(height: 7),
                        globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                        SizedBox(height: 12),
                      ],

                      ///__________Total Return amount______________________
                      if (widget.saleTransaction.salesReturns!.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text.rich(
                            TextSpan(
                              text: '${lang.S.of(context).totalReturnAmount} : ',
                              children: [
                                TextSpan(
                                  text: '$currency${mainConstant.formatPointNumber(getTotalReturndAmount())}',
                                ),
                              ],
                            ),
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),

                      ///-----------total payable-------------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            text: '${lang.S.of(context).totalPayable} : ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text:
                                    '$currency${mainConstant.formatPointNumber(widget.saleTransaction.totalAmount ?? 0)}',
                              ),
                            ],
                          ),
                          style: _theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),

                      ///-------paid-----------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            text: '${lang.S.of(context).receivedAmount} : ',
                            children: [
                              TextSpan(
                                text:
                                    '$currency${mainConstant.formatPointNumber(((widget.saleTransaction.totalAmount ?? 0) - (widget.saleTransaction.dueAmount ?? 0)) + (widget.saleTransaction.changeAmount ?? 0))}',
                              ),
                            ],
                          ),
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),

                      ///-------------due---------------
                      Visibility(
                        visible: (widget.saleTransaction.dueAmount ?? 0) > 0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text.rich(
                            TextSpan(
                              text: '${lang.S.of(context).due} : ',
                              children: [
                                TextSpan(
                                  text:
                                      '$currency${mainConstant.formatPointNumber(widget.saleTransaction.dueAmount ?? 0)}',
                                ),
                              ],
                            ),
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                            ),
                          ),
                        ),
                      ),

                      ///-------------Change Amount---------------
                      Visibility(
                        visible: (widget.saleTransaction.changeAmount ?? 0) > 0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text.rich(
                            TextSpan(
                              text: '${_lang.changeAmount} : ',
                              children: [
                                TextSpan(
                                  text:
                                      '$currency${mainConstant.formatPointNumber(widget.saleTransaction.changeAmount ?? 0)}',
                                ),
                              ],
                            ),
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                      SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${_lang.paidVia} :',
                            style: _theme.textTheme.titleLarge?.copyWith(
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ...?(widget.saleTransaction.transactions?.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;

                            String label;
                            switch (item.transactionType) {
                              case 'cash_payment':
                                label = 'Cash';
                                break;

                              case 'cheque_payment':
                                label = 'Cheque';
                                break;

                              case 'wallet_payment':
                                label = 'Wallet';
                                break;

                              default:
                                label = item.paymentType?.name ?? 'n/a';
                            }

                            final isLast = index == widget.saleTransaction.transactions!.length - 1;
                            final text = isLast ? label : '$label,';

                            return Text(
                              text,
                              style: _theme.textTheme.titleLarge?.copyWith(
                                fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList()),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Visibility(
                        visible: widget.saleTransaction.image?.isNotEmpty ?? false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _lang.attachment,
                              style: _theme.textTheme.titleLarge?.copyWith(
                                fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 100,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xffF5F3F3),
                                image: DecorationImage(
                                    image: NetworkImage(
                                      '${widget.saleTransaction.image}',
                                    ),
                                    fit: BoxFit.contain),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.businessInfo.data?.showNote == 1) ...[
                        Text(
                          '${widget.businessInfo.data?.invoiceNoteLevel ?? ''}: ${widget.businessInfo.data?.invoiceNote ?? ''}',
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                      if (widget.businessInfo.data?.gratitudeMessage != null &&
                          widget.businessInfo.data?.showGratitudeMsg == 1)
                        Center(
                          child: Text(
                            widget.businessInfo.data?.gratitudeMessage ?? '',
                            maxLines: 3,
                            style: _theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (widget.businessInfo.data?.showInvoiceScannerLogo == 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: UniversalImage(
                              imagePath: '${widget.businessInfo.data?.invoiceScannerLogo}',
                              height: 120,
                              width: 120,
                            ),
                          ),
                        ),

                      if (widget.businessInfo.data?.developByLevel != null ||
                          widget.businessInfo.data?.developBy != null)
                        Center(
                          child: Text(
                            '${widget.businessInfo.data?.developByLevel ?? ''} ${widget.businessInfo.data?.developBy ?? ''}',
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              fontSize: fontSizeForPrinter(widget.businessInfo.data?.invoiceSize),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              )),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          if (widget.fromSale ?? false) {
                            int count = 0;
                            bool popped = false;

                            Navigator.popUntil(context, (route) {
                              count++;
                              if (count == 2 && !popped) {
                                popped = true;
                                Navigator.pop(context, true);
                              }
                              return count == 2;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          lang.S.of(context).cancel,
                          //'Cancel',
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    pro.Consumer<LanguageChangeProvider>(
                      builder: (BuildContext context, LanguageChangeProvider value, Widget? child) {
                        return Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              PrintSalesTransactionModel model = PrintSalesTransactionModel(
                                  transitionModel: widget.saleTransaction,
                                  personalInformationModel: widget.businessInfo);
                              await printerData.printSalesThermalInvoiceNow(
                                transaction: model,
                                productList: model.transitionModel!.salesDetails,
                                context: context,
                              );
                            },
                            child: Text(
                              lang.S.of(context).print,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
