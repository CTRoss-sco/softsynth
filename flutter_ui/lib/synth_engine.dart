import 'dart:ffi';
import 'dart:io';

// FFI bindings for the SynthFFI library
class SynthEngine {
  static late DynamicLibrary _library;
  static late Pointer<Void> _synthHandle;
  
  // Dart function wrappers
  static late Pointer<Void> Function() _synthCreate;
  static late int Function(Pointer<Void>) _synthInitializeAudio;
  static late void Function(Pointer<Void>) _synthDestroy;
  static late void Function(Pointer<Void>, double) _synthSetCutoff;
  static late void Function(Pointer<Void>, int, double) _synthNoteOn;
  static late void Function(Pointer<Void>, int) _synthNoteOff;

  static bool _initialized = false;

  static bool initialize() {
    if (_initialized) return true;

    try {
      // Load the DLL
      if (Platform.isWindows) {
        try {
          // Try current directory first
          _library = DynamicLibrary.open('./SynthFFI.dll');
        } catch (e) {
          try {
            // Try without path prefix
            _library = DynamicLibrary.open('SynthFFI.dll');
          } catch (e) {
            try {
              // Try in the build directory where we copied it
              _library = DynamicLibrary.open('build/windows/x64/runner/Debug/SynthFFI.dll');
            } catch (e) {
              throw Exception('Could not find SynthFFI.dll in any expected location');
            }
          }
        }
      } else {
        throw UnsupportedError('Platform not supported yet');
      }

      // Get function pointers and create Dart function wrappers
      _synthCreate = _library
          .lookup<NativeFunction<Pointer<Void> Function()>>('synth_create')
          .asFunction<Pointer<Void> Function()>();
      
      _synthInitializeAudio = _library
          .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>('synth_initialize_audio')
          .asFunction<int Function(Pointer<Void>)>();
      
      _synthDestroy = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('synth_destroy')
          .asFunction<void Function(Pointer<Void>)>();
      
      _synthSetCutoff = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('synth_set_cutoff')
          .asFunction<void Function(Pointer<Void>, double)>();
      
      _synthNoteOn = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>('synth_note_on')
          .asFunction<void Function(Pointer<Void>, int, double)>();
      
      _synthNoteOff = _library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>('synth_note_off')
          .asFunction<void Function(Pointer<Void>, int)>();

      // Create synth instance
      _synthHandle = _synthCreate();
      
      // Initialize audio
      final audioResult = _synthInitializeAudio(_synthHandle);
      if (audioResult == 0) {
        print('Failed to initialize audio system');
        _synthDestroy(_synthHandle);
        return false;
      }
      
      _initialized = true;
      print('SynthEngine initialized successfully with audio');
      return true;
    } catch (e) {
      print('Failed to initialize SynthEngine: $e');
      return false;
    }
  }

  static void cleanup() {
    if (_initialized && _synthHandle != nullptr) {
      _synthDestroy(_synthHandle);
      _initialized = false;
      print('SynthEngine cleaned up');
    }
  }

  static void playNote(int midiNote, double velocity) {
    if (!_initialized) {
      print('SynthEngine not initialized');
      return;
    }
    _synthNoteOn(_synthHandle, midiNote, velocity);
    print('FFI: Note ON - MIDI: $midiNote, Velocity: $velocity');
  }

  static void stopNote(int midiNote) {
    if (!_initialized) {
      print('SynthEngine not initialized');
      return;
    }
    _synthNoteOff(_synthHandle, midiNote);
    print('FFI: Note OFF - MIDI: $midiNote');
  }

  static void setCutoffFrequency(double cutoff) {
    if (!_initialized) {
      print('SynthEngine not initialized');
      return;
    }
    _synthSetCutoff(_synthHandle, cutoff);
    print('FFI: Cutoff set to $cutoff');
  }
}
