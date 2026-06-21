// File: product_rack_list_screen.dart (Rack List)

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/product%20racks/provider/product_recks_provider.dart';
import 'package:mobile_pos/Screens/product%20racks/repo/product_racks_repo.dart';
import 'package:nb_utils/nb_utils.dart'; // For .launch()

// --- Local Imports ---
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../GlobalComponents/glonal_popup.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../../widgets/deleteing_alart_dialog.dart';
import '../hrm/widgets/global_search_appbar.dart';
import '../product_category/product_category_list_screen.dart';
import 'add_edit_racks_screen.dart';
import 'model/product_racks_model.dart'; // Assuming GlobalSearchAppBar exists

class ProductRackList extends ConsumerStatefulWidget {
  const ProductRackList({super.key, required this.isFromProductList});

  final bool isFromProductList;

  @override
  ConsumerState<ProductRackList> createState() => _ProductRackListState();
}

class _ProductRackListState extends ConsumerState<ProductRackList> {
  final TextEditingController _searchController = TextEditingController();
  List<RackData> _filteredList = [];
  bool _isSearch = false;
  String search = ''; // Used for searching the list

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

  void _filterRacks(List<RackData> allRacks) {
    final query = search.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredList = allRacks;
    } else {
      _filteredList = allRacks.where((rack) {
        final nameMatch = (rack.name ?? '').toLowerCase().contains(query);
        final shelfNames = (rack.shelves ?? []).map((s) => s.name).join(', ').toLowerCase();

        return nameMatch || shelfNames.contains(query);
      }).toList();
    }
  }

  String _getStatusText(dynamic status) {
    if (status == 1 || status == '1' || status?.toLowerCase() == 'active') return 'Active';
    return 'Inactive';
  }

  Color _getStatusColor(dynamic status) {
    if (status == 1 || status == '1' || status?.toLowerCase() == 'active') return kSuccessColor;
    return Colors.red;
  }

  Future<void> _refreshData() async {
    ref.invalidate(rackListProvider);
    return ref.watch(rackListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: Using GlobalSearchAppBar from your Holiday/Department List structure
    // If you prefer the old BrandList structure (TextField inside the body),
    // you'll need to adapt the GlobalSearchAppBar part below.
    final _lang = lang.S.of(context);

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(_lang.productRacks),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Consumer(builder: (context, ref, __) {
            final rackDataAsync = ref.watch(rackListProvider);
            // Assuming businessInfoProvider and Permit enum are accessible
            final permissionService = PermissionService(ref);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          // Assuming AppTextField is similar to TextFormField
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: lang.S.of(context).search,
                            prefixIcon: Icon(
                              Icons.search,
                              color: kGreyTextColor.withOpacity(0.5),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              search = value;
                              _onSearchChanged(); // Manually trigger search update
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      // Add Button
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () async {
                            // NOTE: Replace 'rack_create_permit' with your actual Permit.value
                            if (!permissionService.hasPermission('rack_create_permit')) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(_lang.youDoNtHavePermissionToCreateRacks)));
                              return;
                            }
                            const AddEditRack().launch(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                            height: 48.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: kGreyTextColor),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: kGreyTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rack Data List Loading and Display
                rackDataAsync.when(
                  data: (model) {
                    final allRacks = model.data ?? [];
                    // Apply Search Filtering
                    _filterRacks(allRacks);

                    // NOTE: Replace 'rack_read_permit' with your actual Permit.value
                    if (!permissionService.hasPermission('rack_read_permit')) {
                      return const Center(child: PermitDenyWidget());
                    }

                    return _filteredList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, i) {
                              final rack = _filteredList[i];
                              return ListCardWidget(
                                // OnSelect action depends on context (e.g., selecting for product creation)
                                onSelect: widget.isFromProductList ? () => Navigator.pop(context, rack) : () {},
                                title: rack.name ?? 'N/A Rack',
                                // subtitle: 'Shelves: ${(rack.shelves ?? []).map((s) => s.name).join(', ')}',

                                // Delete Action
                                onDelete: () async {
                                  // NOTE: Replace 'rack_delete_permit' with your actual Permit.value
                                  if (!permissionService.hasPermission('rack_delete_permit')) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(_lang.youDoNtHavePermissionToDeleteRacks)));
                                    return;
                                  }

                                  bool confirmDelete =
                                      await showDeleteConfirmationDialog(context: context, itemName: 'rack');
                                  if (confirmDelete) {
                                    EasyLoading.show();
                                    if (await RackRepo().deleteRack(context: context, id: rack.id ?? 0, ref: ref)) {
                                      ref.refresh(rackListProvider);
                                    }
                                    EasyLoading.dismiss();
                                  }
                                },

                                // Edit Action
                                onEdit: () async {
                                  // NOTE: Replace 'rack_update_permit' with your actual Permit.value
                                  if (!permissionService.hasPermission('rack_update_permit')) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(_lang.youDoNtHavePermissionToUpdateRacks)));
                                    return;
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEditRack(
                                          isEdit: true,
                                          rack: rack,
                                        ),
                                      ));
                                },
                              );
                            })
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              search.isEmpty ? lang.S.of(context).noDataFound : _lang.notMatchingResultFound,
                            ),
                          );
                  },
                  error: (e, __) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error loading data: ${e.toString()}'),
                    );
                  },
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
