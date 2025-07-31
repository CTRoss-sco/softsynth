#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
    #ifdef SYNTHFFI_EXPORTS
        #define SYNTHFFI_API __declspec(dllexport)
    #else
        #define SYNTHFFI_API __declspec(dllimport)
    #endif
#else
    #define SYNTHFFI_API
#endif

// C interface for Flutter FFI
typedef struct SynthEngineHandle SynthEngineHandle;

// Create/destroy synth engine
SYNTHFFI_API SynthEngineHandle* synth_create();
SYNTHFFI_API int synth_initialize_audio(SynthEngineHandle* handle);
SYNTHFFI_API void synth_destroy(SynthEngineHandle* handle);

// Audio controls
SYNTHFFI_API void synth_set_cutoff(SynthEngineHandle* handle, float value);
SYNTHFFI_API void synth_note_on(SynthEngineHandle* handle, int note, float velocity);
SYNTHFFI_API void synth_note_off(SynthEngineHandle* handle, int note);
SYNTHFFI_API void synth_process_audio(SynthEngineHandle* handle, float* buffer, int frames);

// New dual oscillator controls
SYNTHFFI_API void synth_set_osc1_waveform(SynthEngineHandle* handle, int waveform);
SYNTHFFI_API void synth_set_osc2_waveform(SynthEngineHandle* handle, int waveform);
SYNTHFFI_API void synth_set_detune(SynthEngineHandle* handle, float cents);
SYNTHFFI_API void synth_set_osc_mix(SynthEngineHandle* handle, float mix);

// Filter controls
SYNTHFFI_API void synth_set_filter_cutoff(SynthEngineHandle* handle, float value);
SYNTHFFI_API void synth_set_filter_resonance(SynthEngineHandle* handle, float value);

// Effects processing control
SYNTHFFI_API void synth_enable_effects_processing(SynthEngineHandle* handle, bool enable);

// Reverb effect control
SYNTHFFI_API void synth_set_reverb_room_size(SynthEngineHandle* handle, float value);
SYNTHFFI_API void synth_set_reverb_damping(SynthEngineHandle* handle, float value);
SYNTHFFI_API void synth_set_reverb_wet_level(SynthEngineHandle* handle, float value);
SYNTHFFI_API void synth_set_reverb_dry_level(SynthEngineHandle* handle, float value);

// Delay effect control
SYNTHFFI_API void synth_enable_delay(SynthEngineHandle* handle, int enable);
SYNTHFFI_API void synth_set_delay_time(SynthEngineHandle* handle, float timeInSeconds);
SYNTHFFI_API void synth_set_delay_feedback(SynthEngineHandle* handle, float feedback);
SYNTHFFI_API void synth_set_delay_wet_level(SynthEngineHandle* handle, float wetLevel);
SYNTHFFI_API void synth_set_delay_dry_level(SynthEngineHandle* handle, float dryLevel);

// Chorus effect controls
SYNTHFFI_API void synth_enable_chorus(SynthEngineHandle* handle, int enable);
SYNTHFFI_API void synth_set_chorus_rate(SynthEngineHandle* handle, float rate);
SYNTHFFI_API void synth_set_chorus_depth(SynthEngineHandle* handle, float depth);
SYNTHFFI_API void synth_set_chorus_voices(SynthEngineHandle* handle, int voices);
SYNTHFFI_API void synth_set_chorus_feedback(SynthEngineHandle* handle, float feedback);
SYNTHFFI_API void synth_set_chorus_wet_level(SynthEngineHandle* handle, float wetLevel);
SYNTHFFI_API void synth_set_chorus_dry_level(SynthEngineHandle* handle, float dryLevel);

#ifdef __cplusplus
}
#endif
