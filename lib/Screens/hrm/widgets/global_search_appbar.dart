import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../../../constant.dart';

class GlobalSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearch;
  final VoidCallback onSearchToggle;
  final String title;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final PopupMenuItemSelected<dynamic>? onManuSelect;
  final List<PopupMenuItem>? popupMenuButtons;

  const GlobalSearchAppBar({
    super.key,
    required this.isSearch,
    required this.onSearchToggle,
    required this.title,
    this.controller,
    this.onChanged,
    this.popupMenuButtons,
    this.onManuSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearch
          ? TextField(
              autofocus: true,
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: '${l.S.of(context).searchH}...',
                border: InputBorder.none,
                suffixIcon: Icon(
                  FeatherIcons.search,
                  // size: 18,
                  color: kNeutral800,
                ),
              ),
            )
          : Text(title),
      centerTitle: true,
      automaticallyImplyLeading: !isSearch,
      actions: [
        IconButton(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
          ),
          visualDensity: const VisualDensity(horizontal: -4),
          padding: EdgeInsets.only(right: 16),
          onPressed: onSearchToggle,
          icon: Icon(
            isSearch ? Icons.close : FeatherIcons.search,
            color: isSearch ? kMainColor : kNeutral800,
            size: isSearch ? null : 22,
          ),
        ),
        if (popupMenuButtons != null)
          PopupMenuButton(
            onSelected: onManuSelect,
            itemBuilder: (context) => popupMenuButtons!,
            icon: const Icon(Icons.more_vert),
          )
      ],
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 2,
            color: kBackgroundColor,
          )),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(isSearch ? 65 : kToolbarHeight);
}
