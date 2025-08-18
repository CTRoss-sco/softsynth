#include "SynthEngine.h"
#include <iostream>
#include <cmath>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/*
Class to represent the main synthesis engine,
handling both oscillators, the filter, and effects.
*/

/*
Constructor for the SynthEngine class, that also instantiates
the other effect and filter components.
*/
SynthEngine::SynthEngine() 
    : cutoffFrequency(1000.0f),
    currentSampleRate(44100.0), //44100kHz corresponds to CD quality audio
    globalOsc1Waveform(WaveformType::SINE),
    globalOsc2Waveform(WaveformType::SINE),
    globalDetune(0.0f),
    globalMix(0.5f),
    reverbEnabled(false),
    oscilloscopeEnabled(false),
    oscilloscopeBufferSize(512) {

    filter = std::make_unique<LowpassFilter>();
    filter->setSampleRate(44100.0);
    filter->setCutoff(1000.0f);
    filter->setResonance(1.0f);

    reverbEffect = std::make_unique<ReverbEffect>();
    delayEffect = std::make_unique<DelayEffect>();
    chorusEffect = std::make_unique<ChorusEffect>();
    rebuildEffectsChain();

    std::cout << "SynthEngine created with dual oscillators" << std::endl;
}

SynthEngine::~SynthEngine() {
    shutdownAudio();
    std::cout << "SynthEngine destroyed" << std::endl;
}

/*
Method to initialise the audio settings and specify the number
of audio device outputs (2 is used for stereo output).
*/
bool SynthEngine::initializeAudio() {
    auto result = audioDeviceManager.initialiseWithDefaultDevices(0, 2); 
    
    if (result.isNotEmpty()) {
        std::cout << "Failed to initialize audio: " << result.toStdString() << std::endl;
        return false;
    }
    
    audioSourcePlayer.setSource(this);
    audioDeviceManager.addAudioCallback(&audioSourcePlayer);
    
    std::cout << "Audio initialized successfully" << std::endl;
    
    auto* currentDevice = audioDeviceManager.getCurrentAudioDevice();
    if (currentDevice != nullptr) {
        std::cout << "Using audio device: " << currentDevice->getName().toStdString() << std::endl;
        std::cout << "Sample rate: " << currentDevice->getCurrentSampleRate() << " Hz" << std::endl;
        std::cout << "Buffer size: " << currentDevice->getCurrentBufferSizeSamples() << " samples" << std::endl;
    }
    
    return true;
}

void SynthEngine::shutdownAudio() {
    audioDeviceManager.removeAudioCallback(&audioSourcePlayer);
    audioSourcePlayer.setSource(nullptr);
    audioDeviceManager.closeAudioDevice();
}

void SynthEngine::setCutoff(float value) {
    cutoffFrequency = value;
    if (filter) {
        filter->setCutoff(value);
    }
}

void SynthEngine::setResonance(float value) {
    if (filter) {
        filter->setResonance(value);
    }
}
/*
Method to add a new note being played to the sound. Takes
in a MIDI note number and a velocity value representing
how hard the note was pressed. In the current iteration of
the application, velocity is fixed across all input types.
*/
void SynthEngine::noteOn(int midiNote, float velocity) {
    float frequency = midiNoteToFrequency(midiNote);
    
    // Create or reuse voice
    DualOscVoice& voice = activeVoices[midiNote];
    
    // Apply current global settings to the voice
    voice.setOsc1Waveform(globalOsc1Waveform);
    voice.setOsc2Waveform(globalOsc2Waveform);
    voice.setDetune(globalDetune);
    voice.setMix(globalMix);
    
    // Start the note
    voice.noteOn(frequency, velocity);
    
    std::cout << "Note ON: " << midiNote << " (freq: " << frequency << "Hz)" << std::endl;
}

/*
Method that stops a note from playing when the key is not being 
pressed anymore. Takes in an integer parameter representing the
MIDI note value of the note, which is used to find the corresponding
note in activeVoices.
*/
void SynthEngine::noteOff(int midiNote) {
    auto it = activeVoices.find(midiNote);
    if (it != activeVoices.end()) {
        it->second.noteOff();
        std::cout << "Note OFF: " << midiNote << std::endl;
    }
}


void SynthEngine::setOsc1Waveform(WaveformType type) {
    globalOsc1Waveform = type;
    // Applies to all active notes
    for (auto& voice : activeVoices) {
        voice.second.setOsc1Waveform(type);
    }
}

