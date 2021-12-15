import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zawgyi_unicode_converter/converter_service.dart';

import 'ad_helper.dart';

void main() {
  runApp(const ZawUni());
}

class ZawUni extends StatefulWidget {
  const ZawUni({Key? key}) : super(key: key);

  @override
  _ZawUniState createState() => _ZawUniState();
}

class _ZawUniState extends State<ZawUni> {
  final controller = TextEditingController();
  final service = ConverterService();

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  void loadAds() {
    AdHelper.initGoogleMobileAds();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  onPaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String clipboardValue = clipboardData?.text ?? "";
    String combinedText = controller.text + clipboardValue;
    controller.text = await service.convert(combinedText);
  }

  onUnicodeCopy() {
    if (controller.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: controller.text));
    }
  }

  onZawgyiCopy() {
    if (controller.text.isNotEmpty) {
      final zawgyiText = service.converter.unicodeToZawGyi(controller.text);
      Clipboard.setData(ClipboardData(text: zawgyiText));
    }
  }

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF36EEE0),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zawgyi <> Unicode'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      controller.text = '';
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      onPaste();
                    },
                    child: const Text('Paste'),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      onZawgyiCopy();
                    },
                    child: const Text('Copy Zaw'),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      onUnicodeCopy();
                    },
                    child: const Text('Copy Uni'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste Zawgyi or Unicode text then copy!',
                ),
                controller: controller,
                style: const TextStyle(fontFamily: 'Padauk Bold'),
              ),
            ),
            if (_isBannerAdReady)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
