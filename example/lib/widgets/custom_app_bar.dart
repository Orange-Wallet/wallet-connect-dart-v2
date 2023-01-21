import 'package:example/main.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Alignment? alignment;
  const CustomAppBar({
    Key? key,
    required this.title,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: Colors.white,
      width: double.infinity,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(8.0, kToolbarHeight + 8.0, 8.0, 16.0),
        child: Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
