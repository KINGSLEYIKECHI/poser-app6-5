import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/income_Category_report/income_category_report.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../constant.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Income/Providers/income_category_provider.dart';

class IncomeCategoryReport extends StatefulWidget {
  const IncomeCategoryReport({super.key, this.mainContext});

  final BuildContext? mainContext;

  @override
  // ignore: library_private_types_in_public_api
  _IncomeCategoryReportState createState() => _IncomeCategoryReportState();
}

class _IncomeCategoryReportState extends State<IncomeCategoryReport> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = lang.S.of(context);
    return Consumer(builder: (context, ref, _) {
      final businessData = ref.watch(businessInfoProvider);
      final data = ref.watch(incomeCategoryProvider);
      final permissionService = PermissionService(ref);
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              _lang.incomeCategoriesReport,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            actions: [
              businessData.when(
                data: (business) {
                  return data.when(
                    data: (category) {
                      return IconButton(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (category.isNotEmpty) {
                            generateIncomeCategoryReportPdf(context, category, business);
                          } else {
                            EasyLoading.showInfo(lang.S.of(context).genPdfWarn);
                          }
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedPdf01,
                          color: kSecondayColor,
                        ),
                      );
                    },
                    error: (e, stack) => Center(child: Text(e.toString())),
                    loading: SizedBox.shrink,
                  );
                },
                error: (e, stack) => Center(child: Text(e.toString())),
                loading: SizedBox.shrink,
              )
            ],
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  decoration: InputDecoration(
                    hintText: lang.S.of(context).search,
                    prefixIcon: Icon(
                      Icons.search,
                      color: kGreyTextColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                data.when(data: (data) {
                  if (!permissionService.hasPermission(Permit.incomeCategoriesRead.value)) {
                    return Center(child: PermitDenyWidget());
                  }
                  return Expanded(
                    child: ListView.separated(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
                          child: Text(
                            data[index].categoryName ?? '',
                            style: theme.textTheme.bodyLarge,
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => Divider(
                        color: kLineColor,
                      ),
                    ),
                  );
                }, error: (error, stackTrace) {
                  return Text(error.toString());
                }, loading: () {
                  return const CircularProgressIndicator();
                })
              ],
            ),
          ),
        ),
      );
    });
  }
}
