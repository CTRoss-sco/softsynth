// Mock Synth Engine for Unit Testing
//
// Provides a fake implementation of the SynthEngine class that doesn't
// require native FFI libraries, allowing widget tests to run without
// the actual JUCE audio engine.

class MockSynthEngine {
  static bool _isInitialized = false;
  static final Set<int> _activeNotes = {};
  static List<double> _waveformData = [];

  /// Mock implementation that always returns true
  static bool initialize() {
    _isInitialized = true;
    print('MockSynthEngine: Initialized');
    return true;
  }

  /// Mock cleanup that resets state
  static void cleanup() {
    _isInitialized = false;
    _activeNotes.clear();
    _waveformData.clear();
  }

  /// Mock note playing - just tracks active notes
  static void playNote(int midiNote, double velocity) {
    if (_isInitialized) {
      _activeNotes.add(midiNote);
    }
  }

  /// Mock note stopping - removes from tracking
  static void stopNote(int midiNote) {
    _activeNotes.remove(midiNote);
  }

  /// Get current state for testing
  static bool get isInitialized => _isInitialized;
  static Set<int> get activeNotes => Set.from(_activeNotes);
  static int get activeNoteCount => _activeNotes.length;

  // Effects methods (for EffectsControls widget)
  static void setCutoffFrequency(double frequency) {
    // Mock implementation - just log the call
    print('MockSynthEngine: Cutoff frequency set to $frequency');
  }
  
  static void setResonance(double resonance) {
    print('MockSynthEngine: Resonance set to $resonance');
  }
  
  static void enableReverb(bool enabled) {
    print('MockSynthEngine: Reverb ${enabled ? "enabled" : "disabled"}');
  }
  
  static void setReverbRoomSize(double size) {
    print('MockSynthEngine: Reverb room size set to $size');
  }
  
  static void setReverbDamping(double damping) {
    print('MockSynthEngine: Reverb damping set to $damping');
  }
  
  static void setReverbWetLevel(double level) {
    print('MockSynthEngine: Reverb wet level set to $level');
  }
  
  static void setReverbDryLevel(double level) {
    print('MockSynthEngine: Reverb dry level set to $level');
  }
  
  static void enableDelay(bool enabled) {
    print('MockSynthEngine: Delay ${enabled ? "enabled" : "disabled"}');
  }
  
  static void setDelayTime(double time) {
    print('MockSynthEngine: Delay time set to $time');
  }
  
  static void setDelayFeedback(double feedback) {
    print('MockSynthEngine: Delay feedback set to $feedback');
  }
  
  static void setDelayWetLevel(double level) {
    print('MockSynthEngine: Delay wet level set to $level');
  }
  
  static void setDelayDryLevel(double level) {
    print('MockSynthEngine: Delay dry level set to $level');
  }
  
  static void enableChorus(bool enabled) {
    print('MockSynthEngine: Chorus ${enabled ? "enabled" : "disabled"}');
  }
  
  static void setChorusRate(double rate) {
    print('MockSynthEngine: Chorus rate set to $rate');
  }
  
  static void setChorusDepth(double depth) {
    print('MockSynthEngine: Chorus depth set to $depth');
  }
  
  static void setChorusVoices(int voices) {
    print('MockSynthEngine: Chorus voices set to $voices');
  }
  
  static void setChorusFeedback(double feedback) {
    print('MockSynthEngine: Chorus feedback set to $feedback');
  }
  
  static void setChorusWetLevel(double level) {
    print('MockSynthEngine: Chorus wet level set to $level');
  }
  
  static void setChorusDryLevel(double level) {
    print('MockSynthEngine: Chorus dry level set to $level');
  }
  
  // Oscilloscope methods (for OscilloscopeControls widget)
  static void enableOscilloscope(bool enabled) {
    if (enabled) {
      // Generate some mock waveform data
      _waveformData = List.generate(100, (i) => 
        0.5 * (i / 100.0) * (2.0 * 3.14159) * 440.0);
    } else {
      _waveformData.clear();
    }
    print('MockSynthEngine: Oscilloscope ${enabled ? "enabled" : "disabled"}');
  }
  
  static List<double> getWaveformData() {
    return List.from(_waveformData);
  }
}

/// Mock Oscillator Controls for widget testing
class MockOscillatorControls {
  static bool _initialized = false;
  
  static bool get initialized => _initialized;
  
  static bool initialize(dynamic library) {
    _initialized = true;
    print('MockOscillatorControls: Initialized');
    return true;
  }
  
  static void setOsc1Waveform(int waveform) {
    print('MockOscillatorControls: Osc1 waveform set to $waveform');
  }
  
  static void setOsc2Waveform(int waveform) {
    print('MockOscillatorControls: Osc2 waveform set to $waveform');
  }
  
  static void setDetune(double cents) {
    print('MockOscillatorControls: Detune set to $cents');
  }
  
  static void setOscMix(double mix) {
    print('MockOscillatorControls: Mix set to $mix');
  }
}

/// Mock Firebase Auth for widget testing
class MockAuthService {
  static bool _isSignedIn = false;
  static MockUser? _currentUser;
  
  static bool get isSignedIn => _isSignedIn;
  static MockUser? get currentUser => _currentUser;
  static Stream<MockUser?> get authStateChanges => Stream.value(_currentUser);
  
  static Future<void> signInWithEmail({
    required String email, 
    required String password
  }) async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 10));
    _isSignedIn = true;
    _currentUser = MockUser(email: email, displayName: email.split('@')[0]);
  }
  
  static Future<void> createUserWithEmail({
    required String email, 
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _isSignedIn = true;
    _currentUser = MockUser(email: email, displayName: displayName);
  }
  
  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 10));
    _isSignedIn = false;
    _currentUser = null;
  }
  
  static void reset() {
    _isSignedIn = false;
    _currentUser = null;
  }
}

/// Mock User class
class MockUser {
  final String email;
  final String displayName;
  
  MockUser({required this.email, required this.displayName});
  
  @override
  String toString() => 'MockUser(email: $email, displayName: $displayName)';
}

/// Mock Firestore for preset saving/loading
class MockFirestore {
  static final Map<String, Map<String, dynamic>> _presets = {};
  
  static Future<void> savePreset(String userId, String presetName, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final key = '${userId}_$presetName';
    _presets[key] = Map.from(data);
    print('MockFirestore: Saved preset $presetName for user $userId');
  }
  
  static Future<Map<String, dynamic>?> loadPreset(String userId, String presetName) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final key = '${userId}_$presetName';
    final preset = _presets[key];
    print('MockFirestore: Loaded preset $presetName for user $userId');
    return preset != null ? Map.from(preset) : null;
  }
  
  static Future<List<String>> getUserPresets(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final userPresets = _presets.keys
        .where((key) => key.startsWith('${userId}_'))
        .map((key) => key.substring(userId.length + 1))
        .toList();
    print('MockFirestore: Found ${userPresets.length} presets for user $userId');
    return userPresets;
  }
  
  static void reset() {
    _presets.clear();
  }
}
