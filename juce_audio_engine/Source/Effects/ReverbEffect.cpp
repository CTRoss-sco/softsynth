#include "ReverbEffect.h"
#include <algorithm>

/*
A class to represent the Reverb effect, with 4 nested
DelayLine structs. The Reverb effect class inherits methods
from the base Effects class.
*/


/*
DelayLine struct constructor. Takes in a parameter delaySize to
be used as the size of the buffer, initialises each sample within the
buffer to zero (silence), and initialises the write position
of the buffer to the start.
*/
ReverbEffect::DelayLine::DelayLine(int delaySize) 
    : buffer(delaySize, 0.0f),
             writePos(0),
             size(delaySize) {
}

/*
DelayLine method to process incoming audio samples. Takes in a float
value to represent the input audio sample, and a float value feedback
that represents the feedback amount to create the echo effect of the reverb.
The current buffer position is written to with the new value, then the position 
is advanced by one for the next method call. A float value representing the reverb
sample is returned.
*/
float ReverbEffect::DelayLine::process(float input, float feedback) {
    float output = buffer[writePos];
    buffer[writePos] = input + (output * feedback);
    writePos = (writePos + 1) % size;
    return output;
}

/*
DelayLine method to reset each DelayLine struct to silence, and resets
the write position to the start of the buffer. This method
prevents bleed from old audio samples.
*/
void ReverbEffect::DelayLine::clear() {
    std::fill(buffer.begin(), buffer.end(), 0.0f);
    writePos = 0;
}

/*
ReverbEffect class constructor. The parameters used are initialised as 
default values at 0.5f (50% levels) to create a balanced sound. The sampleRate
parameter follows the same sampleRate value used in SynthEngine, which represents
the standard frequency range this is audible in human hearing.
*/
ReverbEffect::ReverbEffect() 
    : roomSize(0.5f),
      damping(0.5f),
      wetLevel(0.3f),
      dryLevel(0.7f),
      sampleRate(44100.0) {
}

/*
ReverbEffect polymorphic class method inherited from the base Effect class. Takes
in an audio sample value, and processes it through each DelayLine struct with varying
buffer sizes. Averages the final reverb value then returns a mix of the original sample
value with the processed reverb sample.
*/
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
}

/*
ReverbEffect class method to reset each DelayLine struct.
*/
void ReverbEffect::reset() {
    delay1.clear();
    delay2.clear();
    delay3.clear();
    delay4.clear();
}

/*
ReverbEffect polymorphic class method inherited from base class
Effect. As each type of effect will have different amounts of
parameter values to adjust, a switch statement is used to
account for these differences between different effects. 
*/
void ReverbEffect::setParameter(int paramId, float value) {
    switch (paramId) {
        case 0: roomSize = value; break;
        case 1: damping = value; break;   
        case 2: wetLevel = value; break;  
        case 3: dryLevel = value; break;  
    }
}

bool ReverbEffect::isActive() const {
    return wetLevel > 0.0f;
}

float ReverbEffect::getRoomSize() const {
    return roomSize;
}

float ReverbEffect::getDamping() const {
    return damping;
}

float ReverbEffect::getWetLevel() const {
    return wetLevel;
}

float ReverbEffect::getDryLevel() const {
    return dryLevel;
}
