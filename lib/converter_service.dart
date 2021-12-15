import 'package:myanmar_tools/myanmar_tools.dart';

enum MyanmarEncoding { zawgyi, unicode, notDefined }

class ConverterService {
  final ZawGyiConverter converter = ZawGyiConverter();
  ZawGyiDetector? detector;

  Future<MyanmarEncoding> detectText(String text) async {
    detector ??= await ZawGyiDetector.create();
    var zawPossible = detector!.getZawGyiProbability(text);
    if (zawPossible == double.negativeInfinity) {
      return MyanmarEncoding.notDefined;
    } else if (zawPossible < 0.05) {
      return MyanmarEncoding.unicode;
    } else {
      return MyanmarEncoding.zawgyi;
    }
  }

  Future<String> convert(String text) async {
    MyanmarEncoding encoding = await detectText(text);
    if (encoding == MyanmarEncoding.zawgyi) {
      return converter.zawGyiToUnicode(text);
    } else {
      return text;
    }
  }
}
