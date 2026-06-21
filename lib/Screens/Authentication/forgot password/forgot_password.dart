import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Authentication/forgot%20password/repo/forgot_pass_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../constant.dart';
import '../Sign Up/verify_email.dart';
import '../Wedgets/check_email_for_otp_popup.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  bool isClicked = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          titleSpacing: 16,
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          centerTitle: true,
          title: Text(
            // 'Forgot Password',
            lang.S.of(context).forgotPassword,
            style: textTheme.titleMedium?.copyWith(fontSize: 18),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  // 'Forgot Password',
                  lang.S.of(context).forgotPassword,
                  style: textTheme.titleMedium?.copyWith(fontSize: 24.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  //'Reset password by using your email or phone number',
                  lang.S.of(context).reset,
                  style: textTheme.bodyMedium?.copyWith(color: kGreyTextColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: kInputDecoration.copyWith(
                    // labelText: 'Email',
                    labelText: lang.S.of(context).lableEmail,
                    // hintText: 'Enter email address',
                    hintText: lang.S.of(context).hintEmail,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      //return 'Email can\'t be empty';
                      return lang.S.of(context).emailCannotBeEmpty;
                    } else if (!value.contains('@')) {
                      // return 'Please enter a valid email';
                      return lang.S.of(context).pleaseEnterAValidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    maximumSize: const Size(double.infinity, 48),
                    minimumSize: const Size(double.infinity, 48),
                    disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                  ),
                  onPressed: () async {
                    if (isClicked) {
                      return;
                    }
                    if (_formKey.currentState?.validate() ?? false) {
                      isClicked = true;
                      EasyLoading.show();
                      ForgotPassRepo repo = ForgotPassRepo();
                      if (await repo.forgotPass(email: _emailController.text, context: context)) {
                        if (await checkEmailForCodePupUp(
                            email: _emailController.text, context: context, textTheme: textTheme)) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerifyEmail(
                                email: _emailController.text,
                                isFormForgotPass: true,
                              ),
                            ),
                          );
                        }
                      } else {
                        isClicked = false;
                      }
                    }
                  },
                  child: Text(
                    lang.S.of(context).continueE,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _theme.textTheme.bodyMedium?.copyWith(
                      color: _theme.colorScheme.primaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
