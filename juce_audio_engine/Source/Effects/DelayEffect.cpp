#include "DelayEffect.h"
#include <algorithm>

DelayEffect::DelayEffect()
    : bufferSize(0)
    , writePosition(0)
    , sampleRate(44100.0)
    , delayTime(0.25f)      // 250ms default
    , feedback(0.3f)        // 30% feedback
    , wetLevel(0.5f)        // 50% wet
    , dryLevel(0.5f)        // 50% dry
    , enabled(true)
{
}

float DelayEffect::processSample(float sample) {
    if (!enabled || delayBuffer.empty()) {
        return sample; // Bypass if disabled or not initialized
    }
    
    // Calculate read position
    int delayInSamples = getDelayInSamples();
    int readPosition = writePosition - delayInSamples;
    if (readPosition < 0) {
        readPosition += bufferSize;
    }
    
    // Read delayed sample
    float delayedSample = delayBuffer[readPosition];
    
    // Write new sample with feedback
    delayBuffer[writePosition] = sample + (delayedSample * feedback);
    
    // Advance write position
    writePosition = (writePosition + 1) % bufferSize;
    
    // Mix dry and wet signals
    return (sample * dryLevel) + (delayedSample * wetLevel);
}

void DelayEffect::setSampleRate(double sr) {
    sampleRate = sr;
    // Buffer size for maximum 2 seconds delay
    bufferSize = static_cast<int>(sampleRate * 2.0);
    delayBuffer.resize(bufferSize);
    reset();
}

void DelayEffect::reset() {
    if (!delayBuffer.empty()) {
        std::fill(delayBuffer.begin(), delayBuffer.end(), 0.0f);
    }
    writePosition = 0;
}

void DelayEffect::setParameter(int paramId, float value) {
    switch (paramId) {
        case 0: setDelayTime(value); break;
        case 1: setFeedback(value); break;
        case 2: setWetLevel(value); break;
        case 3: setDryLevel(value); break;
        case 4: setEnabled(value > 0.5f); break;
        default: break;
    }
}

bool DelayEffect::isActive() const {
    return enabled;
}

int DelayEffect::getDelayInSamples() const {
    return static_cast<int>(delayTime * sampleRate);
}

void DelayEffect::setDelayTime(float timeInSeconds) {
    delayTime = std::clamp(timeInSeconds, 0.001f, 2.0f);
}

void DelayEffect::setFeedback(float fb) {
    feedback = std::clamp(fb, 0.0f, 0.95f); // Max 95% to prevent runaway
}

void DelayEffect::setWetLevel(float wet) {
    wetLevel = std::clamp(wet, 0.0f, 1.0f);
}

void DelayEffect::setDryLevel(float dry) {
    dryLevel = std::clamp(dry, 0.0f, 1.0f);
}

void DelayEffect::setEnabled(bool enable) {
    enabled = enable;
}