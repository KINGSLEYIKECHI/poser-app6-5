// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Expense/Model/expanse_category.dart';
import 'package:mobile_pos/Screens/Expense/expense_category_list.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../generated/l10n.dart' as lang;
import '../../service/check_user_role_permission_provider.dart';
import '../../widgets/multipal payment mathods/multi_payment_widget.dart';
import 'Repo/expanse_repo.dart';

// ignore: must_be_immutable
class AddExpense extends ConsumerStatefulWidget {
  const AddExpense({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends ConsumerState<AddExpense> {
  ExpenseCategory? selectedCategory;
  final dateController = TextEditingController();
  TextEditingController expanseForNameController = TextEditingController();
  TextEditingController expanseAmountController = TextEditingController();
  TextEditingController expanseNoteController = TextEditingController();
  TextEditingController expanseRefController = TextEditingController();

  // (CHANGE 1) GlobalKey-ke public state class (`MultiPaymentWidgetState`) diye update kora holo
  final GlobalKey<MultiPaymentWidgetState> _paymentKey = GlobalKey<MultiPaymentWidgetState>();

  @override
  void initState() {
    super.initState();
    // All payment listeners are now in MultiPaymentWidget
  }

  @override
  void dispose() {
    // Dispose all parent controllers
    dateController.dispose();
    expanseForNameController.dispose();
    expanseAmountController.dispose();
    expanseNoteController.dispose();
    expanseRefController.dispose();
    // All payment controllers are disposed by MultiPaymentWidget
    super.dispose();
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2030)); // Error fixed: 20121 -> 2021
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
    // bankListAsync is no longer needed here, MultiPaymentWidget will handle it

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            lang.S.of(context).addExpense,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                labelText: lang.S.of(context).expenseDate,
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
                      Container(
                        height: 48.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            selectedCategory = await const ExpenseCategoryList().launch(context);
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              const SizedBox(width: 10.0),
                              Text(selectedCategory?.categoryName ?? lang.S.of(context).selectCategory),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down),
                              const SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///________Expense_for_______________________________________________
                      TextFormField(
                        showCursor: true,
                        controller: expanseForNameController,
                        validator: (value) {
                          if (value.isEmptyOrNull) {
                            return lang.S.of(context).pleaseEnterName;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          expanseForNameController.text = value!;
                        },
                        decoration: kInputDecoration.copyWith(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).expenseFor,
                          hintText: lang.S.of(context).enterName,
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///_________________Total Amount_____________________________
                      TextFormField(
                        controller: expanseAmountController,
                        // (CHANGE 2) readOnly logic-ti notun key diye update kora holo
                        readOnly: (_paymentKey.currentState?.getPaymentEntries().length ?? 1) > 1,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        validator: (value) {
                          if (value.isEmptyOrNull) {
                            return lang.S.of(context).pleaseEnterAmount;
                          }
                          // Get total from the controller itself
                          final total = double.tryParse(value ?? '') ?? 0.0;
                          if (total <= 0) {
                            return lang.S.of(context).amountMustBeGreaterThanZero;
                          }
                          return null;
                        },
                        decoration: kInputDecoration.copyWith(
                          // (CHANGE 3) fillColor logic-ti notun key diye update kora holo
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
                        controller: expanseRefController,
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          expanseRefController.text = value!;
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
                        controller: expanseNoteController,
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          expanseNoteController.text = value!;
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
                        totalAmountController: expanseAmountController,
                        showChequeOption: false,
                        onPaymentListChanged: () {
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 20),

                      ///_______button_________________________________
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          iconAlignment: IconAlignment.end,
                          label: Text(lang.S.of(context).continueButton),
                          onPressed: () async {
                            if (!permissionService.hasPermission(Permit.expensesCreate.value)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(lang.S.of(context).youDonNotHavePermissionToCreateExpense),
                                ),
                              );
                              return;
                            }
                            if (validateAndSave()) {
                              // (CHANGE 5) Notun key diye data neya hocche
                              final totalExpense = double.tryParse(expanseAmountController.text) ?? 0.0;
                              final payments = _paymentKey.currentState?.getPaymentEntries();

                              if (selectedCategory == null) {
                                EasyLoading.showError(lang.S.of(context).pleaseSelectAExpenseCategory);
                                return;
                              }

                              if (totalExpense <= 0) {
                                EasyLoading.showError(lang.S.of(context).amountMustBeGreaterThanZero);
                                return;
                              }

                              if (payments == null || payments.isEmpty) {
                                EasyLoading.showError(lang.S.of(context).canNotRetrievePaymentDetails);
                                return;
                              }

                              EasyLoading.show();
                              ExpenseRepo repo = ExpenseRepo();

                              await repo.createExpense(
                                ref: ref,
                                context: context,
                                amount: totalExpense, // Use state variable
                                expenseCategoryId: selectedCategory?.id ?? 0,
                                expanseFor: expanseForNameController.text,
                                referenceNo: expanseRefController.text,
                                expenseDate: selectedDate.toString(),
                                note: expanseNoteController.text,
                                payments: payments, // Pass the payment list
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
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
