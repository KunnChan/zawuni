import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static Future<InitializationStatus> initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6655545557347816/8643361521';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
