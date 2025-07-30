#include "Oscillator.h"
#include <algorithm>

//Oscillator Implementation

Oscillator::Oscillator() 
    : frequency(440.0f), phase(0.0f), waveform(WaveformType::SINE) {
}

void Oscillator::setFrequency(float freq) {
    frequency = freq;
}

void Oscillator::setWaveform(WaveformType type) {
    waveform = type;
}

void Oscillator::reset() {
    phase = 0.0f;
}

float Oscillator::generateSample(double sampleRate) {
    float sample = generateWaveform(phase);
    
    // Update phase for next sample
    phase += frequency / sampleRate;
    
    // Wrap phase to prevent overflow
    if (phase >= 1.0f) {
        phase -= 1.0f;
    }
    
    return sample;
}

float Oscillator::generateWaveform(float phase) {
    switch (waveform) {
        case WaveformType::SINE:
            return std::sin(phase * 2.0f * M_PI);
            
        case WaveformType::SQUARE:
            return (std::sin(phase * 2.0f * M_PI) >= 0.0f) ? 1.0f : -1.0f;
            
        case WaveformType::SAW:
            return 2.0f * (phase - std::floor(phase + 0.5f));
            
        case WaveformType::TRIANGLE: {
            float p = phase - std::floor(phase);
            return (p < 0.5f) ? (4.0f * p - 1.0f) : (3.0f - 4.0f * p);
        }
        
        default:
            return 0.0f;
    }
}

//DualOscVoice Implementation

DualOscVoice::DualOscVoice() 
    : velocity(0.0f), detune(0.0f), mix(0.5f), active(false) {
}

void DualOscVoice::noteOn(float frequency, float vel) {
    velocity = vel; // Revert back to normal velocity
    active = true;
    
    // Set base frequency for oscillator 1
    osc1.setFrequency(frequency);
    
    // Set detuned frequency for oscillator 2
    float detunedFreq = frequency * centsToRatio(detune);
    osc2.setFrequency(detunedFreq);
    
    // Reset phases for clean note start
    osc1.reset();
    osc2.reset();
}

void DualOscVoice::noteOff() {
    active = false;
    velocity = 0.0f;
}

float DualOscVoice::generateSample(double sampleRate) {
    if (!active) return 0.0f;
    
    // Generate samples from both oscillators
    float sample1 = osc1.generateSample(sampleRate);
    float sample2 = osc2.generateSample(sampleRate);
    
    // Mix the oscillators
    float mixedSample = (sample1 * (1.0f - mix)) + (sample2 * mix);
    
    // Apply velocity
    return mixedSample * velocity;
}

void DualOscVoice::setOsc1Waveform(WaveformType type) {
    osc1.setWaveform(type);
}

void DualOscVoice::setOsc2Waveform(WaveformType type) {
    osc2.setWaveform(type);
}

void DualOscVoice::setDetune(float cents) {
    detune = std::clamp(cents, -100.0f, 100.0f);
}

void DualOscVoice::setMix(float mixLevel) {
    mix = std::clamp(mixLevel, 0.0f, 1.0f);
}

float DualOscVoice::centsToRatio(float cents) {
    // Convert cents to frequency ratio: 2^(cents/1200)
    return std::pow(2.0f, cents / 1200.0f);
}