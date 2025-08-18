#include "ChorusEffect.h"
#include <algorithm>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/*
A class to represent the Chorus effect that inherits
from the base Effect class.
*/

/*
Constructor for the ChorusEffect class, that also 
creates two instances of the ChorusVoice struct upon
initialisation.
*/
ChorusEffect::ChorusEffect()
    : sampleRate(44100.0)
    , rate(1.5f)            
    , depth(0.4f)           
    , feedback(0.2f)        
    , wetLevel(0.5f)        
    , dryLevel(0.8f)        
    , enabled(false)        
    , masterLfoPhase(0.0f)
{
    
    setVoices(2);
}

/*
Main processing function that takes in an audio sample and returns 
a mix of the original dry signal and processed chorus signal.
*/
float ChorusEffect::processSample(float sample) {
    if (!enabled || voices.empty()) {
        return sample; //effect is bypassed if not enabled
    }
    
    // Update master LFO phase (used with each voice)
    masterLfoPhase += (2.0f * static_cast<float>(M_PI) * rate) / static_cast<float>(sampleRate);
    if (masterLfoPhase >= 2.0f * static_cast<float>(M_PI)) {
        masterLfoPhase -= 2.0f * static_cast<float>(M_PI);
    }
    
    float outputSample = sample * dryLevel; 
    
    // Process through each ChorusVoice struct
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
        
        // Clamp delay
        int delayInSamples = static_cast<int>(std::clamp(modulatedDelay, 1.0f, static_cast<float>(voice.bufferSize - 1)));
        
        // Calculate read position
        int readPosition = voice.writePosition - delayInSamples;
        if (readPosition < 0) {
            readPosition += voice.bufferSize;
        }
        
        // Read delayed sample
        float delayedSample = voice.delayBuffer[readPosition];
        
        // Write new sample with feedback
        voice.delayBuffer[voice.writePosition] = sample + (delayedSample * feedback);
        
        // Advance the write position
        voice.writePosition = (voice.writePosition + 1) % voice.bufferSize;
        
        // Add chorus voice to output
        outputSample += delayedSample * wetLevel * (1.0f / static_cast<float>(voices.size()));
    }
    
    return outputSample;
}

/*
Sets the sample rate to be used for the chorus and allocates a buffer for each
voice. 
*/
void ChorusEffect::setSampleRate(double sr) {
    sampleRate = sr;
    
    for (auto& voice : voices) {
        voice.bufferSize = static_cast<int>(sampleRate * (MAX_DELAY_MS / 1000.0f) * 2);
        voice.delayBuffer.resize(voice.bufferSize);
        voice.writePosition = 0;
    }
    
    updateVoiceDelayTimes();
    reset();
}

/*
Method to reset all buffers to zero (silence) and resets all phase values
used for the Low Frequency Oscillator to zero. Used when audio stops or when
user adjusts parameters to prevent old audio from bleeding through.
*/
void ChorusEffect::reset() {
    for (auto& voice : voices) {
        if (!voice.delayBuffer.empty()) {
            std::fill(voice.delayBuffer.begin(), voice.delayBuffer.end(), 0.0f);
        }
        voice.writePosition = 0;
        voice.lfoPhase = 0.0f;
    }
    masterLfoPhase = 0.0f;
}

/*
Inherited method from base Effect class. Uses a switch statement structure
to account for the different numbers of parameters that different effect types
can have.
*/
void ChorusEffect::setParameter(int paramId, float value) {
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
    return enabled;
}

//setter methods for chorus parameters
void ChorusEffect::setRate(float rateHz) {
    rate = std::clamp(rateHz, 0.1f, 5.0f);
}

void ChorusEffect::setDepth(float newDepth) {
    depth = std::clamp(newDepth, 0.0f, 1.0f);
}

void ChorusEffect::setVoices(int numVoices) {
    numVoices = std::clamp(numVoices, 2, 4);
    voices.resize(numVoices);
    if (sampleRate > 0) {
        setSampleRate(sampleRate);
    }
}

void ChorusEffect::setFeedback(float fb) {
    feedback = std::clamp(fb, 0.0f, 0.3f); 
}

void ChorusEffect::setWetLevel(float wet) {
    wetLevel = std::clamp(wet, 0.0f, 1.0f); 
}

void ChorusEffect::setDryLevel(float dry) {
    dryLevel = std::clamp(dry, 0.0f, 1.0f); 
}

void ChorusEffect::setEnabled(bool enable) {
    enabled = enable; 
}

//getter methods for chorus effect parameters
float ChorusEffect::getRate() const {
    return rate;
}

float ChorusEffect::getDepth() const {
    return depth;
}

int ChorusEffect::getVoices() const {
    return static_cast<int>(voices.size());
}

float ChorusEffect::getFeedback() const {
    return feedback;
}

float ChorusEffect::getWetLevel() const {
    return wetLevel;
}

float ChorusEffect::getDryLevel() const {
    return dryLevel;
}

bool ChorusEffect::isChorusEnabled() const {
    return enabled;
}

/*
Helper method that generates a generic sine wave using the 
cmath library. It returns a phase value between -1.0 and 1.0
for modulation purposes in the processSample() method.
*/
float ChorusEffect::generateLFO(float phase) {
    return std::sin(phase);
}

/*
Helper method that calculates the delay time in milliseconds of
each voice, spreading them evenly between 5-20ms delay. 
*/
void ChorusEffect::updateVoiceDelayTimes() {
    if (voices.empty()) return;
    for (size_t i = 0; i < voices.size(); ++i) {
        float delayMs = MIN_DELAY_MS + (i * (MAX_DELAY_MS - MIN_DELAY_MS) / (voices.size() - 1));
        voices[i].baseDelayTime = getDelayInSamples(delayMs);
    }
}

/*
Helper method that takes a float parameter in milliseconds and returns
the sample count from the time in ms. It is used to calculate the delay time
of each voice and the size of each buffer.
*/
int ChorusEffect::getDelayInSamples(float delayTimeMs) const {
    return static_cast<int>((delayTimeMs / 1000.0f) * sampleRate);
}