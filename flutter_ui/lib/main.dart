import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'synth_engine.dart';
import 'oscillator_controls.dart'; 
import 'effects_controls.dart';
import 'effects_engine.dart';
import 'oscilloscope_controls.dart';
import 'firebase/firebase_init.dart';
import 'firebase/auth_service.dart';
import 'login_screen.dart';
import 'firestore/preset_service.dart';
import 'firestore/preset_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.initialize();

  await SynthEngine.initialize();

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
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1a1a1a),
                    Color(0xFF2d2d2d),
                    Color(0xFF1a1a1a),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
              ),
            ),
          );
        }
        
        // If user is signed in, show synth screen
        if (snapshot.hasData && snapshot.data != null) {
          return const SynthMainScreen();
        }
        
        // Otherwise, show login screen
        return const LoginScreen();
      },
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
    EffectsEngine.shutdown();
    super.dispose();
  }
  
  void _initializeSynth() async {
    bool success = SynthEngine.initialize();
    if (success) {
      // Initialize oscillator controls after SynthEngine
      bool oscSuccess = OscillatorControls.initialize(SynthEngine.library);
      
      // ADD THIS: Initialize effects engine
      bool effectsSuccess = EffectsEngine.initialize();
      if (effectsSuccess) {
        print('Effects Engine initialized successfully!');
      } else {
        print('Effects unavailable, but synth still works');
      }
      
      if (oscSuccess) {
        setState(() {
          synthInitialized = true;
        });
        print('SynthEngine and OscillatorControls initialized successfully');
      } else {
        print('Failed to initialize OscillatorControls');
      }
    } else {
      print('Failed to initialize SynthEngine');
    }
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
          title: const Text('Synth App', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          elevation: 0,
          actions: [
            if (AuthService.isSignedIn) ...[
              //Save Preset Button
              IconButton(
                icon: const Icon(Icons.save, color: Colors.deepOrange),
                onPressed: _showSavePresetDialog,
                tooltip: 'Save Current Preset',
              ),
              
              //Load Preset Button  
              IconButton(
                icon: const Icon(Icons.folder_open, color: Colors.deepOrange),
                onPressed: _showLoadPresetDialog,
                tooltip: 'Load Preset',
              ),
              
              // User greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    'Hello, ${AuthService.currentUser?.displayName ?? AuthService.currentUser?.email?.split('@')[0] ?? 'User'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              
              //Logout Button
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.deepOrange),
                onPressed: () async {
                  await AuthService.signOut();
                  // AuthWrapper will automatically redirect to login
                },
                tooltip: 'Sign Out',
              ),
            ],
          ]
        ),
        body: Column(
          children: [
            // Top section - 3-column synthesizer layout
            if (synthInitialized)
              Expanded(
                flex: 3, // Takes up most of the screen
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Left column - Oscillator controls
                      Expanded(
                        flex: 1,
                        child: const OscillatorControlsWidget(),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Middle column - Effects rack (NEW!)
                      Expanded(
                        flex: 1,
                        child: const EffectsControls(), // Your new effects widget
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Right column - Future oscilloscope
                      Expanded(
                        flex: 1,
                        child: OscilloscopeControls(),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Status display (moved to top bar area)
            if (synthInitialized)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  border: Border(
                    top: BorderSide(color: Colors.grey[700]!),
                    bottom: BorderSide(color: Colors.grey[700]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Note: $currentNote',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Octave: $_baseOctave',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Text(
                      '↑↓ arrows: Change octave',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            
            // Piano keyboard at bottom (unchanged)
            Container(
              height: 200,
              child: synthInitialized 
                  ? _buildPianoKeyboard()
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPianoKeyboard() {
    return PianoKeyboard(
      onNotePressed: _onNotePressed,
      onNoteReleased: _onNoteReleased,
      pressedNotes: _pressedMidiNotes,
      baseOctave: _baseOctave,
    );
  }
  
  void _showSavePresetDialog() {
    if (!AuthService.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save presets')),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Save Preset', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a name for your preset:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'My Awesome Preset',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              
              try {
                Navigator.pop(context);
                await PresetService.savePreset(name);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preset "$name" saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save preset: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoadPresetDialog() {
    if (!AuthService.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to load presets')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Load Preset', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder<List<PresetModel>>(
            future: PresetService.getUserPresets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading presets: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final presets = snapshot.data ?? [];
              
              if (presets.isEmpty) {
                return const Center(
                  child: Text(
                    'No presets saved yet.\nCreate your first preset!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  return Card(
                    color: Colors.grey[800],
                    child: ListTile(
                      leading: const Icon(Icons.library_music, color: Colors.deepOrange),
                      title: Text(
                        preset.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Created: ${preset.createdAt.day}/${preset.createdAt.month}/${preset.createdAt.year}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      onTap: () async {
                        try {
                          Navigator.pop(context);
                          await PresetService.loadPreset(preset);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Preset "${preset.name}" loaded successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to load preset: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
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
