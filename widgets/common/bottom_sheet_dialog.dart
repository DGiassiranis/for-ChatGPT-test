/// -----------------------------------------------------------------------
///  [2021] - [2021] Enfinity Software FZ-LLC. All Rights Reserved.
///
/// This file is subject to the terms and conditions defined in
/// file 'LICENSE.txt', which is part of this source code package.
/// -----------------------------------------------------------------------
import 'package:flutter/material.dart';

class BottomSheetDialog extends StatelessWidget {
  final Widget child;
  final GlobalKey<FormState>? formKey;
  final BoxConstraints? constraints;
  final Color? backgroundColor;

  const BottomSheetDialog({Key? key, required this.child, this.formKey, this.constraints, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height - 200,
              constraints: constraints ?? const BoxConstraints(minHeight: 340, maxWidth: 400),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.deepPurpleAccent,
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: child,
            ),
          ),
        )
      ],
    );
  }
}
