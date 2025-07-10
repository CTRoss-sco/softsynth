#pragma once

#ifdef _WIN32
    #ifdef JUCE_DLL_BUILD
        #define SYNTH_API __declspec(dllexport)
    #else
        #define SYNTH_API __declspec(dllimport)
    #endif
#else
    #define SYNTH_API
#endif

class SYNTH_API SynthEngine {
public:
    void setCutoff(float value);
};