#include "SynthEngine.h"
#include <iostream>
#include <cmath>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

SynthEngine::SynthEngine() : cutoffFrequency(1000.0f), currentSampleRate(44100.0) {
    std::cout << "SynthEngine created" << std::endl;
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
    std::cout << "Audio shutdown" << std::endl;
}

void SynthEngine::setCutoff(float value) {
    cutoffFrequency = value;
    std::cout << "Setting cutoff to " << value << std::endl;
}

void SynthEngine::noteOn(int midiNote, float velocity) {
    Voice& voice = activeVoices[midiNote];
    voice.frequency = midiNoteToFrequency(midiNote);
    voice.velocity = velocity;
    voice.phase = 0.0f;
    voice.isActive = true;
    
    std::cout << "Note ON: " << midiNote << " (" << voice.frequency << " Hz) - Velocity: " << velocity << std::endl;
}

void SynthEngine::noteOff(int midiNote) {
    auto it = activeVoices.find(midiNote);
    if (it != activeVoices.end()) {
        it->second.isActive = false;
        activeVoices.erase(it);
    }
    
    std::cout << "Note OFF: " << midiNote << std::endl;
}

void SynthEngine::prepareToPlay(int samplesPerBlockExpected, double sampleRate) {
    currentSampleRate = sampleRate;
    std::cout << "Audio prepared: " << sampleRate << " Hz, " << samplesPerBlockExpected << " samples per block" << std::endl;
}

void SynthEngine::getNextAudioBlock(const juce::AudioSourceChannelInfo& bufferToFill) {
    bufferToFill.clearActiveBufferRegion();
    
    auto* leftChannel = bufferToFill.buffer->getWritePointer(0, bufferToFill.startSample);
    auto* rightChannel = bufferToFill.buffer->getWritePointer(1, bufferToFill.startSample);
    
    for (int sample = 0; sample < bufferToFill.numSamples; ++sample) {
        float mixedSample = 0.0f;
        
        // Generate audio for each active voice
        for (auto& voicePair : activeVoices) {
            Voice& voice = voicePair.second;
            if (voice.isActive) {
                // Simple sine wave synthesis
                float sine = std::sin(voice.phase) * voice.velocity * 0.3f;
                mixedSample += sine;
                
                // Update phase
                voice.phase += (voice.frequency * 2.0f * M_PI) / currentSampleRate;
                if (voice.phase >= 2.0f * M_PI) {
                    voice.phase -= 2.0f * M_PI;
                }
            }
        }
        
        // Apply simple limiting
        mixedSample = juce::jlimit(-1.0f, 1.0f, mixedSample);
        
        leftChannel[sample] = mixedSample;
        rightChannel[sample] = mixedSample;
    }
}

void SynthEngine::releaseResources() {
    activeVoices.clear();
    std::cout << "Audio resources released" << std::endl;
}

float SynthEngine::midiNoteToFrequency(int midiNote) {
    // Convert MIDI note to frequency: f = 440 * 2^((n-69)/12)
    return 440.0f * std::pow(2.0f, (midiNote - 69) / 12.0f);
}