import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyMap());

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  Position _currentPosition;
  double longitude, latitude;
  String _homeloc = "";
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _userpos;
  CameraPosition _home;
  Set<Marker> markers = Set();
  MarkerId markerId1 = MarkerId("12");
  GoogleMapController gmcontroller;
  double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    //_loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Map"),
        ),
        body: new Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              Text('Longitude: ', style: TextStyle(fontSize: 12), ),
              Text('Latitude: ', style: TextStyle(fontSize: 12)),
              
              
          ]),
        ),
      ),
    );
  }

  _loadMapDialog() {
    _controller = null;
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Current location not available", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation();
        return;
      }
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(6.4676929, 100.5067673),
        zoom: 17,
      );
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              var alheight = MediaQuery.of(context).size.height;
              var alwidth = MediaQuery.of(context).size.width;
              return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          _homeloc,
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Container(
                          height: alheight - 300,
                          width: alwidth - 10,
                          child: GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: _userpos,
                              markers: markers.toSet(),
                              onMapCreated: (controller) {
                                _controller.complete(controller);
                              },
                              onTap: (newLatLng) {
                                _loadLoc(newLatLng, newSetState);
                              }),
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          height: 30,
                          child: Text('Close'),
                          color: Colors.red,
                          textColor: Colors.white,
                          elevation: 10,
                          onPressed: () => {
                            markers.clear(),
                            Navigator.of(context).pop(false),
                          },
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  void _loadLoc(LatLng loc, newSetState) async {
    newSetState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(6.4676929, 100.5067673, newSetState);
      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      markers.add(Marker(
        markerId: markerId1,
        position: LatLng(6.4676929, 100.5067673),
        infoWindow: InfoWindow(
          title: 'New Location',
          snippet: 'New Delivery Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });
    _userpos = CameraPosition(
      target: LatLng(6.4676929, 100.5067673),
      zoom: 17,
    );
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        //_calculatePayment();
        return;
      }
    });
    setState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        //_calculatePayment();
        return;
      }
    });
  }

//  _calculatePayment() {
//    setState(() {
//      if (_delivery == "Pickup") {
//        distance = 0;
//        delcharge = restdel * distance;
//        payable = totalPrice + delcharge;
//      } else {
//        distance = calculateDistance(latitude, longitude, restlat, restlon);
//        delcharge = restdel * distance;
//        payable = totalPrice + delcharge;
//      }
//    });
//  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

  Future<void> _getLocation() async {
//    ProgressDialog pr = new ProgressDialog(context,
//    type: ProgressDialogType.Normal, isDismissible: false);
//    pr.style(message: "Locating...");
//    await pr.show();
//    try{
//      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
//      geolocator
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
//        .timeout(Duration(seconds: 10), onTimeout:(){
//          Toast.show("enable location permission",
//          context,
//          duration: Toast.LENGTH_LONG,
//          gravity: Toast.BOTTOM);
//        }).then((Position position){
//          setState(() async{
//            _currentPosition = position;
//          });
//        }).catchError((e){
//          print(e);
//        });
//    }catch(exception){
//      print(exception.toString());
//    }
//    await pr.hide();
//    }
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
              //_calculatePayment();
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}
