import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension PositionExt on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}