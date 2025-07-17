#include <iostream>
#include <map>
#include <cmath>

struct Voice {
    float frequency;
    float velocity;
    bool active;
    
    Voice() : frequency(0.0f), velocity(0.0f), active(false) {}
};

// Simple synth state
static std::map<int, Voice> activeVoices;
static float cutoffFrequency = 1000.0f;

extern "C" {

#ifdef _WIN32
    #ifdef BUILDING_SYNTHFFI_DLL
        #define SYNTHFFI_API __declspec(dllexport)
    #else
        #define SYNTHFFI_API __declspec(dllimport)
    #endif
#else
    #define SYNTHFFI_API
#endif

float midiNoteToFrequency(int midiNote) {
    // Convert MIDI note to frequency: f = 440 * 2^((n-69)/12)
    return 440.0f * std::pow(2.0f, (midiNote - 69) / 12.0f);
}

// Enhanced test functions with basic synth simulation
SYNTHFFI_API void* test_create() {
    std::cout << "Enhanced synth created with audio simulation" << std::endl;
    return (void*)0x12345678; // Return a dummy pointer
}

SYNTHFFI_API void test_destroy(void* handle) {
    activeVoices.clear();
    std::cout << "Enhanced synth destroyed, " << activeVoices.size() << " voices cleared" << std::endl;
}

SYNTHFFI_API void test_note_on(void* handle, int note, float velocity) {
    float frequency = midiNoteToFrequency(note);
    activeVoices[note] = {frequency, velocity, true};
    
    std::cout << "♪ Note ON: " << note << " (" << frequency << " Hz) - Velocity: " << velocity 
              << " - Active voices: " << activeVoices.size() << std::endl;
}

SYNTHFFI_API void test_note_off(void* handle, int note) {
    auto it = activeVoices.find(note);
    if (it != activeVoices.end()) {
        std::cout << "♫ Note OFF: " << note << " (" << it->second.frequency << " Hz)" << std::endl;
        activeVoices.erase(it);
    }
    std::cout << "Active voices remaining: " << activeVoices.size() << std::endl;
}

SYNTHFFI_API void test_set_cutoff(void* handle, float value) {
    cutoffFrequency = value;
    std::cout << "🎛️  Filter cutoff: " << value << " Hz" << std::endl;
}

}
