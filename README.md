# Flutter JUCE Synthesizer

A synthesizer application built with Flutter UI and JUCE/C++ audio processing, connected via a FFI bridge.

## Architecture

```
Flutter UI (Dart) Frontend UI
FFI file (C) Bridge layer between UI and Audio Processing layer
JUCE Audio Engine (C++) Backend for processing audio
Google Firestore (cloud based account management and preset storage)
```

## Project Structure

- **`flutter_ui/`** - Flutter frontend application
- **`juce_audio_engine/`** - JUCE/C++ audio processing engine
- **`ffi_bridge/`** - C wrapper for Flutter FFI integration

### Prerequisite Tools/Frameworks
- CMake 3.15+ (installed and added to PATH)
- Visual Studio 2022 (Windows)
- Flutter SDK
- Git

### Build Steps

1. **Initialize JUCE submodule**
   ```bash
   cd juce_audio_engine
   git submodule add https://github.com/juce-framework/JUCE.git JUCE
   ```

2. **Build SynthFFI and SynthEngine dll files:**
   ```bash
   cd ffi_bridge
   cmake -S . -B build
   cmake --build build --config Debug
   ```

3. **Copy dlls over to Flutter directory**

   Copy both created dll files (SynthFFI.dll and SynthEngine.dll)
   over to the flutter_ui/build/windows/x64/runner/Debug directory

4. **Setup Flutter:**
   ```bash
   cd flutter_ui
   flutter pub get
   flutter run -d windows
   ```

## User Controls
   This application supports touchscreen controls and computer keyboard and mouse
   input controls. For the synthesizer onscreen keyboard, the keys are mapped as follows:
   
   WHITE KEYS: A, S, D, F, G, H , J, K, L, ;
   BLACK KEYS: W, E, T, Y, U, O, P
