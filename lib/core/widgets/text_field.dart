import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

TextStyle headerLabelStyleMd(BuildContext context) => TextStyle(
  fontWeight: FontWeight.w400,
  fontSize: Sizes.fontSizeSm,
  color: context.appColors.gray1000,
);

TextStyle dialogTitleStyle(BuildContext context) => TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: Sizes.fontSizeLg,
  color: context.appColors.gray1000,
);
