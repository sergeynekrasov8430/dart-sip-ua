class Codec {

  Codec(this.name, this.payload);
  final String name; // rtp['codec']
  final int payload; // rtp['payload']
  int? rate; // rtp['rate']
  int? encoding; // rtp['encoding']
  String? config; // fmtp['config']
  String? type; // rtcpFb['type']
  String? subtype; // rtcpFb['subtype']
  List? fmtp;
  List? rtcpFb;

  void log() {
    print(runtimeType == AudioCodec ? 'AudioCodec:' : 'VideoCodec:');
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
      <String, dynamic>{
        'payload': payload,
        'codec': name,
        'rate': rate,
        'encoding': encoding
      };
}

class VideoCodec extends Codec {
  VideoCodec(String name, int payload) : super(name, payload);
}

class AudioCodec extends Codec {
  AudioCodec(String name, int payload) : super(name, payload);
}

class SdpSimplified {
  // update groups

  SdpSimplified.fromSdpMap(Map<String, dynamic> sdpMap) {
    var media = sdpMap['media'];

    // find indexes of audio and video sections
    int indexOfAudioMedia = (sdpMap['media'] as List)
        .indexWhere((element) => element['type'] == 'audio');
    int indexOfVideoMedia = (sdpMap['media'] as List)
        .indexWhere((element) => element['type'] == 'video');

    if (indexOfAudioMedia != null && indexOfAudioMedia != -1) {
      // audio section
      var audio = media[indexOfAudioMedia];
      var audioRtp = audio['rtp'];
      var audioFmtp = audio['fmtp'];
      var audioRtcpFb = audio['rtcpFb'];
      // build audio codecs
      for (var rtp in audioRtp as List) {
        AudioCodec codec = AudioCodec(rtp['codec'], rtp['payload']);
        codec.fmtp = (audioFmtp as List)
            .where((element) => element['payload'] == rtp['payload'])
            .toList();
        codec.rtcpFb = (audioRtcpFb as List)
            .where((element) => element['payload'] == rtp['payload'])
            .toList();
        codec.rate = rtp['rate'];
        codec.encoding = rtp['encoding'];
        if (audioFmtp != null && audioFmtp.isNotEmpty) {
          codec.config = audioFmtp.first['config'];
        }
        audioCodecs.add(codec);
      }
      // direction
      audioDirection = audio['direction'];
    }

    if (indexOfVideoMedia != null && indexOfVideoMedia != -1) {
      // video section
      var video = media[indexOfVideoMedia];
      var videoRtp = video['rtp'];
      var videoFmtp = video['fmtp'];
      var videoRtcpFb = video['rtcpFb'];
      // build video codecs
      for (var rtp in videoRtp as List) {
        VideoCodec codec = VideoCodec(rtp['codec'], rtp['payload']);
        codec.rate = rtp['rate'];
        codec.encoding = rtp['encoding'];
        codec.fmtp = (videoFmtp as List)
            .where((element) => element['payload'] == rtp['payload'])
            .toList();
        codec.rtcpFb = (videoRtcpFb as List)
            .where((element) => element['payload'] == rtp['payload'])
            .toList();
        if (videoFmtp != null && videoFmtp.isNotEmpty) {
          codec.config = videoFmtp.first['config'];
        }
        videoCodecs.add(codec);
      }
      // direction
      videoDirection = video['direction'];
    }

    groups = (sdpMap['groups'] as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }
  List<AudioCodec> audioCodecs = <AudioCodec>[]; // manage audio codecs
  List<VideoCodec> videoCodecs = <VideoCodec>[]; // manage video codecs
  bool includeAudioExt = true; // include or exclude ext parameter from audio
  bool includeVideoExt = true; // include or exclude ext parameter from video
  String? audioDirection; // change audio direction
  String? videoDirection; // change video direction
  List<Map<String, dynamic>>? groups;

  void log() {
    print('SdpSimplified:');
    print('audioCodecs:');
    for (AudioCodec element in audioCodecs) {
      element.log();
    }
    print('videoCodecs:');
    for (VideoCodec element in videoCodecs) {
      element.log();
    }
    print('includeAudioExt: $includeAudioExt');
    print('includeVideoExt: $includeVideoExt');
    print('audioDirection: $audioDirection');
    print('videoDirection: $videoDirection');
    print('groups: $groups');
  }
}