void SynthEngine::setOsc2Waveform(WaveformType type) {
    globalOsc2Waveform = type;
    // Applies to all active notes
    for (auto& voice : activeVoices) {
        voice.second.setOsc2Waveform(type);
    }
}

void SynthEngine::setDetune(float cents) {
    globalDetune = cents;
    // Applies to all active notes
    for (auto& voice : activeVoices) {
        voice.second.setDetune(cents);
    }
}

void SynthEngine::setOscMix(float mix) {
    globalMix = mix;
    // Applies to all active notes
    for (auto& voice : activeVoices) {
        voice.second.setMix(mix);
    }
}

void SynthEngine::enableReverb(bool enable) {
    reverbEnabled = enable;
    if (reverbEffect) {
        reverbEffect->setSampleRate(currentSampleRate);
        if (enable) {
            reverbEffect->reset(); // Clear any existing reverb tail
        }
    }
    rebuildEffectsChain(); // Rebuild chain when effects change
}

void SynthEngine::setReverbParameter(int paramId, float value) {
    if (reverbEffect) {
        reverbEffect->setParameter(paramId, value);
    }
}

void SynthEngine::enableDelay(bool enable) {
    if (delayEffect) {
        delayEffect->setEnabled(enable);
        rebuildEffectsChain();
    }
}

void SynthEngine::setDelayTime(float timeInSeconds) {
    if (delayEffect) {
        delayEffect->setDelayTime(timeInSeconds);
    }
}

void SynthEngine::setDelayFeedback(float feedback) {
    if (delayEffect) {
        delayEffect->setFeedback(feedback);
    }
}

void SynthEngine::setDelayWetLevel(float wetLevel) {
    if (delayEffect) {
        delayEffect->setWetLevel(wetLevel);
    }
}

void SynthEngine::setDelayDryLevel(float dryLevel) {
    if (delayEffect) {
        delayEffect->setDryLevel(dryLevel);
    }
}

void SynthEngine::enableChorus(bool enable) {
    if (chorusEffect) {
        chorusEffect->setEnabled(enable);
        rebuildEffectsChain();
    }
}

void SynthEngine::setChorusRate(float rate) {
    if (chorusEffect) {
        chorusEffect->setRate(rate);
    }
}

void SynthEngine::setChorusDepth(float depth) {
    if (chorusEffect) {
        chorusEffect->setDepth(depth);
    }
}

void SynthEngine::setChorusVoices(int voices) {
    if (chorusEffect) {
        chorusEffect->setVoices(voices);
    }
}

void SynthEngine::setChorusFeedback(float feedback) {
    if (chorusEffect) {
        chorusEffect->setFeedback(feedback);
    }
}

void SynthEngine::setChorusWetLevel(float wetLevel) {
    if (chorusEffect) {
        chorusEffect->setWetLevel(wetLevel);
    }
}

void SynthEngine::setChorusDryLevel(float dryLevel) {
    if (chorusEffect) {
        chorusEffect->setDryLevel(dryLevel);
    }
}

//getter methods for oscillators
WaveformType SynthEngine::getOsc1Waveform() const {
    return globalOsc1Waveform;
}

WaveformType SynthEngine::getOsc2Waveform() const {
    return globalOsc2Waveform;
}

float SynthEngine::getDetune() const {
    return globalDetune;
}

float SynthEngine::getOscMix() const {
    return globalMix;
}

//low pass filter getter methods
float SynthEngine::getCutoff() const {
    return cutoffFrequency;
}

float SynthEngine::getResonance() const {
    if (filter) {
        return filter->getResonance();
    }
    return 1.0f; //returns default resonance if alternate value not set
}

//reverb getter methods
bool SynthEngine::isReverbEnabled() const {
    return reverbEnabled;
}

float SynthEngine::getReverbRoomSize() const {
    if (reverbEffect) {
        return reverbEffect->getRoomSize();
    }
    return 0.5f; // Default value
}

float SynthEngine::getReverbDamping() const {
    if (reverbEffect) {
        return reverbEffect->getDamping();
    }
    return 0.5f; // Default value
}

float SynthEngine::getReverbWetLevel() const {
    if (reverbEffect) {
        return reverbEffect->getWetLevel();
    }
    return 0.3f; // Default value
}

