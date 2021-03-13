import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:happy_postcode_flutter/helpers/map_marker.dart';
import 'package:happy_postcode_flutter/helpers/uber_map_theme.dart';
import 'package:happy_postcode_flutter/models/address.dart';
import 'package:happy_postcode_flutter/providers/address_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class MapaPage extends StatefulWidget {
  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController _controller;
  LatLng _initialPosition;
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) async {
    controller.setMapStyle(jsonEncode(uberMapTheme));
    if (_markers.isNotEmpty) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _markers.first.position,
            zoom: 11.0,
          ),
        ),
      );
    }

    _controller = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initialize() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _initialPosition = LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddressProvider>(context, listen: false);

    _markers = provider.route
        .map((address) => Marker(
            markerId: MarkerId(Uuid().v1()),
            position: LatLng(address.latitude, address.longitude),
            infoWindow: InfoWindow(title: address.line1),
            draggable: false))
        .toSet();

    return Scaffold(
      body: FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
              break;
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              return Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMap(
                      markers: _markers,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 11.0,
                      ),
                      myLocationEnabled: true,
                    ),
                  )
                ],
              );
              break;
            case ConnectionState.none:
              break;
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
