import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/vat_&_tax/provider/text_repo.dart';
import 'package:mobile_pos/Screens/vat_&_tax/repo/tax_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../service/check_user_role_permission_provider.dart';
import 'model/vat_model.dart';

class AddGroupTax extends ConsumerStatefulWidget {
  const AddGroupTax({
    super.key,
    this.taxModel,
  });

  final VatModel? taxModel;

  @override
  AddTaxGroupState createState() => AddTaxGroupState();
}

class AddTaxGroupState extends ConsumerState<AddGroupTax> {
  List<VatModel> subTaxList = [];
  List<VatModel> innerVatsList = [];
  List<VatModel> outerVatsList = [];

  TextEditingController nameController = TextEditingController();
  bool status = true;
  bool isManageState = false;

  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.taxModel != null) {
      nameController.text = widget.taxModel?.name ?? '';
      status = widget.taxModel?.status ?? false;

      // Manage State Flag Handling from API
      isManageState = widget.taxModel?.manageState == 1;

      Future.microtask(() async {
        final data = await ref.read(singleTaxProvider.future);

        // ________________ Logic for Standard Sub Tax (Legacy) ________________
        if (widget.taxModel?.subTax != null && !isManageState) {
          List<VatModel> matchingItems = [];
          for (var element in widget.taxModel!.subTax!) {
            try {
              VatModel matchingItem = data.firstWhere(
                (item) => element.id == item.id,
                orElse: () => VatModel(),
              );
              if (matchingItem.id != null) {
                matchingItems.add(matchingItem);
              }
            } catch (_) {}
          }
          setState(() {
            subTaxList = matchingItems;
          });
        }

        // ________________ Logic for Manage State (Inner/Outer) ________________
        if (isManageState) {
          List<VatModel> matchingInner = [];
          List<VatModel> matchingOuter = [];

          // Fill Inner Vats (Matching child_vat_id with Single Tax ID)
          if (widget.taxModel?.innerStateVats != null) {
            for (var innerVat in widget.taxModel!.innerStateVats!) {
              try {
                VatModel matchingItem = data.firstWhere(
                  (item) => innerVat.childVatId == item.id,
                  orElse: () => VatModel(),
                );
                if (matchingItem.id != null) {
                  matchingInner.add(matchingItem);
                }
              } catch (_) {}
            }
          }

          // Fill Outer Vats (Matching child_vat_id with Single Tax ID)
          if (widget.taxModel?.outerStateVats != null) {
            for (var outerVat in widget.taxModel!.outerStateVats!) {
              try {
                VatModel matchingItem = data.firstWhere(
                  (item) => outerVat.childVatId == item.id,
                  orElse: () => VatModel(),
                );
                if (matchingItem.id != null) {
                  matchingOuter.add(matchingItem);
                }
              } catch (_) {}
            }
          }

          setState(() {
            innerVatsList = matchingInner;
            outerVatsList = matchingOuter;
          });
        }
      });
    }
  }

  // _______________ Reusable Widget for Tax Selection _______________
  Widget buildTaxSelector({
    required BuildContext context,
    required String title,
    required List<VatModel> selectedList,
    required List<VatModel> allTaxes,
    required Function(List<VatModel>) onListUpdate,
  }) {
    final _lang = lang.S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title*', style: const TextStyle(color: kTitleColor)),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () async {
            List<VatModel> result = await getTaxesModalSheet(
              mainContext: context,
              ref: ref,
              oldList: selectedList,
              taxList: allTaxes,
            );
            onListUpdate(result);
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.transparent,
              border: Border.all(color: kBorderColorTextField),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                selectedList.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            children: List.generate(
                              selectedList.length,
                              (index) {
                                final category = selectedList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: kMainColor,
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            List<VatModel> newList = List.from(selectedList);
                                            newList.removeAt(index);
                                            onListUpdate(newList);
                                          },
                                          icon: const Icon(Icons.close, color: kWhite, size: 16),
                                        ),
                                        Text(category.name ?? '', style: const TextStyle(color: kWhite)),
                                        const SizedBox(width: 8)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : Text(_lang.noSubTaxSelected, style: const TextStyle(color: kTitleColor)),
                const Padding(
                  padding: EdgeInsets.all(11.0),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: kGreyTextColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final permissionService = PermissionService(ref);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(widget.taxModel == null ? _lang.addTaxGroup : _lang.editTaxGroup),
        centerTitle: true,
        backgroundColor: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.taxModel == null ? _lang.add : _lang.edit} ${_lang.taxWithSingleMultipleTaxType}',
              style: const TextStyle(color: kTitleColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),

            // ___________________ Name Field ___________________
            Text('${lang.S.of(context).name}*', style: const TextStyle(color: kTitleColor)),
            const SizedBox(height: 8.0),
            Form(
              key: _fromKey,
              child: TextFormField(
                controller: nameController,
                keyboardType: TextInputType.text,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Tax name is required' : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 8, right: 8.0),
                  border: const OutlineInputBorder(),
                  hintText: lang.S.of(context).enterName,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // ___________________ Manage State Checkbox ___________________
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: isManageState,
                    activeColor: kMainColor,
                    onChanged: (value) {
                      setState(() {
                        isManageState = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(_lang.manageState, style: TextStyle(color: kTitleColor, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20.0),

            // ___________________ Dynamic Fields ___________________
            SingleChildScrollView(
              child: Consumer(builder: (context, ref, __) {
                final taxesAsync = ref.watch(singleTaxProvider);

                return taxesAsync.when(
                  data: (allTaxes) {
                    if (isManageState) {
                      return Column(
                        children: [
                          buildTaxSelector(
                            context: context,
                            title: _lang.selectInnerVats,
                            selectedList: innerVatsList,
                            allTaxes: allTaxes,
                            onListUpdate: (newList) => setState(() => innerVatsList = newList),
                          ),
                          buildTaxSelector(
                            context: context,
                            title: _lang.selectOuterVats,
                            selectedList: outerVatsList,
                            allTaxes: allTaxes,
                            onListUpdate: (newList) => setState(() => outerVatsList = newList),
                          ),
                        ],
                      );
                    } else {
                      return buildTaxSelector(
                        context: context,
                        title: _lang.subTaxes,
                        selectedList: subTaxList,
                        allTaxes: allTaxes,
                        onListUpdate: (newList) => setState(() => subTaxList = newList),
                      );
                    }
                  },
                  error: (e, s) => Text(e.toString()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                );
              }),
            ),

            // ___________________ Status Switch ___________________
            Row(
              children: [
                Text(_lang.status, style: const TextStyle(color: kTitleColor)),
                const SizedBox(width: 8.0),
                Switch(
                  value: status,
                  onChanged: (value) => setState(() => status = value),
                )
              ],
            ),

            const SizedBox(height: 10),

            // ___________________ Save Button ___________________
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 45.0,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    backgroundColor: kMainColor,
                  ),
                  onPressed: () async {
                    if (widget.taxModel == null) {
                      if (!permissionService.hasPermission(Permit.vatsCreate.value)) {
                        EasyLoading.showError('Permission denied');
                        return;
                      }
                    } else {
                      if (!permissionService.hasPermission(Permit.vatsUpdate.value)) {
                        EasyLoading.showError('Permission denied');
                        return;
                      }
                    }

                    if (_fromKey.currentState!.validate()) {
                      TaxRepo repo = TaxRepo();
                      EasyLoading.show();

                      if (isManageState) {
                        // ________________ Manage State Save Logic ________________
                        if (innerVatsList.isNotEmpty || outerVatsList.isNotEmpty) {
                          List<num> innerIds = innerVatsList.map((e) => e.id!).toList();
                          List<num> outerIds = outerVatsList.map((e) => e.id!).toList();

                          if (widget.taxModel != null) {
                            await repo.updateGroupTax(
                              ref: ref,
                              context: context,
                              id: widget.taxModel!.id!,
                              taxName: nameController.text,
                              status: status,
                              isManageState: true,
                              innerVatIds: innerIds,
                              outerVatIds: outerIds,
                            );
                          } else {
                            await repo.createGroupTax(
                              ref: ref,
                              context: context,
                              taxName: nameController.text,
                              status: status,
                              isManageState: true,
                              innerVatIds: innerIds,
                              outerVatIds: outerIds,
                            );
                          }
                        } else {
                          EasyLoading.dismiss();
                          EasyLoading.showError(_lang.pleaseSelectInnerOrOtherTax);
                        }
                      } else {
                        // ________________ Normal Save Logic ________________
                        if (subTaxList.isNotEmpty) {
                          List<num> ids = subTaxList.map((e) => e.id!).toList();

                          if (widget.taxModel != null) {
                            await repo.updateGroupTax(
                              id: widget.taxModel!.id!,
                              ref: ref,
                              context: context,
                              taxName: nameController.text,
                              status: status,
                              isManageState: false,
                              taxIds: ids,
                            );
                          } else {
                            await repo.createGroupTax(
                              ref: ref,
                              context: context,
                              taxName: nameController.text,
                              status: status,
                              isManageState: false,
                              taxIds: ids,
                            );
                          }
                        } else {
                          EasyLoading.dismiss();
                          EasyLoading.showError(_lang.pleaseSelectTaxes);
                        }
                      }
                    }
                  },
                  child: Text(
                    lang.S.of(context).save,
                    style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modal Sheet Function
Future<List<VatModel>> getTaxesModalSheet({
  required BuildContext mainContext,
  required WidgetRef ref,
  required List<VatModel> oldList,
  required List<VatModel> taxList,
}) async {
  List<VatModel> subTaxList = [...oldList];

  bool? isDone = await showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    context: mainContext,
    builder: (BuildContext context) {
      final _lang = lang.S.of(context);
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setNewState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 13.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _lang.subTaxList,
                      style: const TextStyle(color: kTitleColor, fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 21, color: kTitleColor),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const Divider(color: kBorderColorTextField),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  itemCount: taxList.length,
                  itemBuilder: (context, index) {
                    final category = taxList[index];
                    return Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                          fillColor:
                              WidgetStatePropertyAll(subTaxList.contains(category) ? kMainColor : kBackgroundColor),
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          side: const BorderSide(color: kBorderColorTextField),
                          title: Text(category.name ?? '',
                              style: const TextStyle(color: kTitleColor, overflow: TextOverflow.ellipsis)),
                          subtitle: Text('${_lang.taxPercent}: ${category.rate}%',
                              style: const TextStyle(color: kGreyTextColor)),
                          value: subTaxList.contains(category),
                          onChanged: (isChecked) {
                            setNewState(() {
                              if (isChecked!) {
                                if (!subTaxList.contains(category)) subTaxList.add(category);
                              } else {
                                subTaxList.remove(category);
                              }
                            });
                          },
                        ),
                        const Divider(color: kBorderColorTextField, height: 0.0)
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 45.0,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      backgroundColor: kMainColor,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(_lang.done, style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
  return (isDone ?? false) ? subTaxList : oldList;
}
