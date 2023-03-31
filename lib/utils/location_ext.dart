import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension LocationExt on Location {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}