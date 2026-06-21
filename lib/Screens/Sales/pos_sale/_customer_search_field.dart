import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../constant.dart';
import '../../../generated/l10n.dart' as l;
import '../../Customers/Model/parties_model.dart';
import '../../Customers/Provider/customer_provider.dart';
import '../../Customers/add_customer.dart';

class CustomerSearchField extends ConsumerStatefulWidget {
  const CustomerSearchField({
    super.key,
    required this.selectedCustomer,
    this.onCustomerSelected,
  });
  final Party? selectedCustomer;
  final ValueChanged<Party?>? onCustomerSelected;

  @override
  ConsumerState<CustomerSearchField> createState() => _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends ConsumerState<CustomerSearchField> {
  //--------------------------State Vars--------------------------//
  final _searchController = TextEditingController();
  //--------------------------State Vars--------------------------//

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(partiesProvider);

    final lang = l.S.of(context);

    return customerAsync.when(
      data: (customers) {
        return TypeAheadField<Party>(
          controller: _searchController,
          hideOnUnfocus: true, // --- Fix: Added this to hide suggestions when unfocused ---
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: widget.selectedCustomer != null ? widget.selectedCustomer?.name : lang.selectCustomer,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: const VisualDensity(horizontal: -4),
                      tooltip: 'Clear',
                      onPressed: widget.selectedCustomer == null
                          ? focusNode.requestFocus
                          : () {
                              _searchController.clear();
                              return widget.onCustomerSelected?.call(null);
                            },
                      icon: Icon(
                        widget.selectedCustomer != null ? Icons.close : Icons.keyboard_arrow_down,
                        size: 20,
                        color: kSubPeraColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        return Navigator.push<void>(context, MaterialPageRoute(builder: (_) => const AddParty()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          width: 50,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: kMainColor50,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: const Icon(Icons.add, color: kMainColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          suggestionsCallback: (pattern) {
            final onlyCustomers = customers.where((element) {
              return element.type?.toLowerCase() != 'supplier';
            }).toList();

            if (pattern.isEmpty) return onlyCustomers;

            return onlyCustomers
                .where((party) => (party.name ?? '').toLowerCase().startsWith(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, suggestion) {
            // ----- Reference Style Party Type Color & Label Logic -----
            final normalizedType = (suggestion.type ?? '').toLowerCase();

            Color typeColor = Colors.black; // Default
            if (normalizedType == 'retailer' || normalizedType == 'customer') {
              typeColor = const Color(0xFF56da87);
            } else if (normalizedType == 'wholesaler') {
              typeColor = const Color(0xFF25a9e0);
            } else if (normalizedType == 'dealer') {
              typeColor = const Color(0xFFff5f00);
            } else if (normalizedType == 'supplier') {
              typeColor = const Color(0xFFA569BD);
            }

            String effectiveDisplayType;
            if (normalizedType == 'retailer') {
              effectiveDisplayType = lang.customer;
            } else if (normalizedType == 'wholesaler') {
              effectiveDisplayType = lang.wholesaler;
            } else if (normalizedType == 'dealer') {
              effectiveDisplayType = lang.dealer;
            } else if (normalizedType == 'supplier') {
              effectiveDisplayType = lang.supplier;
            } else {
              effectiveDisplayType = suggestion.type ?? 'Retailer';
            }
            // ------------------------------------------------------------

            return Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Text(suggestion.name ?? '', style: const TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(suggestion.phone ?? ''),
                        // Dynamic Party Type With Reference Colors
                        Text(
                          effectiveDisplayType,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                ],
              ),
            );
          },
          onSelected: (Party selectedParty) {
            _searchController.text = selectedParty.name ?? '';
            widget.onCustomerSelected?.call(selectedParty);
            return FocusScope.of(context).unfocus();
          },
        );
      },
      error: (e, stack) => Text('Error: $e'),
      loading: () => const Center(child: LinearProgressIndicator()),
    );
  }
}
