import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Authentication/Sign%20Up/repo/sign_up_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:pinput/pinput.dart' as p;
import '../../../GlobalComponents/glonal_popup.dart';
import '../Repo/otp_settings_repo.dart';
import '../forgot password/repo/forgot_pass_repo.dart';
import '../forgot password/set_new_password.dart';
import '../profile_setup_screen.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key, required this.email, required this.isFormForgotPass});
  final String email;
  final bool isFormForgotPass;

  @override
  State<VerifyEmail> createState() => _VerifyEmailNewState();
}

class _VerifyEmailNewState extends State<VerifyEmail> {
  bool isClicked = false;

  Timer? _timer;
  int _start = 180; // default fallback
  bool _isButtonEnabled = false;

  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final _pinputKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadOtpSettings();
  }

  Future<void> _loadOtpSettings() async {
    EasyLoading.show(status: lang.S.of(context).loadingOtpSetting);
    final settings = await OtpSettingsRepo().fetchOtpSettings();
    print(settings?.otpExpirationTime);
    EasyLoading.dismiss();

    if (settings != null) {
      int durationInSec = int.parse(settings.otpExpirationTime);

      if (settings.otpDurationType.toLowerCase().contains("minute")) {
        durationInSec *= 60;
      } else if (settings.otpDurationType.toLowerCase().contains("hour")) {
        durationInSec *= 3600;
      }

      setState(() {
        _start = durationInSec;
      });
    }
    startTimer();
  }

  void startTimer() {
    _isButtonEnabled = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _isButtonEnabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  static const focusedBorderColor = kMainColor;
  static const fillColor = Color(0xFFF3F3F3);
  final defaultPinTheme = p.PinTheme(
    width: 45,
    height: 52,
    textStyle: const TextStyle(
      fontSize: 20,
      color: kTitleColor,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kBorderColor),
    ),
  );

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          centerTitle: true,
          titleSpacing: 16,
          title: Text(lang.S.of(context).verityEmail),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                lang.S.of(context).verityEmail,
                style: textTheme.titleMedium?.copyWith(fontSize: 24.0),
              ),
              const SizedBox(height: 8.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: lang.S.of(context).digits,
                  style: textTheme.bodyMedium?.copyWith(color: kGreyTextColor, fontSize: 16),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style:
                          textTheme.bodyMedium?.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Form(
                key: _pinputKey,
                child: p.Pinput(
                  length: 6,
                  controller: pinController,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 11),
                  validator: (value) {
                    if ((value?.length ?? 0) < 6) {
                      return lang.S.of(context).enterValidOTP;
                    }
                    return null;
                  },
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: kMainColor.withOpacity(0.1),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: fillColor,
                      border: Border.all(color: kTitleColor),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 11, bottom: 11),
                    child: Text(
                      _isButtonEnabled
                          ? lang.S.of(context).youCanNowResendYourOtp
                          : lang.S.of(context).resendOtpSeconds(_start),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Visibility(
                    visible: _isButtonEnabled,
                    child: TextButton(
                      onPressed: _isButtonEnabled
                          ? () async {
                              EasyLoading.show();
                              SignUpRepo repo = SignUpRepo();
                              if (await repo.resendOTP(email: widget.email, context: context)) {
                                _loadOtpSettings();
                              }
                            }
                          : null,
                      child: Text(
                        lang.S.of(context).resendOTP,
                        style: TextStyle(color: kMainColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: widget.isFormForgotPass
                    ? () async {
                        if (isClicked) return;
                        focusNode.unfocus();
                        if (_pinputKey.currentState?.validate() ?? false) {
                          isClicked = true;
                          EasyLoading.show();
                          ForgotPassRepo repo = ForgotPassRepo();
                          if (await repo.verifyOTPForgotPass(
                              email: widget.email, otp: pinController.text, context: context)) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetNewPassword(email: widget.email),
                              ),
                            );
                          } else {
                            isClicked = false;
                          }
                        }
                      }
                    : () async {
                        if (isClicked) return;
                        focusNode.unfocus();
                        if (_pinputKey.currentState?.validate() ?? false) {
                          isClicked = true;
                          EasyLoading.show();
                          SignUpRepo repo = SignUpRepo();
                          if (await repo.verifyOTP(email: widget.email, otp: pinController.text, context: context)) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileSetup(),
                              ),
                            );
                          } else {
                            isClicked = false;
                          }
                        }
                      },
                child: Text(lang.S.of(context).continueE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
