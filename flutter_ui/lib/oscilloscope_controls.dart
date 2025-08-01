import 'package:flutter/material.dart';
import 'synth_engine.dart';

class OscilloscopeControls extends StatefulWidget {
  @override
  _OscilloscopeControlsState createState() => _OscilloscopeControlsState();
}

class _OscilloscopeControlsState extends State<OscilloscopeControls>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<double> _waveformData = [];
  bool _oscilloscopeEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 50), // ~20fps for smooth display
      vsync: this,
    );
    
    _animationController.addListener(() {
      if (_oscilloscopeEnabled && mounted) {
        setState(() {
          _waveformData = SynthEngine.getWaveformData();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_oscilloscopeEnabled) {
      SynthEngine.enableOscilloscope(false);
    }
    super.dispose();
  }

  void _toggleOscilloscope() {
    setState(() {
      _oscilloscopeEnabled = !_oscilloscopeEnabled;
    });
    
    SynthEngine.enableOscilloscope(_oscilloscopeEnabled);
    
    if (_oscilloscopeEnabled) {
      _animationController.repeat();
    } else {
      _animationController.stop();
      _waveformData.clear();
    }
  }

  Widget _buildToggleButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: _oscilloscopeEnabled 
            ? const Color(0xFF2196F3).withOpacity(0.1)
            : const Color(0xFF424242),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _toggleOscilloscope,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _oscilloscopeEnabled 
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF616161),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _oscilloscopeEnabled ? Icons.stop : Icons.play_arrow,
                  color: _oscilloscopeEnabled 
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFBDBDBD),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _oscilloscopeEnabled ? 'STOP SCOPE' : 'START SCOPE',
                  style: TextStyle(
                    color: _oscilloscopeEnabled 
                        ? const Color(0xFF2196F3)
                        : const Color(0xFFBDBDBD),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOscilloscopeDisplay() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF424242),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CustomPaint(
          painter: WaveformPainter(_waveformData, _oscilloscopeEnabled),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF424242),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF81C784),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'STATUS',
                style: TextStyle(
                  color: const Color(0xFF81C784),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _oscilloscopeEnabled 
                ? 'Capturing: ${_waveformData.length} samples'
                : 'Oscilloscope disabled',
            style: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sample Rate: 44.1 kHz',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!SynthEngine.isInitialized) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Synth Engine not initialized',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header matching your effects style
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: const Color(0xFF64B5F6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'OSCILLOSCOPE',
                style: const TextStyle(
                  color: Color(0xFF64B5F6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Toggle button
          _buildToggleButton(),
          
          // Oscilloscope display
          _buildOscilloscopeDisplay(),
          
          // Info panel
          _buildInfoPanel(),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final bool enabled;

  WaveformPainter(this.samples, this.enabled);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid (matches your dark theme)
    _drawGrid(canvas, size);
    
    if (!enabled) {
      _drawStatusMessage(canvas, size, 'OSCILLOSCOPE OFF', const Color(0xFF757575));
      return;
    }
    
    if (samples.isEmpty) {
      _drawStatusMessage(canvas, size, 'NO SIGNAL', const Color(0xFF616161));
      return;
    }
    
    // Draw waveform
    _drawWaveform(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF424242)
      ..strokeWidth = 0.5;

    // Vertical lines (10 divisions)
    for (int i = 0; i <= 10; i++) {
      final x = (i / 10) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Horizontal lines (6 divisions)
    for (int i = 0; i <= 6; i++) {
      final y = (i / 6) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Center line (brighter - matches your accent color)
    final centerPaint = Paint()
      ..color = const Color(0xFF616161)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  void _drawWaveform(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    final waveformPaint = Paint()
      ..color = const Color(0xFF64B5F6) // Matches your blue accent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    for (int i = 0; i < samples.length; i++) {
      final x = (i / (samples.length - 1)) * size.width;
      // Clamp and scale the sample value
      final clampedSample = samples[i].clamp(-1.0, 1.0);
      final y = size.height / 2 - (clampedSample * size.height * 0.4);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, waveformPaint);
    
    // Add subtle glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    canvas.drawPath(path, glowPaint);
  }

  void _drawStatusMessage(Canvas canvas, Size size, String message, Color color) {
    final textStyle = TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    );
    
    final textSpan = TextSpan(text: message, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}