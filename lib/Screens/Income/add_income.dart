// ignore_for_file: unused_result
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Income/Model/income_category.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../../widgets/multipal payment mathods/multi_payment_widget.dart';
import 'Repo/income_repo.dart';
import 'income_category_list.dart';

// ignore: must_be_immutable
class AddIncome extends ConsumerStatefulWidget {
  const AddIncome({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends ConsumerState<AddIncome> {
  IncomeCategory? selectedCategory;
  final dateController = TextEditingController();
  TextEditingController incomeForNameController = TextEditingController();
  TextEditingController incomeAmountController = TextEditingController();
  TextEditingController incomeNoteController = TextEditingController();
  TextEditingController incomeRefController = TextEditingController();

  final GlobalKey<MultiPaymentWidgetState> _paymentKey = GlobalKey<MultiPaymentWidgetState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    incomeForNameController.dispose();
    incomeAmountController.dispose();
    incomeNoteController.dispose();
    incomeRefController.dispose();
    super.dispose();
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService(ref);

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            lang.S.of(context).addIncome,
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: context.width(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      ///_______date________________________________
                      SizedBox(
                        height: 48,
                        child: FormField(
                          builder: (FormFieldState<dynamic> field) {
                            return InputDecorator(
                              decoration: kInputDecoration.copyWith(
                                suffixIcon: const Icon(IconlyLight.calendar, color: kGreyTextColor),
                                contentPadding: const EdgeInsets.all(8),
                                labelText: lang.S.of(context).incomeDate,
                                hintText: lang.S.of(context).enterExpenseDate,
                              ),
                              child: Text(
                                '${DateFormat.d().format(selectedDate)} ${DateFormat.MMM().format(selectedDate)} ${DateFormat.y().format(selectedDate)}',
                              ),
                            );
                          },
                        ).onTap(() => _selectDate(context)),
                      ),
                      const SizedBox(height: 20),

                      ///_________category_______________________________________________
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                            text: selectedCategory?.categoryName ?? lang.S.of(context).selectCategory),
                        onTap: () async {
                          selectedCategory = await const IncomeCategoryList().launch(context);
                          setState(() {});
                        },
                        decoration: kInputDecoration.copyWith(
                          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(color: kBorderColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(color: kBorderColor, width: 1),
                          ),
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ///________Income_for_______________________________________________
                      TextFormField(
                        showCursor: true,
                        controller: incomeForNameController,
                        validator: (value) {
                          if (value.isEmptyOrNull) {
                            return lang.S.of(context).pleaseEnterName;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          incomeForNameController.text = value!;
                        },
                        decoration: kInputDecoration.copyWith(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).incomeFor,
                          hintText: lang.S.of(context).enterName,
                        ),
                      ),
                      const SizedBox.square(dimension: 20),

                      ///_________________Total Amount_____________________________
                      TextFormField(
                        controller: incomeAmountController,
                        readOnly: (_paymentKey.currentState?.getPaymentEntries().length ?? 1) > 1,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        validator: (value) {
                          if (value.isEmptyOrNull) {
                            return lang.S.of(context).pleaseEnterAmount;
                          }
                          final total = double.tryParse(value ?? '') ?? 0.0;
                          if (total <= 0) {
                            return lang.S.of(context).amountMustBeGreaterThanZero;
                          }
                          return null;
                        },
                        decoration: kInputDecoration.copyWith(
                          fillColor: (_paymentKey.currentState?.getPaymentEntries().length ?? 1) > 1
                              ? Colors.grey.shade100
                              : Colors.white,
                          filled: true,
                          border: const OutlineInputBorder(),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          labelText: lang.S.of(context).amount,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: '0.00',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      ///_______reference_________________________________
                      TextFormField(
                        showCursor: true,
                        controller: incomeRefController,
                        validator: (value) {
                          return null; // Reference is optional
                        },
                        onSaved: (value) {
                          incomeRefController.text = value!;
                        },
                        decoration: kInputDecoration.copyWith(
                          border: const OutlineInputBorder(),
                          labelText: lang.S.of(context).referenceNo,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: lang.S.of(context).enterRefNumber,
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///_________note____________________________________________________
                      TextFormField(
                        showCursor: true,
                        controller: incomeNoteController,
                        validator: (value) {
                          return null; // Note is optional
                        },
                        onSaved: (value) {
                          incomeNoteController.text = value!;
                        },
                        decoration: kInputDecoration.copyWith(
                          border: const OutlineInputBorder(),
                          labelText: lang.S.of(context).note,
                          hintText: lang.S.of(context).enterNote,
                        ),
                      ),
                      const SizedBox(height: 20),

                      MultiPaymentWidget(
                        key: _paymentKey,
                        totalAmountController: incomeAmountController,
                        showChequeOption: true,
                        onPaymentListChanged: () {
                          setState(() {
                            // Rebuild to update readOnly status of amount field
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      ///_______button_________________________________
                      ElevatedButton.icon(
                        iconAlignment: IconAlignment.end,
                        onPressed: () async {
                          if (validateAndSave()) {
                            if (!permissionService.hasPermission(Permit.incomesCreate.value)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(lang.S.of(context).youDonNotHavePermissionToCreateIncome),
                                ),
                              );
                              return;
                            }

                            final totalIncome = double.tryParse(incomeAmountController.text) ?? 0.0;
                            final payments = _paymentKey.currentState?.getPaymentEntries();

                            if (selectedCategory == null) {
                              EasyLoading.showError(lang.S.of(context).pleaseSelectACategory);
                              return;
                            }

                            if (totalIncome <= 0) {
                              EasyLoading.showError(lang.S.of(context).amountMustBeGreaterThanZero);
                              return;
                            }

                            if (payments == null || payments.isEmpty) {
                              EasyLoading.showError(lang.S.of(context).canNotRetrievePaymentDetails);
                              return;
                            }

                            EasyLoading.show();
                            IncomeRepo repo = IncomeRepo();

                            await repo.createIncome(
                              ref: ref,
                              context: context,
                              amount: totalIncome,
                              incomeCategoryId: selectedCategory?.id ?? 0,
                              incomeFor: incomeForNameController.text,
                              referenceNo: incomeRefController.text,
                              incomeDate: selectedDate.toString(),
                              note: incomeNoteController.text,
                              payments: payments, // Pass the payment list
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(lang.S.of(context).continueButton),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
