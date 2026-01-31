enum AppLanguage { english, hindi, gujarati, marathi, kannada }

class Lang {
  static AppLanguage current = AppLanguage.english;

  static final Map<AppLanguage, Map<String, String>> strings = {
    /// ================= ENGLISH =================
    AppLanguage.english: {
      "title": "👩‍⚕️ Staff Legal Declaration & Undertaking",

      "upload_signature": "Upload your signature",
      "tap_upload": "Tap to upload signature",
      "submit": "Submit & Sign",
      "camera": "Camera",
      "gallery": "Gallery",
      "upload_title": "Upload Signature",

      "success": "Signature uploaded successfully!",
      "please_upload": "Please upload signature",
      "signup_done":
          "Signup complete ✅\nWait for admin approval.\nYou will get an email after verification.",

      /// declaration points
      "point1": "1️⃣ I declare that all my documents are genuine.",
      "point2": "2️⃣ I will follow company rules – duty timing and transfers.",
      "point3":
          "3️⃣ I will not misuse patient medical information, photos or videos.",
      "point4": "4️⃣ I will not take direct payment from patients.",
      "point5": "5️⃣ Leaving duty without notice may cause penalty.",
      "point6": "6️⃣ Smoking, alcohol or drugs are strictly prohibited.",
      "point7": "7️⃣ Misbehavior with patients or relatives is not allowed.",
      "point8": "8️⃣ Theft, fraud or damage is punishable.",
      "point9": "9️⃣ I will not misuse confidential data.",
      "point10": "🔟 Service can be terminated if police verification fails.",

      "confidential":
          "🔒 CONFIDENTIALITY & DISCIPLINE\n\nPatient and company data must not be misused. Violation may lead to legal action under IT Act 2000.",
    },

    /// ================= HINDI =================
    AppLanguage.hindi: {
      "title": "👩‍⚕️ स्टाफ कानूनी घोषणा",

      "upload_signature": "अपना हस्ताक्षर अपलोड करें",
      "tap_upload": "अपलोड करने के लिए टैप करें",
      "submit": "सबमिट करें",
      "camera": "कैमरा",
      "gallery": "गैलरी",
      "upload_title": "हस्ताक्षर अपलोड करें",

      "success": "हस्ताक्षर सफलतापूर्वक अपलोड हुआ!",
      "please_upload": "कृपया हस्ताक्षर अपलोड करें",
      "signup_done":
          "साइनअप पूरा हुआ ✅\nएडमिन अप्रूवल का इंतज़ार करें।\nआपको ईमेल मिलेगा।",

      "point1": "1️⃣ मैं घोषित करता/करती हूँ कि मेरे सभी दस्तावेज़ असली हैं।",
      "point2": "2️⃣ मैं कंपनी के नियमों और ड्यूटी समय का पालन करूँगा/करूँगी।",
      "point3": "3️⃣ मरीज की जानकारी का दुरुपयोग नहीं करूँगा/करूँगी।",
      "point4": "4️⃣ मरीज से सीधे भुगतान नहीं लूँगा/लूँगी।",
      "point5": "5️⃣ बिना सूचना ड्यूटी छोड़ना दंडनीय है।",
      "point6": "6️⃣ धूम्रपान/शराब/ड्रग्स सख्त मना है।",
      "point7": "7️⃣ मरीजों या रिश्तेदारों से दुर्व्यवहार नहीं करूँगा/करूँगी।",
      "point8": "8️⃣ चोरी/धोखाधड़ी दंडनीय है।",
      "point9": "9️⃣ गोपनीय जानकारी का दुरुपयोग नहीं होगा।",
      "point10": "🔟 पुलिस वेरिफिकेशन फेल होने पर सेवा समाप्त हो सकती है।",

      "confidential":
          "🔒 गोपनीयता\n\nमरीज और कंपनी की जानकारी सुरक्षित रखना अनिवार्य है।",
    },

    /// ================= GUJARATI =================
    AppLanguage.gujarati: {
      "title": "સ્ટાફ કાનૂની ઘોષણા",
      "upload_signature": "તમારી સહી અપલોડ કરો",
      "tap_upload": "અપલોડ કરવા માટે ટેપ કરો",
      "submit": "સબમિટ કરો",
      "camera": "કેમેરા",
      "gallery": "ગેલેરી",
      "upload_title": "સહી અપલોડ કરો",
      "success": "સહી સફળતાપૂર્વક અપલોડ થઈ!",
      "please_upload": "કૃપા કરીને સહી અપલોડ કરો",

      "point1": "1️⃣ મારા બધા દસ્તાવેજ સાચા છે.",
      "point2": "2️⃣ હું કંપનીના નિયમોનું પાલન કરીશ.",
      "point3": "3️⃣ દર્દીની માહિતીનો દુરુપયોગ નહીં કરું.",
      "point4": "4️⃣ દર્દી પાસેથી સીધી ચુકવણી નહીં લઉં.",
      "point5": "5️⃣ નોટિસ વગર ડ્યુટી છોડવી દંડનીય છે.",
      "point6": "6️⃣ ધુમ્રપાન/દારૂ મનાઈ છે.",
      "point7": "7️⃣ દર્દી સાથે દુર્વ્યવહાર નહીં કરું.",
      "point8": "8️⃣ ચોરી/ઠગાઈ ગુનો છે.",
      "point9": "9️⃣ ગુપ્ત માહિતીનો દુરુપયોગ નહીં કરું.",
      "point10": "🔟 પોલીસ વેરિફિકેશન નિષ્ફળ જાય તો સેવા બંધ થઈ શકે છે.",
      "confidential":
          "🔒 ગોપનીયતા\n\nદર્દી અને કંપનીની માહિતી સુરક્ષિત રાખવી જરૂરી છે.",
    },

    /// ================= MARATHI =================
    AppLanguage.marathi: {
      "title": "कर्मचारी कायदेशीर घोषणा",
      "upload_signature": "आपली सही अपलोड करा",
      "tap_upload": "अपलोड करण्यासाठी टॅप करा",
      "submit": "सबमिट करा",
      "camera": "कॅमेरा",
      "gallery": "गॅलरी",
      "upload_title": "सही अपलोड करा",
      "success": "सही यशस्वीरित्या अपलोड झाली!",
      "please_upload": "कृपया सही अपलोड करा",

      "point1": "1️⃣ माझे सर्व कागदपत्रे खरी आहेत.",
      "point2": "2️⃣ मी कंपनीचे नियम पाळेन.",
      "point3": "3️⃣ रुग्ण माहितीचा गैरवापर करणार नाही.",
      "point4": "4️⃣ थेट पैसे स्वीकारणार नाही.",
      "point5": "5️⃣ सूचना न देता ड्युटी सोडणे दंडनीय आहे.",
      "point6": "6️⃣ धूम्रपान/दारू बंद आहे.",
      "point7": "7️⃣ रुग्णांशी गैरवर्तन करणार नाही.",
      "point8": "8️⃣ चोरी/फसवणूक गुन्हा आहे.",
      "point9": "9️⃣ गोपनीय माहिती सुरक्षित ठेवेन.",
      "point10": "🔟 पोलीस पडताळणी अपयशी ठरल्यास सेवा संपुष्टात येईल.",
      "confidential":
          "🔒 गोपनीयता\n\nरुग्ण आणि कंपनीची माहिती सुरक्षित ठेवणे आवश्यक आहे.",
    },

    /// ================= KANNADA =================
    AppLanguage.kannada: {
      "title": "ಸಿಬ್ಬಂದಿ ಕಾನೂನು ಘೋಷಣೆ",
      "upload_signature": "ನಿಮ್ಮ ಸಹಿಯನ್ನು ಅಪ್ಲೋಡ್ ಮಾಡಿ",
      "tap_upload": "ಅಪ್ಲೋಡ್ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ",
      "submit": "ಸಲ್ಲಿಸಿ",
      "camera": "ಕ್ಯಾಮೆರಾ",
      "gallery": "ಗ್ಯಾಲರಿ",
      "upload_title": "ಸಹಿ ಅಪ್ಲೋಡ್ ಮಾಡಿ",
      "success": "ಸಹಿ ಯಶಸ್ವಿಯಾಗಿ ಅಪ್ಲೋಡ್ ಆಯಿತು!",
      "please_upload": "ದಯವಿಟ್ಟು ಸಹಿ ಅಪ್ಲೋಡ್ ಮಾಡಿ",

      "point1": "1️⃣ ನನ್ನ ದಾಖಲೆಗಳು ನಿಜವಾದವು.",
      "point2": "2️⃣ ಕಂಪನಿಯ ನಿಯಮಗಳನ್ನು ಪಾಲಿಸುತ್ತೇನೆ.",
      "point3": "3️⃣ ರೋಗಿಯ ಮಾಹಿತಿಯನ್ನು ದುರುಪಯೋಗ ಮಾಡುವುದಿಲ್ಲ.",
      "point4": "4️⃣ ನೇರ ಪಾವತಿ ಸ್ವೀಕರಿಸುವುದಿಲ್ಲ.",
      "point5": "5️⃣ ಸೂಚನೆ ಇಲ್ಲದೆ ಕೆಲಸ ಬಿಟ್ಟರೆ ದಂಡ.",
      "point6": "6️⃣ ಧೂಮಪಾನ/ಮದ್ಯ ನಿಷೇಧ.",
      "point7": "7️⃣ ರೋಗಿಗಳೊಂದಿಗೆ ದುರ್ವರ್ತನೆ ಬೇಡ.",
      "point8": "8️⃣ ಕಳ್ಳತನ/ಮೋಸ ಶಿಕ್ಷಾರ್ಹ.",
      "point9": "9️⃣ ರಹಸ್ಯ ಮಾಹಿತಿಯನ್ನು ರಕ್ಷಿಸುತ್ತೇನೆ.",
      "point10": "🔟 ಪೋಲಿಸ್ ಪರಿಶೀಲನೆ ವಿಫಲವಾದರೆ ಸೇವೆ ರದ್ದು.",
      "confidential":
          "🔒 ಗೌಪ್ಯತೆ\n\nರೋಗಿ ಮತ್ತು ಕಂಪನಿಯ ಮಾಹಿತಿಯನ್ನು ಸುರಕ್ಷಿತವಾಗಿರಿಸಿ.",
    },
  };

  static String t(String key) => strings[current]![key]!;
}
