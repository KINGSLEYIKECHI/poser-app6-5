// ignore_for_file: unused_result, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/country_state_dropdown.dart'; // Ensure this import is correct
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/shop_category_provider.dart';
import '../../Repository/API/business_info_update_repo.dart';
import '../../constant.dart';
import '../../model/business_category_model.dart';
import '../../model/business_info_model.dart';
import '../../model/country_state_model.dart'; // Ensure this import is correct

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.profile, required this.ref});

  final BusinessInformationModel profile;
  final WidgetRef ref;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController vatGstTitleController = TextEditingController();
  TextEditingController vatGstNumberController = TextEditingController();

  // Variables for Country and State
  CountryModel? selectedCountry;
  StateModel? selectedState;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.profile.data?.companyName ?? '';
    phoneController.text = widget.profile.data?.phoneNumber ?? '';
    addressController.text = widget.profile.data?.address ?? '';
    vatGstTitleController.text = widget.profile.data?.vatName ?? '';
    vatGstNumberController.text = widget.profile.data?.vatNo ?? '';
  }

  int counter = 0;
  String dropdownValue = '';
  String companyName = 'nodata', phoneNumber = 'nodata';
  double progress = 0.0;
  int invoiceNumber = 0;
  bool showProgress = false;
  String profilePicture = 'nodata';
  num openingBalance = 0;
  num remainingShopBalance = 0;

  // ignore: prefer_typing_uninitialized_variables
  var dialogContext;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');

  BusinessCategory? selectedBusinessCategory;

  DropdownButton<BusinessCategory> getCategory({required List<BusinessCategory> list}) {
    List<DropdownMenuItem<BusinessCategory>> dropDownItems = [];

    for (BusinessCategory category in list) {
      var item = DropdownMenuItem(
        value: category,
        child: Text(category.name),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      isExpanded: true,
      hint: Text(
        lang.S.of(context).selectBusinessCategory,
      ),
      items: dropDownItems,
      value: selectedBusinessCategory,
      onChanged: (value) {
        setState(() {
          selectedBusinessCategory = value!;
        });
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    counter++;
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            lang.S.of(context).updateProfile,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Consumer(builder: (context, ref, child) {
            final categoryList = ref.watch(businessCategoryProvider);

            return categoryList.when(data: (categoryList) {
              if (counter == 1) {
                for (var element in categoryList) {
                  if (element.id == widget.profile.data?.category?.id) {
                    selectedBusinessCategory = element;
                  }
                }
              }

              return Center(
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    ///__________Image_Section________________________________________
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
                                            pickedImage = await _picker.pickImage(source: ImageSource.gallery);

                                            setState(() {
                                              imageFile = File(pickedImage!.path);
                                            });

                                            Future.delayed(const Duration(milliseconds: 100), () {
                                              Navigator.pop(context);
                                            });
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
                                            pickedImage = await _picker.pickImage(source: ImageSource.camera);
                                            setState(() {
                                              imageFile = File(pickedImage!.path);
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
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54, width: 1),
                              borderRadius: const BorderRadius.all(Radius.circular(120)),
                              image: pickedImage == null
                                  ? widget.profile.data?.pictureUrl == null
                                      ? const DecorationImage(
                                          image: AssetImage('images/no_shop_image.png'),
                                          fit: BoxFit.cover,
                                        )
                                      : DecorationImage(
                                          image: NetworkImage((widget.profile.data?.pictureUrl.toString() ?? '')),
                                          fit: BoxFit.cover,
                                        )
                                  : DecorationImage(
                                      image: FileImage(imageFile),
                                      fit: BoxFit.cover,
                                    ),
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
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    ///________Category_Section_______________________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 60.0,
                        child: FormField(
                          builder: (FormFieldState<dynamic> field) {
                            return InputDecorator(
                              decoration: kInputDecoration.copyWith(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).businessCat,
                                  labelStyle: theme.textTheme.titleMedium,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                              child: DropdownButtonHideUnderline(child: getCategory(list: categoryList)),
                            );
                          },
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Business Name Field
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AppTextField(
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
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),

                          // Phone Number Field
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              height: 60.0,
                              child: TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: kInputDecoration.copyWith(
                                  labelText: lang.S.of(context).phone,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),

                          // Address Field
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AppTextField(
                              controller: addressController,
                              validator: (value) {
                                return null;
                              },
                              textFieldType: TextFieldType.NAME,
                              decoration: kInputDecoration.copyWith(
                                labelText: lang.S.of(context).address,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),

                          ///________Country_and_State_Dropdown___________________________
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CountryStateDropdown(
                              initialCountryId: widget.profile.data?.countryId,
                              initialStateId: widget.profile.data?.stateId,
                              onCountryChanged: (value) {
                                selectedCountry = value;
                              },
                              onStateChanged: (value) {
                                selectedState = value;
                              },
                            ),
                          ),

                          ///_______Gst_and_Vat_Section____________________________
                          Row(
                            children: [
                              ///_______Title_Field__________________________________
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                                  child: AppTextField(
                                    validator: (value) {
                                      return null;
                                    },
                                    controller: vatGstTitleController,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: kInputDecoration.copyWith(
                                      hintText: lang.S.of(context).enterVatGstTitle,
                                      labelText: lang.S.of(context).vatGstTitle,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),

                              ///______Vat_and_Gst_Number_Field__________________________________
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: AppTextField(
                                    validator: (value) {
                                      return null;
                                    },
                                    controller: vatGstNumberController,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: kInputDecoration.copyWith(
                                      hintText: lang.S.of(context).enterVatGstNumber,
                                      labelText: lang.S.of(context).vatGstNumber,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }, error: (e, stack) {
              return Center(
                child: Text(e.toString()),
              );
            }, loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
          }),
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
                try {
                  final businessRepository = BusinessUpdateRepository();
                  final isProfileUpdated = await businessRepository.updateProfile(
                    id: widget.profile.data?.id.toString() ?? '',
                    name: nameController.text,
                    categoryId: selectedBusinessCategory!.id.toString(),
                    address: addressController.text,
                    image: pickedImage != null ? File(pickedImage!.path) : null,
                    phone: phoneController.text,
                    vatNumber: vatGstNumberController.text,
                    vatTitle: vatGstTitleController.text,
                    // Passing the selected IDs
                    countryId: selectedCountry?.id.toString(),
                    stateId: selectedState?.id.toString(),
                    ref: widget.ref,
                    context: context,
                  );

                  if (isProfileUpdated) {
                    widget.ref.refresh(businessInfoProvider);
                    widget.ref.refresh(getExpireDateProvider(widget.ref));
                    Navigator.pop(context);
                  }
                } catch (e) {
                  EasyLoading.showError('Update Failed');
                } finally {
                  EasyLoading.dismiss();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
