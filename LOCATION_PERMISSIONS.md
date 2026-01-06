# Location Permissions Setup

This document explains the location permissions configuration for the SkillBridge mobile app.

## Permissions Added

### Android (`android/app/src/main/AndroidManifest.xml`)

Added the following permissions:
- `ACCESS_FINE_LOCATION` - For precise location (GPS)
- `ACCESS_COARSE_LOCATION` - For approximate location (network-based)

These permissions are required for the `geolocator` package to work.

### iOS (`ios/Runner/Info.plist`)

Added the following permission descriptions:
- `NSLocationWhenInUseUsageDescription` - Required for location access when app is in use
- `NSLocationAlwaysUsageDescription` - For always-on location (if needed)
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Required for iOS 11+

## Testing Location Permissions

### Android

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **On first location request:**
   - Android will show a permission dialog
   - User must grant permission for location to work

3. **If permission is denied:**
   - The app will show a snackbar message
   - User can manually enable in Settings > Apps > SkillBridge > Permissions

### iOS

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **On first location request:**
   - iOS will show a permission dialog with the description from Info.plist
   - User must grant permission for location to work

3. **If permission is denied:**
   - The app will show a snackbar message
   - User can enable in Settings > Skillbridge Mobile > Location

## Troubleshooting

### "No permission are defined in manifest" Error

**Solution:**
1. Make sure you've added the permissions to `AndroidManifest.xml`
2. Clean and rebuild the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Location Not Working on Android

**Check:**
1. Permissions are in `AndroidManifest.xml` (not in a different manifest file)
2. App is rebuilt after adding permissions
3. Location services are enabled on the device
4. GPS is enabled on the device

### Location Not Working on iOS

**Check:**
1. Permission descriptions are in `Info.plist`
2. App is rebuilt after adding permissions
3. Location services are enabled on the device
4. Simulator location is set (if testing on simulator)

### Testing on iOS Simulator

To test location on iOS Simulator:
1. Go to Simulator menu: **Features > Location**
2. Choose a location preset or set custom location

### Testing on Android Emulator

To test location on Android Emulator:
1. Open Extended Controls (three dots)
2. Go to **Location** tab
3. Set latitude/longitude or use preset locations

## Code Implementation

The location permission handling is already implemented in:
- `user_registration_screen.dart` - `_getCurrentLocation()` method
- `worker_registration_screen.dart` - `_getCurrentLocation()` method

The code:
1. Checks if location services are enabled
2. Requests permission if not granted
3. Handles permission denied cases
4. Gets current position using `Geolocator.getCurrentPosition()`

## Additional Notes

- **Android 12+ (API 31+)**: Background location requires additional runtime permission
- **iOS 14+**: Requires `NSLocationAlwaysAndWhenInUseUsageDescription` key
- **Privacy**: Always explain why you need location access (done in Info.plist descriptions)

## Next Steps

After adding permissions:
1. Clean build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Rebuild and run: `flutter run`
4. Test location capture on registration forms

