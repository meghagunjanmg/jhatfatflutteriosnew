import 'package:flutter/material.dart';

class BuildListTile extends StatelessWidget {
  final String image;
  final String text;
  Future<Object?> Function() onTap;

  BuildListTile({required this.image, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
      leading: Image.asset(
        image,
        height: 20.3,
      ),
      title: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .headline4!
            .copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.07),
      ),
      onTap: onTap,
    );
  }
}
