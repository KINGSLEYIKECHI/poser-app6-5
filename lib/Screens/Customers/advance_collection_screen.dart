import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/Screens/Customers/Repo/parties_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/multipal%20payment%20mathods/multi_payment_widget.dart';

class AdvanceCollectionScreen extends ConsumerStatefulWidget {
  final Party party;

  const AdvanceCollectionScreen({super.key, required this.party});

  @override
  ConsumerState<AdvanceCollectionScreen> createState() => _AdvanceCollectionScreenState();
}

class _AdvanceCollectionScreenState extends ConsumerState<AdvanceCollectionScreen> {
  // Controller for Amount
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Key for MultiPaymentWidget to access payment data
  final GlobalKey<MultiPaymentWidgetState> paymentKey = GlobalKey<MultiPaymentWidgetState>();

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Advance Collection'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kMainColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kMainColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  // --- Party Image / Initials Logic ---
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // If no image, show light background. If image exists, background is covered.
                      color: kMainColor.withOpacity(0.1),
                      border: Border.all(color: kMainColor.withOpacity(0.1)),
                      image: widget.party.image != null
                          ? DecorationImage(
                              image: NetworkImage('${widget.party.image}'),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.party.image == null
                        ? Center(
                            child: Text(
                              widget.party.name != null && widget.party.name!.isNotEmpty
                                  ? widget.party.name!.substring(0, 1).toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                color: kMainColor, // Colored text instead of white
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // --- Party Name & Phone ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.party.name ?? '',
                        style: _theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.party.phone ?? '',
                        style: _theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount Field
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              readOnly: (paymentKey.currentState?.getPaymentEntries().length ?? 1) > 1,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: lang.S.of(context).amount,
                hintText: '0.00',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),

            // Date Field
            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: lang.S.of(context).date,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(FeatherIcons.calendar, color: kGreyTextColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    dateController.text = formattedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // -------------------------------------------------------
            // Multi Payment Widget
            // -------------------------------------------------------
            MultiPaymentWidget(
              key: paymentKey,
              totalAmountController: amountController,
              showWalletOption: false,
              showChequeOption: true,
            ),
            const SizedBox(height: 20),

            // Note Field
            TextFormField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: lang.S.of(context).note,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // Bottom Navigation Bar (Cancel & Save Buttons)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Row(
          children: [
            // Cancel Button
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  maximumSize: const Size(double.infinity, 48),
                  minimumSize: const Size(double.infinity, 48),
                  disabledBackgroundColor: _theme.colorScheme.primary.withOpacity(0.15),
                  side: BorderSide(color: _theme.colorScheme.primary),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  lang.S.of(context).cancel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    color: _theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Save Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMainColor,
                  maximumSize: const Size(double.infinity, 48),
                  minimumSize: const Size(double.infinity, 48),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (amountController.text.isEmpty || double.tryParse(amountController.text) == 0) {
                    EasyLoading.showError(lang.S.of(context).enterAmount);
                    return;
                  }

                  // Retrieve payments from the widget
                  List<PaymentEntry> payments = paymentKey.currentState?.getPaymentEntries() ?? [];

                  if (payments.isEmpty) {
                    EasyLoading.showError("Select Payment Method");
                    return;
                  }

                  // Prepare payment data for API
                  List<Map<String, dynamic>> paymentData = payments.map((e) => e.toJson()).toList();

                  try {
                    EasyLoading.show(status: 'Collecting...');
                    PartyRepository repo = PartyRepository();

                    await repo.saveAdvanceCollection(
                      ref: ref,
                      context: context,
                      partyId: widget.party.id.toString(),
                      amount: amountController.text,
                      date: dateController.text,
                      payments: paymentData,
                      note: noteController.text,
                    );
                  } catch (e) {
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: Text(
                  lang.S.of(context).save,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
