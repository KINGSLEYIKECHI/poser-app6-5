import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/GlobalComponents/bar_code_scaner_widget.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../../constant.dart';

void showSerialModal({
  required BuildContext context,
  required List<dynamic> initialSerials,
  required List<dynamic> oldSerials,
  required Function(List<String>) onSave,
}) {
  TextEditingController serialInputController = TextEditingController();
  List<String> tempSerials = List.from(initialSerials);

  void addSerial(String value, Function setModalState) {
    String serial = value.trim();
    if (serial.isEmpty) return;

    if (tempSerials.contains(serial)) {
      EasyLoading.showError("This serial is already added in the list!");
      return;
    }

    if (oldSerials.contains(serial)) {
      EasyLoading.showError("This serial already exists in the system!");
      return;
    }

    setModalState(() {
      tempSerials.add(serial);
      serialInputController.clear();
    });
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final _lang = l.S.of(context);
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------------- HEADER ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        _lang.addImeiOrSerial,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    Row(
                      children: [
                        Text('${_lang.entered}: ', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                        Text(
                          '${tempSerials.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---------------- INPUT SECTION ----------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: serialInputController,
                          decoration: InputDecoration(
                            hintText: _lang.searchOrTypeSerialNumber,
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: kMainColor)),
                            suffixIcon: InkWell(
                              onTap: () => showDialog(
                                context: context,
                                builder: (c) => BarcodeScannerWidget(
                                  onBarcodeFound: (code) {
                                    addSerial(code, setModalState);
                                  },
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: 48,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                  color: const Color(0xffD8D8D8).withOpacity(0.3),
                                ),
                                child: SvgPicture.asset('assets/qr_new.svg', fit: BoxFit.scaleDown),
                              ),
                            ),
                          ),
                          onFieldSubmitted: (value) => addSerial(value, setModalState),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEEAEA),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => addSerial(serialInputController.text, setModalState),
                        child: Text(_lang.add,
                            style: TextStyle(color: kMainColor, fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---------------- LIST ----------------
                tempSerials.isEmpty
                    ? Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: Text(_lang.noSerialAddedYet, style: TextStyle(color: Colors.grey.shade400)),
                      )
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: tempSerials.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.only(left: 12, right: 4),
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tempSerials[index],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                      onPressed: () {
                                        setModalState(() {
                                          tempSerials.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // ---------------- BOTTOM BUTTONS ----------------
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kMainColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(_lang.cancel,
                              style: TextStyle(color: kMainColor, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMainColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            onSave(tempSerials);
                            Navigator.pop(context);
                          },
                          child: Text(_lang.done,
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}
