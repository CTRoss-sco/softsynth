#include "SynthEngine.h"
#include <iostream>
#include <cmath>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

SynthEngine::SynthEngine() 
    : cutoffFrequency(1000.0f), currentSampleRate(44100.0),
      globalOsc1Waveform(WaveformType::SINE), globalOsc2Waveform(WaveformType::SINE),
      globalDetune(0.0f), globalMix(0.5f), reverbEnabled(false) {

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

bool SynthEngine::initializeAudio() {
    // Initialize the audio device manager with default settings
    auto result = audioDeviceManager.initialiseWithDefaultDevices(0, 2); // 0 inputs, 2 outputs
    
    if (result.isNotEmpty()) {
        std::cout << "Failed to initialize audio: " << result.toStdString() << std::endl;
        return false;
    }
    
    // Set up the audio source player
    audioSourcePlayer.setSource(this);
    audioDeviceManager.addAudioCallback(&audioSourcePlayer);
    
    std::cout << "Audio initialized successfully" << std::endl;
    
    // Print current audio device info
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

void SynthEngine::noteOff(int midiNote) {
    auto it = activeVoices.find(midiNote);
    if (it != activeVoices.end()) {
        it->second.noteOff();
        std::cout << "Note OFF: " << midiNote << std::endl;
    }
}

// New dual oscillator controls
void SynthEngine::setOsc1Waveform(WaveformType type) {
    globalOsc1Waveform = type;
    // Apply to all active voices
    for (auto& voice : activeVoices) {
        voice.second.setOsc1Waveform(type);
    }
}

void SynthEngine::setOsc2Waveform(WaveformType type) {
    globalOsc2Waveform = type;
    // Apply to all active voices
    for (auto& voice : activeVoices) {
        voice.second.setOsc2Waveform(type);
    }
}

void SynthEngine::setDetune(float cents) {
    globalDetune = cents;
    // Apply to all active voices
    for (auto& voice : activeVoices) {
        voice.second.setDetune(cents);
    }
}

void SynthEngine::setOscMix(float mix) {
    globalMix = mix;
    // Apply to all active voices
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

void SynthEngine::rebuildEffectsChain() {
    effectsChain.clear();
    
    // Effects chain is built in professional order:
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

float SynthEngine::processEffectsChain(float sample) {
    // Process sample through each effect in the chain
    for (auto& effect : effectsChain) {
        sample = effect(sample);
    }
    return sample;
}

// AudioSource overrides
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
    if (activeVoiceCount == 0) return;
    
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

void SynthEngine::releaseResources() {
    // Clear all voices when audio stops
    activeVoices.clear();
    std::cout << "Audio resources released" << std::endl;
}

float SynthEngine::midiNoteToFrequency(int midiNote) {
    // A4 (MIDI note 69) = 440 Hz
    // Each semitone = 2^(1/12) frequency ratio
    return 440.0f * std::pow(2.0f, (midiNote - 69) / 12.0f);
}