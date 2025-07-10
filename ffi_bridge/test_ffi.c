#include <stdio.h>
#include "ffi_bridge.h"

int main() {
    printf("Testing FFI Bridge...\n");
    
    // Create synth engine
    SynthEngineHandle* synth = synth_create();
    if (!synth) {
        printf("Failed to create synth engine\n");
        return 1;
    }
    
    printf("Synth engine created successfully\n");
    
    // Test setting cutoff
    synth_set_cutoff(synth, 1000.0f);
    printf("Cutoff set to 1000.0\n");
    
    // Test note on/off
    synth_note_on(synth, 60, 0.8f);  // Middle C
    printf("Note on: C4 (60)\n");
    
    synth_note_off(synth, 60);
    printf("Note off: C4 (60)\n");
    
    // Cleanup
    synth_destroy(synth);
    printf("Synth engine destroyed\n");
    
    printf("FFI Bridge test completed successfully!\n");
    return 0;
}
