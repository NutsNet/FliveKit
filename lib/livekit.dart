import 'package:flivekit/const.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

Room? liveKitRoom;
String? liveKitMeetingId;

mixin LiveKitDelegate {
  void update(TrackPublication? trackPublication);
}

class LiveKit {
  late LiveKitDelegate? liveKitDelegate;

  static final LiveKit liveKit = LiveKit._internal(liveKitDelegate: null);

  factory LiveKit() {
    return liveKit;
  }

  LiveKit._internal({required this.liveKitDelegate}) {
    debugPrint('INIT LIVEKIT SINGLETON');
  }

  Future<LocalParticipant?> liveKitJoinRoom(String token) async {
    debugPrint('liveKitJoinRoom');

    const roomOptions = RoomOptions(adaptiveStream: true, dynacast: true);

    liveKitRoom =
        await LiveKitClient.connect(kFlkWss, token, roomOptions: roomOptions);
    try {
      // video will fail when running in ios simulator
      await liveKitRoom?.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      debugPrint('Could not publish video, error: $error');
    }

    await liveKitRoom?.localParticipant?.setMicrophoneEnabled(true);

    liveKitRoom?.removeListener(liveKitRoomOnChange);
    liveKitRoom?.addListener(liveKitRoomOnChange);

    return liveKitRoom?.localParticipant;
  }

  void liveKitLeaveRoom() {
    debugPrint('liveKitLeaveRoom');

    liveKitRoom?.disconnect();
  }

  TrackPublication? liveKitGetTrackPublication(
  LocalParticipant? localParticipant, Participant? participant) {
  debugPrint('liveKitGetTrackPublication');

  TrackPublication? trackPublication;
  Iterable<TrackPublication<Track>> visibleVideos = [];

  if (localParticipant != null && participant == null) {
    visibleVideos = localParticipant.videoTracks.where((pub) {
      return pub.kind == TrackType.VIDEO && pub.subscribed && !pub.muted;
    });
  } else if (localParticipant == null && participant != null) {
    visibleVideos = participant.videoTracks
        .where((pub) =>
            pub.kind == TrackType.VIDEO && pub.subscribed && !pub.muted);
  }

  // Handle both LocalTrackPublication and RemoteTrackPublication
  if (visibleVideos.isNotEmpty) {
    var firstVideoTrack = visibleVideos.first;

    if (firstVideoTrack is TrackPublication<LocalVideoTrack>) {
      // Handle LocalTrackPublication
      trackPublication = firstVideoTrack;
    } else if (firstVideoTrack is TrackPublication<RemoteVideoTrack>) {
      // Handle RemoteTrackPublication
      // You might want to convert or do something specific for remote tracks
      trackPublication = firstVideoTrack;
    }
  }

  return trackPublication;
}


  void liveKitRoomOnChange() {
    debugPrint('liveKitRoomOnChange');

    for (RemoteParticipant participant in liveKitRoom!.participants.values) {
      debugPrint('Participant name: ${participant.identity}');

      participant.trackPublications.forEach((key, value) {
        debugPrint(value.name);
        if (value.name == 'camera') {
          liveKitDelegate?.update(value);
        }
      });
    }
  }

  void liveKitParticipantOnChange(Participant participant) {
    debugPrint('liveKitParticipantOnChange');

    TrackPublication? trackPublication;
    var visibleVideos = participant.videoTracks.where((pub) {
      return pub.kind == TrackType.VIDEO && pub.subscribed && !pub.muted;
    });
    if (visibleVideos.isNotEmpty) {
      trackPublication = visibleVideos.first;
    }

    liveKitDelegate?.update(trackPublication);
  }
}
