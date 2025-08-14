#pragma once

class Effect {
public:
    Effect() = default;
    virtual ~Effect() = default;
    
    
    virtual float processSample(float sample) = 0;
    virtual void setSampleRate(double sampleRate) = 0;
    virtual void reset() = 0;
    virtual void setParameter(int paramId, float value) {}
    virtual bool isActive() const { return true; }
};