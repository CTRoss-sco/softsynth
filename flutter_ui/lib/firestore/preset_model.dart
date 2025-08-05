

/* Class to represent a preset model for the synthesizer. Takes in 
various parameters to store the values of oscillators, fliers, and effects
settings. 
*/
class PresetModel {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  
  // Oscillator settings
  final String osc1Waveform;
  final String osc2Waveform;
  final double detune;
  final double oscillatorMix;
  
  // Filter settings
  final double cutoff;
  final double resonance;
  
  // Effects settings
  final bool reverbEnabled;
  final double reverbRoomSize;
  final double reverbDamping;
  final double reverbWetLevel;
  final double reverbDryLevel;
  
  final bool delayEnabled;
  final double delayTime;
  final double delayFeedback;
  final double delayWetLevel;
  final double delayDryLevel;
  
  final bool chorusEnabled;
  final double chorusRate;
  final double chorusDepth;
  final int chorusVoices;
  final double chorusFeedback;
  final double chorusWetLevel;
  final double chorusDryLevel;

  PresetModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.osc1Waveform,
    required this.osc2Waveform,
    required this.detune,
    required this.oscillatorMix,
    required this.cutoff,
    required this.resonance,
    required this.reverbEnabled,
    required this.reverbRoomSize,
    required this.reverbDamping,
    required this.reverbWetLevel,
    required this.reverbDryLevel,
    required this.delayEnabled,
    required this.delayTime,
    required this.delayFeedback,
    required this.delayWetLevel,
    required this.delayDryLevel,
    required this.chorusEnabled,
    required this.chorusRate,
    required this.chorusDepth,
    required this.chorusVoices,
    required this.chorusFeedback,
    required this.chorusWetLevel,
    required this.chorusDryLevel,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'osc1Waveform': osc1Waveform,
      'osc2Waveform': osc2Waveform,
      'detune': detune,
      'oscillatorMix': oscillatorMix,
      'cutoff': cutoff,
      'resonance': resonance,
      'reverbEnabled': reverbEnabled,
      'reverbRoomSize': reverbRoomSize,
      'reverbDamping': reverbDamping,
      'reverbWetLevel': reverbWetLevel,
      'reverbDryLevel': reverbDryLevel,
      'delayEnabled': delayEnabled,
      'delayTime': delayTime,
      'delayFeedback': delayFeedback,
      'delayWetLevel': delayWetLevel,
      'delayDryLevel': delayDryLevel,
      'chorusEnabled': chorusEnabled,
      'chorusRate': chorusRate,
      'chorusDepth': chorusDepth,
      'chorusVoices': chorusVoices,
      'chorusFeedback': chorusFeedback,
      'chorusWetLevel': chorusWetLevel,
      'chorusDryLevel': chorusDryLevel,
    };
  }

  // Create from Firestore JSON
  factory PresetModel.fromJson(Map<String, dynamic> json) {
    return PresetModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      osc1Waveform: json['osc1Waveform'] ?? 'Sine',
      osc2Waveform: json['osc2Waveform'] ?? 'Sine',
      detune: (json['detune'] ?? 0.0).toDouble(),
      oscillatorMix: (json['oscillatorMix'] ?? 0.0).toDouble(),
      cutoff: (json['cutoff'] ?? 1000.0).toDouble(),
      resonance: (json['resonance'] ?? 0.1).toDouble(),
      reverbEnabled: json['reverbEnabled'] ?? false,
      reverbRoomSize: (json['reverbRoomSize'] ?? 0.5).toDouble(),
      reverbDamping: (json['reverbDamping'] ?? 0.5).toDouble(),
      reverbWetLevel: (json['reverbWetLevel'] ?? 0.3).toDouble(),
      reverbDryLevel: (json['reverbDryLevel'] ?? 0.7).toDouble(),
      delayEnabled: json['delayEnabled'] ?? false,
      delayTime: (json['delayTime'] ?? 0.3).toDouble(),
      delayFeedback: (json['delayFeedback'] ?? 0.3).toDouble(),
      delayWetLevel: (json['delayWetLevel'] ?? 0.3).toDouble(),
      delayDryLevel: (json['delayDryLevel'] ?? 0.7).toDouble(),
      chorusEnabled: json['chorusEnabled'] ?? false,
      chorusRate: (json['chorusRate'] ?? 0.5).toDouble(),
      chorusDepth: (json['chorusDepth'] ?? 0.5).toDouble(),
      chorusVoices: json['chorusVoices'] ?? 2,
      chorusFeedback: (json['chorusFeedback'] ?? 0.0).toDouble(),
      chorusWetLevel: (json['chorusWetLevel'] ?? 0.3).toDouble(),
      chorusDryLevel: (json['chorusDryLevel'] ?? 0.7).toDouble(),
    );
  }
}