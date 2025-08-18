#pragma once
#include <cmath>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

//enum class to handle conversion to C compatible types for FFI
enum class WaveformType {
    SINE = 0,
    SQUARE = 1,
    SAW = 2,
    TRIANGLE = 3
};

class Oscillator {
public:
    Oscillator();
    
    float generateSample(double sampleRate);
    void setFrequency(float freq);
    void setWaveform(WaveformType type);
    void reset();
    
private:
    float frequency;
    float phase;
    WaveformType waveform;
    
    float generateWaveform(float phase);
};


class DualOscVoice {
public:
    DualOscVoice();
    
    float generateSample(double sampleRate);
    void noteOn(float frequency, float velocity);
    void noteOff();
    
    // Oscillator controls
    void setOsc1Waveform(WaveformType type);
    void setOsc2Waveform(WaveformType type);
    void setDetune(float cents);        
    void setMix(float mixLevel);        
    
    bool isActive() const { return active; }
    
private:
    Oscillator osc1, osc2;
    float velocity;
    float detune;           
    float mix;              
    bool active;
    
    float centsToRatio(float cents);    
};