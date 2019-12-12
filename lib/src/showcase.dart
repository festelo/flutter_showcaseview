import 'dart:math';

import 'package:flutter/material.dart';
import 'position_controller.dart';
import 'showcase_form.dart';

import 'custom_paint.dart';
import 'layout_overlays.dart';
import 'base_showcase_state.dart';

class Showcase extends StatefulWidget {
  final Widget child;
  final GlobalKey key;
  final Widget topTip;
  final Widget bottomTip;
  final Widget tip;
  final Color overlayColor;
  final EdgeInsets overlayPadding;
  final void Function(BuildContext context) onOverlayTap;
  final ShapeBorder shapeBorder;
  final bool childPadding;

  Showcase({
    @required this.child,
    this.topTip,
    this.bottomTip,
    this.tip,
    this.shapeBorder,
    this.key,
    this.overlayPadding = EdgeInsets.zero,
    this.overlayColor = Colors.black87,
    this.onOverlayTap,
    this.childPadding = false
  }): assert(
      child != null
    ),
    super(key: key);

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends BaseShowcaseState<Showcase> {
  bool _showShowCase = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showOverlayIfActive();
  }

  ///
  /// show overlay if there is any target widget
  ///
  void showOverlayIfActive() {
    final active = ShowcaseForm.of(context).caseActive(context);
    setState(() {
      _showShowCase = active;
    });
  }

  buildOverlayOnTarget(
    Offset offset,
    Size size,
    Size containerSize,
    Rect rectBound,
    Size screenSize,
  ) =>
      Visibility(
        visible: _showShowCase,
        maintainAnimation: true,
        maintainState: true,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => widget.onOverlayTap != null 
                ? widget.onOverlayTap(context)
                : null,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CustomPaint(
                  painter: ShapePainter(
                    color: widget.overlayColor,
                    rect: PositionController(context).getRect(),
                    shapeBorder: widget.shapeBorder,
                    overlayPadding: widget.overlayPadding
                  ),
                ),
              ),
            ),
            TargetWidget(
              offset: offset,
              size: size,
              shapeBorder: widget.shapeBorder,
              containerSize: containerSize,
              childPadding: widget.childPadding,
              customPadding: widget.overlayPadding,
              bottomTip: widget.bottomTip,
              tip: widget.tip,
              topTip: widget.topTip,
            ),
          ],
        ),
      );

  @override
  Widget buildContent(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final containerSize = MediaQuery.of(
      ShowcaseForm.of(context).context
    ).size;
    return AnchoredOverlay(
      overlayBuilder: (BuildContext context, Rect rectBound, Offset offset) =>
          buildOverlayOnTarget(offset, rectBound.size, containerSize, rectBound, size),
      showOverlay: true,
      child: widget.child,
    );
  }
}

class TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size size;
  final Size containerSize;
  final ShapeBorder shapeBorder;
  final bool childPadding;
  final EdgeInsets customPadding;

  final Widget topTip;
  final Widget bottomTip;
  final Widget tip;

  TargetWidget({
    Key key,
    @required this.offset,
    this.size,
    this.shapeBorder,
    this.containerSize,
    this.childPadding = true,
    this.topTip,
    this.customPadding = EdgeInsets.zero,
    this.bottomTip,
    this.tip
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const padding = 16;
    final circleHeight = size.height + padding + customPadding.top + customPadding.bottom;
    final circleWidth = size.width + padding + customPadding.left + customPadding.right;
    double top = offset.dy - circleHeight/2;
    double bottom = containerSize.height - offset.dy - (circleHeight/2);
    double left = offset.dx - circleWidth/2;
    double right = containerSize.width - offset.dx - (circleWidth/2);
    bool useReversedY = false;
    bool useReversedX = false;
    if (right < left) {
      useReversedX = true;
    }
    var bottomTip = this.bottomTip;
    var topTip = this.topTip;
    if (tip != null) {
      if (bottom < top) {
        topTip = this.topTip;
      } else {
        bottomTip = this.bottomTip;
      }
    }
    
    var align = Alignment(useReversedX ? 1 : -1, useReversedY ? 1 : -1);
    final maxWidth = max(containerSize.width, useReversedX ? left + circleWidth : right + circleWidth);
    final children = [
      if(top-10 >= 0)
      Container(
        height: top-10, 
        child: topTip == null ? null : topTip,
      ),
      SizedBox(height: 10,),
      Container(
        transform: childPadding ? null : Matrix4.translationValues(
          left, 0, 0
        ),
        alignment: childPadding ? align : Alignment.topLeft,
        child: Container(
          height: circleHeight,
          width: circleWidth,
          decoration: ShapeDecoration(
            shape: shapeBorder ??
              RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
          ),
        )
      ),
      if (bottom-20 >= 0) ...[
        SizedBox(height: 10),
        Container(height: 
          bottom-10, 
          child: topTip == null ? null : bottomTip,
        ),
      ]
    ];
    useReversedY = useReversedY;
    return Positioned(
      left: !childPadding ? null : useReversedX ? null : left,
      right: !childPadding ? null : useReversedX ? right : null,
      width: !childPadding 
        ? maxWidth
        : useReversedX ? left + circleWidth : right + circleWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children
      ),
    );
  }
}


// class TargetWidget extends StatelessWidget {
//   final Offset offset;
//   final Size size;
//   final Size containerSize;
//   final ShapeBorder shapeBorder;

//   TargetWidget({
//     Key key,
//     @required this.offset,
//     this.size,
//     this.shapeBorder,
//     this.containerSize
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     const padding = 16;
//     final circleHeight = size.height + padding;
//     final circleWidth = size.width + padding;
//     double top = offset.dy - circleHeight/2;
//     double bottom = containerSize.height - offset.dy - (circleHeight/2);
//     double left = offset.dx - circleWidth/2;
//     double right = containerSize.width - offset.dx - (circleWidth/2);
//     bool useReversedY = false;
//     bool useReversedX = false;
//     if (bottom < top) {
//       useReversedY = true;
//     }
//     if (right < left) {
//       useReversedX = true;
//     }
//     var align = Alignment(useReversedX ? 1 : -1, useReversedY ? 1 : -1);
//     final children = [
//       Container(
//         alignment: align,
//         child: Container(
//           height: circleHeight,
//           width: circleWidth,
//           decoration: ShapeDecoration(
//             color: Colors.brown.withOpacity(0.5),
//             shape: shapeBorder ??
//               RoundedRectangleBorder(
//                 borderRadius: const BorderRadius.all(
//                   Radius.circular(8),
//                 ),
//               ),
//           ),
//         ),
//       ),
//       SizedBox(height: 10),
//       Expanded(
//         child: Container(
//           color: Colors.green
//         ),
//       )
//     ];
//     return Positioned(
//       top: useReversedY ? null : top,
//       bottom: useReversedY ? bottom : null,
//       left: useReversedX ? null : left,
//       right: useReversedX ? right : null,
//       width: useReversedX ? left + circleWidth : right + circleWidth,
//       height: useReversedY ? top + circleHeight: bottom + circleHeight,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: useReversedY 
//           ? children.reversed.toList()
//           : children 
//       ),
//     );
//   }
// }