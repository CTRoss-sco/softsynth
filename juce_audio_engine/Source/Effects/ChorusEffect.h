#pragma once
#include "Effect.h"
#include <vector>
#include <cmath>

class ChorusEffect : public Effect {
private:
    struct ChorusVoice {
        std::vector<float> delayBuffer;
        int writePosition;
        int bufferSize;
        float baseDelayTime;
        float lfoPhase;

        ChorusVoice() : writePosition(0), bufferSize(0), baseDelayTime(0.0f), lfoPhase(0.0f) {}
    };

    std::vector<ChorusVoice> voices;

    double sampleRate;
    float rate;
    float depth;
    float feedback;
    float wetLevel;
    float dryLevel;
    bool enabled;

    //variable to track lfo state
    float masterLfoPhase;

    //Constant variables
    static constexpr float MIN_DELAY_MS = 5.0f;
    static constexpr float MAX_DELAY_MS = 20.0f;

    //helper methods
    float generateLFO(float phase);
    void updateVoiceDelayTimes();
    int getDelayInSamples(float delayTimeMs) const;

public:
    ChorusEffect();

    //Override methods from base Effect class
    float processSample(float sample) override;
    void setSampleRate(double sr) override;
    void reset() override;
    void setParameter(int paramId, float value) override;
    bool isActive() const override;

    //Methods specific to ChorusEffect only
    void setRate(float rateHz);
    void setDepth(float depth);
    void setVoices(int numVoices);
    void setFeedback(float fb);
    void setWetLevel(float wet);
    void setDryLevel(float dry);
    void setEnabled(bool enable);

};