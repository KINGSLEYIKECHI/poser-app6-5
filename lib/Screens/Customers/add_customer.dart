import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

// Custom Dropdown and Model Import
import 'package:mobile_pos/widgets/country_state_dropdown.dart';
import '../../model/country_state_model.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'Repo/parties_repo.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';

class AddParty extends StatefulWidget {
  const AddParty({super.key, this.customerModel});
  final Party? customerModel;

  @override
  _AddPartyState createState() => _AddPartyState();
}

class _AddPartyState extends State<AddParty> {
  // Form & General Variables
  final GlobalKey<FormState> _formKay = GlobalKey();
  String groupValue = 'Retailer';
  String advanced = 'advance';
  String due = 'due';
  String openingBalanceType = 'due';
  bool expanded = false;
  bool showProgress = false;

  // Image Picker
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;

  // Controllers
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController(); // New Controller
  TextEditingController addressController = TextEditingController();
  final creditLimitController = TextEditingController();
  final openingBalanceController = TextEditingController();

  // Billing Controllers
  final billingAddressController = TextEditingController();
  final billingCityController = TextEditingController();
  final billingZipCodeCountryController = TextEditingController();

  // Shipping Controllers
  final shippingAddressController = TextEditingController();
  final shippingCityController = TextEditingController();
  final shippingZipCodeCountryController = TextEditingController();

  // Country & State Selection Variables
  CountryModel? selectedBillingCountry;
  StateModel? selectedBillingState;
  CountryModel? selectedShippingCountry;
  StateModel? selectedShippingState;

  // Initial IDs for Edit Mode
  num? initialBillingCountryId;
  num? initialBillingStateId;
  String? initialShippingCountryName;
  String? initialShippingStateName;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final party = widget.customerModel;
    if (party != null) {
      nameController.text = party.name ?? '';
      emailController.text = party.email ?? '';
      taxNumberController.text = party.taxNumber ?? ''; // Initialize Tax Number
      addressController.text = party.address ?? '';
      creditLimitController.text = party.creditLimit?.toString() ?? '';
      openingBalanceController.text = party.openingBalance?.toString() ?? '';
      openingBalanceType = party.openingBalanceType ?? 'due';
      groupValue = party.type ?? 'Retailer';
      phoneController.text = party.phone ?? '';

      // Initialize Billing Fields
      billingAddressController.text = party.billingAddress?.address ?? '';
      billingCityController.text = party.billingAddress?.city ?? '';
      billingZipCodeCountryController.text = party.billingAddress?.zipCode ?? '';

      // Set initial ID (Assign here if ID comes from API)
      initialBillingCountryId = party.countryId;
      initialBillingStateId = party.stateId;

      initialShippingCountryName = party.shippingAddress?.country;
      initialShippingStateName = party.shippingAddress?.state;

      // Initialize Shipping Fields
      shippingAddressController.text = party.shippingAddress?.address ?? '';
      shippingCityController.text = party.shippingAddress?.city ?? '';
      shippingZipCodeCountryController.text = party.shippingAddress?.zipCode ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer(builder: (context, ref, __) {
      final businessInfo = ref.watch(businessInfoProvider);
      final permissionService = PermissionService(ref);

      // Check Read Only Permission
      bool isReadOnly = (widget.customerModel?.branchId != businessInfo.value?.data?.user?.activeBranchId) &&
          widget.customerModel != null;

      return GlobalPopup(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: kWhite,
            backgroundColor: Colors.white,
            title: Text(lang.S.of(context).addParty),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
            bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, thickness: 1)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKay,
              child: Column(
                children: [
                  // Phone Number
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return lang.S.of(context).pleaseEnterAValidPhoneNumber;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).phone,
                      hintText: lang.S.of(context).enterYourPhoneNumber,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return lang.S.of(context).pleaseEnterAValidName;
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).name,
                      hintText: lang.S.of(context).enterYourName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opening Balance
                  TextFormField(
                    controller: openingBalanceController,
                    readOnly: isReadOnly,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: lang.S.of(context).balance,
                      hintText: lang.S.of(context).enterOpeningBalance,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                              color: Color(0xffF7F7F7),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              )),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: isReadOnly ? Colors.grey : kPeraColor,
                              ),
                              items: [
                                DropdownMenuItem(value: advanced, child: Text(lang.S.of(context).advance)),
                                DropdownMenuItem(value: due, child: Text(lang.S.of(context).due)),
                              ],
                              value: openingBalanceType,
                              onChanged: isReadOnly
                                  ? null
                                  : (String? value) {
                                      setState(() {
                                        openingBalanceType = value!;
                                      });
                                    },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customer Type Radio Buttons
                  Row(
                    children: [
                      Expanded(child: _buildRadioTile('Retailer', lang.S.of(context).customer, theme)),
                      Expanded(child: _buildRadioTile('Dealer', lang.S.of(context).dealer, theme)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildRadioTile('Wholesaler', lang.S.of(context).wholesaler, theme)),
                      Expanded(child: _buildRadioTile('Supplier', lang.S.of(context).supplier, theme)),
                    ],
                  ),

                  Visibility(
                    visible: showProgress,
                    child: const CircularProgressIndicator(color: kMainColor, strokeWidth: 5.0),
                  ),

                  // Expansion Panel for More Info
                  ExpansionPanelList(
                    expandIconColor: Colors.transparent,
                    expandedHeaderPadding: EdgeInsets.zero,
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                    animationDuration: const Duration(milliseconds: 500),
                    elevation: 0,
                    dividerColor: Colors.white,
                    children: [
                      ExpansionPanel(
                        backgroundColor: kWhite,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return TextButton.icon(
                            style: const ButtonStyle(
                              alignment: Alignment.center,
                              padding: WidgetStatePropertyAll(EdgeInsets.only(left: 70)),
                            ),
                            onPressed: () {
                              setState(() {
                                expanded = !expanded;
                              });
                            },
                            label: Text(
                              lang.S.of(context).moreInfo,
                              style: theme.textTheme.titleSmall?.copyWith(color: Colors.red),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_outlined),
                            iconAlignment: IconAlignment.end,
                          );
                        },
                        body: Column(
                          children: [
                            // Image Picker Widget
                            _buildImagePicker(context, theme),
                            const SizedBox(height: 20),

                            // Email
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).email,
                                  hintText: lang.S.of(context).hintEmail),
                            ),
                            const SizedBox(height: 20),

                            // Tax Number Field (New Added)
                            TextFormField(
                              controller: taxNumberController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).taxNo, // You can add this to your language file
                                hintText: lang.S.of(context).enterTaxNumber,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Address
                            TextFormField(
                              controller: addressController,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).address,
                                  hintText: lang.S.of(context).hintEmail),
                            ),
                            const SizedBox(height: 20),

