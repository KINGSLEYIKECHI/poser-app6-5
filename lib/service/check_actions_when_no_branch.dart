import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/constant.dart';

import '../Screens/branch/branch_list.dart';

Future<bool> checkActionWhenNoBranch({required BuildContext context, required WidgetRef ref, String? actionName}) async {
  final businessInfo = await ref.watch(businessInfoProvider.future);
  if ((businessInfo.data?.addons?.multiBranchAddon == null) || (businessInfo.data?.addons?.multiBranchAddon == false)) {
    return true;
  }

  if ((businessInfo.data?.addons?.multiBranchAddon == true) && (businessInfo.data?.branchCount ?? 0) < 1) {
    return true;
  }

  if (actionName != null) {
    switch (actionName.toLowerCase()) {
      case 'sale':
        break;
      case 'pos sale':
        break;
      case 'purchase':
        break;
      default:
        return true;
    }
  }

  if (businessInfo.data?.user?.activeBranchId == null && businessInfo.data?.user?.branchId == null) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "You have to switch a branch for this action.",
              style: TextStyle(
                color: kMainColor,
              ),
            ),
            BranchListWidget(formFullPage: false),
          ],
        );
      },
    );
    return false;
  }
  return true;
}