float SynthEngine::getReverbDryLevel() const {
    if (reverbEffect) {
        return reverbEffect->getDryLevel();
    }
    return 0.7f; // Default value
}

bool SynthEngine::isDelayEnabled() const {
    if (delayEffect) {
        return delayEffect->isActive();
    }
    return false;
}

float SynthEngine::getDelayTime() const {
    if (delayEffect) {
        return delayEffect->getDelayTime();
    }
    return 0.3f; // Default value
}

float SynthEngine::getDelayFeedback() const {
    if (delayEffect) {
        return delayEffect->getFeedback();
    }
    return 0.3f; // Default value
}

float SynthEngine::getDelayWetLevel() const {
    if (delayEffect) {
        return delayEffect->getWetLevel();
    }
    return 0.3f; // Default value
}

float SynthEngine::getDelayDryLevel() const {
    if (delayEffect) {
        return delayEffect->getDryLevel();
    }
    return 0.7f; // Default value
}

bool SynthEngine::isChorusEnabled() const {
    if (chorusEffect) {
        return chorusEffect->isActive();
    }
    return false;
}

float SynthEngine::getChorusRate() const {
    if (chorusEffect) {
        return chorusEffect->getRate();
    }
    return 1.5f; // Default value
}

float SynthEngine::getChorusDepth() const {
    if (chorusEffect) {
        return chorusEffect->getDepth();
    }
    return 0.4f; // Default value
}

int SynthEngine::getChorusVoices() const {
    if (chorusEffect) {
        return chorusEffect->getVoices();
    }
    return 2; // Default value
}

float SynthEngine::getChorusFeedback() const {
    if (chorusEffect) {
        return chorusEffect->getFeedback();
    }
    return 0.2f; // Default value
}

float SynthEngine::getChorusWetLevel() const {
    if (chorusEffect) {
        return chorusEffect->getWetLevel();
    }
    return 0.5f; // Default value
}

float SynthEngine::getChorusDryLevel() const {
    if (chorusEffect) {
        return chorusEffect->getDryLevel();
    }
    return 0.8f; // Default value
}

/*
Method to manage the specific order of effects that are
enabled at any one time. 
*/
void SynthEngine::rebuildEffectsChain() {
    effectsChain.clear();
    
    // Effects chain is built in the following order:
    // 1. Modulation effects (chorus) 
    // 2. Time-based effects (delay)   
    // 3. Spatial effects (reverb) 

    if (chorusEffect && chorusEffect->isActive()) {
        effectsChain.push_back([this](float sample) {
            return chorusEffect->processSample(sample);
        });
    }

    if (delayEffect && delayEffect->isActive()) {
        effectsChain.push_back([this](float sample) {
            return delayEffect->processSample(sample);
        });
    }
    
    if (reverbEnabled && reverbEffect && reverbEffect->isActive()) {
        effectsChain.push_back([this](float sample) {
            return reverbEffect->processSample(sample);
        });
    }

    
}


/*
Method that manages the processing of audio samples through the
effects chain.
*/
float SynthEngine::processEffectsChain(float sample) {
    // Process sample through each effect in the chain
    for (auto& effect : effectsChain) {
        sample = effect(sample);
    }
    return sample;
}

/*
Inherited method from JUCE's AudioSource class. Takes in a 
sampleRate parameter and updates each component's sample rate 
member variable for real-time audio processing. 
*/
void SynthEngine::prepareToPlay(int samplesPerBlockExpected, double sampleRate) {
    currentSampleRate = sampleRate;
    if (filter) {
        filter->setSampleRate(sampleRate);
    }

    if (reverbEffect) {
        reverbEffect->setSampleRate(sampleRate);
    }

    if (delayEffect) {
        delayEffect->setSampleRate(sampleRate);
    }

    if (chorusEffect) {
        chorusEffect->setSampleRate(sampleRate);
    }

    std::cout << "Prepared to play: " << samplesPerBlockExpected << " samples at " << sampleRate << " Hz" << std::endl;
}

