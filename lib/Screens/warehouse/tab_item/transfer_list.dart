import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

Widget transferWidget({
  required String invoiceNumber,
  required String date,
  required String from,
  required String to,
  required String quantity,
  required String stockValue,
  required BuildContext context,
  required VoidCallback onDelete,
}) {
  final _theme = Theme.of(context);
  final _lang = l.S.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_lang.invoice}: #$invoiceNumber',
                  style: _theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    color: kPeraColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'delete', child: Text(_lang.delete)),
                  ],
                  child: Icon(Icons.more_vert, color: kSubPeraColor),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lang.from,
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  from,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lang.to,
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  from,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            )
          ],
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lang.quantity,
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  quantity,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _lang.stockValue,
                  style: _theme.textTheme.bodySmall?.copyWith(
                    color: kPeraColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  stockValue,
                  textAlign: TextAlign.end,
                  style: _theme.textTheme.titleSmall,
                )
              ],
            )
          ],
        ),
      ],
    ),
  );
}
