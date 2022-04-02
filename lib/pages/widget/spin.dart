import 'package:flutter/material.dart';
import 'package:king011_icons/king011_icons.dart';
import 'package:ppg_ui/widget/spin.dart';

Spin createSpin() => const Spin(
      child: Icon(
        FontAwesome.spinner,
        size: 32,
      ),
    );

FloatingActionButton createSpinFloating() => const FloatingActionButton(
      child: Spin(
        child: Icon(
          FontAwesome.spinner,
          size: 32,
        ),
      ),
      onPressed: null,
    );
Widget buildError(BuildContext context, error) => Text(
      "$error",
      style: TextStyle(color: Theme.of(context).errorColor),
    );
