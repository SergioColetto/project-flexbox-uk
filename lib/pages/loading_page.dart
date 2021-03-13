import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:happy_postcode_flutter/helpers/helpers.dart';
import 'package:happy_postcode_flutter/pages/main_page.dart';
import 'package:permission_handler/permission_handler.dart';

import 'acceso_gps_page.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await Geolocator().isLocationServiceEnabled()) {
        Navigator.pushReplacement(
            context, navegarMapaFadeIn(context, MainPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: this.checkGpsYLocation(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) return Center(child: Text(snapshot.data));

          return Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      ),
    );
  }

  Future checkGpsYLocation(BuildContext context) async {
    final permisoGPS = await Permission.location.isGranted;
    final gpsActivo = await Geolocator().isLocationServiceEnabled();

    if (permisoGPS && gpsActivo) {
      Navigator.pushReplacement(
          context, navegarMapaFadeIn(context, MainPage()));
      return '';
    } else if (!permisoGPS) {
      Navigator.pushReplacement(
          context, navegarMapaFadeIn(context, AccesoGpsPage()));
      return 'GPS permission required';
    } else {
      return 'Active GPS';
    }
  }
}
