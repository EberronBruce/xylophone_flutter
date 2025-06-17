import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(XylophoneApp());

class XylophoneApp extends StatefulWidget {
  // Changed to StatefulWidget
  const XylophoneApp({super.key});

  @override
  State<XylophoneApp> createState() => _XylophoneAppState();
}

class _XylophoneAppState extends State<XylophoneApp> {
  //final player = AudioPlayer();
  final Map<int, AudioPlayer> notePlayers = {};
  final int numberOfKeys = 7;

  final List<Color> buttonColors = const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 1; i <= numberOfKeys; i++) {
      final player = AudioPlayer();
      // Optional: Configure player defaults if needed, e.g.,
      player.setReleaseMode(
        ReleaseMode.stop,
      ); // Keeps player alive but stops sound
      notePlayers[i] = player;

      // Set up onPlayerComplete listener for each player from the start
      // This listener will now mostly just log or reset state if needed,
      // as we are reusing the player.
      player.onPlayerComplete.listen((event) {
        if (kDebugMode) {
          print('Player for note $i (${player.playerId}) completed sound.');
        }
      });

      player.onLog.listen((logMessage) {
        // Good for debugging
        if (kDebugMode) {
          print('Player for note $i (ID: ${player.playerId}) log: $logMessage');
        }
      });
      if (kDebugMode) {
        print('Initialized ${notePlayers.length} audio players.');
      }
    }
  }

  Future<void> playSoundForKey(int soundNumber) async {
    String soundAsset = 'note$soundNumber.wav';

    // Get the pre-initialized player for this note
    AudioPlayer? player = notePlayers[soundNumber];

    if (player == null) {
      if (kDebugMode) {
        print('Error: No pre-initialized player found for note $soundNumber');
      }
    }

    if (kDebugMode) {
      print('Using player (${player!.playerId}) for note$soundNumber.wav');
    }
    try {
      // Stop current playback (if any) on this specific player and play new sound.
      // The `play` method itself often handles stopping the current source
      // before playing a new one on the same player instance.
      // Calling stop() explicitly first ensures a clean state.
      await player!.stop();
      await player.play(AssetSource(soundAsset));
    } catch (e) {
      if (kDebugMode) {
        print(
          'Error playing sound for note $soundNumber with player ${player?.playerId}: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose all pre-initialized players
    notePlayers.forEach((soundNumber, player) {
      if (kDebugMode) {
        print('Disposing player for note $soundNumber in main dispose');
      }
      player.dispose();
    });
    notePlayers.clear();
    super.dispose();
  }

  // void playSound(int soundNumber) async {
  //   await player.stop();
  //   await player.play(AssetSource('note$soundNumber.wav'));
  //   print('Playing note$soundNumber.wav');
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(numberOfKeys, (index) {
              int soundNoteNumber = index + 1;
              Color currentButtonColor = buttonColors[index];
              return buildKey(currentButtonColor, soundNoteNumber);
            }),
          ),
        ),
      ),
    );
  }

  Expanded buildKey(Color currentButtonColor, int soundNoteNumber) {
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: currentButtonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: () async {
          //playSound(soundNoteNumber);
          playSoundForKey(soundNoteNumber);
        },
        child: Text(''),
      ),
    );
  }
}
