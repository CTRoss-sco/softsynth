// effects_bridge/src/effects_ffi.h
#pragma once

#ifdef _WIN32
#define EFFECTSFFI_API __declspec(dllexport)
#else
#define EFFECTSFFI_API
#endif

struct EffectsHandle;

extern "C" {
    EFFECTSFFI_API EffectsHandle* effects_create();
    EFFECTSFFI_API void effects_destroy(EffectsHandle* handle);
    EFFECTSFFI_API void effects_set_sample_rate(EffectsHandle* handle, double sampleRate);
    EFFECTSFFI_API void effects_reset(EffectsHandle* handle);
    
    // Reverb parameters (using your parameter ID system)
    EFFECTSFFI_API void effects_set_reverb_room_size(EffectsHandle* handle, float value);
    EFFECTSFFI_API void effects_set_reverb_damping(EffectsHandle* handle, float value);
    EFFECTSFFI_API void effects_set_reverb_wet_level(EffectsHandle* handle, float value);
    EFFECTSFFI_API void effects_set_reverb_dry_level(EffectsHandle* handle, float value);
    
    // Process audio
    EFFECTSFFI_API void effects_process_audio(EffectsHandle* handle, 
                                             float* buffer, int numSamples);
}