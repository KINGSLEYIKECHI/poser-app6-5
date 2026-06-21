import 'dart:ui';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mobile_pos/Screens/Products/Widgets/selected_button.dart';
import 'package:mobile_pos/constant.dart';

class AcnooMultiSelectDropdown<T> extends StatefulWidget {
  AcnooMultiSelectDropdown({
    super.key,
    this.decoration,
    this.menuItemStyleData,
    this.buttonStyleData,
    this.iconStyleData,
    this.dropdownStyleData,
    required this.items,
    this.values,
    this.onChanged,
    required this.labelText,
  }) : assert(
          items.isEmpty ||
              values == null ||
              items.where((item) {
                    return values.contains(item.value);
                  }).length ==
                  values.length,
          "There should be exactly one item with [AcnooMultiSelectDropdown]'s value in the items list. "
          'Either zero or 2 or more [MultiSelectDropdownMenuItem]s were detected with the same value',
        );

  final List<MultiSelectDropdownMenuItem<T?>> items;
  final List<T?>? values;
  final void Function(List<T>? values)? onChanged;

  final InputDecoration? decoration;
  final MenuItemStyleData? menuItemStyleData;
  final ButtonStyleData? buttonStyleData;
  final IconStyleData? iconStyleData;
  final DropdownStyleData? dropdownStyleData;

  final String labelText;

  @override
  State<AcnooMultiSelectDropdown<T>> createState() => _AcnooMultiSelectDropdownState<T>();
}

class _AcnooMultiSelectDropdownState<T> extends State<AcnooMultiSelectDropdown<T>> {
  bool isOpen = false;
  void listenMenuChange(bool value) {
    setState(() {
      isOpen = value;
      if (!value) {
        widget.onChanged?.call(
          selectedItems.map((e) => e.value!).toList(),
        );
      }
    });
  }

  late List<MultiSelectDropdownMenuItem<T?>> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = widget.items.where((element) => widget.values?.contains(element.value) ?? false).toList();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return DropdownButtonFormField2<T>(
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        labelText: widget.labelText,
        hintText: '',
      ),
      menuItemStyleData: widget.menuItemStyleData ?? const MenuItemStyleData(),
      buttonStyleData: widget.buttonStyleData ?? const ButtonStyleData(),
      iconStyleData: widget.iconStyleData ?? const IconStyleData(),
      dropdownStyleData: widget.dropdownStyleData ?? const DropdownStyleData(),
      onMenuStateChange: listenMenuChange,
      customButton: _buildCustomButton(context),
      items: widget.items.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          enabled: false,
          child: _buildMenuItem(context, item, _theme),
        );
      }).toList(),
      onChanged: (_) {},
    );
  }

  // --------------- CHANGE IS HERE ---------------- //
  Widget _buildCustomButton(BuildContext context) {
    const _itemPadding = EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    );
    if (selectedItems.isEmpty) {
      final _iconWidget = widget.iconStyleData?.icon ?? Icon(Icons.keyboard_arrow_down_outlined);
      return Padding(
        padding: _itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.decoration?.hintText ?? lang.S.of(context).selectItems,
              style: widget.decoration?.hintStyle,
            ),
            _iconWidget,
          ],
        ),
      );
    }
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.touch,
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: selectedItems.reversed.map((item) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SelectedItemButton(
                padding: _itemPadding,
                labelText: item.labelText,
                onTap: () {
                  // 1. Remove item from local state
                  setState(() {
                    selectedItems.remove(item);
                  });

                  // 2. Trigger the onChanged callback immediately
                  widget.onChanged?.call(
                    selectedItems.map((e) => e.value!).toList(),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  // ----------------------------------------------- //

  Widget _buildMenuItem(
    BuildContext context,
    MultiSelectDropdownMenuItem<T?> item,
    ThemeData _theme,
  ) {
    return StatefulBuilder(
      builder: (context, itemState) {
        final _isSelected = selectedItems.contains(item);
        return InkWell(
          onTap: () {
            _isSelected ? selectedItems.remove(item) : selectedItems.add(item);
            widget.onChanged?.call(
              selectedItems.map((e) => e.value!).toList(),
            );
            setState(() {});
            itemState(() {});
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: AlignmentDirectional.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.labelText),
                ),
                if (_isSelected)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: kMainColor,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MultiSelectDropdownMenuItem<T> {
  MultiSelectDropdownMenuItem({
    required this.labelText,
    this.value,
  });
  final String labelText;
  final T? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiSelectDropdownMenuItem<T> &&
          runtimeType == other.runtimeType &&
          labelText == other.labelText &&
          value == other.value;

  @override
  int get hashCode => labelText.hashCode ^ value.hashCode;
}
