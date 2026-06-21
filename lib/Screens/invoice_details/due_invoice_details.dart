import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/invoice_details/components/common_image_builder.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart' as pro;

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart' as mainConstant;
import '../../constant.dart' show fontSizeForPrinter;
import '../../model/business_info_model.dart';
import '../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../widgets/dotted_border/global_dotted_border.dart';
import '../../widgets/universal_image.dart';
import '../Due Calculation/Model/due_collection_model.dart';
import '../language/language_provider.dart';

class DueInvoiceDetails extends StatefulWidget {
  const DueInvoiceDetails({
    super.key,
    required this.dueCollection,
    required this.personalInformationModel,
    this.isFromDue,
  });

  final DueCollection dueCollection;
  final BusinessInformationModel personalInformationModel;
  final bool? isFromDue;

  @override
  State<DueInvoiceDetails> createState() => _DueInvoiceDetailsState();
}

class _DueInvoiceDetailsState extends State<DueInvoiceDetails> {
  final GlobalKey _screenshotKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _theme = Theme.of(context);
    final _lang = lang.S.of(context);
    return Consumer(
      builder: (context, ref, __) {
        final printerData = ref.watch(thermalPrinterProvider);
        final businessSettingData = ref.watch(businessInfoProvider);
        final locale = Localizations.localeOf(context).languageCode;
        return GlobalPopup(
          child: SafeArea(
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
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ///----------------header--------------------------------------------
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //----------Invoice Logo------------------------
                                  if (widget.personalInformationModel.data?.showThermalInvoiceLogo == 1)
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
                                                    height: 54.12,
                                                    width: 52,
                                                    fit: BoxFit.cover,
                                                    colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                                  )
                                                : buildInvoiceLogo(image: NetworkImage(imageUrl));
                                      },
                                      error: (e, stack) => Text(e.toString()),
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                    ),
                                  //----------company name---------------------------
                                  if (widget.personalInformationModel.data?.meta?.showCompanyName == 1)
                                    Text('${widget.personalInformationModel.data?.companyName}',
                                        style: _theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                                  //-------------company Branch---------------------------------
                                  if (widget.dueCollection.branch?.name?.isNotEmpty ?? false)
                                    Text.rich(
                                      TextSpan(
                                        text: '${_lang.branch} : ',
                                        children: [
                                          TextSpan(
                                            text: widget.dueCollection.branch?.name.toString() ?? 'n/a',
                                            style: _theme.textTheme.bodyLarge?.copyWith(
                                              fontSize:
                                                  fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                              color: mainConstant.kTextColor,
                                            ),
                                          ),
                                        ],
                                        style: _theme.textTheme.bodyLarge?.copyWith(
                                          fontSize:
                                              fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                          color: mainConstant.kTextColor,
                                        ),
                                      ),
                                    ),
                                  //----------------Address----------------------------------
                                  if (widget.personalInformationModel.data?.meta?.showAddress == 1)
                                    Text(
                                      '${_lang.address}: ${widget.personalInformationModel.data?.address ?? ''}',
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),
                                  //---------------Phone-------------------------------------------
                                  if (widget.personalInformationModel.data?.meta?.showPhoneNumber == 1)
                                    Text(
                                      '${_lang.mobile} ${(widget.dueCollection.branch?.phone?.isNotEmpty ?? false) ? widget.dueCollection.branch?.phone?.toString() ?? 'n/a' : widget.personalInformationModel.data?.phoneNumber?.toString() ?? 'n/a'}',
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),
                                  //-----------------email----------------------------
                                  if (widget.personalInformationModel.data?.meta?.showEmail == 1)
                                    Text(
                                      '${_lang.email}: ${widget.personalInformationModel.data?.user?.email ?? ''}',
                                      style: _theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                        color: mainConstant.kTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  SizedBox(height: 8),
                                  //-----------------Invoice-------------------
                                  Text(
                                    _lang.moneyReceipt.toUpperCase(),
                                    style: _theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

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
                                          text: '${lang.S.of(context).receipt} : ',
                                          children: [
                                            TextSpan(
                                              text: widget.dueCollection.invoiceNumber ?? '',
                                              style: _theme.textTheme.titleSmall?.copyWith(
                                                fontSize: fontSizeForPrinter(
                                                    widget.personalInformationModel.data?.invoiceSize),
                                                color: mainConstant.kTextColor,
                                              ),
                                            ),
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize:
                                                fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      //invoice
                                      Text.rich(
                                        TextSpan(
                                          text: widget.dueCollection.party?.type == 'Supplier'
                                              ? 'Purchase Invoice : '
                                              : 'Sale Invoice : ',
                                          children: [
                                            TextSpan(
                                              text: widget.dueCollection.party?.type == 'Supplier'
                                                  ? widget.dueCollection.purchase?.invoiceNumber ?? 'N/A'
                                                  : widget.dueCollection.sale?.invoiceNumber ?? 'N/A',
                                            ),
                                          ],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize:
                                                fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      //name
                                      Text.rich(
                                        TextSpan(
                                          text: '${lang.S.of(context).name} : ',
                                          children: [TextSpan(text: widget.dueCollection.party?.name ?? 'Guest')],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize:
                                                fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      //mobile
                                      Text.rich(
                                        TextSpan(
                                          text: '${lang.S.of(context).mobile} ',
                                          children: [TextSpan(text: widget.dueCollection.party?.phone ?? '')],
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontSize:
                                                fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                            color: mainConstant.kTextColor,
                                          ),
                                        ),
                                      ),
                                      if (widget.personalInformationModel.data?.invoiceSize != "3_inch_80mm") ...[
                                        //date----------------
                                        Text.rich(
                                          TextSpan(
                                            text: '${lang.S.of(context).date} : ',
                                            children: [
                                              TextSpan(
                                                  text: DateFormat.yMMMd()
                                                      .format(DateTime.parse(widget.dueCollection.paymentDate ?? '')))
                                            ],
                                            style: _theme.textTheme.bodyMedium?.copyWith(
                                              fontSize:
                                                  fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
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
                                                      widget.dueCollection.paymentDate ?? DateTime.now().toString())))
                                            ],
                                            style: _theme.textTheme.bodyMedium?.copyWith(
                                              fontSize:
                                                  fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                              color: mainConstant.kTextColor,
                                            ),
                                          ),
                                        ),
                                        //Sales by
                                        Text.rich(
                                          TextSpan(
                                            text: '${lang.S.of(context).collectedBy} ',
                                            children: [
                                              TextSpan(
                                                  text: widget.dueCollection.user?.role == "shop-owner"
                                                      ? 'Admin'
                                                      : widget.dueCollection.user?.name ?? '')
                                            ],
                                            style: _theme.textTheme.titleSmall?.copyWith(
                                                fontSize: fontSizeForPrinter(
                                                    widget.personalInformationModel.data?.invoiceSize),
                                                color: mainConstant.kTextColor),
                                          ),
                                        ),
                                        //Vat Number
                                        Visibility(
                                          visible: widget.personalInformationModel.data?.vatNo != null &&
                                              widget.personalInformationModel.data?.meta?.showVat == 1,
                                          child: Text.rich(
                                            TextSpan(
                                              text:
                                                  '${widget.personalInformationModel.data?.vatName ?? _lang.vatNumber} : ',
                                              children: [
                                                TextSpan(text: widget.personalInformationModel.data?.vatNo ?? '')
                                              ],
                                              style: _theme.textTheme.bodyLarge?.copyWith(
                                                fontSize: fontSizeForPrinter(
                                                    widget.personalInformationModel.data?.invoiceSize),
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
                                SizedBox(width: 8),
                                if (widget.personalInformationModel.data?.invoiceSize == "3_inch_80mm") ...[
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
                                                  text: DateFormat.yMMMd()
                                                      .format(DateTime.parse(widget.dueCollection.paymentDate ?? '')))
                                            ],
                                            style: _theme.textTheme.bodyMedium?.copyWith(
                                              fontSize:
                                                  fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
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
                                                      widget.dueCollection.paymentDate ?? DateTime.now().toString())))
                                            ],
                                            style: _theme.textTheme.bodyMedium?.copyWith(
                                              fontSize:
                                                  fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                              color: mainConstant.kTextColor,
                                            ),
                                          ),
                                        ),
                                        //Sales by
                                        Text.rich(
                                          TextSpan(
                                            text: '${lang.S.of(context).collectedBy} ',
                                            children: [
                                              TextSpan(
                                                  text: widget.dueCollection.user?.role == "shop-owner"
                                                      ? 'Admin'
                                                      : widget.dueCollection.user?.name ?? '')
                                            ],
                                            style: _theme.textTheme.titleSmall?.copyWith(
                                                fontSize: fontSizeForPrinter(
                                                    widget.personalInformationModel.data?.invoiceSize),
                                                color: mainConstant.kTextColor),
                                          ),
                                        ),
                                        //Vat Number
                                        Visibility(
                                          visible: widget.personalInformationModel.data?.vatNo != null &&
                                              widget.personalInformationModel.data?.meta?.showVat == 1,
                                          child: Text.rich(
                                            TextSpan(
                                              text:
                                                  '${widget.personalInformationModel.data?.vatName ?? _lang.vatNumber} : ',
                                              children: [
                                                TextSpan(text: widget.personalInformationModel.data?.vatNo ?? '')
                                              ],
                                              style: _theme.textTheme.bodyLarge?.copyWith(
                                                fontSize: fontSizeForPrinter(
                                                    widget.personalInformationModel.data?.invoiceSize),
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

                            ///-----------------header data----------------------------
                            const SizedBox(height: 12.0),

                            ///--------------------Product table data----------------------
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
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize) - 4,
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),
                                  ),
                                  //Product
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _lang.totalDue,
                                      textAlign: TextAlign.start,
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize) - 4,
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),
                                  ),
                                  //Quantity
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _lang.payment,
                                      textAlign: TextAlign.center,
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize) - 4,
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),
                                  ),
                                  //Unit Price
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _lang.remainingDue,
                                      textAlign: TextAlign.center,
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize) - 4,
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        '1',
                                        textAlign: TextAlign.start,
                                        style: _theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                          color: mainConstant.kTextColor,
                                        ),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        "$currency${widget.dueCollection.totalDue?.toStringAsFixed(2)}",
                                        textAlign: TextAlign.start,
                                        style: _theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                          color: mainConstant.kTextColor,
                                        ),
                                      )),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "$currency${(widget.dueCollection.totalDue!.toDouble() - widget.dueCollection.dueAmountAfterPay!).toStringAsFixed(2)}",
                                      // '$currency${formatPointNumber(saleDetail.price)}',
                                      textAlign: TextAlign.center,
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                        color: mainConstant.kTextColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        "$currency${widget.dueCollection.dueAmountAfterPay?.toStringAsFixed(2)}",
                                        textAlign: TextAlign.end,
                                        style: _theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                          color: mainConstant.kTextColor,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(height: 7),
                            globalDottedLine(borderColor: Colors.black54, height: 2, generatedLine: 60),
                            SizedBox(height: 12),
                            Align(
                              alignment: AlignmentGeometry.centerRight,
                              child: Text(
                                "${_lang.payableAmount}: $currency ${widget.dueCollection.totalDue?.toStringAsFixed(2) ?? '0.00'}",
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                  color: mainConstant.kTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${_lang.receivedAmount}: $currency ${(widget.dueCollection.totalDue!.toDouble() - widget.dueCollection.dueAmountAfterPay!.toDouble()).toStringAsFixed(2)}",
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                  color: mainConstant.kTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${_lang.dueAmount} $currency ${widget.dueCollection.dueAmountAfterPay?.toStringAsFixed(2) ?? '0.00'}",
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                  color: mainConstant.kTextColor,
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
                                  style: _theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: mainConstant.kPeraColor,
                                    fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                  ),
                                ),
                                ...?(widget.dueCollection.transactions?.asMap().entries.map((entry) {
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

                                  final isLast = index == widget.dueCollection.transactions!.length - 1;
                                  final text = isLast ? label : '$label,';

                                  return Text(
                                    text,
                                    style: _theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: mainConstant.kPeraColor,
                                      fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                    ),
                                  );
                                }).toList()),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                            if (widget.personalInformationModel.data?.showNote == 1) ...[
                              Text(
                                '${widget.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${widget.personalInformationModel.data?.invoiceNote ?? ''}',
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: mainConstant.kPeraColor,
                                  fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                            if (widget.personalInformationModel.data?.showGratitudeMsg == 1)
                              Center(
                                child: Text(
                                  widget.personalInformationModel.data?.gratitudeMessage ?? '',
                                  maxLines: 3,
                                  style: _theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: mainConstant.kPeraColor,
                                    fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (widget.personalInformationModel.data?.showInvoiceScannerLogo == 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: UniversalImage(
                                    imagePath: '${widget.personalInformationModel.data?.invoiceScannerLogo}',
                                    height: 120,
                                    width: 120,
                                  ),
                                ),
                              ),
                            if (widget.personalInformationModel.data?.developByLevel != null ||
                                widget.personalInformationModel.data?.developBy != null)
                              Center(
                                child: Text(
                                  '${widget.personalInformationModel.data?.developByLevel ?? ''} ${widget.personalInformationModel.data?.developBy ?? ''}',
                                  style: _theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: mainConstant.kPeraColor,
                                    fontSize: fontSizeForPrinter(widget.personalInformationModel.data?.invoiceSize),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
                            if (widget.isFromDue ?? false) {
                              int count = 0;
                              Navigator.popUntil(context, (route) {
                                return count++ == 2;
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            lang.S.of(context).cancel,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      pro.Consumer<LanguageChangeProvider>(
                        builder: (BuildContext context, LanguageChangeProvider value, Widget? child) {
                          return Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                PrintDueTransactionModel model = PrintDueTransactionModel(
                                  dueTransactionModel: widget.dueCollection,
                                  personalInformationModel: widget.personalInformationModel,
                                );
                                await printerData.printDueThermalInvoiceNow(
                                    invoiceSize: widget.personalInformationModel.data?.invoiceSize,
                                    transaction: model,
                                    context: context);
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
      },
    );
  }
}
