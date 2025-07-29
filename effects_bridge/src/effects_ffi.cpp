#include "effects_ffi.h"
#include "../../juce_audio_engine/Source/Effects/ReverbEffect.h"
#include <memory>

struct EffectsHandle {
    std::unique_ptr<ReverbEffect> reverb;
};

extern "C" {
    EffectsHandle* effects_create() {
        auto* handle = new EffectsHandle();
        handle->reverb = std::make_unique<ReverbEffect>();
        return handle;
    }
    
    void effects_destroy(EffectsHandle* handle) {
        delete handle;
    }
    
    void effects_set_sample_rate(EffectsHandle* handle, double sampleRate) {
        if (handle && handle->reverb) {
            handle->reverb->setSampleRate(sampleRate);
        }
    }
    
    void effects_reset(EffectsHandle* handle) {
        if (handle && handle->reverb) {
            handle->reverb->reset();
        }
    }
    
    void effects_set_reverb_room_size(EffectsHandle* handle, float value) {
        if (handle && handle->reverb) {
            handle->reverb->setParameter(0, value); // param ID 0 = room size
        }
    }
    
    void effects_set_reverb_damping(EffectsHandle* handle, float value) {
        if (handle && handle->reverb) {
            handle->reverb->setParameter(1, value); // param ID 1 = damping
        }
    }
    
    void effects_set_reverb_wet_level(EffectsHandle* handle, float value) {
        if (handle && handle->reverb) {
            handle->reverb->setParameter(2, value); // param ID 2 = wet level
        }
    }

    void effects_set_reverb_dry_level(EffectsHandle* handle, float value) { 
        if (handle && handle->reverb) {
            handle->reverb->setParameter(3, value); // param ID 3 = dry level
        }
    }

    void effects_process_audio(EffectsHandle* handle, float* buffer, int numSamples) {
        if (handle && handle->reverb && handle->reverb->isActive()) {
            for (int i = 0; i < numSamples; ++i) {
                buffer[i] = handle->reverb->processSample(buffer[i]);
            }
        }
    }
}