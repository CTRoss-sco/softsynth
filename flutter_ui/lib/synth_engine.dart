import 'dart:ffi';
import 'dart:io';

// FFI bindings for the SynthFFI library
class SynthEngine {
  static late DynamicLibrary _library;
  static late Pointer<Void> _synthInstance;
  
  // Dart function wrappers
  static late Pointer<Void> Function() _synthCreate;
  static late int Function(Pointer<Void>) _synthInitializeAudio;
  static late void Function(Pointer<Void>) _synthDestroy;
  static late void Function(Pointer<Void>, double) _synthSetCutoff;
  static late void Function(Pointer<Void>, int, double) _synthNoteOn;
  static late void Function(Pointer<Void>, int) _synthNoteOff;
  static late void Function(Pointer<Void>, double) _synthSetResonance;

  static bool _initialized = false;

  static bool initialize() {
    if (_initialized) return true;

    try {
      print('🔍 Starting SynthEngine initialization...');
      
      // Load the DLL
      if (Platform.isWindows) {
        try {
          print('🔍 Trying ./SynthFFI.dll...');
          _library = DynamicLibrary.open('./SynthFFI.dll');
          print('✅ Loaded DLL from ./SynthFFI.dll');
        } catch (e) {
          print('❌ Failed ./SynthFFI.dll: $e');
          try {
            print('🔍 Trying SynthFFI.dll...');
            _library = DynamicLibrary.open('SynthFFI.dll');
            print('✅ Loaded DLL from SynthFFI.dll');
          } catch (e) {
            print('❌ Failed SynthFFI.dll: $e');
            try {
              print('🔍 Trying build/windows/x64/runner/Debug/SynthFFI.dll...');
              _library = DynamicLibrary.open('build/windows/x64/runner/Debug/SynthFFI.dll');
              print('✅ Loaded DLL from build path');
            } catch (e) {
              print('❌ Failed build path: $e');
              throw Exception('Could not find SynthFFI.dll in any expected location');
            }
          }
        }
      } else {
        throw UnsupportedError('Platform not supported yet');
      }

      // Get function pointers and create Dart function wrappers
      print('🔍 Looking up synth_create...');
      _synthCreate = _library
          .lookup<NativeFunction<Pointer<Void> Function()>>('synth_create')
          .asFunction<Pointer<Void> Function()>();
      print('✅ Found synth_create');
      
      print('🔍 Looking up synth_initialize_audio...');
      _synthInitializeAudio = _library
          .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('synth_initialize_audio')
          .asFunction<int Function(Pointer<Void>)>();
      print('✅ Found synth_initialize_audio');
      
      print('🔍 Looking up synth_destroy...');
      _synthDestroy = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('synth_destroy')
          .asFunction<void Function(Pointer<Void>)>();
      print('✅ Found synth_destroy');
      
      print('🔍 Looking up synth_set_cutoff...');
      _synthSetCutoff = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('synth_set_cutoff')
          .asFunction<void Function(Pointer<Void>, double)>();
      print('✅ Found synth_set_cutoff');
      
      print('🔍 Looking up synth_note_on...');
      _synthNoteOn = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>('synth_note_on')
          .asFunction<void Function(Pointer<Void>, int, double)>();
      print('✅ Found synth_note_on');
      
      print('🔍 Looking up synth_note_off...');
      _synthNoteOff = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>('synth_note_off')
          .asFunction<void Function(Pointer<Void>, int)>();
      print('✅ Found synth_note_off');

      print('🔍 Looking up synth_set_filter_resonance...');
      _synthSetResonance = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('synth_set_filter_resonance')
          .asFunction<void Function(Pointer<Void>, double)>();
      print('✅ Found synth_set_filter_resonance!');

      // Create synth instance
      print('🔍 Creating synth instance...');
      _synthInstance = _synthCreate();
      print('✅ Created synth instance');
      
      // Initialize audio
      print('🔍 Initializing audio...');
      final audioResult = _synthInitializeAudio(_synthInstance);
      if (audioResult == 0) {
        print('❌ Failed to initialize audio system');
        _synthDestroy(_synthInstance);
        return false;
      }
      print('✅ Audio initialized successfully');
      
      _initialized = true;
      print('🎉 SynthEngine initialized successfully with audio');
      return true;
    } catch (e) {
      print('❌ Failed to initialize SynthEngine: $e');
      return false;
    }
  }

  static void cleanup() {
    if (_initialized && _synthInstance != nullptr) {
      _synthDestroy(_synthInstance);
      _initialized = false;
      print('SynthEngine cleaned up');
    }
  }

  static void playNote(int midiNote, double velocity) {
    if (!_initialized) {
      print('SynthEngine not initialized');
      return;
    }
    _synthNoteOn(_synthInstance, midiNote, velocity);
    print('FFI: Note ON - MIDI: $midiNote, Velocity: $velocity');
  }

  static void stopNote(int midiNote) {
    if (!_initialized) {
      print('SynthEngine not initialized');
      return;
    }
    _synthNoteOff(_synthInstance, midiNote);
    print('FFI: Note OFF - MIDI: $midiNote');
  }

  static void setCutoffFrequency(double cutoff) {
    if (!_initialized) {
      print('SynthEngine not initialized');
      return;
    }
    _synthSetCutoff(_synthInstance, cutoff);
    print('FFI: Cutoff set to $cutoff');
  }

  static void setResonance(double resonance) {
    if (!_initialized) {
      print('SynthEngine not initialized');
      return;
    }
    _synthSetResonance(_synthInstance, resonance);
    print('FFI: Resonance set to $resonance');
  }

  // Add these getters for OscillatorControls to access
  static DynamicLibrary get library => _library;
  static Pointer<Void> get synthHandle => _synthInstance;
  static bool get isInitialized => _initialized;
}
