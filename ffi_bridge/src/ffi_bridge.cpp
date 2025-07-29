#include "ffi_bridge.h"
#include "../../juce_audio_engine/Source/SynthEngine.h"
#include "../../juce_audio_engine/Source/Oscillator.h"  
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

int synth_initialize_audio(SynthEngineHandle* handle) {
    if (handle && handle->engine) {
        return handle->engine->initializeAudio() ? 1 : 0;
    }
    return 0;
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
        handle->engine->noteOn(note, velocity);
    }
}

void synth_note_off(SynthEngineHandle* handle, int note) {
    if (handle && handle->engine) {
        handle->engine->noteOff(note);
    }
}

void synth_process_audio(SynthEngineHandle* handle, float* buffer, int frames) {
    if (handle && handle->engine) {
        // TODO: Implement audio processing
    }
}

// New dual oscillator control functions
void synth_set_osc1_waveform(SynthEngineHandle* handle, int waveform) {
    if (handle && handle->engine) {
        handle->engine->setOsc1Waveform(static_cast<WaveformType>(waveform));
    }
}

void synth_set_osc2_waveform(SynthEngineHandle* handle, int waveform) {
    if (handle && handle->engine) {
        handle->engine->setOsc2Waveform(static_cast<WaveformType>(waveform));
    }
}

void synth_set_detune(SynthEngineHandle* handle, float cents) {
    if (handle && handle->engine) {
        handle->engine->setDetune(cents);
    }
}

void synth_set_osc_mix(SynthEngineHandle* handle, float mix) {
    if (handle && handle->engine) {
        handle->engine->setOscMix(mix);
    }
}

void synth_set_filter_cutoff(SynthEngineHandle* handle, float value) {
    if (handle && handle->engine) {
        handle->engine->setCutoff(value);
    }
}

void synth_set_filter_resonance(SynthEngineHandle* handle, float value) {
    if (handle && handle->engine) {
        handle->engine->setResonance(value);
    }
}

void synth_enable_effects_processing(SynthEngineHandle* handle, bool enable) {
        if (!handle || !handle->engine) return;
        handle->engine->enableReverb(enable);
}

void synth_set_reverb_room_size(SynthEngineHandle* handle, float value) {
    if (!handle || !handle->engine) return;
    handle->engine->setReverbParameter(0, value);
}

void synth_set_reverb_damping(SynthEngineHandle* handle, float value) {
    if (!handle || !handle->engine) return;
    handle->engine->setReverbParameter(1, value);
}

void synth_set_reverb_wet_level(SynthEngineHandle* handle, float value) {
    if (!handle || !handle->engine) return;
    handle->engine->setReverbParameter(2, value);
}

void synth_set_reverb_dry_level(SynthEngineHandle* handle, float value) {
    if (!handle || !handle->engine) return;
    handle->engine->setReverbParameter(3, value);
}
}