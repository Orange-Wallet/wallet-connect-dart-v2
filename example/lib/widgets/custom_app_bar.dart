import 'package:example/main.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Alignment? alignment;
  final TextAlign? textAlign;
  final List<Widget>? trailing;
  final EdgeInsetsGeometry? padding;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.alignment,
    this.textAlign,
    this.trailing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: Colors.white,
      width: double.infinity,
      height: 88.0,
      child: Padding(
        padding: padding ??
            EdgeInsets.fromLTRB(
              8.0,
              MediaQuery.of(context).padding.top + 16.0,
              8.0,
              16.0,
            ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: textAlign ?? TextAlign.start,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...?trailing,
          ],
        ),
      ),
    );
  }
}
