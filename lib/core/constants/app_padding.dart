import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPadding {
  // 🔹 All sides
  static EdgeInsets allSmall = EdgeInsets.all(8.w);
  static EdgeInsets allMedium = EdgeInsets.all(16.w);
  static EdgeInsets allLarge = EdgeInsets.all(24.w);

  // 🔹 Horizontal only
  static EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: 24.w);

  // 🔹 Vertical only
  static EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: 24.h);

  // 🔹 Symmetric
  static EdgeInsets symmetricSmall = EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h);
  static EdgeInsets symmetricMedium = EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  static EdgeInsets symmetricLarge = EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h);

  // 🔹 Only (custom sides)
  static EdgeInsets onlyTop = EdgeInsets.only(top: 16.h);
  static EdgeInsets onlyBottom = EdgeInsets.only(bottom: 16.h);
  static EdgeInsets onlyLeft = EdgeInsets.only(left: 16.w);
  static EdgeInsets onlyRight = EdgeInsets.only(right: 16.w);
}
