#include "ffi_bridge.h"
#include "../../juce_audio_engine/Source/SynthEngine.h"
#include <memory>

struct SynthEngineHandle {
    std::unique_ptr<SynthEngine> engine;
};

extern "C" {

SynthEngineHandle* synth_create() {
    auto* handle = new SynthEngineHandle();
    handle->engine = std::make_unique<SynthEngine>();
    return handle;
}

void synth_destroy(SynthEngineHandle* handle) {
    delete handle;
}

void synth_set_cutoff(SynthEngineHandle* handle, float value) {
    if (handle && handle->engine) {
        handle->engine->setCutoff(value);
    }
}

void synth_note_on(SynthEngineHandle* handle, int note, float velocity) {
    if (handle && handle->engine) {
        // TODO: Implement note on functionality
    }
}

void synth_note_off(SynthEngineHandle* handle, int note) {
    if (handle && handle->engine) {
        // TODO: Implement note off functionality
    }
}

void synth_process_audio(SynthEngineHandle* handle, float* buffer, int frames) {
    if (handle && handle->engine) {
        // TODO: Implement audio processing
    }
}

}
