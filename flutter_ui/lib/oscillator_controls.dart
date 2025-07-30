import 'dart:ffi';
import 'package:flutter/material.dart';
import 'synth_engine.dart';

// Oscillator control extensions for SynthEngine
class OscillatorControls {
  // New dual oscillator function wrappers
  static late void Function(Pointer<Void>, int) _synthSetOsc1Waveform;
  static late void Function(Pointer<Void>, int) _synthSetOsc2Waveform;
  static late void Function(Pointer<Void>, double) _synthSetDetune;
  static late void Function(Pointer<Void>, double) _synthSetOscMix;

  static bool _initialized = false;

  static bool initialize(DynamicLibrary library) {
    if (_initialized) return true;

    try {
      // Get new dual oscillator function pointers
      _synthSetOsc1Waveform = library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>('synth_set_osc1_waveform')
          .asFunction<void Function(Pointer<Void>, int)>();
      
      _synthSetOsc2Waveform = library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>('synth_set_osc2_waveform')
          .asFunction<void Function(Pointer<Void>, int)>();
      
      _synthSetDetune = library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('synth_set_detune')
          .asFunction<void Function(Pointer<Void>, double)>();
      
      _synthSetOscMix = library
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>('synth_set_osc_mix')
          .asFunction<void Function(Pointer<Void>, double)>();

      _initialized = true;
      print('OscillatorControls initialized successfully');
      return true;
    } catch (e) {
      print('Failed to initialize OscillatorControls: $e');
      return false;
    }
  }

  // Oscillator control methods
  static void setOsc1Waveform(int waveform) {
    if (!_initialized || !SynthEngine.isInitialized) return;
    _synthSetOsc1Waveform(SynthEngine.synthHandle, waveform);
    print('FFI: Osc1 waveform set to ${Waveforms.getName(waveform)}');
  }

  static void setOsc2Waveform(int waveform) {
    if (!_initialized || !SynthEngine.isInitialized) return;
    _synthSetOsc2Waveform(SynthEngine.synthHandle, waveform);
    print('FFI: Osc2 waveform set to ${Waveforms.getName(waveform)}');
  }

  static void setDetune(double cents) {
    if (!_initialized || !SynthEngine.isInitialized) return;
    _synthSetDetune(SynthEngine.synthHandle, cents);
    print('FFI: Detune set to $cents cents');
  }

  static void setOscMix(double mix) {
    if (!_initialized || !SynthEngine.isInitialized) return;
    _synthSetOscMix(SynthEngine.synthHandle, mix);
    print('FFI: Oscillator mix set to $mix');
  }
}

// Waveform constants and utilities
class Waveforms {
  static const int sine = 0;
  static const int square = 1;
  static const int saw = 2;
  static const int triangle = 3;

  static String getName(int waveform) {
    switch (waveform) {
      case sine: return 'Sine';
      case square: return 'Square';
      case saw: return 'Saw';
      case triangle: return 'Triangle';
      default: return 'Unknown';
    }
  }

  static List<String> get allNames => ['Sine', 'Square', 'Saw', 'Triangle'];
  static List<int> get allValues => [sine, square, saw, triangle];
}

// UI Widget for Oscillator Controls
class OscillatorControlsWidget extends StatefulWidget {
  const OscillatorControlsWidget({Key? key}) : super(key: key);

  @override
  State<OscillatorControlsWidget> createState() => _OscillatorControlsWidgetState();
}

class _OscillatorControlsWidgetState extends State<OscillatorControlsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Current parameter values
  int _osc1Waveform = Waveforms.sine;
  int _osc2Waveform = Waveforms.sine;
  double _detune = 0.0; // -100 to +100 cents
  double _oscMix = 0.0; // Start with OSC1 only
  bool _osc2Enabled = false; // OSC2 starts disabled

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeOscillators();
  }

  void _initializeOscillators() {
    // Start with OSC1 only, OSC2 disabled
    OscillatorControls.setOsc1Waveform(_osc1Waveform);
    OscillatorControls.setOsc2Waveform(_osc2Waveform);
    OscillatorControls.setDetune(_detune);
    OscillatorControls.setOscMix(_oscMix); // 0.0 = OSC1 only
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleOsc2() {
    setState(() {
      _osc2Enabled = !_osc2Enabled;
      if (_osc2Enabled) {
        // When enabling OSC2, set mix to 50/50
        _oscMix = 0.5;
      } else {
        // When disabling OSC2, set mix to OSC1 only
        _oscMix = 0.0;
      }
    });
    OscillatorControls.setOscMix(_oscMix);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 280, 
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          Container(
            height: 48, 
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                const Tab(text: 'OSC 1'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('OSC 2'),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _osc2Enabled ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const Tab(text: 'MIX'),
              ],
              indicatorColor: Colors.blue,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOsc1Tab(),
                _buildOsc2Tab(),
                _buildMixTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOsc1Tab() {
    return Padding(
      padding: const EdgeInsets.all(12), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Oscillator 1 (Main)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text('Waveform:', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          DropdownButton<int>(
            value: _osc1Waveform,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            isExpanded: true,
            items: Waveforms.allValues.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(Waveforms.getName(value)),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _osc1Waveform = newValue;
                });
                OscillatorControls.setOsc1Waveform(newValue);
              }
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              'OSC1 is always active and provides the main sound.',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOsc2Tab() {
    return Padding(
      padding: const EdgeInsets.all(12), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Oscillator 2',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Transform.scale(
                scale: 0.8, // Smaller switch
                child: Switch(
                  value: _osc2Enabled,
                  onChanged: (bool value) => _toggleOsc2(),
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Waveform control
          Opacity(
            opacity: _osc2Enabled ? 1.0 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Waveform:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                DropdownButton<int>(
                  value: _osc2Waveform,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  isExpanded: true,
                  items: Waveforms.allValues.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(Waveforms.getName(value)),
                    );
                  }).toList(),
                  onChanged: _osc2Enabled ? (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _osc2Waveform = newValue;
                      });
                      OscillatorControls.setOsc2Waveform(newValue);
                    }
                  } : null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Detune control
          Expanded(
            child: Opacity(
              opacity: _osc2Enabled ? 1.0 : 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detune: ${_detune.toInt()} cents',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      value: _detune,
                      min: -100.0,
                      max: 100.0,
                      divisions: 200,
                      activeColor: _osc2Enabled ? Colors.blue : Colors.grey,
                      inactiveColor: Colors.grey,
                      onChanged: _osc2Enabled ? (double value) {
                        setState(() {
                          _detune = value;
                        });
                        OscillatorControls.setDetune(value);
                      } : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixTab() {
    return Padding(
      padding: const EdgeInsets.all(12), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Oscillator Mix',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          
          if (!_osc2Enabled) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 24),
                      const SizedBox(height: 4),
                      const Text(
                        'Enable OSC 2 to access\nmix controls',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Currently using OSC 1 only',
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text('Mix Level:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('OSC1', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Expanded(
                  child: Slider(
                    value: _oscMix,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey,
                    onChanged: (double value) {
                      setState(() {
                        _oscMix = value;
                      });
                      OscillatorControls.setOscMix(value);
                    },
                  ),
                ),
                const Text('OSC2', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  _oscMix < 0.1
                      ? 'OSC1 Only'
                      : _oscMix > 0.9
                          ? 'OSC2 Only'
                          : _oscMix < 0.5
                              ? 'More OSC1: ${((1 - _oscMix) * 100).toInt()}%'
                              : _oscMix > 0.5
                                  ? 'More OSC2: ${(_oscMix * 100).toInt()}%'
                                  : 'Equal Mix: 50%/50%',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}