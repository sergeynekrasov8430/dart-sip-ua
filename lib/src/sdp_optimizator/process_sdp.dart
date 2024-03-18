import 'sdp_simplified.dart';

SdpSimplified processSdp(SdpSimplified sdp, bool isOffer, bool isLocal) {
  if (isLocal) {
    // 0 Separate offers and answers:
    if (isOffer) {
      // work with sdp from offers

      List<String> allowedAudioCodecs = <String>['PCMA', 'opus', 'PCMU'];
      sdp.audioCodecs
          .removeWhere(
          (AudioCodec element) => !allowedAudioCodecs.contains(element.name));

      List<String> allowedVideoCodecs = <String>['H264', 'VP8'];
      sdp.videoCodecs
          .removeWhere(
          (VideoCodec element) => !allowedVideoCodecs.contains(element.name));

      //    sdp.audioCodecs.removeWhere((element) => element.name == 'opus');

      //    sdp.audioCodecs.removeWhere((element) => element.payload.toString() == '98');

      //    var videoCodecs = sdp.videoCodecs.forEach((codec) {
      //      if (codec.name == 'H264') { // find all codecs with the given name
      //        codec.config = 'level-asymmetry- allowed=1;packetization-mode=1;profile-level-id=428016';
      //      }
      //    });

      //    var newVideoCodec = VideoCodec('H264', 126, false, false);
      //    newVideoCodec.rate = 90000;
      //    newVideoCodec.encoding = null;

      //    newVideoCodec.config =
      //        'level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=428016';//    newVideoCodec.shouldOverrideEmptyFmtp = true;

      //  newVideoCodec.type = '';
      //  newVideoCodec.subtype = '';
      //  newVideoCodec.shouldOverrideEmptyRtcpFb = false;

      //    sdp.videoCodecs.add(newVideoCodec); // в конец
      //    sdp.videoCodecs.insert(0, newVideoCodec); // на первое место

      sdp.includeAudioExt = false;
      sdp.includeVideoExt = false;
    } else {
      // work with sdp from asnwers

    }

    // 1. Manage which codecs should be used or removed

    // 1.1 to add only allowed audioCodecs:
    //  var allowedAudioCodecs = ['enter codec'];
    //  sdp.audioCodecs.removeWhere((element) => !allowedAudioCodecs.contains(element.name));

    // 1.2 to add only allowed videoCodecs:
    //  var allowedVideoCodecs = ['enter codec'];
    //  sdp.videoCodecs.removeWhere((element) => !allowedVideoCodecs.contains(element.name));

    // 1.3 to exclude audio codec by name:
    //  sdp.audioCodecs.removeWhere((element) => element.name == 'enter codec');

    // 1.4 to exclude audio codec by payload
    //  sdp.audioCodecs.removeWhere((element) => element.payload.toString() == 'enter payload');

    // 1.5 to exclude video codec by name:
    //  sdp.videoCodecs.removeWhere((element) => element.name == 'enter codec');

    // 1.6 to exclude video codec by payload
    //  sdp.videoCodecs.removeWhere((element) => element.payload.toString() == 'enter payload');

    // 2. Find a codec
    // 2.1 to find audio codec by payload
    //  var audioCodec = sdp.audioCodecs.firstWhere((element) => element.payload.toString() == 'enter payload', orElse: () {});

    // 2.2 to find video codec by payload
    //  var videoCodec = sdp.videoCodecs.firstWhere((element) => element.payload.toString() == 'enter payload', orElse: () {});

    // 2.3 Iterate through the codecs (same for video)
    //  var audioCodecs = sdp.audioCodecs.forEach((codec) {
    //    if (codec.name == 'enter codec') { // find all codecs with the given name
    //
    //    }
    //  });

    // 3 Mutate concrete codec (same for video):
    // change subtype
    //  audioCodec.subtype = 'enter subtype';

    // change rate
    // audioCodec.rate = 90000; // enter rate

    // change encoding
    //  audioCodec.encoding = 2; // enter encoding

    // change type
    //  audioCodec.type = 'enter type';

    // if rtcpFb did'not contain any data for this codec - this value will be true
    //  var rtcpFbWasNull = audioCodec.rtcpFbWasNull;

    // if this is set to true then even if the rtcpFb was null for the codec, it will be set
    //  audioCodec.shouldOverrideEmptyRtcpFb = true;

    // set any string to config
    //  audioCodec.config = 'enter config';

    // if fmtp did'not contain any data for this codec - this value will be true
    //  var fmtp = audioCodec.fmtpWasNull;

    // if this is set to true then even if the fmtp was null for the codec, it will be set
    //  audioCodec.shouldOverrideEmptyFmtp = true;

    // 4 to change audio direction:
    //  sdp.audioDirection = 'recvonly';

    // 4.1 to change video direction:
    //  sdp.videoDirection = 'recvonly';

    // 5 to remove ext
    // 5.1 for video
    //  sdp.includeVideoExt = false;
    // 5.2 for audio
    //  sdp.includeAudioExt = false;

    // 6 to change groups
    //  sdp.groups = [{'type': 'BUNDLE', 'mids': 'audio video'}];

    return sdp;
  }
  if (!isLocal) {
    if (isOffer) {
      if (sdp.videoCodecs != null && sdp.videoCodecs.isNotEmpty) {
        int h264Index = sdp.videoCodecs
            .indexWhere((VideoCodec element) => element.name == 'H264');
        List? currentFmtp = sdp.videoCodecs[h264Index].fmtp;
        Map<String, Object> fakeH264FmtpConfig = <String, Object>{
          'payload': sdp.videoCodecs[h264Index].payload,
          'config':
              'level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f',
        };

        if (currentFmtp == null || currentFmtp.isEmpty) {
          sdp.videoCodecs[h264Index].fmtp = [fakeH264FmtpConfig];
          print('fixed broken h264 params in sdp (created fake h264fmtp)');
        } else {
          List? copy = sdp.videoCodecs[h264Index].fmtp ?? List.empty();
          copy.add(fakeH264FmtpConfig);
          sdp.videoCodecs[h264Index].fmtp = copy;
          print('fixed broken h264 params in sdp (added fake h264fmtp)');
        }
      }
      return sdp;
    }
  }
  return sdp;
}
