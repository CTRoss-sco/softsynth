#include "DelayEffect.h"
#include <algorithm>

/*
A class to represent the Delay effect, that inherits from
the base Effect class.
*/

/*
DelayEffect class constructor. The user adjusted parameters
are initialised at 0.5f (50% levels) to create a balanced sound.
The sampleRate member variable is the same as the SynthEngine sample rate. 
*/
DelayEffect::DelayEffect()
    : bufferSize(0)
    , writePosition(0)
    , sampleRate(44100.0)
    , delayTime(0.25f)      
    , feedback(0.3f)        
    , wetLevel(0.5f)        
    , dryLevel(0.5f)        
    , enabled(true)
{
}

/*
DelayEffect polymorphic class method inherited from the base Effect class.
Takes in an audio sample float value as an input parameter to write it in the
next buffer position. Uses the previous buffer position to read the delayed sample,
and returns a mix of the original and delayed signal.
*/
float DelayEffect::processSample(float sample) {
    if (!enabled || delayBuffer.empty()) {
        return sample; 
    }
    
    int delayInSamples = getDelayInSamples();
    int readPosition = writePosition - delayInSamples;
    if (readPosition < 0) {
        readPosition += bufferSize;
    }
    
    float delayedSample = delayBuffer[readPosition];
    
    delayBuffer[writePosition] = sample + (delayedSample * feedback);
    
    writePosition = (writePosition + 1) % bufferSize;

    return (sample * dryLevel) + (delayedSample * wetLevel);
}

/*
Setter method for the sample rate that allows a maximum delay time of
2 seconds (2000 milliseconds). 
*/
void DelayEffect::setSampleRate(double sr) {
    sampleRate = sr;
    // Buffer size for maximum 2 seconds delay
    bufferSize = static_cast<int>(sampleRate * 2.0);
    delayBuffer.resize(bufferSize);
    reset();
}

/*
Method that clears the delay buffer and resets the write position
of the buffer. Used when audio stops or when settings are changed
by user to prevent older audio from bleeding through.
*/
void DelayEffect::reset() {
    if (!delayBuffer.empty()) {
        std::fill(delayBuffer.begin(), delayBuffer.end(), 0.0f);
    }
    writePosition = 0;
}

/*
Polymorphic method inherited from base Effect class. Uses a switch
statement structure to account for the different parameters of each effect.
*/
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

/*
Helper method used in processSample() to convert the delay time in seconds
to sample count, which in turn is used by processSample() to calculate buffer
read positions. 
*/
int DelayEffect::getDelayInSamples() const {
    return static_cast<int>(delayTime * sampleRate);
}

void DelayEffect::setDelayTime(float timeInSeconds) {
    delayTime = std::clamp(timeInSeconds, 0.001f, 2.0f);
}

void DelayEffect::setFeedback(float fb) {
    feedback = std::clamp(fb, 0.0f, 0.95f); 
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