import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:happy_postcode_flutter/components/centered_message.dart';
import 'package:happy_postcode_flutter/providers/address_provider.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class TimeLineRouteList extends StatefulWidget {
  @override
  _TimeLineRouteListState createState() => _TimeLineRouteListState();
}

class _TimeLineRouteListState extends State<TimeLineRouteList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
        builder: (context, provider, child) => provider.totalInRoute > 0
            ? Timeline(
                children: provider.route.map((address) {
                return Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(address.line1),
                          subtitle:
                              Text('${address.postcode} | ${address.postTown}'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.grey),
                        onPressed: () {
                          provider.deleteInRoute(address);
                        },
                      ),
                    ],
                  ),
                );
              }).toList())
            : CenteredMessage(
                "Add address to get started",
                icon: Icons.room_outlined,
              ));
  }
}

class Timeline extends StatelessWidget {
  const Timeline({
    @required this.children,
    this.indicators,
    this.isLeftAligned = true,
    this.itemGap = 12.0,
    this.gutterSpacing = 4.0,
    this.padding = const EdgeInsets.all(8),
    this.controller,
    this.lineColor = Colors.grey,
    this.physics,
    this.shrinkWrap = true,
    this.primary = false,
    this.reverse = false,
    this.indicatorSize = 30.0,
    this.lineGap = 4.0,
    this.indicatorColor = Colors.black45,
    this.indicatorStyle = PaintingStyle.fill,
    this.strokeCap = StrokeCap.butt,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  })  : itemCount = children.length,
        assert(itemGap >= 0),
        assert(lineGap >= 0),
        assert(indicators == null || children.length == indicators.length);

  final List<Widget> children;
  final double itemGap;
  final double gutterSpacing;
  final List<Widget> indicators;
  final bool isLeftAligned;
  final EdgeInsets padding;
  final ScrollController controller;
  final int itemCount;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final bool primary;
  final bool reverse;

  final Color lineColor;
  final double lineGap;
  final double indicatorSize;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddressProvider>(context, listen: false);
    return CustomScrollView(
      slivers: <Widget>[
        ReorderableSliverList(
            delegate: ReorderableSliverChildListDelegate(
              children.map(_buildItem).toList(),
            ),
            onReorder: provider.onReorder),
      ],
    );
  }

  Widget _buildItem(Widget item) {
    final index = children.indexOf(item);
    final child = item;

    final isFirst = index == 0;
    final isLast = index == itemCount - 1;

    final timelineTile = <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 8),
        child: CustomPaint(
          foregroundPainter: _TimelinePainter(
            hideDefaultIndicator: false,
            lineColor: lineColor,
            indicatorColor: indicatorColor,
            number: index,
            indicatorSize: indicatorSize,
            indicatorStyle: indicatorStyle,
            isFirst: isFirst,
            isLast: isLast,
            lineGap: lineGap,
            strokeCap: strokeCap,
            strokeWidth: strokeWidth,
            style: style,
            itemGap: itemGap,
          ),
          child: SizedBox(
            height: double.infinity,
            width: indicatorSize,
          ),
        ),
      ),
      SizedBox(width: gutterSpacing),
      Expanded(child: child),
    ];

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: isLeftAligned ? timelineTile : timelineTile.reversed.toList(),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    @required this.hideDefaultIndicator,
    @required this.indicatorColor,
    @required this.indicatorStyle,
    @required this.indicatorSize,
    @required this.lineGap,
    @required this.number,
    @required this.strokeCap,
    @required this.strokeWidth,
    @required this.style,
    @required this.lineColor,
    @required this.isFirst,
    @required this.isLast,
    @required this.itemGap,
  })  : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeCap
          ..strokeWidth = strokeWidth
          ..style = style,
        circlePaint = Paint()
          ..color = indicatorColor
          ..style = indicatorStyle;

  final bool hideDefaultIndicator;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final double indicatorSize;
  final double lineGap;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;
  final Color lineColor;
  final Paint linePaint;
  final Paint circlePaint;
  final bool isFirst;
  final bool isLast;
  final double itemGap;
  final int number;

  @override
  void paint(Canvas canvas, Size size) {
    final indicatorRadius = indicatorSize / 2;
    final halfItemGap = itemGap / 2;
    final indicatorMargin = indicatorRadius + lineGap;

    final top = size.topLeft(Offset(indicatorRadius, 0.0 - halfItemGap));
    final centerTop = size.centerLeft(
      Offset(indicatorRadius, -indicatorMargin),
    );

    final bottom = size.bottomLeft(Offset(indicatorRadius, 0.0 + halfItemGap));
    final centerBottom = size.centerLeft(
      Offset(indicatorRadius, indicatorMargin),
    );

    if (!isFirst) canvas.drawLine(top, centerTop, linePaint);
    if (!isLast) canvas.drawLine(centerBottom, bottom, linePaint);

    if (!hideDefaultIndicator) {
      final Offset offsetCenter = size.centerLeft(Offset(indicatorRadius, 0));
      canvas.drawCircle(offsetCenter, indicatorRadius, circlePaint);
      TextSpan textSpan = new TextSpan(
        text: (number + 1).toString(),
        style: TextStyle(color: Colors.white, fontSize: 20),
      );
      TextPainter textPainter = new TextPainter(
          text: textSpan,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.justify)
        ..layout(maxWidth: 0, minWidth: 0);

      textPainter.paint(canvas, size.centerLeft(Offset(21, -11)));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
