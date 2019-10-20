// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:PureBook/event/event.dart';
import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

class MyPageController extends ScrollController {
  MyPageController({
    this.initialPage = 0,
    this.keepPage = true,
    this.viewportFraction = 1.0,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0);

  final int initialPage;

  final bool keepPage;

  final double viewportFraction;

  double get page {
    assert(
      positions.isNotEmpty,
      'MyPageController.page cannot be accessed before a MyPageView is built with it.',
    );
    assert(
      positions.length == 1,
      'The page property cannot be read when multiple MyPageViews are attached to '
      'the same MyPageController.',
    );
    final _PagePosition position = this.position;
    return position.page;
  }

  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) {
    final _PagePosition position = this.position;
    return position.animateTo(
      position.getPixelsFromPage(page.toDouble()),
      duration: duration,
      curve: curve,
    );
  }

  void jumpToPage(int page) {
    final _PagePosition position = this.position;
    position.jumpTo(position.getPixelsFromPage(page.toDouble()));
  }

  Future<void> nextPage({@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() + 1, duration: duration, curve: curve);
  }

  Future<void> previousPage(
      {@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() - 1, duration: duration, curve: curve);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    return _PagePosition(
      physics: physics,
      context: context,
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      oldPosition: oldPosition,
    );
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    final _PagePosition pagePosition = position;
    pagePosition.viewportFraction = viewportFraction;
  }
}

class PageMetrics extends FixedScrollMetrics {
  PageMetrics({
    @required double minScrollExtent,
    @required double maxScrollExtent,
    @required double pixels,
    @required double viewportDimension,
    @required AxisDirection axisDirection,
    @required this.viewportFraction,
  }) : super(
          minScrollExtent: minScrollExtent,
          maxScrollExtent: maxScrollExtent,
          pixels: pixels,
          viewportDimension: viewportDimension,
          axisDirection: axisDirection,
        );

  @override
  PageMetrics copyWith({
    double minScrollExtent,
    double maxScrollExtent,
    double pixels,
    double viewportDimension,
    AxisDirection axisDirection,
    double viewportFraction,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
    );
  }

  /// The current page displayed in the [MyPageView].
  double get page {
    return math.max(0.0, pixels.clamp(minScrollExtent, maxScrollExtent)) /
        math.max(1.0, viewportDimension * viewportFraction);
  }

  /// The fraction of the viewport that each page occupies.
  ///
  /// Used to compute [page] from the current [pixels].
  final double viewportFraction;
}

