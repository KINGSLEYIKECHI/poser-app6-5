import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Repository/check_addon_providers.dart';
import 'package:mobile_pos/Screens/Settings/printing_invoice/repo/invoice_size_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Repository/API/business_info_update_repo.dart';
import '../../../constant.dart';
import '../../../widgets/printer_profile/printer_profile.dart';

class PrintingInvoiceScreen extends ConsumerStatefulWidget {
  const PrintingInvoiceScreen({super.key});

  @override
  ConsumerState<PrintingInvoiceScreen> createState() => _PrintingInvoiceScreenState();
}

class _PrintingInvoiceScreenState extends ConsumerState<PrintingInvoiceScreen> {
  Map<String, bool> invoiceVisibility = {
    "show_company_name": true,
    "show_phone_number": true,
    "show_address": true,
    "show_email": true,
    "show_vat": true,
    "show_note": true,
    "show_gratitude_msg": true,
    "show_invoice_scanner_logo": true,
    "show_a4_invoice_logo": true,
    "show_thermal_invoice_logo": true,
    "show_warranty": true,
  };

  TextEditingController addressController = TextEditingController();
  TextEditingController vatNameController = TextEditingController();
  TextEditingController vatNumberController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final noteLevelController = TextEditingController();
  final warrantyVoidLabel = TextEditingController();
  final warrantyVoid = TextEditingController();
  final noteController = TextEditingController();
  final gratitudeController = TextEditingController();
  Map<String, String> invoiceSizeOptions = {
    '3_inch_80mm': '3 inch 80mm',
    '2_inch_58mm': '2 inch 58mm',
  };
  Map<String, String> invoiceLanguageOptions = {
    'english': 'English',
    'all_language': 'All Language',
  };

  bool isProductDiscountAllowed = true;

