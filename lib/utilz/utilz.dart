import 'package:flutter/material.dart';

void showMsg({required BuildContext context, required String title}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
      ),
    );
