import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/auth_service.dart';
import '../firestore/preset_model.dart';
import '../oscillator_controls.dart';
import '../synth_engine.dart';

/*
Class to handle preset management, covering saving
and loading presets.
*/

class PresetService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Save current synth state as a preset
  static Future<void> savePreset(String presetName) async {
    final user = AuthService.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to save presets');
    }

    try {
      // Capture current synth state
      final preset = PresetModel(
        id: '', // Firestore generates this
        name: presetName,
        userId: user.uid,
        createdAt: DateTime.now(),
        
        // Get current oscillator values
        osc1Waveform: _waveformIdToString(OscillatorControls.getOsc1Waveform()),
        osc2Waveform: _waveformIdToString(OscillatorControls.getOsc2Waveform()),
        detune: OscillatorControls.getDetune(),
        oscillatorMix: OscillatorControls.getMix(),

        // Get current filter values
        cutoff: SynthEngine.getCutoff(),
        resonance: SynthEngine.getResonance(),

        // Get current effects values
        reverbEnabled: SynthEngine.isReverbEnabled(),
        reverbRoomSize: SynthEngine.getReverbRoomSize(),
        reverbDamping: SynthEngine.getReverbDamping(),
        reverbWetLevel: SynthEngine.getReverbWetLevel(),
        reverbDryLevel: SynthEngine.getReverbDryLevel(),

        delayEnabled: SynthEngine.isDelayEnabled(),
        delayTime: SynthEngine.getDelayTime(),
        delayFeedback: SynthEngine.getDelayFeedback(),
        delayWetLevel: SynthEngine.getDelayWetLevel(),
        delayDryLevel: SynthEngine.getDelayDryLevel(),

        chorusEnabled: SynthEngine.isChorusEnabled(),
        chorusRate: SynthEngine.getChorusRate(),
        chorusDepth: SynthEngine.getChorusDepth(),
        chorusVoices: SynthEngine.getChorusVoices(),
        chorusFeedback: SynthEngine.getChorusFeedback(),
        chorusWetLevel: SynthEngine.getChorusWetLevel(),
        chorusDryLevel: SynthEngine.getChorusDryLevel(),
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection('presets')
          .add(preset.toJson());

      // Update with the generated ID
      await docRef.update({'id': docRef.id});

      print('Preset "${presetName}" saved successfully!');
      
    } catch (e) {
      print('Failed to save preset: $e');
      rethrow;
    }
  }

  /// Get all presets for the current user
  static Future<List<PresetModel>> getUserPresets() async {
    final user = AuthService.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to load presets');
    }

    try {
      final querySnapshot = await _firestore
          .collection('presets')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PresetModel.fromJson(doc.data()))
          .toList();
          
    } catch (e) {
      print('Failed to load presets: $e');
      rethrow;
    }
  }

  /// Load a preset and apply it to the synth
  static Future<void> loadPreset(PresetModel preset) async {
    try {
      // Apply oscillator settings
      OscillatorControls.setOsc1Waveform(_waveformStringToId(preset.osc1Waveform));
      OscillatorControls.setOsc2Waveform(_waveformStringToId(preset.osc2Waveform));
      OscillatorControls.setDetune(preset.detune);
      OscillatorControls.setOscMix(preset.oscillatorMix);

      // Apply filter settings
      SynthEngine.setCutoffFrequency(preset.cutoff);
      SynthEngine.setResonance(preset.resonance);

      // Apply effects settings
      SynthEngine.enableReverb(preset.reverbEnabled);
      SynthEngine.setReverbRoomSize(preset.reverbRoomSize);
      SynthEngine.setReverbDamping(preset.reverbDamping);
      SynthEngine.setReverbWetLevel(preset.reverbWetLevel);
      SynthEngine.setReverbDryLevel(preset.reverbDryLevel);

      SynthEngine.enableDelay(preset.delayEnabled);
      SynthEngine.setDelayTime(preset.delayTime);
      SynthEngine.setDelayFeedback(preset.delayFeedback);
      SynthEngine.setDelayWetLevel(preset.delayWetLevel);
      SynthEngine.setDelayDryLevel(preset.delayDryLevel);

      SynthEngine.enableChorus(preset.chorusEnabled);
      SynthEngine.setChorusRate(preset.chorusRate);
      SynthEngine.setChorusDepth(preset.chorusDepth);
      SynthEngine.setChorusVoices(preset.chorusVoices);
      SynthEngine.setChorusFeedback(preset.chorusFeedback);
      SynthEngine.setChorusWetLevel(preset.chorusWetLevel);
      SynthEngine.setChorusDryLevel(preset.chorusDryLevel);

      print('Preset "${preset.name}" loaded successfully');
      
    } catch (e) {
      print('Failed to load preset: $e');
      rethrow;
    }
  }

  /// Convert waveform ID to string name
  static String _waveformIdToString(int waveformId) {
    switch (waveformId) {
      case 0: return 'Sine';
      case 1: return 'Square';
      case 2: return 'Sawtooth';
      case 3: return 'Triangle';
      default: return 'Sine'; // Fallback
    }
  }

  /// Convert waveform string name to ID
  static int _waveformStringToId(String waveformName) {
    switch (waveformName.toLowerCase()) {
      case 'sine': return 0;
      case 'square': return 1;
      case 'sawtooth': return 2;
      case 'triangle': return 3;
      default: return 0; // Fallback to sine
    }
  }
}
