import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? address;
  final String? locationName;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.address,
    this.locationName,
  });
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class LocationService {
  // geocoding 5.x uses an instance of Geocoding.
  final Geocoding _geocoding = Geocoding();

  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    try {
      // Check whether the device's location service is enabled.
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('[LOCATION SERVICE] System location services are DISABLED');
        return LocationPermissionStatus.serviceDisabled;
      }

      // Check current permission.
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('[LOCATION SERVICE] Initial permission status: $permission');

      // Ask for permission if not granted yet.
      if (permission == LocationPermission.denied) {
        debugPrint('[LOCATION SERVICE] Permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        debugPrint('[LOCATION SERVICE] Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          return LocationPermissionStatus.denied;
        }
      }

      // User permanently denied location permission.
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }

      // Valid foreground location permission.
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return LocationPermissionStatus.granted;
      }

      return LocationPermissionStatus.error;
    } catch (e) {
      debugPrint('Location permission error: $e');
      return LocationPermissionStatus.error;
    }
  }

  Future<LocationResult?> getCurrentLocation() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      // Get the device's current GPS position.
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      String? address;
      String? locationName;

      // Reverse geocode coordinates into a human-readable address.
      try {
        final List<Placemark> placemarks =
        await _geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;

          final List<String> addressParts = [
            if (place.street != null && place.street!.isNotEmpty)
              place.street!,
            if (place.subLocality != null && place.subLocality!.isNotEmpty)
              place.subLocality!,
            if (place.locality != null && place.locality!.isNotEmpty)
              place.locality!,
            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty)
              place.administrativeArea!,
            if (place.postalCode != null && place.postalCode!.isNotEmpty)
              place.postalCode!,
            if (place.country != null && place.country!.isNotEmpty)
              place.country!,
          ];

          if (addressParts.isNotEmpty) {
            address = addressParts.join(', ');
          }

          if (place.name != null && place.name!.isNotEmpty) {
            locationName = place.name;
          } else if (place.subLocality != null &&
              place.subLocality!.isNotEmpty) {
            locationName = place.subLocality;
          } else if (place.locality != null &&
              place.locality!.isNotEmpty) {
            locationName = place.locality;
          }
        }
      } catch (e) {
        // GPS coordinates are still useful even if reverse geocoding fails.
        debugPrint('Reverse geocoding failed: $e');
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
        locationName: locationName,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}