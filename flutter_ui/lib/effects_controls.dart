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
  
  // Filter state
  double _filterCutoff = 1000.0;
  double _filterResonance = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Start with just FILTER tab
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
              // TODO: Add more tabs as we implement them
              // Tab(icon: Icon(Icons.waves), text: 'REVERB'),
              // Tab(icon: Icon(Icons.repeat), text: 'DELAY'),
              // Tab(icon: Icon(Icons.graphic_eq), text: 'CHORUS'),
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
                // TODO: Add other effect tabs
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // ✅ Much more compact
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
              Icon(icon, color: Colors.cyanAccent, size: 14), // ✅ Smaller icon
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // ✅ Smaller font
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                valueDisplay,
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 10, // ✅ Smaller value display
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4), // ✅ Minimal spacing
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.cyanAccent,
              inactiveTrackColor: Colors.grey[600],
              thumbColor: Colors.cyanAccent,
              overlayColor: Colors.cyanAccent.withOpacity(0.1),
              trackHeight: 2.5, // ✅ Thinner track
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8), // ✅ Smaller thumb
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