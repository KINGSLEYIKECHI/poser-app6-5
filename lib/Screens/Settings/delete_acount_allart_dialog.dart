import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../Authentication/Repo/logout_repo.dart';
import 'account detele/repo/delete_account_repo.dart';

void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  final _lang = lang.S.of(context);
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isChecked = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // AlertDialog-er baire theke SingleChildScrollView soriye deya hoyeche
          return AlertDialog(
            title: Text(_lang.deleteAcc),
            content: SingleChildScrollView(
              // Ekhane use korun
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Column-ke tar dorkari jayga nite bolbe
                  children: [
                    Text(
                      _lang.deleteDialogDetails,
                      style: TextStyle(color: kMainColor),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: _lang.enterYourPassword,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _lang.passwordIsRequired;
                        }
                        if (value.length < 6) {
                          return _lang.passwordMust6Character;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      title: Text(_lang.iAgreeDeleteMyAccountPermanent),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(_lang.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                onPressed: isChecked
                    ? () async {
                        if (formKey.currentState!.validate()) {
                          // ref.read use kora better callback function-er bhetor
                          final businessId = ref.read(businessInfoProvider).value?.data?.id.toString() ?? '';

                          final bool isDeleted = await DeleteAccountRepository()
                              .deleteAccount(businessId: businessId, password: passwordController.text);

                          if (isDeleted) {
                            await LogOutRepo().signOut();
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMainColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(_lang.delete),
              ),
            ],
          );
        },
      );
    },
  );
}
