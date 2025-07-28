#include "Filter.h"
#include <algorithm>
#include <cmath>
#include <memory>

//LowpassFilter Implementation

LowpassFilter::LowpassFilter() 
    : cutoff(1000.0f), resonance(1.0f), z1(0.0f), z2(0.0f), sampleRate(44100.0) {
}

void LowpassFilter::setCutoff(float freq) {
    cutoff = std::clamp(freq, 20.0f, 20000.0f);
}

void LowpassFilter::setResonance(float q) {
    resonance = std::clamp(q, 0.1f, 10.0f);
}

void LowpassFilter::setSampleRate(double sr) {
    sampleRate = sr;
}

void LowpassFilter::reset() {
    z1 = 0.0f;
    z2 = 0.0f;
}

float LowpassFilter::processSample(float sample) {
    // Simple 2-pole lowpass filter 
    float nyquist = sampleRate / 2.0f;
    float normalizedCutoff = cutoff / nyquist;
    
    // Clamp to prevent instability
    normalizedCutoff = std::clamp(normalizedCutoff, 0.001f, 0.99f);
    
    // Simple filter calculation
    float alpha = normalizedCutoff;
    float feedback = resonance * 0.1f;
    
    // Apply filter
    z1 = z1 + alpha * (sample - z1 + feedback * (z1 - z2));
    z2 = z2 + alpha * (z1 - z2);
    
    return z2;
}