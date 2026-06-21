import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';

class SelectedItemButton extends StatelessWidget {
  const SelectedItemButton({
    super.key,
    required this.labelText,
    this.padding,
    this.onTap,
    this.showCloseButton = true,
  });
  final String labelText;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
      decoration: BoxDecoration(
        color: kDarkWhite,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text.rich(
        TextSpan(
          text: labelText,
          style: _theme.textTheme.titleSmall?.copyWith(
            color: kTitleColor,
          ),
          children: [
            if (showCloseButton)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    onTap: onTap,
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
        style: TextStyle(color: _theme.colorScheme.onPrimary),
      ),
    );
  }
}
