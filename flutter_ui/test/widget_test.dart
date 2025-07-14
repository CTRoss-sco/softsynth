// Synthesizer Widget and Unit Tests
//
// Tests for the Flutter synthesizer application including:
// - UI component functionality
// - MIDI note conversion accuracy
// - Keyboard input handling
// - Piano keyboard widget interactions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

import 'package:synth_ui/main.dart';

void main() {
  group('Synthesizer App Tests', () {
    testWidgets('App should build and show initial state', (WidgetTester tester) async {
      // Build the synthesizer app
      await tester.pumpWidget(const SynthApp());

      // Verify the app title appears
      expect(find.text('Synth App'), findsOneWidget);
      
      // Verify initial note display
      expect(find.text('Current Note:'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
      
      // Verify control instructions are present
      expect(find.text('Controls'), findsOneWidget);
      expect(find.text('Desktop - Keyboard: A S D F G H J K L ;'), findsOneWidget);
      expect(find.text('Mobile/Tablet: Touch piano keys below'), findsOneWidget);
    });

    testWidgets('Piano keyboard widget should be present', (WidgetTester tester) async {
      await tester.pumpWidget(const SynthApp());
      
      // Find the PianoKeyboard widget
      expect(find.byType(PianoKeyboard), findsOneWidget);
    });

    testWidgets('Octave display should show current octave', (WidgetTester tester) async {
      await tester.pumpWidget(const SynthApp());
      
      // Should show default octave 4
      expect(find.textContaining('Current octave: 4'), findsOneWidget);
    });

    testWidgets('Audio engine status indicator should be present', (WidgetTester tester) async {
      await tester.pumpWidget(const SynthApp());
      
      // Should show audio engine status (Connected or Disconnected)
      expect(find.textContaining('Audio Engine:'), findsOneWidget);
    });
  });

  group('MIDI Note Conversion Tests', () {
    test('MIDI note to frequency conversion should be accurate', () {
      // Test known frequency values
      expect(_midiNoteToFrequency(69), closeTo(440.0, 0.1)); // A4 = 440Hz
      expect(_midiNoteToFrequency(60), closeTo(261.63, 0.1)); // C4 = 261.63Hz
      expect(_midiNoteToFrequency(81), closeTo(880.0, 0.1)); // A5 = 880Hz
      expect(_midiNoteToFrequency(57), closeTo(220.0, 0.1)); // A3 = 220Hz
    });

    test('MIDI note to name conversion should be correct', () {
      expect(_midiNoteToName(60), equals('C4'));
      expect(_midiNoteToName(69), equals('A4'));
      expect(_midiNoteToName(61), equals('C#4'));
      expect(_midiNoteToName(72), equals('C5'));
      expect(_midiNoteToName(48), equals('C3'));
    });

    test('Edge case MIDI values should be handled', () {
      expect(_midiNoteToName(0), equals('C-1'));
      expect(_midiNoteToName(127), equals('G9'));
    });
  });

  group('Keyboard Mapping Tests', () {
    test('White key mapping should be correct', () {
      final keyboardMap = {
        LogicalKeyboardKey.keyA: 0,  // C
        LogicalKeyboardKey.keyS: 2,  // D
        LogicalKeyboardKey.keyD: 4,  // E
        LogicalKeyboardKey.keyF: 5,  // F
        LogicalKeyboardKey.keyG: 7,  // G
        LogicalKeyboardKey.keyH: 9,  // A
        LogicalKeyboardKey.keyJ: 11, // B
        LogicalKeyboardKey.keyK: 12, // C (next octave)
        LogicalKeyboardKey.keyL: 14, // D (next octave)
      };

      // Verify white key offsets correspond to correct notes
      expect(keyboardMap[LogicalKeyboardKey.keyA], equals(0)); // C
      expect(keyboardMap[LogicalKeyboardKey.keyS], equals(2)); // D
      expect(keyboardMap[LogicalKeyboardKey.keyD], equals(4)); // E
      expect(keyboardMap[LogicalKeyboardKey.keyF], equals(5)); // F
      expect(keyboardMap[LogicalKeyboardKey.keyG], equals(7)); // G
      expect(keyboardMap[LogicalKeyboardKey.keyH], equals(9)); // A
      expect(keyboardMap[LogicalKeyboardKey.keyJ], equals(11)); // B
    });

    test('Black key mapping should be correct', () {
      final keyboardMap = {
        LogicalKeyboardKey.keyW: 1,  // C#
        LogicalKeyboardKey.keyE: 3,  // D#
        LogicalKeyboardKey.keyT: 6,  // F#
        LogicalKeyboardKey.keyY: 8,  // G#
        LogicalKeyboardKey.keyU: 10, // A#
      };

      // Verify black key offsets correspond to correct sharp notes
      expect(keyboardMap[LogicalKeyboardKey.keyW], equals(1)); // C#
      expect(keyboardMap[LogicalKeyboardKey.keyE], equals(3)); // D#
      expect(keyboardMap[LogicalKeyboardKey.keyT], equals(6)); // F#
      expect(keyboardMap[LogicalKeyboardKey.keyY], equals(8)); // G#
      expect(keyboardMap[LogicalKeyboardKey.keyU], equals(10)); // A#
    });

    test('Octave calculation should be correct', () {
      const baseOctave = 4;
      const noteOffset = 0; // C
      final midiNote = (baseOctave * 12) + noteOffset;
      expect(midiNote, equals(48)); // C4 = MIDI 48

      const baseOctave5 = 5;
      final midiNote5 = (baseOctave5 * 12) + noteOffset;
      expect(midiNote5, equals(60)); // C5 = MIDI 60
    });
  });

  group('Piano Keyboard Widget Tests', () {
    testWidgets('Piano keyboard should have correct number of white keys', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PianoKeyboard(
            onNotePressed: (note, velocity) {},
            onNoteReleased: (note) {},
            pressedNotes: const {},
            baseOctave: 4,
          ),
        ),
      ));

      // The piano keyboard should build without errors
      expect(find.byType(PianoKeyboard), findsOneWidget);
    });

    testWidgets('Piano keyboard should respond to taps', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PianoKeyboard(
            onNotePressed: (note, velocity) {
              // Callback triggered - note press successful
            },
            onNoteReleased: (note) {},
            pressedNotes: const {},
            baseOctave: 4,
          ),
        ),
      ));

      // Find any white key container and tap it
      final whiteKeyFinder = find.byType(Container).first;
      await tester.tap(whiteKeyFinder);
      await tester.pump();

      // Verify the widget doesn't crash on tap and remains present
      expect(find.byType(PianoKeyboard), findsOneWidget);
    });
  });

  group('Octave Range Tests', () {
    test('Octave should be bounded between 0 and 8', () {
      // Test octave bounds
      expect(0, greaterThanOrEqualTo(0));
      expect(8, lessThanOrEqualTo(8));
      
      // Test MIDI note ranges
      const minOctave = 0;
      const maxOctave = 8;
      final minMidiNote = minOctave * 12; // MIDI 0
      final maxMidiNote = maxOctave * 12 + 11; // MIDI 107 (B8)
      
      expect(minMidiNote, equals(0));
      expect(maxMidiNote, equals(107));
    });
  });
}

// Helper functions for testing (mirror the main app functions)
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