                            // Credit Limit
                            TextFormField(
                              controller: creditLimitController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).creditLimit,
                                  hintText: 'Ex: 800'),
                            ),
                            const SizedBox(height: 4),

                            // ----------------- BILLING ADDRESS SECTION -----------------
                            Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                collapsedIconColor: kGreyTextColor,
                                visualDensity: const VisualDensity(vertical: -2, horizontal: -4),
                                tilePadding: EdgeInsets.zero,
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(FeatherIcons.plus, size: 20),
                                    const SizedBox(width: 8),
                                    Text(lang.S.of(context).billingAddress, style: theme.textTheme.titleMedium)
                                  ],
                                ),
                                children: [
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: billingAddressController,
                                    decoration: InputDecoration(
                                      labelText: lang.S.of(context).address,
                                      hintText: lang.S.of(context).enterAddress,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // --- Billing Country State Dropdown ---
                                  CountryStateDropdown(
                                    initialCountryId: initialBillingCountryId,
                                    initialStateId: initialBillingStateId,
                                    onCountryChanged: (CountryModel? country) {
                                      setState(() {
                                        selectedBillingCountry = country;
                                      });
                                    },
                                    onStateChanged: (StateModel? state) {
                                      setState(() {
                                        selectedBillingState = state;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: billingCityController,
                                          decoration: InputDecoration(
                                            labelText: lang.S.of(context).city,
                                            hintText: lang.S.of(context).cityName,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: billingZipCodeCountryController,
                                          decoration: InputDecoration(
                                            labelText: lang.S.of(context).zip,
                                            hintText: lang.S.of(context).zipCode,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),

                            // ----------------- SHIPPING ADDRESS SECTION -----------------
                            Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                collapsedIconColor: kGreyTextColor,
                                tilePadding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(FeatherIcons.plus, size: 20),
                                    const SizedBox(width: 8),
                                    Text(lang.S.of(context).shippingAddress, style: theme.textTheme.titleMedium)
                                  ],
                                ),
                                children: [
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: shippingAddressController,
                                    decoration: InputDecoration(
                                      labelText: lang.S.of(context).address,
                                      hintText: lang.S.of(context).enterAddress,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // --- Shipping Country State Dropdown ---
                                  CountryStateDropdown(
                                    initialCountryName: initialShippingCountryName,
                                    initialStateName: initialShippingStateName,
                                    onCountryChanged: (CountryModel? country) {
                                      setState(() {
                                        selectedShippingCountry = country;
                                      });
                                    },
                                    onStateChanged: (StateModel? state) {
                                      setState(() {
                                        selectedShippingState = state;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: shippingCityController,
                                          decoration: InputDecoration(
                                            labelText: lang.S.of(context).city,
                                            hintText: lang.S.of(context).cityName,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: shippingZipCodeCountryController,
                                          decoration: InputDecoration(
                                            labelText: lang.S.of(context).zip,
                                            hintText: lang.S.of(context).zipCode,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            )
                          ],
                        ),
                        isExpanded: expanded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    onPressed: () async {
                      // 1. Check Permissions
                      if (!permissionService.hasPermission(Permit.partiesCreate.value)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(lang.S.of(context).partyCreateWarn),
                          ),
                        );
                        return;
                      }

                      // 2. Validate Form
                      if (_formKay.currentState!.validate()) {
                        // Start Loading
                        EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);

                        try {
                          // Helper function to parse number inputs safely
                          num parseOrZero(String? input) {
                            if (input == null || input.isEmpty) return 0;
                            return num.tryParse(input) ?? 0;
                          }

                          // Create Customer Object
                          Customer customer = Customer(
                            id: widget.customerModel?.id.toString() ?? '',
                            name: nameController.text,
                            phone: phoneController.text ?? '',
                            customerType: groupValue,
                            image: pickedImage != null ? File(pickedImage!.path) : null,
                            email: emailController.text,
                            taxNumber: taxNumberController.text,
                            address: addressController.text,
                            openingBalanceType: openingBalanceType.toString(),
                            openingBalance: parseOrZero(openingBalanceController.text),
                            creditLimit: parseOrZero(creditLimitController.text),

                            // Billing Info
                            billingAddress: billingAddressController.text,
                            billingCity: billingCityController.text,
                            billingZipcode: billingZipCodeCountryController.text,
                            billingCountryId: selectedBillingCountry?.id,
                            billingStateId: selectedBillingState?.id,

                            // Shipping Info
                            shippingAddress: shippingAddressController.text,
                            shippingCity: shippingCityController.text,
                            shippingZipcode: shippingZipCodeCountryController.text,
                            shippingCountry: selectedShippingCountry?.name ?? '',
                            shippingState: selectedShippingState?.name ?? '',
                          );

                          final partyRepo = PartyRepository();

                          // Call Repository methods based on mode (Add or Update)
                          if (widget.customerModel == null) {
                            await partyRepo.addParty(
                              ref: ref,
                              context: context,
                              customer: customer,
                            );
                          } else {
                            await partyRepo.updateParty(
                              ref: ref,
                              context: context,
                              customer: customer,
                            );
                          }
                        } catch (e) {
                          // Handle Errors
                          EasyLoading.dismiss();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } finally {
                          // Dismiss Loading (This runs whether success or fail)
                          EasyLoading.dismiss();
                        }
                      }
                    },
                    child: Text(lang.S.of(context).save),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Radio Button Helper
  Widget _buildRadioTile(String value, String title, ThemeData theme) {
    return RadioListTile(
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kMainColor;
        return kPeraColor;
      }),
      contentPadding: EdgeInsets.zero,
      groupValue: groupValue,
      title: Text(title, maxLines: 1, style: theme.textTheme.bodyMedium),
      value: value,
      onChanged: (val) {
        setState(() {
          groupValue = val.toString();
        });
      },
    );
  }

  // Image Picker Helper
  Widget _buildImagePicker(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SizedBox(
                  height: 200.0,
                  width: MediaQuery.of(context).size.width - 80,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                            setState(() {});
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_library_rounded, size: 60.0, color: kMainColor),
                              Text(lang.S.of(context).gallery,
                                  style: theme.textTheme.titleMedium?.copyWith(color: kMainColor)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40.0),
                        GestureDetector(
                          onTap: () async {
                            pickedImage = await _picker.pickImage(source: ImageSource.camera);
                            setState(() {});
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera, size: 60.0, color: kGreyTextColor),
                              Text(lang.S.of(context).camera,
                                  style: theme.textTheme.titleMedium?.copyWith(color: kGreyTextColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      child: Stack(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: pickedImage == null
                  ? const DecorationImage(image: AssetImage('images/no_shop_image.png'), fit: BoxFit.cover)
                  : DecorationImage(image: FileImage(File(pickedImage!.path)), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(120)),
                color: kMainColor,
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

// Updated Customer DTO with taxNumber
class Customer {
  String? id;
  String name;
  String? phone;
  String? customerType;
  File? image;
  String? email;
  String? taxNumber; // New Field
  String? address;
  String? openingBalanceType;
  num? openingBalance;
  num? creditLimit;
  String? billingAddress;
  String? billingCity;
  num? billingStateId;
  String? billingZipcode;
  num? billingCountryId;
  String? shippingAddress;
  String? shippingCity;
  String? shippingState;
  String? shippingZipcode;
  String? shippingCountry;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.customerType,
    this.image,
    this.email,
    this.taxNumber, // New Field
    this.address,
    this.openingBalanceType,
    this.openingBalance,
    this.creditLimit,
    this.billingAddress,
    this.billingCity,
    this.billingStateId,
    this.billingZipcode,
    this.billingCountryId,
    this.shippingAddress,
    this.shippingCity,
    this.shippingState,
    this.shippingZipcode,
    this.shippingCountry,
  });
}
