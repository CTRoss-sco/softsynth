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

void synth_enable_delay(SynthEngineHandle* handle, int enable) {
    if (!handle || !handle->engine) return;
    handle->engine->enableDelay(enable != 0);
}

void synth_set_delay_time(SynthEngineHandle* handle, float timeInSeconds) {
    if (!handle || !handle->engine) return;
    handle->engine->setDelayTime(timeInSeconds);
}

void synth_set_delay_feedback(SynthEngineHandle* handle, float feedback) {
    if (!handle || !handle->engine) return;
    handle->engine->setDelayFeedback(feedback);
}

void synth_set_delay_wet_level(SynthEngineHandle* handle, float wetLevel) {
    if (!handle || !handle->engine) return;
    handle->engine->setDelayWetLevel(wetLevel);
}

void synth_set_delay_dry_level(SynthEngineHandle* handle, float dryLevel) {
    if (!handle || !handle->engine) return;
    handle->engine->setDelayDryLevel(dryLevel);
}

void synth_enable_chorus(SynthEngineHandle* handle, int enable) {
    if (!handle || !handle->engine) return;
    handle->engine->enableChorus(enable != 0);
}

void synth_set_chorus_rate(SynthEngineHandle* handle, float rate) {
    if (!handle || !handle->engine) return;
    handle->engine->setChorusRate(rate);
}

void synth_set_chorus_depth(SynthEngineHandle* handle, float depth) {
    if (!handle || !handle->engine) return;
    handle->engine->setChorusDepth(depth);
}

void synth_set_chorus_voices(SynthEngineHandle* handle, int voices) {
    if (!handle || !handle->engine) return;
    handle->engine->setChorusVoices(voices);
}

void synth_set_chorus_feedback(SynthEngineHandle* handle, float feedback) {
    if (!handle || !handle->engine) return;
    handle->engine->setChorusFeedback(feedback);
}

void synth_set_chorus_wet_level(SynthEngineHandle* handle, float wetLevel) {
    if (!handle || !handle->engine) return;
    handle->engine->setChorusWetLevel(wetLevel);
}

void synth_set_chorus_dry_level(SynthEngineHandle* handle, float dryLevel) {
    if (!handle || !handle->engine) return;
    handle->engine->setChorusDryLevel(dryLevel);
}

void synth_enable_oscilloscope(SynthEngineHandle* handle, int enable) {
    if (!handle || !handle->engine) {
        printf("FFI: Invalid handle for enable_oscilloscope\n");
        return;
    }

    handle->engine->enableOscilloscope(enable != 0);
    printf("FFI: Oscilloscope %s\n", enable ? "ENABLED" : "DISABLED");
}

int synth_get_waveform_data(SynthEngineHandle* handle, float* buffer, int bufferSize) {
    if (!handle || !handle->engine || !buffer) {
        printf("FFI: Invalid parameters for get_waveform_data\n");
        return 0;
    }

    int samplesReturned = handle->engine->getWaveformData(buffer, bufferSize);

    return samplesReturned;
}
}