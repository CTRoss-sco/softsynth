

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

  Map<String, dynamic> toJson() {
     Map<String, dynamic> json = {
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
  };

  if (reverbEnabled) {
    json.addAll({
      'reverbEnabled': reverbEnabled,
      'reverbRoomSize': reverbRoomSize,
      'reverbDamping': reverbDamping,
      'reverbWetLevel': reverbWetLevel,
      'reverbDryLevel': reverbDryLevel,
    });
  } else {
    json['reverbEnabled'] = false; 
  }

  if (delayEnabled) {
    json.addAll({
      'delayEnabled': delayEnabled,
      'delayTime': delayTime,
      'delayFeedback': delayFeedback,
      'delayWetLevel': delayWetLevel,
      'delayDryLevel': delayDryLevel,
    });
  } else {
    json['delayEnabled'] = false; 
  }

  if (chorusEnabled) {
    json.addAll({
      'chorusEnabled': chorusEnabled,
      'chorusRate': chorusRate,
      'chorusDepth': chorusDepth,
      'chorusVoices': chorusVoices,
      'chorusFeedback': chorusFeedback,
      'chorusWetLevel': chorusWetLevel,
      'chorusDryLevel': chorusDryLevel,
    });
  } else {
    json['chorusEnabled'] = false; 
  }

  return json;
}

// Create from Firestore JSON format
  factory PresetModel.fromJson(Map<String, dynamic> json) {
      return PresetModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    userId: json['userId'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    
    // Oscillator and filter settings (always present)
    osc1Waveform: json['osc1Waveform'] ?? 'Sine',
    osc2Waveform: json['osc2Waveform'] ?? 'Sine',
    detune: (json['detune'] ?? 0.0).toDouble(),
    oscillatorMix: (json['oscillatorMix'] ?? 0.5).toDouble(),
    cutoff: (json['cutoff'] ?? 1000.0).toDouble(),
    resonance: (json['resonance'] ?? 1.0).toDouble(),
    
    // Reverb settings (use defaults if not saved due to being disabled)
    reverbEnabled: json['reverbEnabled'] ?? false,
    reverbRoomSize: json.containsKey('reverbRoomSize') 
        ? (json['reverbRoomSize']).toDouble() 
        : 0.5, // Default only if key doesn't exist
    reverbDamping: json.containsKey('reverbDamping') 
        ? (json['reverbDamping']).toDouble() 
        : 0.5,
    reverbWetLevel: json.containsKey('reverbWetLevel') 
        ? (json['reverbWetLevel']).toDouble() 
        : 0.3,
    reverbDryLevel: json.containsKey('reverbDryLevel') 
        ? (json['reverbDryLevel']).toDouble() 
        : 0.7,
    
    // Delay settings (use defaults if not saved due to being disabled)
    delayEnabled: json['delayEnabled'] ?? false,
    delayTime: json.containsKey('delayTime') 
        ? (json['delayTime']).toDouble() 
        : 0.3,
    delayFeedback: json.containsKey('delayFeedback') 
        ? (json['delayFeedback']).toDouble() 
        : 0.3,
    delayWetLevel: json.containsKey('delayWetLevel') 
        ? (json['delayWetLevel']).toDouble() 
        : 0.3,
    delayDryLevel: json.containsKey('delayDryLevel') 
        ? (json['delayDryLevel']).toDouble() 
        : 0.7,
    
    // Chorus settings (use defaults if not saved due to being disabled)
    chorusEnabled: json['chorusEnabled'] ?? false,
    chorusRate: json.containsKey('chorusRate') 
        ? (json['chorusRate']).toDouble() 
        : 1.5,
    chorusDepth: json.containsKey('chorusDepth') 
        ? (json['chorusDepth']).toDouble() 
        : 0.4,
    chorusVoices: json.containsKey('chorusVoices') 
        ? json['chorusVoices'] 
        : 2,
    chorusFeedback: json.containsKey('chorusFeedback') 
        ? (json['chorusFeedback']).toDouble() 
        : 0.2,
    chorusWetLevel: json.containsKey('chorusWetLevel') 
        ? (json['chorusWetLevel']).toDouble() 
        : 0.5,
    chorusDryLevel: json.containsKey('chorusDryLevel') 
        ? (json['chorusDryLevel']).toDouble() 
        : 0.8,
    );
  }
}