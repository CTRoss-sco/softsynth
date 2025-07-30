#pragma once

#include <juce_audio_basics/juce_audio_basics.h>
#include <juce_audio_devices/juce_audio_devices.h>
#include <juce_core/juce_core.h>
#include <map>
#include <vector>
#include <functional>
#include "Oscillator.h"
#include "Effects/Filter.h" 
#include "Effects/ReverbEffect.h"
#include "Effects/DelayEffect.h"

#ifdef _WIN32
    #ifdef JUCE_DLL_BUILD
        #define SYNTH_API __declspec(dllexport)
    #else
        #define SYNTH_API __declspec(dllimport)
    #endif
#else
    #define SYNTH_API
#endif

class SYNTH_API SynthEngine : public juce::AudioSource {
public:
    SynthEngine();
    ~SynthEngine();
    
    bool initializeAudio();
    void shutdownAudio();
    void setCutoff(float value);
    void setResonance(float value);
    void noteOn(int midiNote, float velocity);
    void noteOff(int midiNote);
    
    // New dual oscillator controls
    void setOsc1Waveform(WaveformType type);
    void setOsc2Waveform(WaveformType type);
    void setDetune(float cents);
    void setOscMix(float mix);
    
    // AudioSource overrides
    void prepareToPlay(int samplesPerBlockExpected, double sampleRate) override;
    void getNextAudioBlock(const juce::AudioSourceChannelInfo& bufferToFill) override;
    void releaseResources() override;

    //reverb effect control
    void enableReverb(bool enable);
    void setReverbParameter(int paramId, float value);

    //delay effect control
    void enableDelay(bool enable);
    void setDelayTime(float timeInSeconds);
    void setDelayFeedback(float feedback);
    void setDelayWetLevel(float wet);
    void setDelayDryLevel(float dry);

private:
    // Replace simple Voice with DualOscVoice
    std::map<int, DualOscVoice> activeVoices;
    
    // Global oscillator parameters (applied to new voices)
    WaveformType globalOsc1Waveform;
    WaveformType globalOsc2Waveform;
    float globalDetune;
    float globalMix;
    
    float cutoffFrequency;
    double currentSampleRate;

    std::unique_ptr<LowpassFilter> filter;

    // system for reverb effect
    std::unique_ptr<ReverbEffect> reverbEffect;
    bool reverbEnabled;

    // system for delay effect
    std::unique_ptr<DelayEffect> delayEffect;

    //vector structure to manage multiple effects at once
    std::vector<std::function<float(float)>> effectsChain;
    
    // Audio device management
    juce::AudioDeviceManager audioDeviceManager;
    juce::AudioSourcePlayer audioSourcePlayer;
    
    float midiNoteToFrequency(int midiNote);

    //methods to handle effects chain
    void rebuildEffectsChain();
    float processEffectsChain(float sample);
};