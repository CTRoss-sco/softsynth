// Mock Synth Engine for Unit Testing
//
// Provides a fake implementation of the SynthEngine class that doesn't
// require native FFI libraries, allowing widget tests to run without
// the actual JUCE audio engine.

class MockSynthEngine {
  static bool _isInitialized = false;
  static final Set<int> _activeNotes = {};

  /// Mock implementation that always returns true
  static bool initialize() {
    _isInitialized = true;
    return true;
  }

  /// Mock cleanup that resets state
  static void cleanup() {
    _isInitialized = false;
    _activeNotes.clear();
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
}
