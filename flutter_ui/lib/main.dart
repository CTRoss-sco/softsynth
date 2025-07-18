import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'synth_engine.dart';

void main() {
  runApp(const SynthApp());
}

class SynthApp extends StatelessWidget {
  const SynthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synth App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const SynthMainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class SynthMainScreen extends StatefulWidget {
  const SynthMainScreen({super.key});

  @override
  State<SynthMainScreen> createState() => _SynthMainScreenState();
}

class _SynthMainScreenState extends State<SynthMainScreen> {
  String currentNote = "None";
  bool synthInitialized = false;
  
  // Keyboard input state
  final Set<int> _pressedComputerKeys = {};
  final Set<int> _pressedMidiNotes = {}; // Track all pressed notes (mouse + keyboard)
  int _baseOctave = 4; // Starting at C4 (MIDI 60)
  
  // Piano layout keyboard mapping
  final Map<LogicalKeyboardKey, int> _keyboardMap = {
    // White keys: A S D F G H J K L ;
    LogicalKeyboardKey.keyA: 0,  // C
    LogicalKeyboardKey.keyS: 2,  // D
    LogicalKeyboardKey.keyD: 4,  // E
    LogicalKeyboardKey.keyF: 5,  // F
    LogicalKeyboardKey.keyG: 7,  // G
    LogicalKeyboardKey.keyH: 9,  // A
    LogicalKeyboardKey.keyJ: 11, // B
    LogicalKeyboardKey.keyK: 12, // C (next octave)
    LogicalKeyboardKey.keyL: 14, // D (next octave)
    LogicalKeyboardKey.semicolon: 16, // E (next octave)
    
    // Black keys: W E T Y U O P [
    LogicalKeyboardKey.keyW: 1,  // C#
    LogicalKeyboardKey.keyE: 3,  // D#
    LogicalKeyboardKey.keyT: 6,  // F#
    LogicalKeyboardKey.keyY: 8,  // G#
    LogicalKeyboardKey.keyU: 10, // A#
    LogicalKeyboardKey.keyO: 13, // C# (next octave)
    LogicalKeyboardKey.keyP: 15, // D# (next octave)
    LogicalKeyboardKey.bracketLeft: 17, // F# (next octave)
  };
  
  @override
  void initState() {
    super.initState();
    _initializeSynth();
  }
  
  @override
  void dispose() {
    SynthEngine.cleanup();
    super.dispose();
  }
  
  void _initializeSynth() async {
    setState(() {
      synthInitialized = SynthEngine.initialize();
    });
  }
  
  void _onNotePressed(int midiNote, double velocity) {
    setState(() {
      currentNote = _midiNoteToName(midiNote);
      _pressedMidiNotes.add(midiNote);
    });
    print("Note ON: $midiNote (${_midiNoteToName(midiNote)}) - Velocity: $velocity");
    
    // Play audio through JUCE engine
    if (synthInitialized) {
      SynthEngine.playNote(midiNote, velocity);
    }
  }
  
  void _onNoteReleased(int midiNote) {
    setState(() {
      _pressedMidiNotes.remove(midiNote);
      if (_pressedMidiNotes.isEmpty) {
        currentNote = "None";
      } else {
        // Show the highest currently pressed note
        currentNote = _midiNoteToName(_pressedMidiNotes.last);
      }
    });
    print("Note OFF: $midiNote (${_midiNoteToName(midiNote)})");
    
    // Stop audio through JUCE engine
    if (synthInitialized) {
      SynthEngine.stopNote(midiNote);
    }
  }
  
  String _midiNoteToName(int midiNote) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    int octave = (midiNote ~/ 12) - 1;
    String noteName = noteNames[midiNote % 12];
    return '$noteName$octave';
  }
  
