import 'package:flutter/material.dart';
import 'synth_engine.dart';


class EffectsControls extends StatefulWidget {

  const EffectsControls({Key? key}) : super(key: key);

  @override
  _EffectsControlsState createState() => _EffectsControlsState();
}

class _EffectsControlsState extends State<EffectsControls>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter state variables
  double _filterCutoff = 1000.0;
  double _filterResonance = 1.0;

  //reverb state variables
  double _reverbRoomSize = 0.5;
  double _reverbDamping = 0.5;
  double _reverbWetLevel = 0.5;
  double _reverbDryLevel = 0.5;
  bool _reverbEnabled = true;

  //delay state variables
  double _delayTime = 0.25;
  double _delayFeedback = 0.3;
  double _delayWetLevel = 0.5;
  double _delayDryLevel = 0.5;
  bool _delayEnabled = false;

  //chorus state variables
  bool _chorusEnabled = false;
  double _chorusRate = 1.5;
  double _chorusDepth = 0.4;
  int _chorusVoices = 2;
  double _chorusFeedback = 0.2;
  double _chorusWetLevel = 0.5;
  double _chorusDryLevel = 0.8;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Start with just FILTER tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          // Effects header
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'EFFECTS RACK',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          // Effects tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.filter_alt, size: 18),
                text: 'FILTER',
              ),
              Tab(
                icon: Icon(Icons.waves, size: 18),
                text: 'REVERB',
              ),
              Tab(icon: Icon(Icons.repeat), text: 'DELAY'),
              Tab(icon: Icon(Icons.graphic_eq), text: 'CHORUS'),
            ],
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: Colors.cyanAccent,
            indicatorWeight: 3,
          ),
          
          // Effects content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFilterTab(),
                _buildReverbTab(),
                _buildDelayTab(),
                _buildChorusTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Low-pass Filter',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Cutoff frequency slider
          _buildCompactSlider(
            label: 'Cutoff Frequency',
            value: _filterCutoff,
            min: 20.0,
            max: 20000.0,
            divisions: 200,
            onChanged: (value) {
              setState(() {
                _filterCutoff = value;
                SynthEngine.setCutoffFrequency(value);
              });
            },
            valueDisplay: '${_filterCutoff.round()} Hz',
            icon: Icons.tune,
          ),
          
          const SizedBox(height: 20),
          
          // Resonance slider
          _buildCompactSlider(
            label: 'Resonance',
            value: _filterResonance,
            min: 0.1,
            max: 10.0,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                _filterResonance = value;
                SynthEngine.setResonance(value);
              });
            },
            valueDisplay: _filterResonance.toStringAsFixed(1),
            icon: Icons.waves,
          ),
        ],
      ),
    );
  }

  Widget _buildReverbTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable/Disable Switch
          if (SynthEngine.isInitialized) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.power_settings_new, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 8),
                  Text('Enable Reverb', style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
                  Spacer(),
                  Switch(
                    value: _reverbEnabled,
                    onChanged: (value) {
                      setState(() {
                        _reverbEnabled = value;
                      });
                      SynthEngine.enableReverb(value);
                      print('🌊 Reverb ${value ? "ENABLED" : "DISABLED"}');
                    },
                    activeColor: Colors.cyanAccent,
                    activeTrackColor: Colors.cyanAccent.withOpacity(0.3),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[600],
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Only show controls if effects engine is initialized
          if (SynthEngine.isInitialized) ...[
            // Room Size slider
            _buildCompactSlider(
              label: 'Room Size',
              value: _reverbRoomSize,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _reverbRoomSize = value;
                  SynthEngine.setReverbRoomSize(value);
                });
              },
              valueDisplay: '${(_reverbRoomSize * 100).round()}%',
              icon: Icons.home,
            ),
            
            const SizedBox(height: 20),
            
            // Damping slider
            _buildCompactSlider(
              label: 'Damping',
              value: _reverbDamping,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _reverbDamping = value;
                  SynthEngine.setReverbDamping(value);
                });
              },
              valueDisplay: '${(_reverbDamping * 100).round()}%',
              icon: Icons.water_drop,
            ),
            
            const SizedBox(height: 20),
            
            // Wet Level slider
            _buildCompactSlider(
              label: 'Wet Level',
              value: _reverbWetLevel,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _reverbWetLevel = value;
                  SynthEngine.setReverbWetLevel(value);
                });
              },
              valueDisplay: '${(_reverbWetLevel * 100).round()}%',
              icon: Icons.waves,
            ),
            
            const SizedBox(height: 20),
            
            // Dry Level slider
            _buildCompactSlider(
              label: 'Dry Level',
              value: _reverbDryLevel,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _reverbDryLevel = value;
                  SynthEngine.setReverbDryLevel(value);
                });
              },
              valueDisplay: '${(_reverbDryLevel * 100).round()}%',
              icon: Icons.volume_up,
            ),
          ] else ...[
            // Show message if effects not available
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400], size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Reverb effects are currently unavailable',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The synthesizer will continue to work normally',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDelayTab() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable/Disable Switch
        if (SynthEngine.isInitialized) 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                Icon(Icons.power_settings_new, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 8),
                Text('Enable Delay', style: TextStyle(
                  color: Colors.white, 
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
                Spacer(),
                Switch(
                  value: _delayEnabled,
                  onChanged: (value) {
                    setState(() {
                      _delayEnabled = value;
                    });
                    SynthEngine.enableDelay(value);
                    print('🚀 Delay ${value ? "ENABLED" : "DISABLED"}');
                  },
                  activeColor: Colors.cyanAccent,
                  activeTrackColor: Colors.cyanAccent.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[600],
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Only show controls if effects engine is initialized
        if (SynthEngine.isInitialized) ...[
          // Delay Time slider
          _buildCompactSlider(
            label: 'Delay Time',
            value: _delayTime,
            min: 0.001,
            max: 2.0,
            divisions: 200,
            onChanged: (value) {
              setState(() {
                _delayTime = value;
                SynthEngine.setDelayTime(value);
              });
            },
            valueDisplay: '${(_delayTime * 1000).round()} ms',
            icon: Icons.access_time,
          ),
          
          const SizedBox(height: 20),
          
          // Feedback slider
          _buildCompactSlider(
            label: 'Feedback',
            value: _delayFeedback,
            min: 0.0,
            max: 0.95,
            divisions: 95,
            onChanged: (value) {
              setState(() {
                _delayFeedback = value;
                SynthEngine.setDelayFeedback(value);
              });
            },
            valueDisplay: '${(_delayFeedback * 100).round()}%',
            icon: Icons.repeat,
          ),
          
          const SizedBox(height: 20),
          
          // Wet Level slider
          _buildCompactSlider(
            label: 'Wet Level',
            value: _delayWetLevel,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                _delayWetLevel = value;
                SynthEngine.setDelayWetLevel(value);
              });
            },
            valueDisplay: '${(_delayWetLevel * 100).round()}%',
            icon: Icons.waves,
          ),
          
          const SizedBox(height: 20),
          
          // Dry Level slider
          _buildCompactSlider(
            label: 'Dry Level',
            value: _delayDryLevel,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                _delayDryLevel = value;
                SynthEngine.setDelayDryLevel(value);
              });
            },
            valueDisplay: '${(_delayDryLevel * 100).round()}%',
            icon: Icons.volume_up,
          ),
        ] else ...[
          // Show message if effects not available
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400], size: 32),
                const SizedBox(height: 12),
                Text(
                  'Delay effects are currently unavailable',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The synthesizer will continue to work normally',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildChorusTab() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable/Disable Switch
        if (SynthEngine.isInitialized) 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                Icon(Icons.power_settings_new, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 8),
                Text('Enable Chorus', style: TextStyle(
                  color: Colors.white, 
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
                Spacer(),
                Switch(
                  value: _chorusEnabled,
                  onChanged: (value) {
                    setState(() {
                      _chorusEnabled = value;
                    });
                    SynthEngine.enableChorus(value);
                    print('🌊 Chorus ${value ? "ENABLED" : "DISABLED"}');
                  },
                  activeColor: Colors.cyanAccent,
                  activeTrackColor: Colors.cyanAccent.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[600],
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Only show controls if effects engine is initialized
        if (SynthEngine.isInitialized) ...[
          // Rate slider
          _buildCompactSlider(
            label: 'Rate',
            value: _chorusRate,
            min: 0.1,
            max: 5.0,
            divisions: 49,
            onChanged: (value) {
              setState(() {
                _chorusRate = value;
                SynthEngine.setChorusRate(value);
              });
            },
            valueDisplay: '${_chorusRate.toStringAsFixed(1)} Hz',
            icon: Icons.speed,
          ),
          
          const SizedBox(height: 16),
          
          // Depth slider
          _buildCompactSlider(
            label: 'Depth',
            value: _chorusDepth,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                _chorusDepth = value;
                SynthEngine.setChorusDepth(value);
              });
            },
            valueDisplay: '${(_chorusDepth * 100).round()}%',
            icon: Icons.waves,
          ),
          
          const SizedBox(height: 14),
          
          // Voices slider
          _buildCompactSlider(
            label: 'Voices',
            value: _chorusVoices.toDouble(),
            min: 2,
            max: 4,
            divisions: 2,
            onChanged: (value) {
              setState(() {
                _chorusVoices = value.round();
                SynthEngine.setChorusVoices(_chorusVoices);
              });
            },
            valueDisplay: '$_chorusVoices',
            icon: Icons.graphic_eq,
          ),
          
          const SizedBox(height: 16),
          
          // Feedback slider
          _buildCompactSlider(
            label: 'Feedback',
            value: _chorusFeedback,
            min: 0.0,
            max: 0.3,
            divisions: 30,
            onChanged: (value) {
              setState(() {
                _chorusFeedback = value;
                SynthEngine.setChorusFeedback(value);
              });
            },
            valueDisplay: '${(_chorusFeedback * 100).round()}%',
            icon: Icons.repeat,
          ),
          
          const SizedBox(height: 16),
          
          // Combined Wet/Dry Row (saves significant space)
          Row(
            children: [
              // Wet Level (left side)
              Expanded(
                child: _buildCompactSlider(
                  label: 'Wet',
                  value: _chorusWetLevel,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      _chorusWetLevel = value;
                      SynthEngine.setChorusWetLevel(value);
                    });
                  },
                  valueDisplay: '${(_chorusWetLevel * 100).round()}%',
                  icon: Icons.waves,
                ),
              ),
              const SizedBox(width: 16),
              // Dry Level (right side)
              Expanded(
                child: _buildCompactSlider(
                  label: 'Dry',
                  value: _chorusDryLevel,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      _chorusDryLevel = value;
                      SynthEngine.setChorusDryLevel(value);
                    });
                  },
                  valueDisplay: '${(_chorusDryLevel * 100).round()}%',
                  icon: Icons.volume_up,
                ),
              ),
            ],
          ),
        ] else ...[
          // Show message if effects not available
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400], size: 32),
                const SizedBox(height: 12),
                Text(
                  'Chorus effects are currently unavailable',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The synthesizer will continue to work normally',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildCompactSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String valueDisplay,
    required IconData icon,
    int? divisions,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent, size: 14), 
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                valueDisplay,
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4), 
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.cyanAccent,
              inactiveTrackColor: Colors.grey[600],
              thumbColor: Colors.cyanAccent,
              overlayColor: Colors.cyanAccent.withOpacity(0.1),
              trackHeight: 2.5, // ✅ Thinner track
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8), 
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}