/*
Inherited method from JUCE's AudioSource class. It is called for every audio
block. This mixes all the active voices (notes), applies gain compensation for 
multiple notes at once, processes through filter and effects, captures oscilloscope
data and outputs audio in stereo format.
*/
void SynthEngine::getNextAudioBlock(const juce::AudioSourceChannelInfo& bufferToFill) {
    // Clear the buffer first
    bufferToFill.clearActiveBufferRegion();
    
    // Get buffer details
    int numSamples = bufferToFill.numSamples;
    int numChannels = bufferToFill.buffer->getNumChannels();
    
    // Count active voices for gain compensation
    int activeVoiceCount = 0;
    for (auto& voicePair : activeVoices) {
        if (voicePair.second.isActive()) {
            activeVoiceCount++;
        }
    }
    
    // Skip processing if no active voices
    if (activeVoiceCount == 0) {
        
        if (oscilloscopeEnabled) {
            int captureSize = std::min(numSamples, oscilloscopeBufferSize);
            for (int i = 0; i < captureSize; ++i) {
                oscilloscopeBuffer[i] = 0.0f;
            }
        }
        return;
    }
    
    // Calculate polyphonic gain compensation
    float polyGain = 1.0f / std::sqrt(static_cast<float>(activeVoiceCount));
    float masterGain = 0.4f; // Overall volume reduction
    float totalGain = polyGain * masterGain;
    
    // Generate audio for each sample
    for (int sample = 0; sample < numSamples; ++sample) {
        float mixedSample = 0.0f;
        
        // Sum all active voices
        for (auto& voicePair : activeVoices) {
            DualOscVoice& voice = voicePair.second;
            if (voice.isActive()) {
                mixedSample += voice.generateSample(currentSampleRate);
            }
        }
        
        // Apply polyphonic gain compensation
        mixedSample *= totalGain;

        //any filters applied are processed after gain compensation
        if (filter) {
            mixedSample = filter->processSample(mixedSample);
        }

        if (!effectsChain.empty()) {
            mixedSample = processEffectsChain(mixedSample);
        }
        
        // Soft limiter to prevent harsh clipping
        if (mixedSample > 0.95f) {
            mixedSample = 0.95f + 0.05f * std::tanh((mixedSample - 0.95f) / 0.05f);
        } else if (mixedSample < -0.95f) {
            mixedSample = -0.95f + 0.05f * std::tanh((mixedSample + 0.95f) / 0.05f);
        }

        //Oscilloscope data capture
        if (oscilloscopeEnabled && sample < oscilloscopeBufferSize) {
            oscilloscopeBuffer[sample] = mixedSample;
        }
        
        // Write to all output channels
        for (int channel = 0; channel < numChannels; ++channel) {
            bufferToFill.buffer->addSample(channel, bufferToFill.startSample + sample, mixedSample);
        }
    }
    
    // Clean up inactive voices
    auto it = activeVoices.begin();
    while (it != activeVoices.end()) {
        if (!it->second.isActive()) {
            it = activeVoices.erase(it);
        } else {
            ++it;
        }
    }
}

/*
Inherited method from JUCE's AudioSource class. Clears
all active voices(notes) currently playing to prevent resource
leaks.
*/
void SynthEngine::releaseResources() {
    // Clear all voices when audio stops
    activeVoices.clear();
    std::cout << "Audio resources released" << std::endl;
}

/*
Helper method used to convert MIDI note numbers to frequencies.
The value 440.0f is used as this corresponds to equal temperament tuning.
*/
float SynthEngine::midiNoteToFrequency(int midiNote) {
    return 440.0f * std::pow(2.0f, (midiNote - 69) / 12.0f);
}

/*
Enables and disables oscilloscope visualisation by setting
oscilloscopeEnabled to true/false, and allocates a buffer to capture
audio samples.
*/
void SynthEngine::enableOscilloscope(bool enable) {
    oscilloscopeEnabled = enable;
    if (enable) {
        oscilloscopeBuffer.resize(oscilloscopeBufferSize);
        std::fill(oscilloscopeBuffer.begin(), oscilloscopeBuffer.end(), 0.0f);
        DBG("Oscilloscope enabled");
    } else {
        DBG("Oscilloscope disabled");
    }
}

/*
Method to copy over the captured audio samples to an external buffer
for the oscilloscope display. Takes in a pointer to the first element
of the buffer where waveform data will be written and an integer value 
representing the size of the buffer.
*/
int SynthEngine::getWaveformData(float* buffer, int bufferSize) {
    if (!oscilloscopeEnabled || !buffer) return 0;

    int samplesAvailable = std::min(bufferSize, (int)oscilloscopeBuffer.size());
    std::copy(oscilloscopeBuffer.begin(), oscilloscopeBuffer.begin() + samplesAvailable, buffer);

    return samplesAvailable;
}