import 'dart:async';

import 'package:flutter/material.dart';

import 'base_showcase_state.dart';

class ShowcaseForm extends StatefulWidget {
  final Widget child;
  final VoidCallback onFinish;

  ShowcaseForm({
    @required this.child, 
    this.onFinish,
    Key key
  }): super(key: key);

  // static activeTargetWidget(BuildContext context) {
  //   return (context.inheritFromWidgetOfExactType(_InheritedShowCaseView)
  //           as _InheritedShowCaseView)
  //       .activeWidgetIds;
  // }

  static ShowcaseFormState of(BuildContext context) {
    final _ShowcaseFormScope scope = 
      context.dependOnInheritedWidgetOfExactType<_ShowcaseFormScope>();
    return scope?._formState;
  }

  @override
  ShowcaseFormState createState() => ShowcaseFormState();
}

class ShowcaseFormState extends State<ShowcaseForm> {
  List<BaseShowcaseState> _cases = [];
  int _currentCase = 0;
  bool showCases = false;
  bool _forceShow = false;
  Completer _completer;

  void register(BaseShowcaseState state) {
    if(!_cases.contains(state)) {
      _cases.add(state);
      if (_forceShow) {
        _forceShow = false;
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showWithoutDismissing()
        );
      }
    }
  }

  void unregister(BaseShowcaseState state) {
    _cases.remove(state);
  }

  bool caseActive(BuildContext context) {
    return showCases && 
      _currentCase < _cases.length && 
      _cases[_currentCase].context == context;
  }

  void _startSilent() {
    _currentCase = 0;
    showCases = true;
  }

  Future<void> _showWithoutDismissing() async {
    if(_completer == null) _completer = Completer();
    if (_cases.length == 0) _forceShow = true;
    else {
      setState(() {
        _startSilent();
      });
    }
    await _completer.future;
  }

  Future<void> show() async {
    if (_completer != null && !_completer.isCompleted) {
      dismiss();
    }
    await _showWithoutDismissing();
  }

  void complete() {
    setState(() => _cleanupAfterSteps());
    if (widget.onFinish != null) {
      widget.onFinish();
    }
  }

  void next() {
    setState(() {
      _currentCase++;
    });
    if (_currentCase >= _cases.length) {
      complete();
    }
  }

  void dismiss() {
    setState(() {
      _cleanupAfterSteps();
    });
  }

  void _cleanupAfterSteps() {
    _currentCase = 0;
    showCases = false;
    _completer?.complete();
  }

  @override
  Widget build(BuildContext context) {
    return _ShowcaseFormScope(
      child: widget.child,
      currentCase: _currentCase,
      showCases: showCases,
      formState: this,
    );
  }
}

class _ShowcaseFormScope extends InheritedWidget {
  final int currentCase;
  final bool showCases;
  final ShowcaseFormState _formState; 

  _ShowcaseFormScope({
    @required this.currentCase,
    @required child,
    @required this.showCases,
    @required ShowcaseFormState formState
  }) : this._formState = formState, 
    super(child: child);

  @override
  bool updateShouldNotify(_ShowcaseFormScope oldWidget) =>
      oldWidget.currentCase != currentCase ||
      oldWidget.showCases != showCases;
}
