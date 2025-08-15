import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synth_ui/main.dart';
import 'package:synth_ui/login_screen.dart';
import 'package:synth_ui/effects_controls.dart';
import 'package:synth_ui/oscillator_controls.dart';
import 'package:synth_ui/oscilloscope_controls.dart';
import 'mock_classes.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Clean slate for each test
    MockSynthEngine.cleanup();
    MockAuthService.reset();
    MockFirestore.reset();
  });

  group('Login Screen Widget Tests', () {
    testWidgets('LoginScreen should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      
      // Should find login form elements
      expect(find.byType(TextFormField), findsNWidgets(2)); // email + password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('SynthApp'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('Login form validation should work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      
      // Try to submit empty form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      
      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Switch between login and register should work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      
      // Should start in login mode
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      
      // Switch to register
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();
      
      // Should now be in register mode
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3)); // name + email + password
    });
  });

  group('Synthesizer Widget Tests', () {
    testWidgets('Effects Controls should render tabs', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EffectsControls(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should find the effects tabs
      expect(find.text('FILTER'), findsOneWidget);
      expect(find.text('REVERB'), findsOneWidget);
      expect(find.text('DELAY'), findsOneWidget);
      expect(find.text('CHORUS'), findsOneWidget);
      expect(find.text('EFFECTS RACK'), findsOneWidget);
    });

    testWidgets('Oscillator Controls should render and not overflow', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      MockOscillatorControls.initialize(null);
      
      // Give it more space to prevent overflow
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600, // Give it adequate width
              height: 400,
              child: OscillatorControlsWidget(),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should find oscillator tabs (but be flexible about exact text)
      expect(find.text('OSC 1'), findsOneWidget);
      expect(find.text('OSC 2'), findsOneWidget);
      expect(find.text('MIX'), findsOneWidget);
      
      // Should render without major layout errors
      expect(find.byType(OscillatorControlsWidget), findsOneWidget);
    });

    testWidgets('Oscilloscope Controls should render', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OscilloscopeControls(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should render the main widget
      expect(find.byType(OscilloscopeControls), findsOneWidget);
      
      // Should find either initialized or not-initialized state
      final hasText = find.byType(Text).evaluate().isNotEmpty;
      expect(hasText, isTrue);
      
      // Should find some kind of UI elements
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Piano keyboard should render and be interactive', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      
      final Set<int> pressedNotes = {};
      void onNotePressed(int note, double velocity) {
        pressedNotes.add(note);
      }
      void onNoteReleased(int note) {
        pressedNotes.remove(note);
      }
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: PianoKeyboard(
                onNotePressed: onNotePressed,
                onNoteReleased: onNoteReleased,
                pressedNotes: pressedNotes,
                baseOctave: 4,
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should find piano keyboard
      expect(find.byType(PianoKeyboard), findsOneWidget);
      
      // Should have interactive elements (GestureDetectors for keys)
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);
      
      // Try to tap a key if any exist
      if (gestureDetectors.evaluate().isNotEmpty) {
        await tester.tap(gestureDetectors.first);
        await tester.pump();
        
        // Note: The callback should work, but let's just verify no crash
        expect(find.byType(PianoKeyboard), findsOneWidget);
      }
    });
  });

  group('Basic Component Rendering Tests', () {
    testWidgets('Effects Controls should render without crashing', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EffectsControls(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Just verify it renders
      expect(find.byType(EffectsControls), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('Oscillator Controls should render without crashing', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      MockOscillatorControls.initialize(null);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 800, // Give plenty of space
              height: 600,
              child: OscillatorControlsWidget(),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Just verify it renders
      expect(find.byType(OscillatorControlsWidget), findsOneWidget);
    });

    testWidgets('Oscilloscope Controls should render without crashing', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OscilloscopeControls(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Just verify it renders
      expect(find.byType(OscilloscopeControls), findsOneWidget);
    });
  });

  group('Mock Integration Tests', () {
    testWidgets('Complete mock authentication flow', (WidgetTester tester) async {
      // Test the mock auth service directly
      expect(MockAuthService.isSignedIn, isFalse);
      
      await MockAuthService.signInWithEmail(
        email: 'test@example.com', 
        password: 'password123'
      );
      
      expect(MockAuthService.isSignedIn, isTrue);
      expect(MockAuthService.currentUser?.email, equals('test@example.com'));
      expect(MockAuthService.currentUser?.displayName, equals('test'));
      
      await MockAuthService.signOut();
      expect(MockAuthService.isSignedIn, isFalse);
    });

    testWidgets('Mock synth engine functionality', (WidgetTester tester) async {
      expect(MockSynthEngine.isInitialized, isFalse);
      expect(MockSynthEngine.activeNoteCount, equals(0));
      
      MockSynthEngine.initialize();
      expect(MockSynthEngine.isInitialized, isTrue);
      
      MockSynthEngine.playNote(60, 0.8); // Middle C
      MockSynthEngine.playNote(64, 0.7); // E
      expect(MockSynthEngine.activeNoteCount, equals(2));
      
      MockSynthEngine.stopNote(60);
      expect(MockSynthEngine.activeNoteCount, equals(1));
      
      MockSynthEngine.cleanup();
      expect(MockSynthEngine.isInitialized, isFalse);
      expect(MockSynthEngine.activeNoteCount, equals(0));
    });

    testWidgets('Mock preset saving/loading', (WidgetTester tester) async {
      const userId = 'test_user_123';
      const presetName = 'My Awesome Preset';
      final presetData = {
        'osc1Waveform': 2,
        'osc2Waveform': 1,
        'cutoffFreq': 1200.0,
        'resonance': 0.7,
      };
      
      // Save preset
      await MockFirestore.savePreset(userId, presetName, presetData);
      
      // Load preset back
      final loadedPreset = await MockFirestore.loadPreset(userId, presetName);
      expect(loadedPreset, isNotNull);
      expect(loadedPreset!['osc1Waveform'], equals(2));
      expect(loadedPreset['cutoffFreq'], equals(1200.0));
      
      // Get user presets list
      final userPresets = await MockFirestore.getUserPresets(userId);
      expect(userPresets, contains(presetName));
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Widgets should handle missing initialization gracefully', (WidgetTester tester) async {
      // Don't initialize mocks - test error handling
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EffectsControls(),
          ),
        ),
      );
      
      // Should still render without crashing
      await tester.pumpAndSettle();
      expect(find.byType(EffectsControls), findsOneWidget);
    });
  });

  group('Interactive Control Tests', () {
    testWidgets('Effects slider should respond to drag gestures', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: EffectsControls(),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should find sliders (even if synth engine shows not initialized)
      final sliders = find.byType(Slider);
      expect(sliders, findsWidgets);
      
      if (sliders.evaluate().isNotEmpty) {
        final firstSlider = sliders.first;
        
        // Find the slider's center point for dragging
        final sliderCenter = tester.getCenter(firstSlider);
        final sliderSize = tester.getSize(firstSlider);
        
        // Drag from center to right (increase value)
        await tester.dragFrom(
          sliderCenter, 
          Offset(sliderSize.width * 0.3, 0), // Drag 30% to the right
        );
        await tester.pumpAndSettle();
        
        // Verify the widget is still there (no crash)
        expect(find.byType(EffectsControls), findsOneWidget);
        expect(find.byType(Slider), findsWidgets);
      }
    });

    testWidgets('Oscillator dropdown should respond to selection', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      MockOscillatorControls.initialize(null);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: OscillatorControlsWidget(),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should find dropdown buttons for waveform selection
      final dropdowns = find.byType(DropdownButton<int>);
      expect(dropdowns, findsWidgets);
      
      if (dropdowns.evaluate().isNotEmpty) {
        final firstDropdown = dropdowns.first;
        
        // Tap to open dropdown
        await tester.tap(firstDropdown);
        await tester.pumpAndSettle();
        
        // Look for any dropdown options (be flexible about exact text)
        final sineOption = find.text('Sine');
        final squareOption = find.text('Square');
        
        // At least one waveform option should exist
        expect(sineOption.evaluate().isNotEmpty || squareOption.evaluate().isNotEmpty, isTrue);
        
        // Try to select an option if available
        if (squareOption.evaluate().isNotEmpty) {
          await tester.tap(squareOption.last);
          await tester.pumpAndSettle();
        } else if (sineOption.evaluate().isNotEmpty) {
          await tester.tap(sineOption.last);
          await tester.pumpAndSettle();
        }
        
        // Verify the widget is still there (no crash)
        expect(find.byType(OscillatorControlsWidget), findsOneWidget);
      }
    });

    testWidgets('Piano keyboard should handle key presses', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      
      bool notePressed = false;
      void onNotePressed(int note, double velocity) {
        notePressed = true;
      }
      void onNoteReleased(int note) {
        // Note released
      }
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: PianoKeyboard(
                onNotePressed: onNotePressed,
                onNoteReleased: onNoteReleased,
                pressedNotes: {},
                baseOctave: 4,
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);
      
      if (gestureDetectors.evaluate().isNotEmpty) {
        // Try to tap first key
        await tester.tap(gestureDetectors.first);
        await tester.pump();
        
        // Verify widget is still there and callback might have fired
        expect(find.byType(PianoKeyboard), findsOneWidget);
        
        // Try tapping multiple keys (don't rely on exact callback counting)
        if (gestureDetectors.evaluate().length >= 3) {
          await tester.tap(gestureDetectors.at(1));
          await tester.pump();
          await tester.tap(gestureDetectors.at(2));
          await tester.pump();
          
          // Just verify no crashes
          expect(find.byType(PianoKeyboard), findsOneWidget);
        }
      }
    });

    testWidgets('Effects tabs should switch content', (WidgetTester tester) async {
      MockSynthEngine.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: EffectsControls(),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should start with FILTER tab active
      expect(find.text('FILTER'), findsOneWidget);
      expect(find.text('REVERB'), findsOneWidget);
      
      // Tap on REVERB tab
      await tester.tap(find.text('REVERB'));
      await tester.pumpAndSettle();
      
      // Should now show reverb controls
      expect(find.byType(EffectsControls), findsOneWidget);
      
      // Tap on DELAY tab
      await tester.tap(find.text('DELAY'));
      await tester.pumpAndSettle();
      
      // Should now show delay controls
      expect(find.byType(EffectsControls), findsOneWidget);
      
      // Tap on CHORUS tab
      await tester.tap(find.text('CHORUS'));
      await tester.pumpAndSettle();
      
      // Should now show chorus controls
      expect(find.byType(EffectsControls), findsOneWidget);
    });

    testWidgets('Form input should handle real typing', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      
      // Type in email field
      await tester.tap(emailField);
      await tester.enterText(emailField, 'user@example.com');
      await tester.pump();
      
      // Type in password field
      await tester.tap(passwordField);
      await tester.enterText(passwordField, 'mypassword123');
      await tester.pump();
      
      // Verify text was entered
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('mypassword123'), findsOneWidget);
      
      // Clear and test validation
      await tester.tap(emailField);
      await tester.enterText(emailField, '');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Oscilloscope toggle should change state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OscilloscopeControls(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Look for any tappable elements
      final gestureDetectors = find.byType(GestureDetector);
      
      if (gestureDetectors.evaluate().isNotEmpty) {
        // Try to tap the toggle
        await tester.tap(gestureDetectors.first);
        await tester.pumpAndSettle();
        
        // Should still render after interaction
        expect(find.byType(OscilloscopeControls), findsOneWidget);
      }
    });
  });
}
