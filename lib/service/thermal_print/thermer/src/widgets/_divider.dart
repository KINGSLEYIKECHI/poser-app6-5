import '_base_widget.dart';

class ThermerDivider extends ThermerWidget {
  final bool isHorizontal;
  final String character;
  final int? length;

  ThermerDivider._({
    required this.isHorizontal,
    required this.character,
    required this.length,
  });

  ThermerDivider copyWith({String? character, int? length}) {
    return ThermerDivider._(
      isHorizontal: isHorizontal,
      character: character ?? this.character,
      length: length ?? this.length,
    );
  }

  factory ThermerDivider.horizontal({String character = '-', int? length}) {
    return ThermerDivider._(
      isHorizontal: true,
      character: character,
      length: length,
    );
  }

  factory ThermerDivider.vertical({String character = '|', int? length}) {
    return ThermerDivider._(
      isHorizontal: false,
      character: character,
      length: length ?? 1,
    );
  }
}