  // Keyboard input handling
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!synthInitialized) return KeyEventResult.ignored;
    
    final key = event.logicalKey;
    
    // Handle octave shifting
    if (event is KeyDownEvent) {
      if (key == LogicalKeyboardKey.arrowUp && _baseOctave < 8) {
        setState(() {
          _baseOctave++;
        });
        print("Octave shifted up to $_baseOctave");
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown && _baseOctave > 0) {
        setState(() {
          _baseOctave--;
        });
        print("Octave shifted down to $_baseOctave");
        return KeyEventResult.handled;
      }
    }
    
    // Handle note keys
    if (_keyboardMap.containsKey(key)) {
      final noteOffset = _keyboardMap[key]!;
      final midiNote = (_baseOctave * 12) + noteOffset;
      
      if (event is KeyDownEvent) {
        // Prevent key repeat
        if (!_pressedComputerKeys.contains(midiNote)) {
          _pressedComputerKeys.add(midiNote);
          _onNotePressed(midiNote, 0.8);
        }
        return KeyEventResult.handled;
      } else if (event is KeyUpEvent) {
        if (_pressedComputerKeys.contains(midiNote)) {
          _pressedComputerKeys.remove(midiNote);
          _onNoteReleased(midiNote);
        }
        return KeyEventResult.handled;
      }
    }
    
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text('Synth App', style: TextStyle(color: Colors.white)),        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top area - Controls (placeholder for now)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Synth engine status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: synthInitialized ? Colors.green[700] : Colors.red[700],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      synthInitialized ? 'Audio Engine: Connected' : 'Audio Engine: Disconnected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Current Note:',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentNote,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Keyboard instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Controls',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Desktop - Keyboard: A S D F G H J K L ;',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Desktop - Black keys: W E   T Y U   O P [',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Mobile/Tablet: Touch piano keys below',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Octave: ↑↓ arrows  |  Current octave: $_baseOctave',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Tip: Hold keys while changing octave for pedal tones',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom area - Piano keyboard
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PianoKeyboard(
                onNotePressed: _onNotePressed,
                onNoteReleased: _onNoteReleased,
                pressedNotes: _pressedMidiNotes,
                baseOctave: _baseOctave, // Pass the current octave
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class PianoKeyboard extends StatefulWidget {
  final Function(int midiNote, double velocity) onNotePressed;
  final Function(int midiNote) onNoteReleased;
  final Set<int> pressedNotes;
  final int baseOctave;
  
  const PianoKeyboard({
    super.key,
    required this.onNotePressed,
    required this.onNoteReleased,
    required this.pressedNotes,
    required this.baseOctave,
  });

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> {
  final Set<int> _pressedKeys = {};
  late int _startingNote;
  final int _numberOfWhiteKeys = 10; // Extended to match keyboard mapping
  
  // Define which notes are white keys (relative to C)
  final List<int> _whiteKeyOffsets = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16]; // C D E F G A B C D E
  final List<int> _blackKeyOffsets = [1, 3, 6, 8, 10, 13, 15]; // C# D# F# G# A# C# D#
  final List<double> _blackKeyPositions = [0.75, 1.75, 3.75, 4.75, 5.75, 7.75, 8.75]; // Relative positions

  @override
  void initState() {
    super.initState();
    _updateStartingNote();
  }

  @override
  void didUpdateWidget(PianoKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseOctave != widget.baseOctave) {
      _updateStartingNote();
    }
  }

  void _updateStartingNote() {
    _startingNote = widget.baseOctave * 12; // Dynamic based on current octave
  }

  String _midiNoteToName(int midiNote) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    int octave = (midiNote ~/ 12) - 1;
    String noteName = noteNames[midiNote % 12];
    return '$noteName$octave';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border.all(color: Colors.grey[700]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // White keys background
          _buildWhiteKeys(),
          // Black keys overlay
          _buildBlackKeys(),
        ],
      ),
    );
  }
  
  Widget _buildWhiteKeys() {
    return Row(
      children: List.generate(_numberOfWhiteKeys, (index) {
        final midiNote = _startingNote + _whiteKeyOffsets[index];
        final isPressed = _pressedKeys.contains(midiNote) || widget.pressedNotes.contains(midiNote);
        final noteName = _midiNoteToName(midiNote);
        
        return Expanded(
          child: GestureDetector(
            onTapDown: (_) => _handleNotePress(midiNote, 0.8),
            onTapUp: (_) => _handleNoteRelease(midiNote),
            onTapCancel: () => _handleNoteRelease(midiNote),
            onPanDown: (_) => _handleNotePress(midiNote, 0.8),
            onPanEnd: (_) => _handleNoteRelease(midiNote),
            onPanCancel: () => _handleNoteRelease(midiNote),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: isPressed ? Colors.grey[200] : Colors.white,
                border: Border.all(
                  color: Colors.grey[300]!, 
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      noteName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildBlackKeys() {
    final keyboardWidth = MediaQuery.of(context).size.width - 16; // Account for horizontal padding
    final whiteKeyWidth = keyboardWidth / _numberOfWhiteKeys;
    
    return Positioned.fill(
      child: Stack(
        children: List.generate(_blackKeyOffsets.length, (index) {
          final midiNote = _startingNote + _blackKeyOffsets[index];
          final isPressed = _pressedKeys.contains(midiNote) || widget.pressedNotes.contains(midiNote);
          final position = 8 + (_blackKeyPositions[index] * whiteKeyWidth) - (whiteKeyWidth * 0.25);
          
          return Positioned(
            left: position,
            top: 0,
            child: GestureDetector(
              onTapDown: (_) => _handleNotePress(midiNote, 0.8),
              onTapUp: (_) => _handleNoteRelease(midiNote),
              onTapCancel: () => _handleNoteRelease(midiNote),
              onPanDown: (_) => _handleNotePress(midiNote, 0.8),
              onPanEnd: (_) => _handleNoteRelease(midiNote),
              onPanCancel: () => _handleNoteRelease(midiNote),
              child: Container(
                width: whiteKeyWidth * 0.5,
                height: 110,
                decoration: BoxDecoration(
                  color: isPressed ? Colors.grey[700] : Colors.grey[900],
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(3),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  void _handleNotePress(int midiNote, double velocity) {
    if (!_pressedKeys.contains(midiNote)) {
      setState(() {
        _pressedKeys.add(midiNote);
      });
      widget.onNotePressed(midiNote, velocity);
    }
  }
  
  void _handleNoteRelease(int midiNote) {
    if (_pressedKeys.contains(midiNote)) {
      setState(() {
        _pressedKeys.remove(midiNote);
      });
      widget.onNoteReleased(midiNote);
    }
  }
}
