import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';

// ignore: must_be_immutable
class ButtonGlobal extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  var iconWidget;
  final String buttontext;
  final Color iconColor;
  final Decoration? buttonDecoration;

  // ignore: prefer_typing_uninitialized_variables
  var onPressed;

  // ignore: use_key_in_widget_constructors
  ButtonGlobal({required this.iconWidget, required this.buttontext, required this.iconColor, this.buttonDecoration, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: buttonDecoration ?? BoxDecoration(borderRadius: BorderRadius.circular(8), color: kMainColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttontext,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(
              width: 2,
            ),
            Icon(
              iconWidget,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ButtonGlobalWithoutIcon extends StatelessWidget {
  final String buttontext;
  final Decoration buttonDecoration;

  // ignore: prefer_typing_uninitialized_variables
  var onPressed;
  final Color buttonTextColor;

  // ignore: use_key_in_widget_constructors
  ButtonGlobalWithoutIcon({required this.buttontext, required this.buttonDecoration, required this.onPressed, required this.buttonTextColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: buttonDecoration,
        child: Text(
          buttontext,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: buttonTextColor),
        ),
      ),
    );
  }
}

///-----------------------name with logo------------------
class NameWithLogo extends StatelessWidget {
  const NameWithLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 75,
          width: 66,
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(logo))),
        ),
        const Text(
          appsName,
          style: TextStyle(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ],
    );
  }
}

///-------------------update button--------------------------------

class UpdateButton extends StatelessWidget {
  const UpdateButton({Key? key, required this.text, required this.onpressed}) : super(key: key);
  final String text;
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: kMainColor,
        ),
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(color: kWhite),
        ),
      ),
    );
  }
}
