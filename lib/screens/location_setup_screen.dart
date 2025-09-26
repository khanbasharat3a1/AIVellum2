import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/user_location.dart';
import '../services/location_service.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  bool _isDetecting = false;
  UserLocation? _detectedLocation;
  String? _selectedCountry;

  final List<Map<String, dynamic>> _countries = [
    {'code': 'IN', 'name': 'India', 'flag': '🇮🇳', 'isIndia': true},
    {'code': 'US', 'name': 'United States', 'flag': '🇺🇸', 'isIndia': false},
    {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧', 'isIndia': false},
    {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦', 'isIndia': false},
    {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺', 'isIndia': false},
    {'code': 'DE', 'name': 'Germany', 'flag': '🇩🇪', 'isIndia': false},
    {'code': 'FR', 'name': 'France', 'flag': '🇫🇷', 'isIndia': false},
    {'code': 'JP', 'name': 'Japan', 'flag': '🇯🇵', 'isIndia': false},
    {'code': 'SG', 'name': 'Singapore', 'flag': '🇸🇬', 'isIndia': false},
    {'code': 'AE', 'name': 'UAE', 'flag': '🇦🇪', 'isIndia': false},
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isDetecting = true;
    });

    try {
      final location = await LocationService.getUserLocation();
      setState(() {
        _detectedLocation = location;
        _selectedCountry = location.countryCode;
      });
    } catch (e) {
      print('Location detection failed: $e');
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.paddingXL),
                      
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppConstants.paddingXL),
                              decoration: BoxDecoration(
                                gradient: AppConstants.vaultRedGradient,
                                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                                boxShadow: [AppConstants.premiumShadow],
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 48,
                                color: AppConstants.textOnDark,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingL),
                            Text(
                              'Setup Your Location',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.paddingS),
                            Text(
                              'We need to know your location to show you the correct pricing for premium prompts.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppConstants.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingXL),

                      // Auto-detected location
                      if (_detectedLocation != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppConstants.paddingL),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(
                              color: AppConstants.successColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppConstants.successColor,
                                size: 24,
                              ),
                              const SizedBox(width: AppConstants.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location Detected',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.successColor,
                                      ),
                                    ),
                                    Text(
                                      _detectedLocation!.countryName,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                      ],

                      // Manual selection
                      Text(
                        'Or select your country manually:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingM),

                      // Country list
                      if (_isDetecting) ...[
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: AppConstants.paddingM),
                              Text('Detecting your location...'),
                            ],
                          ),
                        )
                      ] else ..._countries.map((country) {
                            final isSelected = _selectedCountry == country['code'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCountry = country['code'];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(AppConstants.paddingL),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppConstants.vaultRed.withOpacity(0.1)
                                        : AppConstants.surfaceColor,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                    border: Border.all(
                                      color: isSelected 
                                          ? AppConstants.vaultRed
                                          : AppConstants.borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        country['flag'],
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: AppConstants.paddingM),
                                      Expanded(
                                        child: Text(
                                          country['name'],
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? AppConstants.vaultRed : AppConstants.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: AppConstants.vaultRed,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ],
                  ),
                ),
              ),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCountry != null ? _continueSetup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.vaultRed,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingL),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continueSetup() async {
    if (_selectedCountry == null) return;

    final selectedCountryData = _countries.firstWhere(
      (country) => country['code'] == _selectedCountry,
    );

    final userLocation = UserLocation(
      countryCode: selectedCountryData['code'],
      countryName: selectedCountryData['name'],
      isIndia: selectedCountryData['isIndia'],
    );

    await LocationService.updateLocation(userLocation);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }
}