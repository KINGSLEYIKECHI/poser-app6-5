// File: product_variation_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/product%20variation/provider/product_variation_provider.dart';
import 'package:mobile_pos/Screens/product%20variation/repo/product_variation_repo.dart';

// --- Local Imports ---
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import '../../../service/check_user_role_permission_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

// --- Data Layer Imports ---
import '../../widgets/deleteing_alart_dialog.dart';
import '../hrm/widgets/global_search_appbar.dart';
import '../product_category/product_category_list_screen.dart';
import 'add_edit_product_variation_screen.dart';
import 'model/product_variation_model.dart';

class ProductVariationList extends ConsumerStatefulWidget {
  const ProductVariationList({super.key});

  @override
  ConsumerState<ProductVariationList> createState() => _ProductVariationListState();
}

class _ProductVariationListState extends ConsumerState<ProductVariationList> {
  final TextEditingController _searchController = TextEditingController();
  List<VariationData> _filteredList = [];
  bool _isSearch = false;
  String search = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      search = _searchController.text;
    });
  }

  void _filterVariations(List<VariationData> allVariations) {
    final query = search.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredList = allVariations;
    } else {
      _filteredList = allVariations.where((variation) {
        final nameMatch = (variation.name ?? '').toLowerCase().contains(query);
        final valuesMatch = (variation.values ?? []).join(', ').toLowerCase().contains(query);

        return nameMatch || valuesMatch;
      }).toList();
    }
  }

  String _getStatusText(dynamic status) {
    if (status == 1 || status == '1') return 'Active';
    return 'Inactive';
  }

  Color _getStatusColor(dynamic status) {
    if (status == 1 || status == '1') return kSuccessColor;
    return Colors.red;
  }

  Future<void> _refreshData() async {
    ref.invalidate(variationListProvider);
    return ref.watch(variationListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final theme = Theme.of(context);
    final variationListAsync = ref.watch(variationListProvider);
    final permissionService = PermissionService(ref);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalSearchAppBar(
        isSearch: _isSearch,
        onSearchToggle: () {
          setState(() {
            _isSearch = !_isSearch;
            if (!_isSearch) {
              _searchController.clear();
            }
          });
        },
        title: _lang.productVariations,
        controller: _searchController,
        onChanged: (query) {
          // Handled by _searchController.addListener
        },
      ),
      body: variationListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load variations: $err')),
        data: (model) {
          // NOTE: Replace 'variation_read_permit' with your actual Permit.value
          if (!permissionService.hasPermission('variation_read_permit')) {
            // return const Center(child: PermitDenyWidget()); // Assuming this exists
            return Center(child: Text(_lang.permissionDenied));
          }
          final allVariations = model.data ?? [];

          _filterVariations(allVariations);

          if (_filteredList.isEmpty) {
            return Center(
                child: Text(search.isEmpty ? _lang.noVariationFound : _lang.notMatchingResultFound,
                    style: theme.textTheme.titleMedium));
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 1.5),
              itemBuilder: (_, index) => _buildVariationItem(context, ref, _filteredList[index]),
            ),
          );
        },
      ),
      bottomNavigationBar: permissionService.hasPermission('variation_create_permit')
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditVariation())),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(_lang.addNewVariation),
              ),
            )
          : null,
    );
  }

  // --- Helper Methods ---

  Widget _buildVariationItem(BuildContext context, WidgetRef ref, VariationData variation) {
    final permissionService = PermissionService(ref);
    final theme = Theme.of(context);
    final statusText = _getStatusText(variation.status);
    final statusColor = _getStatusColor(variation.status);
    final valuesText = (variation.values ?? []).join(', ');

    return ListCardWidget(
      // Assuming ListCardWidget is available
      onSelect: () => viewModalSheet(
        context: context,
        item: {
          lang.S.of(context).name: variation.name ?? 'N/A',
          lang.S.of(context).status: statusText,
          lang.S.of(context).values: valuesText,
        },
        description: '${lang.S.of(context).variationId}: ${variation.id ?? 'N/A'}',
      ),

      title: variation.name ?? 'N/A ${lang.S.of(context).variations}',
      subtitle: valuesText.isEmpty ? lang.S.of(context).noValuesDenied : valuesText,
      onEdit: () {
        if (!permissionService.hasPermission('variation_update_permit')) return;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddEditVariation(isEdit: true, variation: variation)));
      },
      onDelete: () {
        if (!permissionService.hasPermission('variation_delete_permit')) return;
        if (variation.id != null) {
          _showDeleteConfirmationDialog(context, ref, variation.id!);
        }
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, VariationData variation) {
    final permissionService = PermissionService(ref);
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          if (!permissionService.hasPermission('variation_update_permit')) return;
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddEditVariation(isEdit: true, variation: variation)));
        } else if (value == 'delete') {
          if (!permissionService.hasPermission('variation_delete_permit')) return;
          if (variation.id != null) {
            _showDeleteConfirmationDialog(context, ref, variation.id!);
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(lang.S.of(context).edit, style: TextStyle(color: kSuccessColor)),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(lang.S.of(context).delete, style: TextStyle(color: Colors.red)),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, num id) async {
    bool result = await showDeleteConfirmationDialog(
      context: context,
      itemName: lang.S.of(context).variations,
    );

    if (result) {
      final repo = VariationRepo();
      await repo.deleteVariation(id: id, context: context, ref: ref);
    }
  }
}
