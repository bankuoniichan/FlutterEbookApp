import 'package:flutter/gestures.dart';
import 'package:mno_navigator/src/publication/reader_context.dart';
import 'package:mno_shared/publication.dart';

class WebViewVerticalGestureRecognizer extends VerticalDragGestureRecognizer {
  final int chapNumber;
  final Link link;
  ReaderContext readerContext;

  bool _topOverlayVisible = false;
  bool _bottomOverlayVisible = false;

  void setTopOverlayVisible(bool visibility) {
    _topOverlayVisible = visibility;
  }

  void setBottomOverlayVisible(bool visibility) {
    _bottomOverlayVisible = visibility;
  }

  WebViewVerticalGestureRecognizer({
    required this.chapNumber,
    required this.link,
    PointerDeviceKind? kind,
    required this.readerContext,
  }) : super(supportedDevices: (kind != null) ? {kind} : const {}) {
    onUpdate = _onUpdate;
  }

  void _onUpdate(DragUpdateDetails details) {
    // Fimber.d(
    //     ">>> onUpdate[$chapNumber][${getSpineItemHref()}]: ${details.delta.direction}");
  }

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
    // Fimber.d(
    //     ">>> Pointer tracking STARTED, pointer[$chapNumber][${getSpineItemHref()}]: ${event.pointer}");
  }

  @override
  String get debugDescription => 'vertical drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {
    // Fimber.d(
    //     ">>> didStopTrackingLastPointer [$chapNumber][${getSpineItemHref()}]");
  }

  @override
  void handleEvent(PointerEvent event) {
    // TODO Fix this: readerContext.currentSpineItem?.title is null, so we are using this path to access the title of the current spine item
    // Fimber.d(
    //     ">>> handleEvent[$chapNumber][${link.href}] =============== i_leftOverlayVisible: $_leftOverlayVisible, _rightOverlayVisible: $_rightOverlayVisible");
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (isHorizontalDrag(dy, dx)) {
        // vertical drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      } else if (dy > dx) {
        // horizontal drag
        if ((_bottomOverlayVisible && isDraggingTowardsTop(event)) ||
            (_topOverlayVisible && isDraggingTowardsBottom(event))) {
          // The enclosing PageView must handle the drag since the webview cannot scroll anymore
          // Fimber.d(
          //     ">>> handleEvent[$chapNumber][$curHRef] =============== REJECT, _leftOverlayVisible: $_leftOverlayVisible, _rightOverlayVisible: $_rightOverlayVisible");
          stopTrackingPointer(event.pointer);
        } else {
          // horizontal drag - accept
          // Fimber.d(
          //     ">>> handleEvent[$chapNumber][$curHRef] =============== ACCEPT, _leftOverlayVisible: $_leftOverlayVisible, _rightOverlayVisible: $_rightOverlayVisible");
          resolve(GestureDisposition.accepted);
          _dragDistance = Offset.zero;
        }
      }
    }
  }

  String? getSpineItemHref() => readerContext.publication?.manifest.readingOrder
      .elementAt(chapNumber)
      .href;

  bool isHorizontalDrag(double dy, double dx) => dx > dy && dx > kTouchSlop;

  bool isDraggingTowardsBottom(PointerEvent event) => event.delta.dy > 0;

  bool isDraggingTowardsTop(PointerEvent event) => (event.delta.dy < 0);
}
