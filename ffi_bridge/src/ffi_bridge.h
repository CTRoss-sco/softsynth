#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
    #ifdef BUILDING_SYNTHFFI_DLL
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

// Basic synth controls
SYNTHFFI_API void synth_set_cutoff(SynthEngineHandle* handle, float value);
SYNTHFFI_API void synth_note_on(SynthEngineHandle* handle, int note, float velocity);
SYNTHFFI_API void synth_note_off(SynthEngineHandle* handle, int note);

// Audio processing
SYNTHFFI_API void synth_process_audio(SynthEngineHandle* handle, float* buffer, int frames);

#ifdef __cplusplus
}
#endif
