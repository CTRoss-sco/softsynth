#pragma once
#include "Effect.h"
#include <vector>

class ReverbEffect : public Effect {
private:
    // Simple delay line implementation
    struct DelayLine {
        std::vector<float> buffer;
        int writePos;
        int size;
        
        DelayLine(int delaySize);
        float process(float input, float feedback);
        void clear();
    };
    
    // Multiple delay lines for rich reverb (using prime numbers)
    DelayLine delay1{1051};
    DelayLine delay2{1399};
    DelayLine delay3{1777};
    DelayLine delay4{2003};
    
    // Parameters
    float roomSize;
    float damping;
    float wetLevel;
    float dryLevel;
    double sampleRate;
    
public:
    ReverbEffect();
    
    // Override Effect base class methods
    float processSample(float sample) override;
    void setSampleRate(double sr) override;
    void reset() override;
    void setParameter(int paramId, float value) override;
    bool isActive() const override;
};