import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatfat/Themes/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hint;
  final Function onTap;
  final Color color;
  final BoxShadow boxShadow;
  final ValueChanged<String> onChanged;

  const CustomSearchBar({super.key,
    required this.hint,
    required  this.onTap,
    required this.color,
    required this.boxShadow,
     required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 52,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        boxShadow: [
          boxShadow ?? BoxShadow(color: kCardBackgroundColor),
        ],
        borderRadius: BorderRadius.circular(30.0),
        color: color ?? kCardBackgroundColor,
      ),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        cursorColor: kMainColor,
        decoration: InputDecoration(
          icon: const ImageIcon(
            AssetImage('images/icons/ic_search.png'),
            color: Colors.black,
            size: 16,
          ),
          hintText: hint,
          hintStyle:
              Theme.of(context).textTheme.headline6!.copyWith(color: kHintColor),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
        onTap: onTap(),
      ),
    );
  }
}
