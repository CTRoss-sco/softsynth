#pragma once

#include <juce_audio_basics/juce_audio_basics.h>
#include <juce_audio_devices/juce_audio_devices.h>
#include <juce_core/juce_core.h>
#include <map>
#include "Oscillator.h"
#include "Effects/Filter.h" 

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
    
    // Audio device management
    juce::AudioDeviceManager audioDeviceManager;
    juce::AudioSourcePlayer audioSourcePlayer;
    
    float midiNoteToFrequency(int midiNote);
};