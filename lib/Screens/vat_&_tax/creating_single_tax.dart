import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/vat_&_tax/model/vat_model.dart';
import 'package:mobile_pos/Screens/vat_&_tax/repo/tax_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../service/check_user_role_permission_provider.dart';

class CreateSingleTax extends ConsumerStatefulWidget {
  const CreateSingleTax({super.key, this.taxModel});

  final VatModel? taxModel;

  @override
  ConsumerState<CreateSingleTax> createState() => _CreateSingleTaxState();
}

class _CreateSingleTaxState extends ConsumerState<CreateSingleTax> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController taxNameController;
  late TextEditingController taxRateController;

  bool status = true;

  @override
  void initState() {
    super.initState();
    taxNameController = TextEditingController(text: widget.taxModel?.name ?? '');
    taxRateController = TextEditingController(
      text: widget.taxModel?.rate != null ? widget.taxModel!.rate.toString() : '',
    );
    status = widget.taxModel?.status ?? true;
  }

  @override
  void dispose() {
    taxNameController.dispose();
    taxRateController.dispose();
    super.dispose();
  }

  // Extracted save logic to keep the build method clean
  Future<void> _saveTax({required BuildContext context, required WidgetRef ref}) async {
    final _lang = lang.S.of(context);
    final permissionService = PermissionService(ref);

    if (widget.taxModel == null) {
      if (!permissionService.hasPermission(Permit.vatsCreate.value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(_lang.youDoNotHavePermissionToCreateTax),
          ),
        );
        return;
      }
    } else {
      if (!permissionService.hasPermission(Permit.vatsUpdate.value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(_lang.youDoNotHavePermissionToUpdateTax),
          ),
        );
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show();

    TaxRepo repo = TaxRepo();
    final taxRate = num.tryParse(taxRateController.text) ?? 0;
    final taxName = taxNameController.text;

    try {
      if (widget.taxModel == null) {
        await repo.createSingleTax(
          ref: ref,
          context: context,
          taxRate: taxRate,
          taxName: taxName,
          status: status,
        );
      } else {
        await repo.updateSingleTax(
          ref: ref,
          context: context,
          rate: taxRate,
          name: taxName,
          id: widget.taxModel!.id!,
          status: status,
        );
      }

      EasyLoading.dismiss();

      // FIX: Double Pop Issue
      // Commented out to prevent the app from returning to the home screen.
      // Uncomment ONLY if TaxRepo does NOT already pop the screen automatically.
      // if (mounted) {
      //   Navigator.pop(context);
      // }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          widget.taxModel == null ? _lang.addTax : _lang.editTax,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wrapped the input fields in an Expanded + SingleChildScrollView
              // to prevent RenderFlex overflow when the keyboard opens
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.taxModel == null ? _lang.addNewTax : _lang.editTax,
                        style: const TextStyle(color: kTitleColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),

                      // Tax Name Field
                      Text(
                        '${lang.S.of(context).name}*',
                        style: const TextStyle(color: kTitleColor),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: taxNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                          border: const OutlineInputBorder(),
                          hintText: lang.S.of(context).enterName,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _lang.taxNameIsRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Tax Rate Field
                      Text(
                        '${_lang.taxRates}*',
                        style: const TextStyle(color: kTitleColor),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: taxRateController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                          border: const OutlineInputBorder(),
                          hintText: _lang.enterTaxRates,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _lang.taxRateIsRequired;
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return _lang.enterAValidNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Status Switch
                      Row(
                        children: [
                          Text(
                            _lang.status,
                            style: const TextStyle(color: kTitleColor),
                          ),
                          const SizedBox(width: 8.0),
                          Switch(
                            value: status,
                            onChanged: (value) {
                              setState(() {
                                status = value;
                              });
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Save Button (Kept your exact original styling)
              Consumer(builder: (context1, ref, __) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: kMainColor,
                        elevation: 1.0,
                        shadowColor: kMainColor,
                        animationDuration: const Duration(milliseconds: 300),
                      ),
                      onPressed: () => _saveTax(context: context, ref: ref),
                      child: Text(
                        _lang.save,
                        style: const TextStyle(
                          color: kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
