// juce_audio_engine/Source/Effects/ReverbEffect.cpp
#include "ReverbEffect.h"
#include <algorithm>

// DelayLine implementations
ReverbEffect::DelayLine::DelayLine(int delaySize) 
    : buffer(delaySize, 0.0f), writePos(0), size(delaySize) {
}

float ReverbEffect::DelayLine::process(float input, float feedback) {
    float output = buffer[writePos];
    buffer[writePos] = input + (output * feedback);
    writePos = (writePos + 1) % size;
    return output;
}

void ReverbEffect::DelayLine::clear() {
    std::fill(buffer.begin(), buffer.end(), 0.0f);
    writePos = 0;
}

// ReverbEffect implementations
ReverbEffect::ReverbEffect() 
    : roomSize(0.5f), damping(0.5f), wetLevel(0.3f), dryLevel(0.7f), sampleRate(44100.0) {
}

float ReverbEffect::processSample(float sample) {
    // Process through delay lines
    float reverb = 0.0f;
    reverb += delay1.process(sample, roomSize * damping);
    reverb += delay2.process(sample, roomSize * damping);
    reverb += delay3.process(sample, roomSize * damping);
    reverb += delay4.process(sample, roomSize * damping);
    
    // Average and mix
    reverb *= 0.25f;
    return (sample * dryLevel) + (reverb * wetLevel);
}

void ReverbEffect::setSampleRate(double sr) {
    sampleRate = sr;
    // Delay sizes are fixed, but you could scale them here if needed
}

void ReverbEffect::reset() {
    delay1.clear();
    delay2.clear();
    delay3.clear();
    delay4.clear();
}

void ReverbEffect::setParameter(int paramId, float value) {
    switch (paramId) {
        case 0: roomSize = value; break;  // 0.0 - 1.0
        case 1: damping = value; break;   // 0.0 - 1.0
        case 2: wetLevel = value; break;  // 0.0 - 1.0
        case 3: dryLevel = value; break;  // 0.0 - 1.0
    }
}

bool ReverbEffect::isActive() const {
    return wetLevel > 0.0f;
}