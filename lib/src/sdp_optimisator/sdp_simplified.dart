class Codec {
  final String name; // rtp['codec']
  final int payload; // rtp['payload']
  int rate; // rtp['rate']
  int encoding; // rtp['encoding']
  String config; // fmtp['config']
  String type; // rtcpFb['type']
  String subtype; // rtcpFb['subtype']
  final bool fmtpWasNull; // if fmtp for this payload was empty
  bool shouldOverrideEmptyFmtp = false; // if even if fmtp was empty it should be filled with the given config
  final bool rtcpFbWasNull; // if rtcpFb for this payload was empty
  bool shouldOverrideEmptyRtcpFb = false; // if even if rtcpFb was empty it should be filled with the given config

  Codec(this.name, this.payload, this.fmtpWasNull, this.rtcpFbWasNull);
  
  void log() {
    print('${runtimeType == AudioCodec ? 'AudioCodec:' : 'VideoCodec:'}');
    print('name: $name');
    print('payload: $payload');
    print('rate: $rate');
    print('encoding: $encoding');
    print('config: $config');
    print('type: $type');
    print('subtype: $subtype');
    print('============');
  }

  Map<String, dynamic> makeRtp() =>
      {
        'payload': payload,
        'codec': name,
        'rate': rate,
        'encoding': encoding
      };

  Map<String, dynamic> makeFmtp() {
    if (shouldOverrideEmptyFmtp) {
      return {
        'payload': payload,
        'config': config
      };
    } else if (fmtpWasNull) {
      return null;
    } else {
      return {
        'payload': payload,
        'config': config
      };
    }
  }

  Map<String, dynamic> makeRtcpFb() {
    if (shouldOverrideEmptyRtcpFb) {
      return {
        'payload': payload,
        'type': type,
        'subtype': subtype
      };
    } else if (rtcpFbWasNull) {
      return null;
    } else {
      return {
        'payload': payload,
        'type': type,
        'subtype': subtype
      };
    }
  }
}

class VideoCodec extends Codec {
  VideoCodec(String name, int payload, bool fmtpWasNull, bool rtcpFbWasNull) : super(name, payload, fmtpWasNull, rtcpFbWasNull);
}

class AudioCodec extends Codec {
  AudioCodec(String name, int payload, bool fmtpWasNull, bool rtcpFbWasNull) : super(name, payload, fmtpWasNull, rtcpFbWasNull);
}

class SdpSimplified {
  List<AudioCodec> audioCodecs = []; // manage audio codecs
  List<VideoCodec> videoCodecs = []; // manage video codecs
  bool includeAudioExt = true; // include or exclude ext parameter from audio
  bool includeVideoExt = true; // include or exclude ext parameter from video
  String audioDirection; // change audio direction
  String videoDirection; // change video direction
  List<Map<String, dynamic>> groups; // update groups

  SdpSimplified.fromSdpMap(Map<String, dynamic> sdpMap) {
    var media = sdpMap['media'];

    // find indexes of audio and video sections
    var indexOfAudioMedia = (sdpMap['media'] as List).indexWhere((element) => element['type'] == 'audio');
    var indexOfVideoMedia = (sdpMap['media'] as List).indexWhere((element) => element['type'] == 'video');

    // audio section
    var audio = media[indexOfAudioMedia];
    var audioRtp = audio['rtp'];
    var audioFmtp = audio['fmtp'];
    var audioRtcpFb = audio['rtcpFb'];
    // build audio codecs
    (audioRtp as List).forEach((rtp) {
      var fmtp = (audioFmtp as List)
          ?.firstWhere((fmtp) => fmtp['payload'] == rtp['payload'], orElse: () { });
      var rtcpFb = (audioRtcpFb as List)
          ?.firstWhere((rtcpFb) => rtcpFb['payload'] == rtp['payload'], orElse: () { });
      var codec = AudioCodec(rtp['codec'], rtp['payload'], fmtp == null, rtcpFb == null);
      codec.rate = rtp['rate'];
      codec.encoding = rtp['encoding'];
      if (fmtp != null) {
        codec.config = fmtp['config'];
      }
      if (rtcpFb != null) {
        codec.type = rtcpFb['type'];
        codec.subtype = rtcpFb['subtype'];
      }
      audioCodecs.add(codec);
    });
    // direction
    audioDirection = audio['direction'];

    // video section
    var video = media[indexOfVideoMedia];
    var videoRtp = video['rtp'];
    var videoFmtp = video['fmtp'];
    var videoRtcpFb = video['rtcpFb'];
    // build video codecs
    (videoRtp as List).forEach((rtp) {
      var fmtp = (videoFmtp as List)
          ?.firstWhere((fmtp) => fmtp['payload'] == rtp['payload'], orElse: () {});
      var rtcpFb = (videoRtcpFb as List)
          ?.firstWhere((rtcpFb) => rtcpFb['payload'] == rtp['payload'], orElse: () {});
      var codec = VideoCodec(rtp['codec'], rtp['payload'], fmtp == null, rtcpFb == null);
      codec.rate = rtp['rate'];
      codec.encoding = rtp['encoding'];
      if (fmtp != null) {
        codec.config = fmtp['config'];
      }
      if (rtcpFb != null) {
        codec.type = rtcpFb['type'];
        codec.subtype = rtcpFb['subtype'];
      }
      videoCodecs.add(codec);
    });
    // direction
    videoDirection = video['direction'];

    groups = (sdpMap['groups'] as List)?.map((e) => (e as Map).cast<String, dynamic>())?.toList();
  }

  void log() {
    print('SdpSimplified:');
    print('audioCodecs:');
    audioCodecs.forEach((element) { element.log(); });
    print('videoCodecs:');
    videoCodecs.forEach((element) { element.log(); });
    print('includeAudioExt: $includeAudioExt');
    print('includeVideoExt: $includeVideoExt');
    print('audioDirection: $audioDirection');
    print('videoDirection: $videoDirection');
    print('groups: $groups');
  }
}
