import 'package:flivekit/api.dart';
import 'package:flivekit/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flivekit/livekit.dart';
import 'package:livekit_client/livekit_client.dart';

TrackPublication? videoPubiOS;
TrackPublication? videoPubAnd;

class ScaffoldWidget extends StatefulWidget {
  const ScaffoldWidget({super.key});

  @override
  ScaffoldState createState() => ScaffoldState();
}

class ScaffoldState extends State<ScaffoldWidget> with LiveKitDelegate {
  bool isJoining = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white54,
                  width: 2,
                ),
              ),
              child: videoPubiOS != null
                  ? VideoTrackRenderer(videoPubiOS?.track as VideoTrack)
                  : const Center(
                      child: Icon(Icons.apple, size: 64, color: Colors.white54),
                    ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white54,
                  width: 2,
                ),
              ),
              child: videoPubAnd != null
                  ? VideoTrackRenderer(videoPubAnd?.track as VideoTrack)
                  : const Center(
                      child:
                          Icon(Icons.android, size: 64, color: Colors.white54),
                    ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
            child: Text(
              textAlign: TextAlign.center,
              liveKitMeetingId != null
                  ? '\nMeeting ID:\n$liveKitMeetingId'
                  : '',
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      joinRoom();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white54, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isJoining
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login, color: Colors.white54),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 24, // Add padding top and bottom
                          ),
                          child: Text(
                            '      J o i n',
                            style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Add some space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      leaveRoom();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white54, width: 2),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white54),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 24, // Add padding top and bottom
                          ),
                          child: Text(
                            '      L e a v e',
                            style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  void joinRoom() async {
    if (!isJoining) {
      setState(() {
        isJoining = true;
      });

      int userid = 0;
      String username = 'Anonymous';
      if (Tools.tools.appDevice == AppDevice.ios) {
        userid = 89;
        username = 'ToF-iOS';
      } else if (Tools.tools.appDevice == AppDevice.android) {
        userid = 104;
        username = 'ToF-And';
      }

      String? token = await Api.api.apiPostGetToken(username, userid);
      debugPrint('Token: $token');

      if (token != null) {
        LiveKit.liveKit.liveKitDelegate = this;

        LocalParticipant? localParticipant =
            await LiveKit.liveKit.liveKitJoinRoom(token);

        if (localParticipant != null) {
          if (Tools.tools.appDevice == AppDevice.ios) {
            videoPubiOS = LiveKit.liveKit
                .liveKitGetTrackPublication(localParticipant, null);
          } else if (Tools.tools.appDevice == AppDevice.android) {
            videoPubAnd = LiveKit.liveKit
                .liveKitGetTrackPublication(localParticipant, null);
          }

          setState(() {
            isJoining = false;
          });
        }
      }
    }
  }

  void leaveRoom() async {
    LiveKit.liveKit.liveKitLeaveRoom();

    setState(() {
      videoPubiOS = null;
      videoPubAnd = null;

      isJoining = false;
    });
  }

  // LiveKitDelegate
  @override
  void update(TrackPublication? trackPublication) {
    if (trackPublication != null) {
      if ((Tools.tools.appDevice == AppDevice.ios &&
              trackPublication.participant.identity == 'ToF-And') ||
          (Tools.tools.appDevice == AppDevice.android &&
              trackPublication.participant.identity == 'ToF-iOS')) {
        debugPrint('update');
        debugPrint(trackPublication.participant.name);

        if (videoPubiOS == null &&
            trackPublication.participant.identity == 'ToF-iOS') {
          videoPubiOS = LiveKit.liveKit
              .liveKitGetTrackPublication(null, trackPublication.participant);

          setState(() {
            isJoining = false;
          });
        } else if (videoPubAnd == null &&
            trackPublication.participant.identity == 'ToF-And') {
          videoPubAnd = LiveKit.liveKit
              .liveKitGetTrackPublication(null, trackPublication.participant);

          setState(() {
            isJoining = false;
          });
        }
      }
    }
  }
}
