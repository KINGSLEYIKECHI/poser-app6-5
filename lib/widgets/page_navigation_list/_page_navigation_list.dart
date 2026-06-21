import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constant.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constant.dart';

class PageNavigationListView extends StatefulWidget {
  const PageNavigationListView({
    super.key,
    this.header,
    this.footer,
    required this.navTiles,
    this.onTap,
  });

  final Widget? header;
  final Widget? footer;
  final List<PageNavigationNavTile> navTiles;
  final void Function(PageNavigationNavTile value)? onTap;

  @override
  State<PageNavigationListView> createState() => _PageNavigationListViewState();
}

class _PageNavigationListViewState extends State<PageNavigationListView> {
  PageNavigationNavTile? selectedChildTile;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        if (widget.header != null) widget.header!,
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
          child: ListView.separated(
            shrinkWrap: true,
            primary: false,
            itemCount: widget.navTiles.length,
            itemBuilder: (context, index) {
              final _navTile = widget.navTiles[index];

              // =============================
              //    EXPANSION TILE
              // =============================
              if (_navTile.type == PageNavigationListTileType.expansion) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: SvgPicture.asset(
                      _navTile.svgIconPath,
                      height: 36,
                      width: 36,
                    ),
                    title: Text(_navTile.title),
                    children: (_navTile.children ?? []).map((child) {
                      final isSelected = selectedChildTile == child;
                      return ListTile(
                        leading: SizedBox(),
                        onTap: () {
                          setState(() => selectedChildTile = child);
                          widget.onTap?.call(child);
                        },
                        title: Text(
                          child.title,
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? kMainColor : kTitleColor,
                          ),
                        ),
                        contentPadding: EdgeInsetsDirectional.only(start: 22),
                        visualDensity: const VisualDensity(
                          vertical: -4,
                          horizontal: -2,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }

              // =============================
              //   NORMAL TILE (unchanged)
              // =============================
              return ListTile(
                onTap: () => widget.onTap?.call(_navTile),
                leading: SvgPicture.asset(
                  _navTile.svgIconPath,
                  height: 36,
                  width: 36,
                ),
                title: Text(_navTile.title),
                trailing: (_navTile.hideTrailing ?? false)
                    ? null
                    : _navTile.trailing ??
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: kGreyTextColor,
                        ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1.5),
          ),
        ),
        if (widget.footer != null) widget.footer!,
      ],
    );
  }
}

class PageNavigationNavTile<T> {
  final String title;
  final Widget? trailing;
  final Color? color;
  final String svgIconPath;
  final PageNavigationListTileType type;
  final Widget? route;
  final bool? hideTrailing;
  final T? value;
  final List<PageNavigationNavTile<T>>? children;

  const PageNavigationNavTile({
    required this.title,
    this.trailing,
    this.color,
    required this.svgIconPath,
    this.type = PageNavigationListTileType.navigation,
    this.route,
    this.value,
    this.hideTrailing,
    this.children,
  }) : assert(
          type != PageNavigationListTileType.navigation || value == null,
          'value cannot be assigned in navigation type',
        );
}

enum PageNavigationListTileType { navigation, tool, function, expansion }

// class PageNavigationListView extends StatelessWidget {
//   const PageNavigationListView({
//     super.key,
//     this.header,
//     this.footer,
//     required this.navTiles,
//     this.onTap,
//   });
//
//   final Widget? header;
//   final Widget? footer;
//   final List<PageNavigationNavTile> navTiles;
//   final void Function(PageNavigationNavTile value)? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final _theme = Theme.of(context);
//
//     return ListView(
//       physics: const ClampingScrollPhysics(),
//       children: [
//         // Header
//         if (header != null) header!,
//
//         // Nav Items
//         Padding(
//           padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
//           child: ListView.separated(
//             shrinkWrap: true,
//             primary: false,
//             itemCount: navTiles.length,
//             itemBuilder: (context, index) {
//               final _navTile = navTiles[index];
//
//               return Material(
//                 color: Colors.transparent,
//                 child: ListTile(
//                   onTap: () => onTap?.call(_navTile),
//                   leading: SvgPicture.asset(
//                     _navTile.svgIconPath,
//                     height: 36,
//                     width: 36,
//                   ),
//                   title: Text(_navTile.title),
//                   titleTextStyle: _theme.textTheme.bodyLarge,
//                   trailing: (_navTile.hideTrailing ?? false)
//                       ? null
//                       : _navTile.trailing ??
//                           const Icon(
//                             Icons.arrow_forward_ios,
//                             size: 20,
//                             color: kGreyTextColor,
//                           ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   tileColor: _theme.colorScheme.primaryContainer,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 4),
//                   visualDensity: const VisualDensity(
//                     vertical: -1,
//                     horizontal: -2,
//                   ),
//                 ),
//               );
//             },
//             separatorBuilder: (c, i) => const Divider(height: 1.5),
//           ),
//         ),
//
//         // Footer
//         if (footer != null) footer!,
//       ],
//     );
//   }
// }
//
// class PageNavigationNavTile<T> {
//   final String title;
//   final Widget? trailing;
//   final Color? color;
//   final String svgIconPath;
//   final PageNavigationListTileType type;
//   final Widget? route;
//   final bool? hideTrailing;
//   final T? value;
//
//   const PageNavigationNavTile({
//     required this.title,
//     this.trailing,
//     this.color,
//     required this.svgIconPath,
//     this.type = PageNavigationListTileType.navigation,
//     this.route,
//     this.value,
//     this.hideTrailing,
//   }) : assert(
//           type != PageNavigationListTileType.navigation || value == null,
//           'value cannot be assigned in navigation type',
//         );
// }
//
// enum PageNavigationListTileType { navigation, tool, function }
