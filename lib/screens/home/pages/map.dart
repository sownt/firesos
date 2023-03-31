import 'package:firesos/controllers/position_controller.dart';
import 'package:firesos/utils/fire_emergency_number.dart';
import 'package:firesos/utils/location_ext.dart';
import 'package:firesos/utils/position_ext.dart';
import 'package:firesos/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  final TextEditingController _searchController = TextEditingController();
  final PositionController _positionController = Get.find<PositionController>();
  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderOverlay(
        child: Stack(
          children: [
            FutureBuilder(
              future: _positionController.determinePosition(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('error'.tr),
                  );
                }

                if (snapshot.hasData) {
                  return GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: snapshot.data?.toLatLng() ?? const LatLng(0, 0),
                      zoom: 16,
                    ),
                    markers: markers,
                    onLongPress: _changeMarker,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            SafeArea(
              child: Container(
                margin:
                    const EdgeInsets.all(16),
                child: SearchBar(
                  controller: _searchController,
                  onSearch: _handleSearch,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'my-location',
            onPressed: _determinePosition,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.my_location,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          FloatingActionButton(
            heroTag: 'call-emergency',
            onPressed: _callForEmergency,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.call),
          )
        ],
      ),
    );
  }

  void _handleSearch(String query) async {
    List<Location> locations = await locationFromAddress(query);
    Set<Marker> results = locations
        .take(5)
        .map(
          (e) => Marker(
            markerId: MarkerId(e.timestamp.toString()),
            position: e.toLatLng(),
          ),
        )
        .toSet();

    _updateMarkers(results);

    mapController.moveCamera(CameraUpdate.newLatLng(locations[0].toLatLng()));
  }

  void _callForEmergency() async {
    context.loaderOverlay.show();
    try {
      final currentLocation = markers.isEmpty
          ? (await _positionController.determinePosition()).toLatLng()
          : markers.elementAt(0).position;
      List<Placemark> places = await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);
      String? phone = FireEmergencyNumber.phones[places[0].isoCountryCode];
      if (phone != null) {
        Get.dialog(
          AlertDialog(
            contentPadding: const EdgeInsets.all(24),
            content: Text('Marked position: ${places[0].name}, ${places[0].street} ${places[0].locality}'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () {
                  launchUrl(Uri(scheme: 'tel', path: phone));
                },
                child: Text('call_phone'.trParams({'phone': phone})),
              ),
            ],
          ),
        );
      } else {
        Get.dialog(
          AlertDialog(
            contentPadding: const EdgeInsets.all(24),
            content: Text('unavailable'.trParams({'country': places[0].country!})),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('ok'.tr),
              ),
            ],
          )
        );
      }
    } finally {
      context.loaderOverlay.hide();
    }
  }

  void _determinePosition() async {
    final current = await _positionController.determinePosition();
    _changeMarker(current.toLatLng());
  }

  void _changeMarker(LatLng latLng) {
    mapController.animateCamera(CameraUpdate.newLatLng(latLng));
    _updateMarkers({
      Marker(markerId: MarkerId('manual'.tr), position: latLng),
    });
  }

  void _updateMarkers(Set<Marker> data) {
    setState(() {
      markers.clear();
      markers.addAll(data);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
