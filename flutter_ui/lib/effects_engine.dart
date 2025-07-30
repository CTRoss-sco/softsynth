// Create: flutter_ui/lib/effects_engine.dart
import 'dart:ffi';
import 'dart:io';

class EffectsEngine {
  static late DynamicLibrary _effectsLibrary;
  static late Pointer<Void> _effectsInstance;
  static bool _initialized = false;
  
  // Function pointers
  static late Pointer<Void> Function() _effectsCreate;
  static late void Function(Pointer<Void>) _effectsDestroy;
  static late void Function(Pointer<Void>, double) _effectsSetSampleRate;
  static late void Function(Pointer<Void>) _effectsReset;
  static late void Function(Pointer<Void>, double) _setReverbRoomSize;
  static late void Function(Pointer<Void>, double) _setReverbDamping;
  static late void Function(Pointer<Void>, double) _setReverbWetLevel;
  static late void Function(Pointer<Void>, double) _setReverbDryLevel;
  static late void Function(Pointer<Void>, Pointer<Float>, int) _processAudio;
  
  static bool initialize() {
    if (_initialized) return true;
    
    try {
      print('🌊 Initializing Effects Engine...');
      
      // Try to load EffectsFHI.dll
      try {
        _effectsLibrary = DynamicLibrary.open('./EffectsFHI.dll');
        print('Loaded EffectsFHI.dll from current directory');
      } catch (e) {
        print('Failed to load EffectsFHI.dll: $e');
        return false; // Effects unavailable, but synth still works!
      }
      
      // Lookup functions
      _effectsCreate = _effectsLibrary
          .lookup<NativeFunction<Pointer<Void> Function()>>('effects_create')
          .asFunction<Pointer<Void> Function()>();
      
      _effectsDestroy = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('effects_destroy')
          .asFunction<void Function(Pointer<Void>)>();
      
      _effectsSetSampleRate = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>, Double)>>('effects_set_sample_rate')
          .asFunction<void Function(Pointer<Void>, double)>();
      
      _effectsReset = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('effects_reset')
          .asFunction<void Function(Pointer<Void>)>();
      
      _setReverbRoomSize = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('effects_set_reverb_room_size')
          .asFunction<void Function(Pointer<Void>, double)>();
      
      _setReverbDamping = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('effects_set_reverb_damping')
          .asFunction<void Function(Pointer<Void>, double)>();
      
      _setReverbWetLevel = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('effects_set_reverb_wet_level')
          .asFunction<void Function(Pointer<Void>, double)>();
      
      _setReverbDryLevel = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('effects_set_reverb_dry_level')
          .asFunction<void Function(Pointer<Void>, double)>();

      _processAudio = _effectsLibrary
          .lookup<NativeFunction<Void Function(Pointer<Void>, Pointer<Float>, Int32)>>('effects_process_audio')
          .asFunction<void Function(Pointer<Void>, Pointer<Float>, int)>();
      
      // Create effects instance
      _effectsInstance = _effectsCreate();
      _effectsSetSampleRate(_effectsInstance, 44100.0);
      _initialized = true;
      
      print('Effects Engine initialized successfully with reverb!');
      return true;
    } catch (e) {
      print('Effects unavailable: $e');
      return false; // Synth still works without effects!
    }
  }
  
  static bool get isInitialized => _initialized;
  
  static void setReverbRoomSize(double roomSize) {
    if (!_initialized) return;
    _setReverbRoomSize(_effectsInstance, roomSize.clamp(0.0, 1.0));
  }
  
  static void setReverbDamping(double damping) {
    if (!_initialized) return;
    _setReverbDamping(_effectsInstance, damping.clamp(0.0, 1.0));
  }
  
  static void setReverbWetLevel(double wetLevel) {
    if (!_initialized) return;
    _setReverbWetLevel(_effectsInstance, wetLevel.clamp(0.0, 1.0));
  }
  
  static void setReverbDryLevel(double dryLevel) {
    if (!_initialized) return;
    _setReverbDryLevel(_effectsInstance, dryLevel.clamp(0.0, 1.0));
  }
  
  static void reset() {
    if (!_initialized) return;
    _effectsReset(_effectsInstance);
  }
  
  static void shutdown() {
    if (!_initialized) return;
    _effectsDestroy(_effectsInstance);
    _initialized = false;
  }

  static void processAudioBuffer(Pointer<Float> buffer, int numSamples) {
    if (!_initialized) return;
    _processAudio(_effectsInstance, buffer, numSamples);
  }
}