  @override
  void initState() {
    super.initState();
    printing = isPrintEnable;

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final businessData = ref.read(businessInfoProvider).value;
    if (businessData?.data != null) {
      final data = businessData!.data!;

      // Load form field data - ALWAYS LOAD THESE
      nameController.text = data.companyName ?? '';
      phoneController.text = data.phoneNumber ?? '';
      emailController.text = data.invoiceEmail ?? '';
      addressController.text = data.address ?? '';
      vatNameController.text = data.vatName ?? '';
      vatNumberController.text = data.vatNo ?? '';
      noteLevelController.text = data.invoiceNoteLevel ?? '';
      warrantyVoidLabel.text = data.warrantyVoidLabel ?? '';
      warrantyVoid.text = data.warrantyVoid ?? '';
      noteController.text = data.invoiceNote ?? '';
      gratitudeController.text = data.gratitudeMessage ?? '';

      // Load Product Discount Setting
      isProductDiscountAllowed = data.allowProductDiscount == 1;

      /// ---------- Load visibility flags from META ----------
      final meta = data.meta;
      if (meta != null) {
        invoiceVisibility["show_company_name"] = meta.showCompanyName == 1;
        invoiceVisibility["show_phone_number"] = meta.showPhoneNumber == 1;
        invoiceVisibility["show_address"] = meta.showAddress == 1;
        invoiceVisibility["show_email"] = meta.showEmail == 1;
        invoiceVisibility["show_vat"] = meta.showVat == 1;
      }

      /// ---------- Load visibility flags from ROOT ----------
      invoiceVisibility["show_note"] = data.showNote == 1;
      invoiceVisibility["show_gratitude_msg"] = data.showGratitudeMsg == 1;
      invoiceVisibility["show_invoice_scanner_logo"] = data.showInvoiceScannerLogo == 1;
      invoiceVisibility["show_a4_invoice_logo"] = data.showA4InvoiceLogo == 1;
      invoiceVisibility["show_thermal_invoice_logo"] = data.showThermalInvoiceLogo == 1;
      invoiceVisibility["show_warranty"] = data.showWarranty == 1;

      // Set invoice size
      final invoiceSize = data.invoiceSize;
      if (invoiceSizeOptions.containsKey(invoiceSize)) {
        selectedThermalPrinter = invoiceSize;
      } else {
        selectedThermalPrinter = '2_inch_58mm';
      }

      // Set invoice language
      final invoiceLanguage = data.invoiceLanguage;
      if (invoiceLanguageOptions.containsKey(invoiceLanguage)) {
        selectedThermalPrinterLanguage = invoiceLanguage;
      } else {
        selectedThermalPrinterLanguage = 'english';
      }

      if (data.profilePrinter != null && data.profilePrinter!.isNotEmpty) {
        selectedPrinterProfile = PrinterProfile(name: data.profilePrinter!);
      } else {
        selectedPrinterProfile = PrinterProfile.fallback;
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget invoiceCheckbox(String key) {
    return Checkbox(
      value: invoiceVisibility[key] ?? false,
      onChanged: (val) {
        setState(() {
          invoiceVisibility[key] = val ?? false;
        });
      },
    );
  }

  bool printing = false;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');
  final ImagePicker _a4Picker = ImagePicker();
  XFile? pickedA4Image;
  File a4ImageFile = File('No File');
  final ImagePicker _thermalPicker = ImagePicker();
  XFile? pickedThermalImage;
  File thermalImageFile = File('No File');

  // Warranty picker
  final ImagePicker _scannerPicker = ImagePicker();
  XFile? pickedScannerImage;
  File scannerImageFile = File('No File');

  final GlobalKey<FormState> _formKey = GlobalKey();

  String? selectedThermalPrinter;
  String? selectedThermalPrinterLanguage = 'english';

  PrinterProfile? selectedPrinterProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = lang.S.of(context);
    final printerProfileAsync = ref.watch(printerProfileProvider);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            _lang.printingInvoice,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.S.of(context).pleaseEnterAValidBusinessName;
                        }
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).businessName,
                        suffixIcon: invoiceCheckbox("show_company_name"),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: phoneController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.PHONE,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).phone,
                        border: const OutlineInputBorder(),
                        suffixIcon: invoiceCheckbox("show_phone_number"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: emailController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.EMAIL,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).email,
                        border: const OutlineInputBorder(),
                        suffixIcon: invoiceCheckbox("show_email"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: addressController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).address,
                        border: const OutlineInputBorder(),
                        suffixIcon: invoiceCheckbox("show_address"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: vatNameController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).vatGstTitle,
                        border: const OutlineInputBorder(),
                        suffixIcon: invoiceCheckbox("show_vat"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: vatNumberController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).vatGstNumber,
                        border: const OutlineInputBorder(),
                        suffixIcon: invoiceCheckbox("show_vat"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: noteLevelController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).noteLevel,
                        suffixIcon: invoiceCheckbox("show_note"),
                        hintText: lang.S.of(context).enterYourNoteLevel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: noteController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).note,
                        suffixIcon: invoiceCheckbox("show_note"),
                        hintText: lang.S.of(context).enterNote,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: warrantyVoidLabel,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: 'Warranty Void Label ',
                        suffixIcon: invoiceCheckbox("show_warranty"),
                        hintText: 'Enter warranty void label',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: warrantyVoid,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: 'Warranty Void ',
                        suffixIcon: invoiceCheckbox("show_warranty"),
                        hintText: 'Enter warranty void',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: gratitudeController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).postSaleMessage,
                        suffixIcon: invoiceCheckbox("show_gratitude_msg"),
                        hintText: lang.S.of(context).enterYourPostSaleMessage,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lang.S.of(context).a4PageLogo,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 20),
                      Checkbox(
                        value: invoiceVisibility["show_a4_invoice_logo"] ?? false,
                        onChanged: (val) {
                          setState(() {
                            invoiceVisibility["show_a4_invoice_logo"] = val!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
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
                                          pickedA4Image = await _a4Picker.pickImage(source: ImageSource.gallery);

                                          setState(() {
                                            a4ImageFile = File(pickedA4Image!.path);
                                          });

                                          Navigator.pop(context);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.photo_library_rounded,
                                              size: 60.0,
                                              color: kMainColor,
                                            ),
                                            Text(
                                              lang.S.of(context).gallery,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                color: kGreyTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40.0,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          pickedA4Image = await _a4Picker.pickImage(source: ImageSource.camera);
                                          setState(() {
                                            a4ImageFile = File(pickedA4Image!.path);
                                          });
                                          Future.delayed(const Duration(milliseconds: 100), () {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.camera,
                                              size: 60.0,
                                              color: kGreyTextColor,
                                            ),
                                            Text(
                                              lang.S.of(context).camera,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                color: kGreyTextColor,
                                              ),
                                            ),
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
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        image: pickedA4Image == null
                            ? ref.watch(businessInfoProvider).value?.data?.a4InvoiceLogo == null
                                ? const DecorationImage(
                                    image: AssetImage(logo),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(
                                        (ref.watch(businessInfoProvider).value?.data?.a4InvoiceLogo.toString() ?? '')),
                                    fit: BoxFit.cover,
                                  )
                            : DecorationImage(
                                image: FileImage(a4ImageFile),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _lang.thermalInvoicePageLogo,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 20),
                      Checkbox(
                        value: invoiceVisibility["show_thermal_invoice_logo"] ?? false,
                        onChanged: (val) {
                          setState(() {
                            invoiceVisibility["show_thermal_invoice_logo"] = val!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
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
                                          pickedThermalImage =
                                              await _thermalPicker.pickImage(source: ImageSource.gallery);

                                          setState(() {
                                            thermalImageFile = File(pickedThermalImage!.path);
                                          });

                                          Navigator.pop(context);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.photo_library_rounded,
                                              size: 60.0,
                                              color: kMainColor,
                                            ),
                                            Text(
                                              lang.S.of(context).gallery,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                color: kGreyTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40.0,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          pickedThermalImage =
                                              await _thermalPicker.pickImage(source: ImageSource.camera);
                                          setState(() {
                                            thermalImageFile = File(pickedThermalImage!.path);
                                          });
                                          Future.delayed(const Duration(milliseconds: 100), () {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.camera,
                                              size: 60.0,
                                              color: kGreyTextColor,
                                            ),
                                            Text(
                                              lang.S.of(context).camera,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                color: kGreyTextColor,
                                              ),
                                            ),
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
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        image: pickedThermalImage == null
                            ? ref.watch(businessInfoProvider).value?.data?.thermalInvoiceLogo == null
                                ? const DecorationImage(
                                    image: AssetImage(logo),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(
                                        (ref.watch(businessInfoProvider).value?.data?.thermalInvoiceLogo.toString() ??
                                            '')),
                                    fit: BoxFit.cover,
                                  )
                            : DecorationImage(
                                image: FileImage(thermalImageFile),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Invoice Scanner Logo',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 20),
                      Checkbox(
                        value: invoiceVisibility["show_invoice_scanner_logo"] ?? false,
                        onChanged: (val) {
                          setState(() {
                            invoiceVisibility["show_invoice_scanner_logo"] = val!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
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
                                          pickedScannerImage =
                                              await _scannerPicker.pickImage(source: ImageSource.gallery);

                                          setState(() {
                                            scannerImageFile = File(pickedScannerImage!.path);
                                          });

                                          Navigator.pop(context);
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.photo_library_rounded,
                                              size: 60.0,
                                              color: kMainColor,
                                            ),
                                            Text(
                                              lang.S.of(context).gallery,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                color: kGreyTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40.0,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          pickedScannerImage =
                                              await _scannerPicker.pickImage(source: ImageSource.camera);
                                          setState(() {
                                            scannerImageFile = File(pickedScannerImage!.path);
                                          });
                                          Future.delayed(const Duration(milliseconds: 100), () {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.camera,
                                              size: 60.0,
                                              color: kGreyTextColor,
                                            ),
                                            Text(
                                              lang.S.of(context).camera,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                color: kGreyTextColor,
                                              ),
                                            ),
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
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        image: pickedScannerImage == null
                            ? ref.watch(businessInfoProvider).value?.data?.invoiceScannerLogo == null
                                ? const DecorationImage(
                                    image: AssetImage(logo),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(
                                        (ref.watch(businessInfoProvider).value?.data?.invoiceScannerLogo.toString() ??
                                            '')),
                                    fit: BoxFit.cover,
                                  )
                            : DecorationImage(
                                image: FileImage(scannerImageFile),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30.0),
              // ----------- Product Discount Option -----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Product Discount', style: theme.textTheme.titleMedium),
                  SizedBox(
                    width: 44,
                    height: 22,
                    child: Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        activeTrackColor: kMainColor,
                        value: isProductDiscountAllowed,
                        onChanged: (bool value) async {
                          setState(() => isProductDiscountAllowed = value);
                        },
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),

              ///___________Tharmal_printing_Language_________
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                title: Text(
                  _lang.thermalPrinterLanguage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: SizedBox(
                  width: 105,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      padding: EdgeInsets.zero,
                      items: invoiceLanguageOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      value: selectedThermalPrinterLanguage ?? 'english',
                      onChanged: (String? value) async {
                        setState(() {
                          selectedThermalPrinterLanguage = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox.square(dimension: 10),
              printerProfileAsync.when(
                data: (profiles) {
                  // Ensure selected value exists in list
                  if (selectedPrinterProfile != null && !profiles.contains(selectedPrinterProfile)) {
                    selectedPrinterProfile = null;
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                    title: Text(
                      'Printer Profile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: SizedBox(
                      width: 105,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PrinterProfile>(
                          isExpanded: true,
                          value: selectedPrinterProfile,
                          hint: Text(_lang.select),
                          items: profiles.map((profile) {
                            return DropdownMenuItem<PrinterProfile>(
                              value: profile,
                              child: Text(
                                profile.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (PrinterProfile? value) {
                            setState(() {
                              selectedPrinterProfile = value;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Text('Error: $error'),
              ),

              ///________Tharmal_printing_page_size_________
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                title: Text(
                  _lang.thermalPrinterPageSize,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: ref.watch(invoice80mmAddonCheckProvider).when(
                      data: (data) {
                        if (!data) {
                          invoiceSizeOptions = {
                            '2_inch_58mm': '2 inch 58mm',
                          };
                        }
                        return SizedBox(
                          width: 105,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              padding: EdgeInsets.zero,
                              items: invoiceSizeOptions.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(
                                    entry.value,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: selectedThermalPrinter ?? '2_inch_58mm',
                              onChanged: (String? value) async {
                                InvoiceSizeRepo repo = InvoiceSizeRepo();
                                final bool result =
                                    await repo.invoiceSizeChange(invoiceSize: value, ref: ref, context: context);
                                if (result) {
                                  setState(() {
                                    selectedThermalPrinter = value;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                      error: (error, stackTrace) => Text(error.toString()),
                      loading: () => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 105,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton.icon(
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              label: Text(lang.S.of(context).continueButton),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  EasyLoading.show();

                  final businessRepository = BusinessUpdateRepository();
                  final businessData = ref.read(businessInfoProvider).value?.data;

                  if (businessData == null) {
                    EasyLoading.showError('Business data not found');
                    return;
                  }

                  /// ---------- BUILD NUMERIC VISIBILITY FIELDS ----------
                  final visibilityFields = <String, int>{
                    'show_company_name': invoiceVisibility["show_company_name"]! ? 1 : 0,
                    'show_phone_number': invoiceVisibility["show_phone_number"]! ? 1 : 0,
                    'show_address': invoiceVisibility["show_address"]! ? 1 : 0,
                    'show_email': invoiceVisibility["show_email"]! ? 1 : 0,
                    'show_vat': invoiceVisibility["show_vat"]! ? 1 : 0,
                    'show_note': invoiceVisibility["show_note"]! ? 1 : 0,
                    'show_gratitude_msg': invoiceVisibility["show_gratitude_msg"]! ? 1 : 0,
                    'show_invoice_scanner_logo': invoiceVisibility["show_invoice_scanner_logo"]! ? 1 : 0,
                    'show_a4_invoice_logo': invoiceVisibility["show_a4_invoice_logo"]! ? 1 : 0,
                    'show_thermal_invoice_logo': invoiceVisibility["show_thermal_invoice_logo"]! ? 1 : 0,
                    'show_warranty': invoiceVisibility["show_warranty"]! ? 1 : 0,
                  };

                  final isProfileUpdated = await businessRepository.updateProfile(
                    id: businessData.id.toString(),
                    name: nameController.text.trim(),
                    categoryId: businessData.category?.id.toString() ?? '1',
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    vatTitle: vatNameController.text.trim(),
                    vatNumber: vatNumberController.text.trim(),
                    warrantyLabelVoid: warrantyVoidLabel.text.trim(),
                    warrantyVoid: warrantyVoid.text.trim(),
                    invoiceNoteLevel: noteLevelController.text.trim(),
                    invoiceNote: noteController.text.trim(),
                    gratitudeMessage: gratitudeController.text.trim(),
                    allowProductDiscount: isProductDiscountAllowed ? 1 : 0, // Passed to Repo
                    invoiceLogo: pickedImage != null ? File(pickedImage!.path) : null,
                    a4InvoiceLogo: pickedA4Image != null ? File(pickedA4Image!.path) : null,
                    thermalInvoiceLogo: pickedThermalImage != null ? File(pickedThermalImage!.path) : null,
                    invoiceScannerLogo: pickedScannerImage != null ? File(pickedScannerImage!.path) : null,
                    ref: ref,
                    invoiceSize: selectedThermalPrinter ?? '2_inch_58mm',
                    profilePrinter: selectedPrinterProfile ?? PrinterProfile.fallback,
                    context: context,
                    invoiceLanguage: selectedThermalPrinterLanguage ?? 'english',
                    invoiceVisibilityMeta: visibilityFields,
                  );

                  if (isProfileUpdated) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isPrintEnable', printing);
                    isPrintEnable = printing;

                    ref.invalidate(businessInfoProvider);

                    EasyLoading.showSuccess('Settings updated successfully');
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pop(context);
                    });
                  } else {
                    EasyLoading.dismiss();
                  }
                }
              }),
        ),
      ),
    );
  }
}

final printerProfileProvider = FutureProvider(
  (ref) => PrinterProfile.loadProfiles(),
);
