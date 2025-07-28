#pragma once
#include "Effect.h"
#include <cmath>

class LowpassFilter : public Effect {
private:
    float cutoff;
    float resonance;
    float z1, z2;  // Filter state variables
    double sampleRate;
    
    // Helper method (like your generateWaveform)
    //void calculateCoefficients();
    
public:
    LowpassFilter();
    
    // Effect interface implementation
    float processSample(float sample) override;
    void setSampleRate(double sr) override;
    void reset() override;
    
    // Filter-specific methods (like your setFrequency/setWaveform)
    void setCutoff(float freq);
    void setResonance(float q);
};

// Future filter types will go here
// class HighpassFilter : public Effect { ... };
// class BandpassFilter : public Effect { ... };