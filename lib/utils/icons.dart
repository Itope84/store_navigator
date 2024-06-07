import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget getSvgIcon(String path, {double? size, Color? color}) {
  return SvgPicture.asset(
    path,
    height: size,
    width: size,
    colorFilter:
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}

// create a set of icons that can be called statically as CustomIcons.iconName, each icon is located in assets/icons/iconName.svg

class CustomIcons {
  static Widget home({double? size, Color? color}) =>
      getSvgIcon('assets/icons/home.svg', size: size, color: color);
  static Widget list({double? size, Color? color}) =>
      getSvgIcon('assets/icons/list.svg', size: size, color: color);
  // store
  static Widget store({double? size, Color? color}) =>
      getSvgIcon('assets/icons/store.svg', size: size, color: color);
}