class _PagePosition extends ScrollPositionWithSingleContext
    implements PageMetrics {
  _PagePosition({
    ScrollPhysics physics,
    ScrollContext context,
    this.initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    ScrollPosition oldPosition,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        _viewportFraction = viewportFraction,
        _pageToUseOnStartup = initialPage.toDouble(),
        super(
          physics: physics,
          context: context,
          initialPixels: null,
          keepScrollOffset: keepPage,
          oldPosition: oldPosition,
        );

  final int initialPage;
  double _pageToUseOnStartup;

  bool isInitialPixelsValueSet = false;

  @override
  void dispose() {
    if (pixels == null && !isInitialPixelsValueSet) {
      correctPixels(0);
    }
    super.dispose();
  }

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  set viewportFraction(double value) {
    if (_viewportFraction == value) return;
    final double oldPage = page;
    _viewportFraction = value;
    if (oldPage != null) forcePixels(getPixelsFromPage(oldPage));
  }

  double getPageFromPixels(double pixels, double viewportDimension) {
    final double actual = math.max(0.0, pixels) /
        math.max(1.0, viewportDimension * viewportFraction);
    final double round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }

  double getPixelsFromPage(double page) {
    return page * viewportDimension * viewportFraction;
  }

  @override
  double get page {
    assert(
      pixels == null || (minScrollExtent != null && maxScrollExtent != null),
      'Page value is only available after content dimensions are established.',
    );
    return pixels == null
        ? null
        : getPageFromPixels(
            pixels.clamp(minScrollExtent, maxScrollExtent), viewportDimension);
  }

  @override
  void saveScrollOffset() {
    PageStorage.of(context.storageContext)?.writeState(
        context.storageContext, getPageFromPixels(pixels, viewportDimension));
  }

  @override
  void restoreScrollOffset() {
    if (pixels == null) {
      final double value = PageStorage.of(context.storageContext)
          ?.readState(context.storageContext);
      if (value != null) _pageToUseOnStartup = value;
    }
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    final double oldViewportDimensions = this.viewportDimension;
    final bool result = super.applyViewportDimension(viewportDimension);
    final double oldPixels = pixels;
    final double page = (oldPixels == null || oldViewportDimensions == 0.0)
        ? _pageToUseOnStartup
        : getPageFromPixels(oldPixels, oldViewportDimensions);
    final double newPixels = getPixelsFromPage(page);

    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      isInitialPixelsValueSet = true;
      return false;
    }
    return result;
  }

  @override
  PageMetrics copyWith({
    double minScrollExtent,
    double maxScrollExtent,
    double pixels,
    double viewportDimension,
    AxisDirection axisDirection,
    double viewportFraction,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
    );
  }
}

class PageScrollPhysics extends ScrollPhysics {
  const PageScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  PageScrollPhysics applyTo(ScrollPhysics ancestor) {
    return PageScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    if (position is _PagePosition) return position.page;
    return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    if (position is _PagePosition) return position.getPixelsFromPage(page);
    return page * position.viewportDimension;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      if (velocity > 0) {
        eventBus.fire(PageEvent(1));
      } else if (velocity < 0) {
        eventBus.fire(PageEvent(-1));
      }
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

final MyPageController _defaultMyPageController = MyPageController();
const PageScrollPhysics _kPagePhysics = PageScrollPhysics();

class MyPageView extends StatefulWidget {
  MyPageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    MyPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    List<Widget> children = const <Widget>[],
    this.dragStartBehavior = DragStartBehavior.start,
  })  : controller = controller ?? _defaultMyPageController,
        childrenDelegate = SliverChildListDelegate(children),
        super(key: key);

  MyPageView.builder({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    MyPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : controller = controller ?? _defaultMyPageController,
        childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key);

  MyPageView.custom({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    MyPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required this.childrenDelegate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(childrenDelegate != null),
        controller = controller ?? _defaultMyPageController,
        super(key: key);

  final Axis scrollDirection;

  final bool reverse;

  final MyPageController controller;

  final ScrollPhysics physics;

  final bool pageSnapping;

  final ValueChanged<int> onPageChanged;

  final SliverChildDelegate childrenDelegate;

  final DragStartBehavior dragStartBehavior;

  @override
  _MyPageViewState createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
            textDirectionToAxisDirection(textDirection);
        return widget.reverse
            ? flipAxisDirection(axisDirection)
            : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics = widget.pageSnapping
        ? _kPagePhysics.applyTo(widget.physics)
        : widget.physics;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 &&
            widget.onPageChanged != null &&
            notification is ScrollUpdateNotification) {
          final PageMetrics metrics = notification.metrics;
          final int currentPage = metrics.page.round();
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged(currentPage);
          }
        }
        return false;
      },
      child: Scrollable(
        dragStartBehavior: widget.dragStartBehavior,
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            cacheExtent: 0.0,
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              SliverFillViewport(
                viewportFraction: widget.controller.viewportFraction,
                delegate: widget.childrenDelegate,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    description.add(
        FlagProperty('reverse', value: widget.reverse, ifTrue: 'reversed'));
    description.add(DiagnosticsProperty<MyPageController>(
        'controller', widget.controller,
        showName: false));
    description.add(DiagnosticsProperty<ScrollPhysics>(
        'physics', widget.physics,
        showName: false));
    description.add(FlagProperty('pageSnapping',
        value: widget.pageSnapping, ifFalse: 'snapping disabled'));
  }
}
