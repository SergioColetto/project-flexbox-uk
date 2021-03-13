import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';
import 'package:happy_postcode_flutter/components/app_theme.dart';
import 'package:happy_postcode_flutter/providers/address_provider.dart';
import 'package:provider/provider.dart';

class NavigateButton extends StatefulWidget {
  @override
  _NavigateButtonState createState() => _NavigateButtonState();
}

class _NavigateButtonState extends State<NavigateButton> {
  bool _isMultipleStop = false;
  double _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController _controller;
  MapBoxNavigation _directions;
  MapBoxOptions _options;
  String _instruction = "";
  bool _arrived = false;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: onEmbeddedRouteEvent);
    _options = MapBoxOptions(
        mode: MapBoxNavigationMode.drivingWithTraffic,
        animateBuildRoute: false,
        language: "en",
        units: VoiceUnits.metric);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Consumer<AddressProvider>(
      builder: (context, provider, child) => MaterialButton(
        minWidth: width - 120,
        child: Text('Start Traval', style: TextStyle(color: Colors.white)),
        color: HexColor("#ff5208"),
        shape: StadiumBorder(),
        elevation: 0,
        splashColor: Colors.transparent,
        onPressed: () async {
          if (provider.totalInRoute > 0) {
            List<WayPoint> wayPoints = [];

            Position position = await Geolocator()
                .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

            wayPoints.add(new WayPoint(
                name: 'My local',
                latitude: position.latitude,
                longitude: position.longitude));

            wayPoints.addAll(provider.route
                .map((address) => new WayPoint(
                    name: address.line1,
                    latitude: address.latitude,
                    longitude: address.longitude))
                .toList());

            _isMultipleStop = wayPoints.length > 2;
            await _directions.startNavigation(
                wayPoints: wayPoints, options: _options);
          }
        },
      ),
    );
  }

  Future<void> onEmbeddedRouteEvent(e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        final progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
        break;
      case MapBoxEvent.route_built:
        break;
      case MapBoxEvent.route_build_failed:
        break;
      case MapBoxEvent.navigation_running:
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _directions.finishNavigation();
        }
        break;
      case MapBoxEvent.navigation_finished:
        _controller.finishNavigation();
        _directions.finishNavigation();
        break;
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        _controller.finishNavigation();
        _directions.finishNavigation();
        break;
      default:
        print(e.eventType);
        break;
    }
  }
}
