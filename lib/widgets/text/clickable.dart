import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableUrl extends StatelessWidget {
  late final String text;
  late final String url;
  final TextStyle? textStyle;

  ClickableUrl({Key? key,
    required this.text,
    required this.url,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = textStyle?? TextStyle(
        color: Colors.blue,
      //decoration: TextDecoration.underline,
    );

    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          style: style,
          text: text,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(url)) {
                await launch(url, forceSafariVC: false,);
              }
            },
        ),
      ],
    )
    );
  }
}
