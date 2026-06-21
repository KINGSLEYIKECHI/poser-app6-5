import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Repository/API/business_info_update_repo.dart';
import '../../../constant.dart';
import 'model/amount_rounding_dropdown_model.dart';

class SalesSettingsScreen extends ConsumerStatefulWidget {
  const SalesSettingsScreen({super.key});

  @override
  ConsumerState<SalesSettingsScreen> createState() => _PrintingInvoiceScreenState();
}

class _PrintingInvoiceScreenState extends ConsumerState<SalesSettingsScreen> {
  bool isGuestDueSaleAllowed = true;
  AmountRoundingDropdownModel? selectedMethod = roundingMethods[0];

  @override
  void initState() {
    super.initState();
    ref.read(businessInfoProvider).when(
          data: (data) {
            setState(() {
              selectedMethod = roundingMethods.firstWhere(
                (element) => element.value == data.data?.saleRoundingOption,
                orElse: () => roundingMethods[0],
              );
              isGuestDueSaleAllowed = data.data?.allowDueSale == 1;
            });
          },
          error: (error, stackTrace) {},
          loading: () {},
        );
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            _lang.salesSetting,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            child: Text(lang.S.of(context).save),
            onPressed: () async {
              ref.watch(businessInfoProvider).when(
                    data: (data) async {
                      final businessRepository = BusinessUpdateRepository();
                      final isProfileUpdated = await businessRepository.updateSalesSettings(
                        id: data.data?.id.toString() ?? '',
                        ref: ref,
                        context: context,
                        saleRoundingOption: selectedMethod?.value,
                        allowGuestDueSale: isGuestDueSaleAllowed ? 1 : 0,
                      );

                      if (isProfileUpdated) {
                        ref.refresh(businessInfoProvider);
                        Navigator.pop(context);
                      }
                    },
                    error: (error, stackTrace) {},
                    loading: () {},
                  );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              Text(
                '${_lang.amountRoundingMethod}:',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              DropdownButtonFormField<AmountRoundingDropdownModel>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: _lang.amountRoundingMethod,
                  border: const OutlineInputBorder(),
                ),
                value: selectedMethod,
                items: roundingMethods.map((method) {
                  return DropdownMenuItem<AmountRoundingDropdownModel>(
                    value: method,
                    child: Text(method.option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMethod = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Guest due sale:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: isGuestDueSaleAllowed,
                    activeColor: kWhite,
                    activeTrackColor: kMainColor,
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.grey.shade200,
                    onChanged: (bool value) {
                      setState(() {
                        isGuestDueSaleAllowed = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
