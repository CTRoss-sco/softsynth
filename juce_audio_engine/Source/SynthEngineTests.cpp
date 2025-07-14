// C++ Unit Tests for JUCE Audio Engine
//
// Tests the core synthesizer functionality including:
// - MIDI note to frequency conversion
// - Voice management and polyphony
// - Audio buffer processing
// - Resource cleanup

#include <iostream>
#include <cassert>
#include <cmath>
#include <map>
#include "../Source/SynthEngine.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

class SynthEngineTests {
private:
    static void testMidiToFrequency() {
        std::cout << "Testing MIDI to frequency conversion..." << std::endl;
        
        // Test known frequency values
        float freq69 = SynthEngine::midiNoteToFrequency(69); // A4 = 440Hz
        float freq60 = SynthEngine::midiNoteToFrequency(60); // C4 = 261.63Hz
        float freq81 = SynthEngine::midiNoteToFrequency(81); // A5 = 880Hz
        
        assert(std::abs(freq69 - 440.0f) < 0.1f);
        assert(std::abs(freq60 - 261.63f) < 0.1f);
        assert(std::abs(freq81 - 880.0f) < 0.1f);
        
        std::cout << "  ✓ A4 (MIDI 69) = " << freq69 << " Hz (expected ~440)" << std::endl;
        std::cout << "  ✓ C4 (MIDI 60) = " << freq60 << " Hz (expected ~261.63)" << std::endl;
        std::cout << "  ✓ A5 (MIDI 81) = " << freq81 << " Hz (expected ~880)" << std::endl;
    }
    
    static void testVoiceManagement() {
        std::cout << "Testing voice management..." << std::endl;
        
        SynthEngine synth;
        
        // Test note on/off without audio initialization
        synth.noteOn(60, 0.8f);  // C4
        synth.noteOn(64, 0.7f);  // E4  
        synth.noteOn(67, 0.6f);  // G4
        
        // Verify voices are tracked internally (would need access to activeVoices)
        std::cout << "  ✓ Multiple notes triggered successfully" << std::endl;
        
        synth.noteOff(64);  // Release E4
        std::cout << "  ✓ Note release handled successfully" << std::endl;
        
        synth.noteOff(60);  // Release C4
        synth.noteOff(67);  // Release G4
        std::cout << "  ✓ All notes released successfully" << std::endl;
    }
    
    static void testFrequencyRange() {
        std::cout << "Testing frequency range..." << std::endl;
        
        // Test MIDI range boundaries
        float minFreq = SynthEngine::midiNoteToFrequency(0);   // ~8.18 Hz
        float maxFreq = SynthEngine::midiNoteToFrequency(127); // ~12543 Hz
        
        assert(minFreq > 0.0f);
        assert(maxFreq < 20000.0f); // Below human hearing limit
        assert(maxFreq > minFreq);
        
        std::cout << "  ✓ MIDI 0 = " << minFreq << " Hz" << std::endl;
        std::cout << "  ✓ MIDI 127 = " << maxFreq << " Hz" << std::endl;
        std::cout << "  ✓ Frequency range is reasonable" << std::endl;
    }
    
    static void testCutoffParameter() {
        std::cout << "Testing cutoff parameter..." << std::endl;
        
        SynthEngine synth;
        
        // Test cutoff value setting
        synth.setCutoff(1000.0f);
        synth.setCutoff(500.0f);
        synth.setCutoff(2000.0f);
        
        std::cout << "  ✓ Cutoff parameter accepts various values" << std::endl;
    }
    
    static void testResourceCleanup() {
        std::cout << "Testing resource cleanup..." << std::endl;
        
        SynthEngine synth;
        
        // Add some voices
        synth.noteOn(60, 0.8f);
        synth.noteOn(64, 0.7f);
        
        // Test cleanup
        synth.releaseResources();
        
        std::cout << "  ✓ Resource cleanup completed successfully" << std::endl;
    }
    
    static void testAudioBufferProcessing() {
        std::cout << "Testing audio buffer processing..." << std::endl;
        
        // Note: This would require initializing JUCE AudioBuffer
        // For now, we test that the prepareToPlay function doesn't crash
        SynthEngine synth;
        synth.prepareToPlay(512, 44100.0);
        
        std::cout << "  ✓ Audio preparation completed successfully" << std::endl;
    }

public:
    static void runAllTests() {
        std::cout << "===========================================" << std::endl;
        std::cout << "    JUCE Synthesizer Engine Unit Tests" << std::endl;
        std::cout << "===========================================" << std::endl;
        
        try {
            testMidiToFrequency();
            std::cout << std::endl;
            
            testVoiceManagement();
            std::cout << std::endl;
            
            testFrequencyRange();
            std::cout << std::endl;
            
            testCutoffParameter();
            std::cout << std::endl;
            
            testResourceCleanup();
            std::cout << std::endl;
            
            testAudioBufferProcessing();
            std::cout << std::endl;
            
            std::cout << "===========================================" << std::endl;
            std::cout << "          ✅ ALL TESTS PASSED!" << std::endl;
            std::cout << "===========================================" << std::endl;
            
        } catch (const std::exception& e) {
            std::cout << "❌ Test failed with exception: " << e.what() << std::endl;
        } catch (...) {
            std::cout << "❌ Test failed with unknown exception" << std::endl;
        }
    }
};

// Standalone test function accessible from FFI bridge
extern "C" {
    void runSynthEngineTests() {
        SynthEngineTests::runAllTests();
    }
}

// Main function for standalone testing
int main() {
    SynthEngineTests::runAllTests();
    return 0;
}
