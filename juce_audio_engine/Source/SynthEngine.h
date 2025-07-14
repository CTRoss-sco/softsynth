#pragma once

#include <juce_audio_basics/juce_audio_basics.h>
#include <juce_audio_devices/juce_audio_devices.h>
#include <juce_core/juce_core.h>
#include <map>

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
    void noteOn(int midiNote, float velocity);
    void noteOff(int midiNote);
    
    // AudioSource overrides
    void prepareToPlay(int samplesPerBlockExpected, double sampleRate) override;
    void getNextAudioBlock(const juce::AudioSourceChannelInfo& bufferToFill) override;
    void releaseResources() override;

private:
    struct Voice {
        float frequency;
        float phase;
        float velocity;
        bool isActive;
        
        Voice() : frequency(0.0f), phase(0.0f), velocity(0.0f), isActive(false) {}
    };
    
    std::map<int, Voice> activeVoices;
    float cutoffFrequency;
    double currentSampleRate;
    
    // Audio device management
    juce::AudioDeviceManager audioDeviceManager;
    juce::AudioSourcePlayer audioSourcePlayer;
    
    float midiNoteToFrequency(int midiNote);
};