(
/*
VST Reverb Global - Versión Simple
===================================

Procesa el output de SuperDirt conectándose al bus master.
Simplificado para evitar errores.
*/

if(~dirt.isNil) {
    "[ERROR] SuperDirt no está inicializado".postln;
} {
    var numChannels = ~dirt.numChannels ? 2;
    var vstReverb, vstController;
    
    // Buscar plugins VST
    VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);
    
    // ========================================
    // SynthDef para reverb VST
    // ========================================
    
    SynthDef(\vstReverbGlobal, { |inBus = 0, outBus = 0, mix = 0.3|
        var input, wet, output;
        
        input = In.ar(inBus, numChannels);
        wet = VSTPlugin.ar(input, numChannels);
        output = (input * (1 - mix)) + (wet * mix);
        
        Out.ar(outBus, output);
    }).add;
    
    s.sync;
    
    // ========================================
    // Crear bus y synth
    // ========================================
    
    ~vstReverbBus = Bus.audio(s, numChannels);
    
    // El synth se crea al FINAL de todo
    ~vstReverbSynth = Synth.tail(s, \vstReverbGlobal, [
        \inBus, ~vstReverbBus,
        \outBus, 0,  // Output principal
        \mix, 0.3
    ]);
    
    // Controller para el VST
    ~vstReverbController = VSTPluginController(~vstReverbSynth);
    ~vstReverbController.open('Room Builder Stereo');
    
    // ========================================
    // Funciones de control
    // ========================================
    
    ~setVSTReverbMix = { |mix|
        ~vstReverbSynth.set(\mix, mix);
        "VST mix: %".format(mix).postln;
    };
    
    ~openVSTReverbEditor = {
        if(~vstReverbController.notNil) {
            ~vstReverbController.editor;
        };
    };
    
    ~listVSTReverbParams = {
        if(~vstReverbController.notNil) {
            postln("\n=== Room Builder Stereo - Parámetros ===");
            for(0, ~vstReverbController.numParameters - 1) { |i|
                postln("[%] % = %".format(
                    i,
                    ~vstReverbController.getParameterName(i) ?? "?",
                    ~vstReverbController.getParameter(i)
                ));
            };
        };
    };
    
    ~setVSTReverbParam = { |index, value|
        if(~vstReverbController.notNil) {
            ~vstReverbController.set(index, value);
        };
    };
    
    // ========================================
    // Conectar/Desconectar de SuperDirt
    // ========================================
    
    ~connectVSTReverb = {
        // Guardar configuración original
        ~originalOutBuses = ~dirt.orbits.collect { |orbit| orbit.outBus };
        
        // Redirigir todos los orbits al bus del VST
        ~dirt.orbits.do { |orbit| orbit.outBus = ~vstReverbBus.index; };
        
        "VST Reverb conectado - enviando SuperDirt audio al VST".postln;
    };
    
    ~disconnectVSTReverb = {
        if(~originalOutBuses.notNil) {
            // Restaurar buses originales
            ~dirt.orbits.do { |orbit, i| orbit.outBus = ~originalOutBuses[i]; };
            ~originalOutBuses = nil;
            "VST Reverb desconectado".postln;
        };
    };
    
    postln("\n========================================");
    postln("VST Reverb Global instalado");
    postln("========================================");
    postln("");
    postln("FUNCIONES:");
    postln("  ~connectVSTReverb.()    -- Activar");
    postln("  ~disconnectVSTReverb.() -- Desactivar");
    postln("  ~setVSTReverbMix.(0.5)  -- Wet/dry (0-1)");
    postln("  ~openVSTReverbEditor.()  -- GUI");
    postln("  ~listVSTReverbParams.() -- Parámetros");
    postln("  ~setVSTReverbParam.(0, 0.7) -- Setear parámetro");
}
)