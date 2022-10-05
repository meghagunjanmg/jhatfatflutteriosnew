import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/style.dart';

class BottomBar extends StatelessWidget {
  final Function? onTap;
  final String? text;
  final Color? color;
  final Color? textColor;

  BottomBar(
      { this.onTap,  this.text, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap!(),
      child: Container(
        color: color ?? kMainColor,
        height: 60.0,
        child: Center(
          child: Text(
            text!,
            style: bottomBarTextStyle.copyWith(color: textColor) ??
                bottomBarTextStyle,
          ),
        ),
      ),
    );
  }
}
