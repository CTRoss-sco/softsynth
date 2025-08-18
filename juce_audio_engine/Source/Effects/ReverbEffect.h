#pragma once
#include "Effect.h"
#include <vector>

/*
Header file for the ReverbEffect class.
*/

class ReverbEffect : public Effect {
private:
    struct DelayLine {
        std::vector<float> buffer;
        int writePos;
        int size;
        
        DelayLine(int delaySize);
        float process(float input, float feedback);
        void clear();
    };
    
    /*
    DelayLines are initialised using prime numbers to simulate
    natural reverb characteristics.
    */ 
    DelayLine delay1{1051};
    DelayLine delay2{1399};
    DelayLine delay3{1777};
    DelayLine delay4{2003};
    
    // Reverb Effect class member variables
    float roomSize;
    float damping;
    float wetLevel;
    float dryLevel;
    double sampleRate;
    
public:
    ReverbEffect();
    
    //Overrides the Effect base class methods
    float processSample(float sample) override;
    void setSampleRate(double sr) override;
    void reset() override;
    void setParameter(int paramId, float value) override;
    bool isActive() const override;

    //getter methods for reverb effect member variables
    float getRoomSize() const;
    float getDamping() const;
    float getWetLevel() const;
    float getDryLevel() const;
};