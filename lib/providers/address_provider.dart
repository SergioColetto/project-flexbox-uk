import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happy_postcode_flutter/models/address.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:postcode/postcode.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressProvider extends ChangeNotifier {
  String _apikey = 'iddqd';
  String _url = 'api.ideal-postcodes.co.uk';

  String _urlPrivado = 'location-delivery.herokuapp.com';

  List<Address> _addresses = [];
  List<Address> _route = [];
  final client =
      HttpClientWithInterceptor.build(interceptors: [LoggingInterceptor()]);

  UnmodifiableListView<Address> get addresses =>
      UnmodifiableListView(_addresses);

  UnmodifiableListView<Address> get route => UnmodifiableListView(_route);

  int get totalInRoute => _route.length;

  void onReorder(int oldIndex, int newIndex) {
    var row = _route.removeAt(oldIndex);
    _route.insert(newIndex, row);
    notifyListeners();
  }

  Future<List<Address>> findByPostcode(
      BuildContext context, final String postcode) async {
    if (!isValid(postcode)) {
      _dialog(context, "Invalid Postcode");
      return null;
    }

    final response = await client.get(
        Uri.https('$_url', 'v1/postcodes/$postcode',
            <String, String>{'api_key': _apikey}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    try {
      Map<String, dynamic> body = jsonDecode(response.body);
      _addresses = builderAddresses(body['result']);
      _sendAddressToPrivateServer();
    } on NoSuchMethodError catch (_) {
      if (response.statusCode == 404) {
        _dialog(context, "Postcode Not Found");
      }
      if (response.statusCode == 402) {
        _dialog(context,
            "Limit reached. One of your lookup limits has been breached for today");
      }

      _addresses = [];
    }

    return addresses;
  }

  Future<List<Address>> findPrivado(
      BuildContext context, final String postcode) async {
    final response = await client.get(
      Uri.https(_urlPrivado, 'api/location', <String, String>{
        'postcode': postcode,
      }),
    );

    try {
      final body = json.decode(response.body);
      _addresses = builderAddresses(body);
    } on NoSuchMethodError catch (_) {
      if (response.statusCode == 404) {
        _dialog(context, "Postcode Not Found");
      }
      if (response.statusCode == 402) {
        _dialog(context,
            "Limit reached. One of your lookup limits has been breached for today");
      }
      _addresses = [];
    }

    return addresses;
  }

  void routeAdd(BuildContext context, Address address) {
    if (_route.contains(address)) return;
    if (_route.length >= 9) {
      _dialog(context, "Limit of address in route");
      return;
    }
    _route.add(address);
    notifyListeners();
  }

  void deleteInRoute(Address address) {
    _route.remove(address);
    notifyListeners();
  }

  void deleteAllAddressInRoute() {
    _route = [];
    notifyListeners();
  }

  Future<bool> launchCoordinates(double latitude, double longitude,
      [String label]) {
    return launch(_createCoordinatesUrl(latitude, longitude, label));
  }

  String _createCoordinatesUrl(double latitude, double longitude,
      [String label]) {
    final uri = Uri.https('www.google.com', 'maps/place/$latitude,$longitude',
        {'data': '!3m1!4b1!4m5!3m4!1s0x0:0x0!8m2!3d$latitude!4d$longitude'});

    return uri?.toString();
  }

  void launchRoute(BuildContext context) async {
    if (_route.length == 0) {
      _dialog(context, "Add address in route.");
      return;
    }
    final url = _createRoute();
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  String _createRoute() {
    if (_route.length > 0) {
      final locationsBuild = [];
      locationsBuild.add("");

      _route.forEach((address) =>
          locationsBuild.add('${address.latitude},${address.longitude}'));

      locationsBuild.add('@${locationsBuild[locationsBuild.length - 1]},14z/');

      final allLocations = locationsBuild.join("/");

      return Uri.https('www.google.com', 'maps/dir/$allLocations').toString();
    }
    return '';
  }

  void _dialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                message,
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
        barrierDismissible: false);
  }

  void _sendAddressToPrivateServer() {
    client.post(
      Uri.https('location-delivery.herokuapp.com', 'api/location'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(_addresses),
    );
  }

  bool includes(Address address) {
    return _route.contains(address);
  }

  void addAddress(List<Address> data) {
    _addresses = data;
  }

  void dialog(BuildContext context, String msg) {
    _dialog(context, msg);
  }
}

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    print(data.url);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
    print(data.body);
    return data;
  }
}
