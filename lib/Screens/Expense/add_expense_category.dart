// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Expense/Repo/expanse_category_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../http_client/custome_http_client.dart';
import '../../service/check_user_role_permission_provider.dart';

class AddExpenseCategory extends StatefulWidget {
  const AddExpenseCategory({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseCategoryState createState() => _AddExpenseCategoryState();
}

class _AddExpenseCategoryState extends State<AddExpenseCategory> {
  bool showProgress = false;

  TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      //final allCategory = ref.watch(expanseCategoryProvider);
      final permissionService = PermissionService(ref);
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).addExpenseCat,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: showProgress,
                    child: const CircularProgressIndicator(
                      color: kMainColor,
                      strokeWidth: 5.0,
                    ),
                  ),
                  Form(
                    key: key,
                    child: TextFormField(
                      validator: (value) {
                        if (value?.trim().isEmptyOrNull ?? true) {
                          //return 'Enter expanse category name';
                          return lang.S.of(context).enterExpanseCategoryName;
                        }
                        return null;
                      },
                      controller: nameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: lang.S.of(context).fashions,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: lang.S.of(context).categoryName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!permissionService.hasPermission(Permit.expenseCategoriesCreate.value)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(lang.S.of(context).youDoNotHavePermissionToCreateExpenseCategory),
                          ),
                        );
                        return;
                      }
                      if (key.currentState?.validate() ?? false) {
                        EasyLoading.show();
                        final categoryRepo = ExpanseCategoryRepo();
                        await categoryRepo.addExpanseCategory(
                          ref: ref,
                          context: context,
                          categoryName: nameController.text.trim(),
                        );
                      }
                    },
                    child: Text(lang.S.of(context).save),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
