import 'package:sdp_transform/sdp_transform.dart' as sdp_transform;
import 'process_sdp.dart';
import 'sdp_simplified.dart';

class SdpOptimisator {
  static String optimiseLocalSDP(String sdp, bool isOffer) {
    var sdpMap = sdp_transform.parse(sdp);
    var sdpSimplified = SdpSimplified.fromSdpMap(sdpMap);
    print('=================================');
    print('>>> About to mutate local SDP $sdpMap');
    print('=================================');
    print('>>> from sdpSimplified SDP:');
    sdpSimplified.log();
    print('=================================');
    print('>>> with processed SDP:');
    var processedSdp = processSdp(sdpSimplified, isOffer);
    processedSdp.log();
    print('=================================');

    var media = sdpMap['media'];
    var indexOfAudioMedia = (sdpMap['media'] as List).indexWhere((element) => element['type'] == 'audio');
    var indexOfVideoMedia = (sdpMap['media'] as List).indexWhere((element) => element['type'] == 'video');

    var audio = media[indexOfAudioMedia];
    var audioRtp = audio['rtp'];
    sdpMap['media'][indexOfAudioMedia]['rtp'] = _makeRtp(processedSdp.audioCodecs);
    sdpMap['media'][indexOfAudioMedia]['payloads'] = _makePayloadsForCodecs(processedSdp.audioCodecs);
    sdpMap['media'][indexOfAudioMedia]['fmtp'] = _makeFmtp(processedSdp.audioCodecs);
    sdpMap['media'][indexOfAudioMedia]['rtcpFb'] = _makeRtcpFb(processedSdp.audioCodecs);
    if (!processedSdp.includeAudioExt) {
      (sdpMap['media'][indexOfAudioMedia] as Map).removeWhere((key, value) => key == 'ext');
    }
    sdpMap['media'][indexOfAudioMedia]['direction'] = processedSdp.audioDirection;

    var video = media[indexOfVideoMedia];
    var videoRtp = video['rtp'];
    sdpMap['media'][indexOfVideoMedia]['rtp'] = _makeRtp(processedSdp.videoCodecs);
    sdpMap['media'][indexOfVideoMedia]['payloads'] =  _makePayloadsForCodecs(processedSdp.videoCodecs);
    sdpMap['media'][indexOfVideoMedia]['fmtp'] = _makeFmtp(processedSdp.videoCodecs);
    sdpMap['media'][indexOfVideoMedia]['rtcpFb'] = _makeRtcpFb(processedSdp.videoCodecs);
    if (!processedSdp.includeVideoExt) {
      (sdpMap['media'][indexOfVideoMedia] as Map).removeWhere((key, value) => key == 'ext');
    }
    sdpMap['media'][indexOfVideoMedia]['direction'] = processedSdp.videoDirection;

    sdpMap['groups'] = processedSdp.groups;

    print('SDP optimisation result: $sdpMap');
    print('=================================');
    var optimizedSdp = sdp_transform.write(sdpMap, null);
    return optimizedSdp;
  }

  static List<Map<String, dynamic>> _makeRtp(List<Codec> codecs) =>
      codecs.map((codec) => codec.makeRtp()).toList();

  static List<Map<String, dynamic>> _makeFmtp(List<Codec> codecs) {
    var fmtp = codecs.map((codec) => codec.makeFmtp()).toList();
    fmtp.removeWhere((element) => element == null);
    return fmtp;
  }

  static List<Map<String, dynamic>> _makeRtcpFb(List<Codec> codecs) {
    var rtcpFb = codecs.map((codec) => codec.makeRtcpFb()).toList();
    rtcpFb.removeWhere((element) => element == null);
    return rtcpFb;
  }

  // Removes unneeded codecs from payloads string (video/audio)
  static String _makePayloadsForCodecs(List<Codec> codecs) {
    var payloads = '';
    codecs.forEach((codec) {
      if (payloads.length > 0) {
        payloads += ' ';
      }
      payloads += codec.payload.toString();
    });
    return payloads;
  }
}
