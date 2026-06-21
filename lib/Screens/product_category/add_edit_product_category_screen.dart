// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/product_category/model/category_model.dart'; // Import CategoryModel
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/glonal_popup.dart';
import '../../http_client/custome_http_client.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'repo/product_category_repo.dart';

class CategoryFormScreen extends StatefulWidget {
  // Make the categoryModel nullable to handle both Add (null) and Edit (not null)
  final CategoryModel? categoryModel;

  const CategoryFormScreen({super.key, this.categoryModel});

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  bool showProgress = false;
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if we are in Edit mode
    if (widget.categoryModel != null) {
      // Pre-fill fields for editing
      categoryNameController.text = widget.categoryModel!.categoryName ?? '';
    }
  }

  // Determine if the screen is for editing or adding
  bool get isEditing => widget.categoryModel != null;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final permissionService = PermissionService(ref);

      // Determine the title based on whether we are editing or adding
      final String screenTitle = isEditing
          ? lang.S.of(context).editCategory // Assuming you have an 'editCategory' key
          : lang.S.of(context).addCategory;

      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(screenTitle),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: showProgress,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: kMainColor,
                        strokeWidth: 5.0,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: categoryNameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: lang.S.of(context).enterCategoryName,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).categoryName,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _saveCategory(context, ref, permissionService),
                    child: Text(lang.S.of(context).save),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _saveCategory(BuildContext context, WidgetRef ref, PermissionService permissionService) async {
    // Determine the required permission for the current operation
    final Permit requiredPermit = isEditing ? Permit.categoriesUpdate : Permit.categoriesCreate;

    // Check permission
    if (!permissionService.hasPermission(requiredPermit.value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            isEditing
                ? 'You do not have permission to update category.'
                : 'You do not have permission to create category.',
          ),
        ),
      );
      return;
    }

    setState(() {
      showProgress = true;
    });

    final categoryRepo = CategoryRepo();

    if (isEditing) {
      // Logic for editing an existing category
      await categoryRepo.editCategory(
        id: widget.categoryModel!.id ?? 0,
        ref: ref,
        context: context,
        name: categoryNameController.text,
      );
    } else {
      // Logic for adding a new category
      await categoryRepo.addCategory(
        ref: ref,
        context: context,
        name: categoryNameController.text,
      );
    }

    setState(() {
      showProgress = false;
    });
  }
}
