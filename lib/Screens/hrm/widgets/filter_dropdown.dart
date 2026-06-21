import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/constant.dart';

class FilterDropdownButton<T> extends StatefulWidget {
  const FilterDropdownButton({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.buttonDecoration,
    this.hint,
    this.buttonHeight = 40,
    this.buttonWidth,
    this.dropdownWidth,
    this.icon,
    this.iconSize = 24,
    this.dropdownDecoration,
    this.selectedItemBuilder,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final BoxDecoration? buttonDecoration;
  final Widget? hint;
  final double buttonHeight;
  final double? buttonWidth;
  final double? dropdownWidth;
  final Widget? icon;
  final double iconSize;
  final BoxDecoration? dropdownDecoration;
  final DropdownButtonBuilder? selectedItemBuilder;

  @override
  State<FilterDropdownButton<T>> createState() => _FilterDropdownButtonState<T>();
}

class _FilterDropdownButtonState<T> extends State<FilterDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        value: widget.value,
        items: widget.items,
        onChanged: widget.onChanged,
        selectedItemBuilder: widget.selectedItemBuilder,
        hint: widget.hint ?? Text(l.S.of(context).selectOne),
        buttonStyleData: ButtonStyleData(
          height: widget.buttonHeight,
          width: widget.buttonWidth,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: widget.buttonDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: kBorderColor,
                ),
                color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              ),
          elevation: 0,
        ),
        iconStyleData: IconStyleData(
          icon: widget.icon ??
              const Icon(
                Icons.keyboard_arrow_down,
                color: kNeutral800,
              ),
          iconSize: widget.iconSize,
          iconEnabledColor: theme.iconTheme.color,
          iconDisabledColor: Colors.grey,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 250,
          width: widget.dropdownWidth,
          padding: null,
          decoration: widget.dropdownDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              ),
          elevation: 4,
          // offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all<double>(6),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
