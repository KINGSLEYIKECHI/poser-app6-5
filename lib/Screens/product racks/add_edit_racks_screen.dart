import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/product%20racks/repo/product_racks_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../constant.dart';
import '../shelfs/model/shelf_list_model.dart';
import '../shelfs/provider/shelf_provider.dart';
import 'model/product_racks_model.dart';

class AddEditRack extends ConsumerStatefulWidget {
  final bool isEdit;
  final RackData? rack;

  const AddEditRack({super.key, this.isEdit = false, this.rack});

  @override
  ConsumerState<AddEditRack> createState() => _AddEditRackState();
}

class _AddEditRackState extends ConsumerState<AddEditRack> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  List<ShelfData> _selectedShelves = []; // List of selected shelves (full data)
  String? _selectedStatus;

  final List<String> _statusOptions = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.rack != null) {
      final data = widget.rack!;
      nameController.text = data.name ?? '';
      _selectedStatus = (data.status == 1 || data.status == 'Active') ? 'Active' : 'Inactive';

      // NOTE: _selectedShelves will be populated in build after shelfListAsync loads.
    } else {
      _selectedStatus = 'Active';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // --- Submission Logic ---
  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;

    final repo = RackRepo();
    final String apiStatus = _selectedStatus == 'Active' ? '1' : '0';

    // Extract list of IDs from selected ShelfData objects
    final List<num> shelfIds = _selectedShelves.map((s) => s.id ?? 0).toList();

    if (shelfIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one Shelf.')),
      );
      return;
    }

    if (widget.isEdit) {
      await repo.updateRack(
        ref: ref,
        context: context,
        id: widget.rack!.id!.round(),
        name: nameController.text,
        shelfIds: shelfIds,
        status: apiStatus,
      );
    } else {
      await repo.createRack(
        ref: ref,
        context: context,
        name: nameController.text,
        shelfIds: shelfIds,
        status: apiStatus,
      );
    }
  }

  // --- Reset Logic ---
  void _resetForm() {
    if (widget.isEdit) {
      Navigator.pop(context);
    } else {
      setState(() {
        _key.currentState?.reset();
        nameController.clear();
        _selectedStatus = 'Active';
        _selectedShelves = [];
      });
    }
  }

  // Helper widget to display selected shelves as chips (matching screenshot)
  Widget _buildShelfChip(ShelfData shelf) {
    return Chip(
      label: Text(shelf.name ?? 'N/A'),
      backgroundColor: kMainColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: kMainColor),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        setState(() {
          _selectedShelves.removeWhere((s) => s.id == shelf.id);
        });
        _key.currentState?.validate(); // Re-validate after removal
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shelfListAsync = ref.watch(shelfListProvider);
    final _lang = lang.S.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isEdit ? _lang.editRack : _lang.addNewRack),
        actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Rack Name Input
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: _lang.rackName, hintText: _lang.enterName),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterRackName : null,
              ),
              const SizedBox(height: 20),

              // 2. Shelves Multi-Select Dropdown (Dynamic)
              shelfListAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text('Shelf List Error: $err'),
                  data: (shelfModel) {
                    final allShelves = shelfModel.data ?? [];

                    // FIX: Populate _selectedShelves on first load if editing
                    if (widget.isEdit && widget.rack!.shelves != null && _selectedShelves.isEmpty) {
                      final currentShelfIds = widget.rack!.shelves!.map((s) => s.id).toSet();
                      // Map Shelf (nested model) back to ShelfData (provider model) for consistency
                      _selectedShelves = allShelves.where((s) => currentShelfIds.contains(s.id)).toList();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_lang.shelves, style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        // Display selected items as chips
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _selectedShelves.map(_buildShelfChip).toList(),
                        ),

                        // Custom Dropdown Button for selection
                        DropdownButtonFormField<ShelfData>(
                          decoration: InputDecoration(
                            hintText: _lang.pressToSelect,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                          ),
                          value: null,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          validator: (_) => _selectedShelves.isEmpty ? _lang.selectAtLeastOneRack : null,
                          items: allShelves.map((ShelfData shelf) {
                            final isSelected = _selectedShelves.any((s) => s.id == shelf.id);
                            return DropdownMenuItem<ShelfData>(
                              value: shelf,
                              enabled: !isSelected,
                              child: Text(shelf.name ?? 'N/A',
                                  style: TextStyle(color: isSelected ? Colors.grey : Colors.black)),
                            );
                          }).toList(),
                          onChanged: (ShelfData? newShelf) {
                            if (newShelf != null && !_selectedShelves.any((s) => s.id == newShelf.id)) {
                              setState(() {
                                _selectedShelves.add(newShelf);
                              });
                            }
                            _key.currentState?.validate();
                          },
                        ),
                      ],
                    );
                  }),
              const SizedBox(height: 20),

              // 3. Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: InputDecoration(labelText: _lang.status, hintText: _lang.selectOne),
                items: [
                  DropdownMenuItem(value: 'Active', child: Text(_lang.active)),
                  DropdownMenuItem(value: 'Inactive', child: Text(_lang.inactive)),
                ],
                // items:
                //     _statusOptions.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedStatus = newValue);
                },
                validator: (value) => value == null ? _lang.pleaseSelectAStatus : null,
              ),
              const SizedBox(height: 30),

              // 4. Action Buttons (Reset/Save)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: Text(_lang.resets),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.isEdit ? _lang.update : _lang.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
