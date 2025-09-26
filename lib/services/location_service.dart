import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_location.dart';

class LocationService {
  static const String _locationKey = 'user_location';

  static Future<UserLocation> getUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString(_locationKey);
    
    if (locationJson != null) {
      return UserLocation.fromJson(json.decode(locationJson));
    }
    
    return await _detectLocation();
  }

  static Future<UserLocation> _detectLocation() async {
    try {
      // Using a free IP geolocation service
      final response = await http.get(
        Uri.parse('http://ip-api.com/json/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode = data['countryCode'] ?? 'US';
        final countryName = data['country'] ?? 'United States';
        final isIndia = countryCode.toUpperCase() == 'IN';

        final location = UserLocation(
          countryCode: countryCode,
          countryName: countryName,
          isIndia: isIndia,
        );

        await _saveLocation(location);
        return location;
      }
    } catch (e) {
      print('Location detection failed: $e');
    }

    // Default to US if detection fails
    final defaultLocation = UserLocation(
      countryCode: 'US',
      countryName: 'United States',
      isIndia: false,
    );
    await _saveLocation(defaultLocation);
    return defaultLocation;
  }

  static Future<void> _saveLocation(UserLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, json.encode(location.toJson()));
  }

  static Future<void> updateLocation(UserLocation location) async {
    await _saveLocation(location);
  }
}