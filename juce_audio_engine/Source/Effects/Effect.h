#pragma once

class Effect {
public:
    Effect() = default;
    virtual ~Effect() = default;
    
    // Pure virtual methods - must be implemented by derived classes
    virtual float processSample(float sample) = 0;
    virtual void setSampleRate(double sampleRate) = 0;
    virtual void reset() = 0;
    
    // Virtual methods with default implementations
    virtual void setParameter(int paramId, float value) {}
    virtual bool isActive() const { return true; }
};