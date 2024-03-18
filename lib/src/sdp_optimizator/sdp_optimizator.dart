import 'package:sdp_transform/sdp_transform.dart' as sdp_transform;

import 'process_sdp.dart';
import 'sdp_simplified.dart';

class SdpOptimisator {
  static String optimiseLocalSDP(String sdp, bool isOffer, isLocal) {
    Map<String, dynamic> sdpMap = sdp_transform.parse(sdp);
    SdpSimplified sdpSimplified = SdpSimplified.fromSdpMap(sdpMap);
    // print('=================================');
    // developer.log('>>> About to mutate local SDP \n $sdp}');
    // print('=================================');
    // print('>>> from sdpSimplified SDP:');
    // sdpSimplified.log();
    // print('=================================');
    // print('>>> with processed SDP:');
    SdpSimplified processedSdp = processSdp(sdpSimplified, isOffer, isLocal);
    // processedSdp.log();
    // print('=================================');

    var media = sdpMap['media'];
    int indexOfAudioMedia = (sdpMap['media'] as List)
        .indexWhere((element) => element['type'] == 'audio');
    int indexOfVideoMedia = (sdpMap['media'] as List)
        .indexWhere((element) => element['type'] == 'video');

    if (indexOfAudioMedia != null && indexOfAudioMedia != -1) {
      var audio = media[indexOfAudioMedia];
      var audioRtp = audio['rtp'];
      // print('>>> from (rtp) \n ${sdpMap['media'][indexOfAudioMedia]['rtp']}');
      sdpMap['media'][indexOfAudioMedia]['rtp'] =
          _makeRtp(processedSdp.audioCodecs);
      // print('>>> to (rtp) \n ${sdpMap['media'][indexOfAudioMedia]['rtp']}');
      // print('>>> from (payloads) \n ${sdpMap['media'][indexOfAudioMedia]['payloads']}');
      sdpMap['media'][indexOfAudioMedia]['payloads'] =
          _makePayloadsForCodecs(processedSdp.audioCodecs);
      // print('>>> to (payloads) \n ${sdpMap['media'][indexOfAudioMedia]['payloads']}');
      // print('>>> from (fmtp) \n ${sdpMap['media'][indexOfAudioMedia]['fmtp']}');
      sdpMap['media'][indexOfAudioMedia]['fmtp'] =
          _makeFmtp(processedSdp.audioCodecs);
      // print('>>> to (fmtp) \n ${sdpMap['media'][indexOfAudioMedia]['fmtp']}');
      // print('>>> from (rtcpFb) \n ${sdpMap['media'][indexOfAudioMedia]['rtcpFb']}');
      sdpMap['media'][indexOfAudioMedia]['rtcpFb'] =
          _makeRtcpFb(processedSdp.audioCodecs);
      // print('>>> to (rtcpFb) \n ${sdpMap['media'][indexOfAudioMedia]['rtcpFb']}');
      if (!processedSdp.includeAudioExt) {
        // print('>>> from (ext rmv) \n ${sdpMap['media'][indexOfAudioMedia]['ext']}');
        (sdpMap['media'][indexOfAudioMedia] as Map)
            .removeWhere((key, value) => key == 'ext');
        // print('>>> to (ext rmv) \n ${sdpMap['media'][indexOfAudioMedia]['ext']}');
      }
      // print('>>> from (direction) \n ${sdpMap['media'][indexOfAudioMedia]['direction']}');
      sdpMap['media'][indexOfAudioMedia]['direction'] =
          processedSdp.audioDirection;
      // print('>>> to (direction) \n ${sdpMap['media'][indexOfAudioMedia]['direction']}');
    }

    if (indexOfVideoMedia != null && indexOfVideoMedia != -1) {
      var video = media[indexOfVideoMedia];
      var videoRtp = video['rtp'];
      // print('>>> from (rtp+v) \n ${sdpMap['media'][indexOfVideoMedia]['rtp']}');
      sdpMap['media'][indexOfVideoMedia]['rtp'] =
          _makeRtp(processedSdp.videoCodecs);
      // print('>>> to (rtp+v) \n ${sdpMap['media'][indexOfVideoMedia]['rtp']}');
      // print('>>> from (payloads+v) \n ${sdpMap['media'][indexOfVideoMedia]['payloads']}');
      sdpMap['media'][indexOfVideoMedia]['payloads'] =
          _makePayloadsForCodecs(processedSdp.videoCodecs);
      // print('>>> to (payloads+v) \n ${sdpMap['media'][indexOfVideoMedia]['payloads']}');
      // print('>>> from (fmtp+v) \n ${sdpMap['media'][indexOfVideoMedia]['fmtp']}');
      sdpMap['media'][indexOfVideoMedia]['fmtp'] =
          _makeFmtp(processedSdp.videoCodecs);
      // print('>>> to (fmtp+v) \n ${sdpMap['media'][indexOfVideoMedia]['fmtp']}');
      // print('>>> from (rtcpFb+v) \n ${sdpMap['media'][indexOfVideoMedia]['rtcpFb']}');
      sdpMap['media'][indexOfVideoMedia]['rtcpFb'] =
          _makeRtcpFb(processedSdp.videoCodecs);
      // print('>>> to (rtcpFb+v) \n ${sdpMap['media'][indexOfVideoMedia]['rtcpFb']}');
      if (!processedSdp.includeVideoExt) {
        // print('>>> from (ext rmv+v) \n ${sdpMap['media'][indexOfVideoMedia]['ext']}');
        (sdpMap['media'][indexOfVideoMedia] as Map)
            .removeWhere((key, value) => key == 'ext');
        // print('>>> to (ext rmv+v) \n ${sdpMap['media'][indexOfVideoMedia]['ext']}');
      }
      // print('>>> from (direction+v) \n ${sdpMap['media'][indexOfVideoMedia]['direction']}');
      sdpMap['media'][indexOfVideoMedia]['direction'] =
          processedSdp.videoDirection;
      // print('>>> to (direction+v) \n ${sdpMap['media'][indexOfVideoMedia]['direction']}');
    }
    // print('>>> from (groups) \n ${sdpMap['groups']}');
    sdpMap['groups'] = processedSdp.groups;
    // print('>>> to (groups) \n ${sdpMap['groups']}');

    // print('=================================');
    String optimizedSdp = sdp_transform.write(sdpMap, null);
    // developer.log('SDP optimisation result: \n $optimizedSdp}');
    return optimizedSdp;
  }

  static List<Map<String, dynamic>> _makeRtp(List<Codec> codecs) =>
      codecs.map((Codec codec) => codec.makeRtp()).toList();

  static List? _makeFmtp(List<Codec> codecs) {
    List fmtp = [];
    for (Codec codec in codecs) {
      if (codec.fmtp != null) {
        fmtp.addAll(codec.fmtp);
      }
    }
    if (fmtp.isEmpty) {
      return null;
    }
    return fmtp;
  }

  static List? _makeRtcpFb(List<Codec> codecs) {
    List rtcpFb = [];
    for (Codec codec in codecs) {
      if (codec.rtcpFb != null) {
        rtcpFb.addAll(codec.rtcpFb);
      }
    }
    rtcpFb.removeWhere((element) => element == null);
    if (rtcpFb.isEmpty) {
      return null;
    }
    return rtcpFb;
  }

  // Removes unneeded codecs from payloads string (video/audio)
  static String _makePayloadsForCodecs(List<Codec> codecs) {
    String payloads = '';
    for (Codec codec in codecs) {
      if (payloads.length > 0) {
        payloads += ' ';
      }
      payloads += codec.payload.toString();
    }
    return payloads;
  }
}
