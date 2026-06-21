import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Model/due_collection_model.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Model/guest_due_model.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Repo/due_repo.dart';
import 'package:mobile_pos/Screens/invoice_details/due_invoice_details.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../widgets/multipal payment mathods/multi_payment_widget.dart';
import '../Customers/Model/parties_model.dart';

class GuestDueCollectionScreen extends StatefulWidget {
  const GuestDueCollectionScreen({super.key, required this.guestDueModel});

  final GuestDueModel guestDueModel;

  @override
  State<GuestDueCollectionScreen> createState() => _GuestDueCollectionScreenState();
}

class _GuestDueCollectionScreenState extends State<GuestDueCollectionScreen> {
  // Key for MultiPaymentWidget
  final GlobalKey<MultiPaymentWidgetState> paymentWidgetKey = GlobalKey();

  num paidAmount = 0;
  num remainDueAmount = 0;
  num dueAmount = 0;

  num calculateDueAmount({required num total}) {
    if (total < 0) {
      remainDueAmount = 0;
    } else {
      remainDueAmount = dueAmount - total;
    }
    return dueAmount - total;
  }

  TextEditingController paidText = TextEditingController();
  TextEditingController dateController = TextEditingController(text: DateTime.now().toString().substring(0, 10));
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize due amount from the model
    dueAmount = widget.guestDueModel.dueAmount ?? 0;

    // Listener to update state when paidText changes
    paidText.addListener(() {
      if (paidText.text.isEmpty) {
        if (mounted) {
          setState(() {
            paidAmount = 0;
          });
        }
      } else {
        final val = double.tryParse(paidText.text) ?? 0;
        // Validation: Cannot pay more than due
        if (val <= dueAmount) {
          if (mounted) {
            setState(() {
              paidAmount = val;
            });
          }
        } else {
          paidText.clear();
          if (mounted) {
            setState(() {
              paidAmount = 0;
            });
          }
          EasyLoading.showError(lang.S.of(context).youCanNotPayMoreThenDue);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, consumerRef, __) {
      final personalData = consumerRef.watch(businessInfoProvider);
      final _theme = Theme.of(context);

      return personalData.when(
        data: (data) {
          return GlobalPopup(
            child: Scaffold(
              backgroundColor: kWhite,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(lang.S.of(context).collectDue),
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.black),
                elevation: 0.0,
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Only show invoice number, no dropdown since it's already selected
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  initialValue: widget.guestDueModel.invoiceNumber,
                                  decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: 'Invoice Number',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.name,
                                  readOnly: true,
                                  controller: dateController,
                                  decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: lang.S.of(context).date,
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      onPressed: () async {
                                        final DateTime? picked = await showDatePicker(
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2015, 8),
                                          lastDate: DateTime(2101),
                                          context: context,
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            selectedDate = selectedDate.copyWith(
                                              year: picked.year,
                                              month: picked.month,
                                              day: picked.day,
                                            );
                                            dateController.text = picked.toString().substring(0, 10);
                                          });
                                        }
                                      },
                                      icon: const Icon(FeatherIcons.calendar),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Customer Name (Guest)
                          TextFormField(
                            readOnly: true,
                            initialValue: 'Guest Customer',
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).customerName,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          ///_____Total Calculation Box______________________________
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              color: _theme.colorScheme.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff000000).withValues(alpha: 0.08),
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffFEF0F1),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      topLeft: Radius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang.S.of(context).totalAmount,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        dueAmount.toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang.S.of(context).paidAmount,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: context.width() / 4,
                                        height: 30,
                                        child: TextFormField(
                                          controller: paidText,
                                          readOnly:
                                              (paymentWidgetKey.currentState?.getPaymentEntries().length ?? 1) > 1,
                                          textAlign: TextAlign.right,
                                          decoration: const InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(color: kNeutralColor),
                                            border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                            focusedBorder: UnderlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang.S.of(context).dueAmount,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        calculateDueAmount(total: paidAmount).toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    ///__________Payment_Type_Widget_______________________________________
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Divider(height: 20),
                          MultiPaymentWidget(
                            key: paymentWidgetKey,
                            showWalletOption: false, // Guests don't have wallet
                            showChequeOption: true,
                            totalAmountController: paidText,
                            onPaymentListChanged: () {},
                          ),
                          const Divider(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          maximumSize: const Size(double.infinity, 48),
                          minimumSize: const Size(double.infinity, 48),
                          disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          lang.S.of(context).cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            color: _theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: OutlinedButton.styleFrom(
                          maximumSize: const Size(double.infinity, 48),
                          minimumSize: const Size(double.infinity, 48),
                          disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                        ),
                        onPressed: () async {
                          if (paidAmount > 0 && dueAmount > 0) {
                            List<PaymentEntry> payments = paymentWidgetKey.currentState?.getPaymentEntries() ?? [];

                            if (payments.isEmpty) {
                              EasyLoading.showError(lang.S.of(context).noDueSelected);
                            } else {
                              EasyLoading.show();
                              List<Map<String, dynamic>> paymentData = payments.map((e) => e.toJson()).toList();

                              DueRepo repo = DueRepo();
                              DueCollection? dueData = await repo.guestDueCollect(
                                ref: consumerRef,
                                context: context,
                                invoiceNumber: widget.guestDueModel.invoiceNumber,
                                paymentDate: selectedDate.toIso8601String(),
                                payments: paymentData,
                                payDueAmount: paidAmount,
                              );

                              EasyLoading.dismiss();

                              if (dueData != null && mounted) {
                                final dueDataWithParty = dueData.copyWith(
                                  party: Party(
                                    name: 'Guest Customer',
                                    phone: "N/A",
                                  ),
                                );

                                DueInvoiceDetails(
                                  dueCollection: dueDataWithParty,
                                  personalInformationModel: data, // Directly using data from the .when block
                                  isFromDue: true,
                                ).launch(context);
                              }
                            }
                          } else {
                            EasyLoading.showError(lang.S.of(context).noDueSelected);
                          }
                        },
                        child: Text(
                          lang.S.of(context).save,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            color: _theme.colorScheme.primaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        error: (e, stack) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      );
    });
  }
}
