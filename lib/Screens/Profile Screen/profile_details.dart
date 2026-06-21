import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/edit_profile.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Const/api_config.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../Authentication/change password/change_password_screen.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  ProfileDetailsState createState() => ProfileDetailsState();
}

class ProfileDetailsState extends State<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      final businessInfo = ref.watch(businessInfoProvider);
      return businessInfo.when(data: (details) {
        // Initialize Controllers with data
        TextEditingController addressController = TextEditingController(text: details.data?.address);
        TextEditingController openingBalanceController =
            TextEditingController(text: details.data?.shopOpeningBalance.toString());
        // TextEditingController remainingBalanceController = TextEditingController(text: details.data?.remainingShopBalance.toString());
        TextEditingController phoneController = TextEditingController(text: details.data?.phoneNumber);
        TextEditingController nameController = TextEditingController(text: details.data?.companyName);
        TextEditingController categoryController = TextEditingController(text: details.data?.category?.name);
        TextEditingController vatGstTitleController = TextEditingController(text: details.data?.vatName);
        TextEditingController vatGstNumberController = TextEditingController(text: details.data?.vatNo);

        // New Controllers for Country and State
        TextEditingController countryController = TextEditingController(text: details.data?.country?.name ?? '');
        TextEditingController stateController = TextEditingController(text: details.data?.state?.name ?? '');

        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              title: Text(
                lang.S.of(context).profile,
              ),
              actions: [
                Visibility(
                  // visible: details.data?.user?.visibility?.profileEditPermission ?? true,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(
                                profile: details,
                                ref: ref,
                              ),
                            ));
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            color: kMainColor,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            lang.S.of(context).edit,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kMainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                label: Text(lang.S.of(context).changePassword),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ));
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: details.data?.pictureUrl == null
                            ? BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage('images/no_shop_image.png'), fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(50),
                              )
                            : BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage((details.data?.pictureUrl.toString() ?? '')),
                                    fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(50),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    ///________Name___________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: nameController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).name,
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///________Email__________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        initialValue: details.data?.user?.email,
                        cursorColor: kGreyTextColor,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).email,
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///_____________Category__________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: categoryController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).businessCat,
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///_____________Phone_________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: phoneController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).phone,
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///__________Address_________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: addressController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).address,
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///__________Country_and_State________________________
                    Row(
                      children: [
                        ///_______Country__________________________________
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                            child: AppTextField(
                              readOnly: true,
                              controller: countryController,
                              textFieldType: TextFieldType.NAME,
                              decoration: kInputDecoration.copyWith(
                                labelText: 'Country',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),

                        ///______State__________________________________
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AppTextField(
                              readOnly: true,
                              controller: stateController,
                              textFieldType: TextFieldType.NAME,
                              decoration: kInputDecoration.copyWith(
                                labelText: 'State',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///_______Gst_number____________________________
                    Row(
                      children: [
                        ///_______title__________________________________
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                            child: AppTextField(
                              readOnly: true,
                              validator: (value) {
                                return null;
                              },
                              controller: vatGstTitleController,
                              textFieldType: TextFieldType.NAME,
                              decoration: kInputDecoration.copyWith(
                                labelText: lang.S.of(context).vatGstTitle,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),

                        ///______Vat_and_Gst_Number__________________________________
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AppTextField(
                              readOnly: true,
                              validator: (value) {
                                return null;
                              },
                              controller: vatGstNumberController,
                              textFieldType: TextFieldType.NAME,
                              decoration: kInputDecoration.copyWith(
                                labelText: lang.S.of(context).vatGstNumber,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///__________Opening_Balance________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: openingBalanceController,
                        decoration: kInputDecoration.copyWith(
                          prefixText: '$currency ',
                          labelText: lang.S.of(context).shopOpeningBalance,
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }, error: (e, stack) {
        return Center(child: Text(e.toString()));
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}
