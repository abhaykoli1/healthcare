import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate({
    String reason = "Authenticate to continue",
  }) async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      final bool canCheck = await _auth.canCheckBiometrics;

      // 👇 DEBUG – YAHAN LAGANA HAI
      final available = await _auth.getAvailableBiometrics();
      print("Device Supported: $isSupported");
      print("Can Check Biometrics: $canCheck");
      print("Available biometrics: $available");

      if (!isSupported) return false;

      final bool authenticated = await _auth.authenticate(
        localizedReason: reason,
      );

      return authenticated;
    } catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }
}
