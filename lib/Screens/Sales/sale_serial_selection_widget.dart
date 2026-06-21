import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class BatchSerialSelectionWidget extends StatefulWidget {
  final List<dynamic> availableSerials;
  final List<dynamic> preSelectedSerials;
  final Function(List<dynamic>) onConfirmed;

  const BatchSerialSelectionWidget({
    super.key,
    required this.availableSerials,
    required this.preSelectedSerials,
    required this.onConfirmed,
  });

  @override
  State<BatchSerialSelectionWidget> createState() => _BatchSerialSelectionWidgetState();
}

class _BatchSerialSelectionWidgetState extends State<BatchSerialSelectionWidget> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredSerials = [];
  List<dynamic> tempSelected = [];

  @override
  void initState() {
    super.initState();
    filteredSerials = widget.availableSerials;
    tempSelected = List.from(widget.preSelectedSerials);
  }

  void filterSerials(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSerials = widget.availableSerials;
      } else {
        filteredSerials = widget.availableSerials
            .where((element) => element.toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void toggleSerial(dynamic serial) {
    setState(() {
      if (tempSelected.contains(serial)) {
        tempSelected.remove(serial);
      } else {
        tempSelected.add(serial);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 500, // উচ্চতা ফিক্সড বা প্রয়োজন অনুযায়ী
        child: Column(
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Serial (${tempSelected.length})",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                )
              ],
            ),
            const Divider(),

            // --- Search & Scan Section ---
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: searchController,
                    textFieldType: TextFieldType.NAME,
                    decoration: InputDecoration(
                      hintText: "Search Serial/IMEI...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    onChanged: filterSerials,
                  ),
                ),
                const SizedBox(width: 10),
                // --- Scanner Button ---
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => BarcodeScannerWidget(
                        onBarcodeFound: (String code) {
                          setState(() {
                            searchController.text = code;
                            filterSerials(code);
                          });
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- Serial List ---
            Expanded(
              child: filteredSerials.isEmpty
                  ? const Center(child: Text("No serials found"))
                  : ListView.builder(
                      itemCount: filteredSerials.length,
                      itemBuilder: (context, index) {
                        final serial = filteredSerials[index];
                        final isSelected = tempSelected.contains(serial);
                        return Card(
                          elevation: 0,
                          color: isSelected ? kMainColor.withOpacity(0.1) : Colors.grey.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? kMainColor : Colors.grey.shade300,
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: kMainColor,
                            title: Text(serial.toString()),
                            value: isSelected,
                            onChanged: (val) => toggleSerial(serial),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),

            // --- Bottom Buttons ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(lang.S.of(context).cancel, style: const TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      widget.onConfirmed(tempSelected);
                      Navigator.pop(context);
                    },
                    child: Text(lang.S.of(context).save, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
