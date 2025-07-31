#include "ChorusEffect.h"
#include <algorithm>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

ChorusEffect::ChorusEffect()
    : sampleRate(44100.0)
    , rate(1.5f)            // 1.5 Hz default
    , depth(0.4f)           // 40% depth
    , feedback(0.2f)        // 20% feedback
    , wetLevel(0.5f)        // 50% wet
    , dryLevel(0.8f)        // 80% dry
    , enabled(false)        // Start disabled (same as DelayEffect)
    , masterLfoPhase(0.0f)
{
    // Initialize with 2 voices by default
    setVoices(2);
}

float ChorusEffect::processSample(float sample) {
    if (!enabled || voices.empty()) {
        return sample; // Bypass if disabled (same as DelayEffect)
    }
    
    // Update master LFO phase
    masterLfoPhase += (2.0f * static_cast<float>(M_PI) * rate) / static_cast<float>(sampleRate);
    if (masterLfoPhase >= 2.0f * static_cast<float>(M_PI)) {
        masterLfoPhase -= 2.0f * static_cast<float>(M_PI);
    }
    
    float outputSample = sample * dryLevel; // Start with dry signal
    
    // Process each chorus voice
    for (size_t voiceIndex = 0; voiceIndex < voices.size(); ++voiceIndex) {
        auto& voice = voices[voiceIndex];
        
        if (voice.delayBuffer.empty()) continue;
        
        // Update voice LFO phase (phase-shifted per voice)
        voice.lfoPhase = masterLfoPhase + (voiceIndex * static_cast<float>(M_PI) / 2.0f);
        if (voice.lfoPhase >= 2.0f * static_cast<float>(M_PI)) {
            voice.lfoPhase -= 2.0f * static_cast<float>(M_PI);
        }
        
        // Generate LFO modulation
        float lfoValue = generateLFO(voice.lfoPhase);
        
        // Calculate modulated delay time
        float modulationAmount = voice.baseDelayTime * depth * 0.5f;
        float modulatedDelay = voice.baseDelayTime + (lfoValue * modulationAmount);
        
        // Clamp delay (same pattern as DelayEffect)
        int delayInSamples = static_cast<int>(std::clamp(modulatedDelay, 1.0f, static_cast<float>(voice.bufferSize - 1)));
        
        // Calculate read position (same logic as DelayEffect)
        int readPosition = voice.writePosition - delayInSamples;
        if (readPosition < 0) {
            readPosition += voice.bufferSize;
        }
        
        // Read delayed sample
        float delayedSample = voice.delayBuffer[readPosition];
        
        // Write new sample with feedback (same as DelayEffect)
        voice.delayBuffer[voice.writePosition] = sample + (delayedSample * feedback);
        
        // Advance write position (same as DelayEffect)
        voice.writePosition = (voice.writePosition + 1) % voice.bufferSize;
        
        // Add chorus voice to output
        outputSample += delayedSample * wetLevel * (1.0f / static_cast<float>(voices.size()));
    }
    
    return outputSample;
}

void ChorusEffect::setSampleRate(double sr) {
    sampleRate = sr;
    
    // Initialize all voice buffers (same pattern as DelayEffect)
    for (auto& voice : voices) {
        voice.bufferSize = static_cast<int>(sampleRate * (MAX_DELAY_MS / 1000.0f) * 2); // Extra headroom
        voice.delayBuffer.resize(voice.bufferSize);
        voice.writePosition = 0;
    }
    
    updateVoiceDelayTimes();
    reset();
}

void ChorusEffect::reset() {
    // Same pattern as DelayEffect
    for (auto& voice : voices) {
        if (!voice.delayBuffer.empty()) {
            std::fill(voice.delayBuffer.begin(), voice.delayBuffer.end(), 0.0f);
        }
        voice.writePosition = 0;
        voice.lfoPhase = 0.0f;
    }
    masterLfoPhase = 0.0f;
}

void ChorusEffect::setParameter(int paramId, float value) {
    // Same pattern as DelayEffect
    switch (paramId) {
        case 0: setRate(value); break;
        case 1: setDepth(value); break;
        case 2: setVoices(static_cast<int>(value)); break;
        case 3: setFeedback(value); break;
        case 4: setWetLevel(value); break;
        case 5: setDryLevel(value); break;
        case 6: setEnabled(value > 0.5f); break;
        default: break;
    }
}

bool ChorusEffect::isActive() const {
    return enabled; // Same as DelayEffect
}

void ChorusEffect::setRate(float rateHz) {
    rate = std::clamp(rateHz, 0.1f, 5.0f); // Same clamp pattern
}

void ChorusEffect::setDepth(float newDepth) {
    depth = std::clamp(newDepth, 0.0f, 1.0f);
}

void ChorusEffect::setVoices(int numVoices) {
    numVoices = std::clamp(numVoices, 2, 4);
    voices.resize(numVoices);
    
    // Reinitialize if sample rate is set
    if (sampleRate > 0) {
        setSampleRate(sampleRate);
    }
}

void ChorusEffect::setFeedback(float fb) {
    feedback = std::clamp(fb, 0.0f, 0.3f); // Lower max than delay for safety
}

void ChorusEffect::setWetLevel(float wet) {
    wetLevel = std::clamp(wet, 0.0f, 1.0f); // Same as DelayEffect
}

void ChorusEffect::setDryLevel(float dry) {
    dryLevel = std::clamp(dry, 0.0f, 1.0f); // Same as DelayEffect
}

void ChorusEffect::setEnabled(bool enable) {
    enabled = enable; // Same as DelayEffect
}

float ChorusEffect::generateLFO(float phase) {
    // Simple sine wave LFO (pure C++ math)
    return std::sin(phase);
}

void ChorusEffect::updateVoiceDelayTimes() {
    if (voices.empty()) return;
    
    // Spread voices across delay range
    for (size_t i = 0; i < voices.size(); ++i) {
        float delayMs = MIN_DELAY_MS + (i * (MAX_DELAY_MS - MIN_DELAY_MS) / (voices.size() - 1));
        voices[i].baseDelayTime = getDelayInSamples(delayMs);
    }
}

int ChorusEffect::getDelayInSamples(float delayTimeMs) const {
    // Same conversion pattern as DelayEffect
    return static_cast<int>((delayTimeMs / 1000.0f) * sampleRate);
}