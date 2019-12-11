import 'package:flutter/material.dart';

import 'showcase_form.dart';

abstract class BaseShowcaseState<T extends StatefulWidget> extends State<T> {
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    ShowcaseForm.of(context)?.register(this);
    return buildContent(context);
  }

  @override
  void deactivate() {
    ShowcaseForm.of(context)?.unregister(this);
    super.deactivate();
  }
}