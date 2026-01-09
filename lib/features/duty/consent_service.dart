import '../../core/network/api_client.dart';

class ConsentService {
  /// 🔹 Check consent status
  static Future<bool> isConsentSigned() async {
    final res = await ApiClient.get("/nurse/consent/status");
    return res["signed"] == true;
  }

  /// 🔹 Sign consent
  static Future<void> signConsent({
    required bool confidentiality,
    required bool noDirectPayment,
    required bool policeTermination,
    String? signatureImage,
  }) async {
    await ApiClient.post(
      "/nurse/consent/sign",
      {
        "confidentiality_accepted": confidentiality,
        "no_direct_payment_accepted": noDirectPayment,
        "police_termination_accepted": policeTermination,
        "signature_image": signatureImage,
      },
    );
  }
}
