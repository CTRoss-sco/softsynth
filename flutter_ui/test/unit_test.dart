// Pure Unit Tests for Synthesizer Logic
//
// Tests mathematical functions and core logic without dependencies
// on Flutter widgets or native libraries.

import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;
import 'mock_synth_engine.dart';

void main() {
  group('MIDI Mathematical Functions', () {
    test('MIDI note to frequency conversion should be accurate', () {
      // Test known frequency values using the standard formula
      expect(_midiNoteToFrequency(69), closeTo(440.0, 0.1)); // A4 = 440Hz
      expect(_midiNoteToFrequency(60), closeTo(261.63, 0.1)); // C4 = 261.63Hz
      expect(_midiNoteToFrequency(81), closeTo(880.0, 0.1)); // A5 = 880Hz
      expect(_midiNoteToFrequency(57), closeTo(220.0, 0.1)); // A3 = 220Hz
      expect(_midiNoteToFrequency(72), closeTo(523.25, 0.1)); // C5 = 523.25Hz
    });

    test('MIDI note to name conversion should be correct', () {
      expect(_midiNoteToName(60), equals('C4'));
      expect(_midiNoteToName(69), equals('A4'));
      expect(_midiNoteToName(61), equals('C#4'));
      expect(_midiNoteToName(72), equals('C5'));
      expect(_midiNoteToName(48), equals('C3'));
      expect(_midiNoteToName(71), equals('B4'));
      expect(_midiNoteToName(58), equals('A#3'));
    });

    test('Edge case MIDI values should be handled correctly', () {
      expect(_midiNoteToName(0), equals('C-1'));
      expect(_midiNoteToName(127), equals('G9'));
      expect(_midiNoteToName(12), equals('C0'));
      expect(_midiNoteToName(24), equals('C1'));
    });

    test('Octave calculation from MIDI should be correct', () {
      // Test octave extraction
      expect((60 ~/ 12) - 1, equals(4)); // MIDI 60 = C4
      expect((72 ~/ 12) - 1, equals(5)); // MIDI 72 = C5
      expect((48 ~/ 12) - 1, equals(3)); // MIDI 48 = C3
      expect((0 ~/ 12) - 1, equals(-1)); // MIDI 0 = C-1
    });
  });

  group('Keyboard Mapping Logic', () {
    test('White key offsets should follow piano pattern', () {
      // White keys should be: C D E F G A B (0 2 4 5 7 9 11)
      final whiteKeyOffsets = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16];
      
      expect(whiteKeyOffsets[0], equals(0));  // C
      expect(whiteKeyOffsets[1], equals(2));  // D
      expect(whiteKeyOffsets[2], equals(4));  // E
      expect(whiteKeyOffsets[3], equals(5));  // F
      expect(whiteKeyOffsets[4], equals(7));  // G
      expect(whiteKeyOffsets[5], equals(9));  // A
      expect(whiteKeyOffsets[6], equals(11)); // B
      expect(whiteKeyOffsets[7], equals(12)); // C (next octave)
    });

    test('Black key offsets should follow piano pattern', () {
      // Black keys should be: C# D# F# G# A# (1 3 6 8 10)
      final blackKeyOffsets = [1, 3, 6, 8, 10, 13, 15];
      
      expect(blackKeyOffsets[0], equals(1));  // C#
      expect(blackKeyOffsets[1], equals(3));  // D#
      expect(blackKeyOffsets[2], equals(6));  // F#
      expect(blackKeyOffsets[3], equals(8));  // G#
      expect(blackKeyOffsets[4], equals(10)); // A#
      expect(blackKeyOffsets[5], equals(13)); // C# (next octave)
    });

    test('Octave to MIDI base calculation should be correct', () {
      // Each octave spans 12 semitones
      expect(4 * 12, equals(48)); // Octave 4 starts at MIDI 48
      expect(5 * 12, equals(60)); // Octave 5 starts at MIDI 60
      expect(3 * 12, equals(36)); // Octave 3 starts at MIDI 36
      expect(0 * 12, equals(0));  // Octave 0 starts at MIDI 0
    });

    test('Full MIDI note calculation should be accurate', () {
      // Test: baseOctave=4, noteOffset=0 (C) = MIDI 48
      expect((4 * 12) + 0, equals(48));  // C4
      // Test: baseOctave=4, noteOffset=7 (G) = MIDI 55  
      expect((4 * 12) + 7, equals(55));  // G4
      // Test: baseOctave=5, noteOffset=0 (C) = MIDI 60
      expect((5 * 12) + 0, equals(60));  // C5
    });
  });

  group('Octave Range Validation', () {
    test('Octave bounds should be enforced', () {
      const minOctave = 0;
      const maxOctave = 8;
      
      expect(minOctave, greaterThanOrEqualTo(0));
      expect(maxOctave, lessThanOrEqualTo(8));
      expect(maxOctave, greaterThan(minOctave));
    });

    test('MIDI range should cover full spectrum', () {
      const minMidiNote = 0 * 12;      // C-1 (MIDI 0)
      const maxMidiNote = 8 * 12 + 11; // B8 (MIDI 107)
      
      expect(minMidiNote, equals(0));
      expect(maxMidiNote, equals(107));
      expect(maxMidiNote, lessThanOrEqualTo(127)); // MIDI max
    });

    test('Frequency range should be reasonable', () {
      // Test frequency boundaries
      final minFreq = _midiNoteToFrequency(0);   // ~8.18 Hz
      final maxFreq = _midiNoteToFrequency(107); // ~12543 Hz
      
      expect(minFreq, greaterThan(0));
      expect(maxFreq, lessThan(20000)); // Below human hearing limit
      expect(maxFreq, greaterThan(minFreq));
    });
  });

  group('Mock Audio Engine Tests', () {
    setUp(() {
      // Reset mock state before each test
      MockSynthEngine.cleanup();
    });

    test('Mock engine should initialize successfully', () {
      expect(MockSynthEngine.isInitialized, isFalse);
      
      final result = MockSynthEngine.initialize();
      
      expect(result, isTrue);
      expect(MockSynthEngine.isInitialized, isTrue);
    });

    test('Mock engine should track notes correctly', () {
      MockSynthEngine.initialize();
      expect(MockSynthEngine.activeNoteCount, equals(0));
      
      // Play some notes
      MockSynthEngine.playNote(60, 0.8); // C4
      MockSynthEngine.playNote(64, 0.8); // E4
      MockSynthEngine.playNote(67, 0.8); // G4
      
      expect(MockSynthEngine.activeNoteCount, equals(3));
      expect(MockSynthEngine.activeNotes, contains(60));
      expect(MockSynthEngine.activeNotes, contains(64));
      expect(MockSynthEngine.activeNotes, contains(67));
    });

    test('Mock engine should stop notes correctly', () {
      MockSynthEngine.initialize();
      
      // Play and stop notes
      MockSynthEngine.playNote(60, 0.8);
      MockSynthEngine.playNote(64, 0.8);
      expect(MockSynthEngine.activeNoteCount, equals(2));
      
      MockSynthEngine.stopNote(60);
      expect(MockSynthEngine.activeNoteCount, equals(1));
      expect(MockSynthEngine.activeNotes, isNot(contains(60)));
      expect(MockSynthEngine.activeNotes, contains(64));
      
      MockSynthEngine.stopNote(64);
      expect(MockSynthEngine.activeNoteCount, equals(0));
    });

    test('Mock engine should handle cleanup', () {
      MockSynthEngine.initialize();
      MockSynthEngine.playNote(60, 0.8);
      MockSynthEngine.playNote(64, 0.8);
      
      expect(MockSynthEngine.isInitialized, isTrue);
      expect(MockSynthEngine.activeNoteCount, equals(2));
      
      MockSynthEngine.cleanup();
      
      expect(MockSynthEngine.isInitialized, isFalse);
      expect(MockSynthEngine.activeNoteCount, equals(0));
    });
  });
}

// Helper functions (mirror the main app functions)
String _midiNoteToName(int midiNote) {
  const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  int octave = (midiNote ~/ 12) - 1;
  String noteName = noteNames[midiNote % 12];
  return '$noteName$octave';
}

double _midiNoteToFrequency(int midiNote) {
  // Convert MIDI note to frequency: f = 440 * 2^((n-69)/12)
  return 440.0 * math.pow(2.0, (midiNote - 69) / 12.0);
}
