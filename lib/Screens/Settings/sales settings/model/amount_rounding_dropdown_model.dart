import 'package:mobile_pos/generated/l10n.dart' as lang;

class AmountRoundingDropdownModel {
  late String value;
  late String option;

  AmountRoundingDropdownModel({required this.value, required this.option});
}

final List<AmountRoundingDropdownModel> roundingMethods = [
  AmountRoundingDropdownModel(value: 'none', option: lang.S.current.none),
  AmountRoundingDropdownModel(value: 'round_up', option: lang.S.current.roundToWholeNumber),
  AmountRoundingDropdownModel(value: 'nearest_whole_number', option: lang.S.current.roundToNearestWholeNumber),
  AmountRoundingDropdownModel(value: 'nearest_0.05', option: lang.S.current.roundToNearnessDecimalNumber005),
  AmountRoundingDropdownModel(value: 'nearest_0.1', option: lang.S.current.roundToNearnessDecimalNumber01),
  AmountRoundingDropdownModel(value: 'nearest_0.5', option: lang.S.current.roundToNearnessDecimalNumber05),
];

num roundNumber({required num value, required String roundingType}) {
  switch (roundingType) {
    case "none":
      return value;

    case "round_up":
      return value.ceilToDouble();

    case "nearest_whole_number":
      return value.roundToDouble();

    case "nearest_0.05":
      return (value / 0.05).round() * 0.05;

    case "nearest_0.1":
      return (value / 0.1).round() * 0.1;

    case "nearest_0.5":
      return (value / 0.5).round() * 0.5;

    default:
      return value;
  }
}
