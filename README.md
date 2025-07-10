# Flutter JUCE Synthesizer

A cross-platform synthesizer application built with Flutter UI and JUCE audio processing, connected via FFI bridge.

## Architecture

```
Flutter UI (Dart) Frontend UI
FFI file (C) Bridge layer between UI and Audio Processing layer
JUCE Audio Engine (C++) Backend for processing audio
TBA Google Firestore (cloud based account management and preset storage)
```

## Project Structure

- **`flutter_ui/`** - Flutter frontend application
- **`juce_audio_engine/`** - JUCE-based audio processing engine
- **`ffi_bridge/`** - C wrapper for Flutter FFI integration

## Features

- Real-time audio synthesis using JUCE
- Cross-platform UI with Flutter
- Low-latency audio processing
- User preset management
- Cloud synchronization (planned)

## Building

### Prerequisites
- CMake 3.15+
- Visual Studio 2022 (Windows)
- Flutter SDK
- Git

### Build Steps

1. **Clone with submodules:**
   ```bash
   git clone --recursive <your-repo-url>
   cd flutter-juce-synthesizer
   ```

2. **Initialize JUCE submodule (if not cloned recursively):**
   ```bash
   cd juce_audio_engine
   git submodule add https://github.com/juce-framework/JUCE.git JUCE
   ```

3. **Build JUCE Audio Engine:**
   ```bash
   cd juce_audio_engine
   cmake -S . -B build
   cmake --build build --config Debug
   ```

4. **Build FFI Bridge:**
   ```bash
   cd ffi_bridge
   cmake -S . -B build
   cmake --build build --config Debug
   ```

5. **Setup Flutter:**
   ```bash
   cd flutter_ui
   flutter pub get
   flutter run
   ```

## Development Timeline

- [x] Project architecture setup
- [x] JUCE audio engine integration
- [x] FFI bridge implementation
- [x] Basic synthesizer functionality
- [ ] Flutter UI implementation
- [ ] Piano keyboard widget
- [ ] User authentication
- [ ] Preset management
- [ ] Cloud synchronization

## License

MIT License - see LICENSE file for details
