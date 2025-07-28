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

#ifdef __cplusplus
}
#endif
