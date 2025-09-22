import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

const double blwLatitude = 25.2901446;
const double blwLongitude = 82.9607415;

const double allowedDistanceMeters = 10000;
Future<Map<String, dynamic>> getCurrentLocationData() async {
  // ✅ Request permissions
  if (!await Geolocator.isLocationServiceEnabled()) {
    return {
      "insideAllowedArea": false,
      "error": "Location services are disabled",
    };
  }

  // 📍 Request all necessary permissions
  var status = await Permission.location.status;
  if (!status.isGranted) {
    await Permission.location.request();
    await Permission.locationWhenInUse.request();
    await Permission.locationAlways.request();

    status = await Permission.location.status;
    if (!status.isGranted) {
      return {
        "insideAllowedArea": false,
        "error": "Location permission denied",
      };
    }
  }

  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      blwLatitude,
      blwLongitude,
    );

    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "distance": distance,
      "insideAllowedArea": distance <= allowedDistanceMeters,
    };
  } catch (e) {
    return {"insideAllowedArea": false, "error": "Error getting location: $e"};
  }
}
