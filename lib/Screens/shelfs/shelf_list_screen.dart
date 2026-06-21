// File: product_shelf_list_screen.dart (Based on BrandsList structure)

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/shelfs/provider/shelf_provider.dart';
import 'package:mobile_pos/Screens/shelfs/repo/shelf_repo.dart';
import 'package:nb_utils/nb_utils.dart'; // Assuming nb_utils is needed for .launch()

// --- Local Imports ---
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../GlobalComponents/glonal_popup.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../../widgets/deleteing_alart_dialog.dart';
import '../product_category/product_category_list_screen.dart';
import 'add_edit_shelf_screen.dart';

// --- Data Layer Imports ---

class ProductShelfList extends ConsumerStatefulWidget {
  const ProductShelfList({super.key, required this.isFromProductList});

  final bool isFromProductList;

  @override
  ConsumerState<ProductShelfList> createState() => _ProductShelfListState();
}

class _ProductShelfListState extends ConsumerState<ProductShelfList> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(_lang.shelf),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Consumer(builder: (context, ref, __) {
            final shelfDataAsync = ref.watch(shelfListProvider);
            // Assuming businessInfoProvider and Permit enum are accessible
            final permissionService = PermissionService(ref);

            // NOTE: I'm skipping the outer businessInfo.when block
            // for simplicity, as the main data is shelfDataAsync.

            // You may insert the outer businessInfo.when block here if required:
            // final businessInfo = ref.watch(businessInfoProvider);
            // return businessInfo.when(data: (details) { ... });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
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
                            // Assuming AddEditShelf is used for adding too (isEdit=false)
                            const AddEditShelf().launch(context);
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

                // Shelf Data List Loading and Display
                shelfDataAsync.when(
                  data: (model) {
                    final allShelves = model.data ?? [];
                    // Apply Search Filtering
                    final filteredShelves = allShelves.where((shelf) {
                      return (shelf.name ?? '').toLowerCase().contains(search.toLowerCase()) ||
                          (shelf.description ?? '').toLowerCase().contains(search.toLowerCase());
                    }).toList();

                    return filteredShelves.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredShelves.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, i) {
                              final shelf = filteredShelves[i];
                              return ListCardWidget(
                                // OnSelect action depends on context (e.g., selecting for product creation)
                                onSelect: widget.isFromProductList
                                    ? () => Navigator.pop(context, shelf)
                                    : () {
                                        // Default action if not from product list
                                        // You might navigate to a detailed view or do nothing
                                      },
                                title: shelf.name ?? 'N/A Shelf',

                                // Delete Action
                                onDelete: () async {
                                  // NOTE: Replace 'shelf_delete_permit' with your actual Permit.value
                                  if (!permissionService.hasPermission('shelf_delete_permit')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(_lang.youDoNotHavePermissionDeleteTheShelf),
                                      ),
                                    );
                                    return;
                                  }

                                  bool confirmDelete =
                                      await showDeleteConfirmationDialog(context: context, itemName: 'shelf');
                                  if (confirmDelete) {
                                    EasyLoading.show();
                                    if (await ShelfRepo().deleteShelf(context: context, id: shelf.id ?? 0, ref: ref)) {
                                      ref.refresh(shelfListProvider);
                                    }
                                    EasyLoading.dismiss();
                                  }
                                },

                                // Edit Action
                                onEdit: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEditShelf(
                                          isEdit: true,
                                          shelf: shelf,
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

            // End of businessInfo.when block if it was used
          }),
        ),
      ),
    );
  }
}
