import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:shimmer/shimmer.dart';
import 'package:mobile_pos/constant.dart';
import '../../model/country_state_model.dart';
import '../../Provider/global_provider.dart';

class CountryStateDropdown extends ConsumerStatefulWidget {
  // Supports both ID and Name for initial selection
  final num? initialCountryId;
  final String? initialCountryName;

  final num? initialStateId;
  final String? initialStateName;

  final Function(CountryModel?) onCountryChanged;
  final Function(StateModel?) onStateChanged;

  const CountryStateDropdown({
    Key? key,
    this.initialCountryId,
    this.initialCountryName,
    this.initialStateId,
    this.initialStateName,
    required this.onCountryChanged,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  ConsumerState<CountryStateDropdown> createState() => _CountryStateDropdownState();
}

class _CountryStateDropdownState extends ConsumerState<CountryStateDropdown> {
  CountryModel? selectedCountry;
  StateModel? selectedState;

  // Flags to ensure initial logic runs only once
  bool isCountryLoaded = false;
  bool isStateLoaded = false;

  @override
  Widget build(BuildContext context) {
    final countryData = ref.watch(countryListProvider);
    final _lang = l.S.of(context);

    return Row(
      children: [
        // ---------------- COUNTRY DROPDOWN ----------------
        Expanded(
          child: countryData.when(
            data: (countries) {
              // Logic to find Country Model (Runs only once initially)
              if (!isCountryLoaded) {
                if (widget.initialCountryId != null) {
                  // 1. Try finding by ID
                  try {
                    selectedCountry = countries.firstWhere((c) => c.id == widget.initialCountryId);
                  } catch (_) {
                    selectedCountry = null;
                  }
                }

                // 2. If ID failed or was null, try finding by Name
                if (selectedCountry == null && widget.initialCountryName != null) {
                  try {
                    selectedCountry = countries.firstWhere(
                        (c) => c.name?.toLowerCase().trim() == widget.initialCountryName!.toLowerCase().trim());
                  } catch (_) {
                    selectedCountry = null;
                  }
                }

                // Mark country as loaded so we don't overwrite user selection later
                if (selectedCountry != null || (widget.initialCountryId == null && widget.initialCountryName == null)) {
                  // Only mark true if we actually found something or if nothing was provided
                  // However, for safety in build method, we usually just let it run until user interacts
                }
              }

              return DropdownButtonFormField<CountryModel>(
                value: selectedCountry,
                isExpanded: true,
                dropdownColor: Colors.white,
                decoration: kInputDecoration.copyWith(
                  labelText: _lang.country,
                ),
                hint: Text(_lang.selectCountry, style: TextStyle(fontSize: 12)),
                items: countries.map((country) {
                  return DropdownMenuItem<CountryModel>(
                    value: country,
                    child: Row(
                      children: [
                        // ----------- Flag Logic -----------
                        if (country.image != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: 24,
                              height: 16,
                              child: _buildFlagImage(country.image!),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            country.name ?? "",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (CountryModel? value) {
                  setState(() {
                    selectedCountry = value;
                    selectedState = null; // Reset state
                    isCountryLoaded = true; // Stop auto-selecting
                    isStateLoaded = false; // Allow state to re-load for new country (though likely empty initially)
                  });

                  widget.onCountryChanged(value);
                  widget.onStateChanged(null);
                },
              );
            },
            error: (err, stack) => const Text('Error loading countries'),
            loading: () => _buildShimmerLoader(),
          ),
        ),

        const SizedBox(width: 10),

        // ---------------- STATE DROPDOWN ----------------
        Expanded(
          child: selectedCountry == null
              ? _buildEmptyStateDropdown()
              : Consumer(
                  builder: (context, ref, child) {
                    final stateData = ref.watch(stateListProvider(selectedCountry!.id!));

                    return stateData.when(
                      data: (states) {
                        // Logic to find State Model (Runs if not manually changed yet)
                        if (!isStateLoaded && selectedState == null) {
                          // 1. Try finding by ID
                          if (widget.initialStateId != null) {
                            try {
                              selectedState = states.firstWhere((s) => s.id == widget.initialStateId);
                            } catch (_) {}
                          }

                          // 2. If ID failed or null, try finding by Name
                          if (selectedState == null && widget.initialStateName != null) {
                            try {
                              selectedState = states.firstWhere(
                                  (s) => s.name?.toLowerCase().trim() == widget.initialStateName!.toLowerCase().trim());
                            } catch (_) {}
                          }
                        }

                        // Validation: If selected state is not in the new list (e.g. country changed)
                        if (selectedState != null) {
                          bool exists = states.any((element) => element.id == selectedState!.id);
                          if (!exists) {
                            selectedState = null;
                          }
                        }

                        return DropdownButtonFormField<StateModel>(
                          value: selectedState,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          decoration: kInputDecoration.copyWith(
                            labelText: _lang.state,
                          ),
                          hint: Text(_lang.selectState, style: TextStyle(fontSize: 12)),
                          items: states.isEmpty
                              ? []
                              : states.map((state) {
                                  return DropdownMenuItem<StateModel>(
                                    value: state,
                                    child: Text(
                                      state.name ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                          onChanged: states.isEmpty
                              ? null
                              : (StateModel? value) {
                                  setState(() {
                                    selectedState = value;
                                    isStateLoaded = true; // Stop auto-selecting
                                  });
                                  widget.onStateChanged(value);
                                },
                        );
                      },
                      error: (err, stack) => _buildEmptyStateDropdown(),
                      loading: () => _buildShimmerLoader(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ----------- Shimmer Loader -----------
  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  // ----------- Flag Image Helper -----------
  Widget _buildFlagImage(String url) {
    if (url.endsWith('.svg')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.cover,
        placeholderBuilder: (BuildContext context) => const Icon(Icons.flag, size: 16),
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 16),
      );
    }
  }

  Widget _buildEmptyStateDropdown() {
    return DropdownButtonFormField<StateModel>(
      value: null,
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: kInputDecoration.copyWith(
        labelText: l.S.of(context).state,
      ),
      hint: Text(l.S.of(context).selectCountyFirst, style: TextStyle(fontSize: 12, color: Colors.grey)),
      items: [],
      onChanged: null,
    );
  }
}
