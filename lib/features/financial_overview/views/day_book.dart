import 'package:flutter/material.dart';

import '../../../core/constants/app_appbar.dart';

class DayBook extends StatelessWidget {
  const DayBook({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(text: 'Day Book'),
    );
  }
}