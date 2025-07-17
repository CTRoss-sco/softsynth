#include <stdio.h>
#include <windows.h>

typedef void* (*synth_create_t)();
typedef void (*synth_destroy_t)(void*);
typedef void (*synth_note_on_t)(void*, int, float);
typedef void (*synth_note_off_t)(void*, int);
typedef void (*synth_set_cutoff_t)(void*, float);

int main() {
    // Load the DLL
    HMODULE hLib = LoadLibraryA("SynthFFI.dll");
    if (!hLib) {
        printf("Failed to load SynthFFI.dll. Error: %lu\n", GetLastError());
        return 1;
    }
    
    printf("SynthFFI.dll loaded successfully!\n");
    
    // Get function pointers
    synth_create_t synth_create = (synth_create_t)GetProcAddress(hLib, "synth_create");
    synth_destroy_t synth_destroy = (synth_destroy_t)GetProcAddress(hLib, "synth_destroy");
    synth_note_on_t synth_note_on = (synth_note_on_t)GetProcAddress(hLib, "synth_note_on");
    synth_note_off_t synth_note_off = (synth_note_off_t)GetProcAddress(hLib, "synth_note_off");
    synth_set_cutoff_t synth_set_cutoff = (synth_set_cutoff_t)GetProcAddress(hLib, "synth_set_cutoff");
    
    if (!synth_create || !synth_destroy || !synth_note_on || !synth_note_off || !synth_set_cutoff) {
        printf("Failed to get function pointers\n");
        FreeLibrary(hLib);
        return 1;
    }
    
    printf("All function pointers loaded successfully!\n");
    
    // Test the functions
    printf("Creating synth engine...\n");
    void* synth = synth_create();
    if (!synth) {
        printf("Failed to create synth engine\n");
        FreeLibrary(hLib);
        return 1;
    }
    
    printf("Synth engine created successfully!\n");
    
    // Test playing some notes
    printf("Playing note C4 (60)...\n");
    synth_note_on(synth, 60, 0.8f);
    
    printf("Setting cutoff to 500Hz...\n");
    synth_set_cutoff(synth, 500.0f);
    
    printf("Playing note E4 (64)...\n");
    synth_note_on(synth, 64, 0.6f);
    
    printf("Wait 2 seconds... (would be audio playing in real implementation)\n");
    Sleep(2000);
    
    printf("Stopping notes...\n");
    synth_note_off(synth, 60);
    synth_note_off(synth, 64);
    
    printf("Destroying synth engine...\n");
    synth_destroy(synth);
    
    printf("Test completed successfully!\n");
    
    FreeLibrary(hLib);
    return 0;
}
