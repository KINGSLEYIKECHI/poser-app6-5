// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class TextFieldLabelWrapper extends StatelessWidget {
  const TextFieldLabelWrapper({
    super.key,
    this.labelText,
    this.label,
    this.labelStyle,
    required this.inputField,
  });
  final String? labelText;
  final Widget? label;
  final TextStyle? labelStyle;
  final Widget inputField;
  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label == null)
          Text(
            labelText ?? lang.S.of(context).enterLabelText,
            style: labelStyle ?? _theme.inputDecorationTheme.floatingLabelStyle,
          )
        else
          label!,
        const SizedBox(height: 8),
        inputField,
      ],
    );
  }
}
