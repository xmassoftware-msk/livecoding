(
/*
VST Reverb como efecto global de SuperDirt
==========================================

Procesa TODO el output de SuperDirt a través del VST.
Más simple que integrarlo en cada orbit.
*/

if(~dirt.isNil) {
    "[ERROR] SuperDirt no está inicializado".postln;
} {
    var numChannels = ~dirt.numChannels ? 2;
    var bus, synth, controller;
    
    // Buscar plugins VST
    VSTPlugin.search(s, ["/usr/lib/vst3", "/usr/local/lib/vst3", "~/.vst3".standardizePath]);
    
    // Crear bus de audio
    bus = Bus.audio(s, numChannels);
    
    // SynthDef para procesar audio del bus
    SynthDef(\vst_reverb_global, { |inBus, outBus = 0, mix = 0.5|
        var input, wet, output;
        
        input = In.ar(inBus, numChannels);
        wet = VSTPlugin.ar(input, numChannels, id: \reverb);
        
        // Wet/dry mix
        output = (input * (1 - mix)) + (wet * mix);
        
        Out.ar(outBus, output);
    }).add;
    
    s.sync;
    
    // Crear synth al final de la cadena
    synth = Synth.tail(s, \vst_reverb_global, [\inBus, bus, \outBus, 0, \mix, 0.3]);
    
    // Crear controller para el VST
    controller = VSTPluginController(synth, id: \reverb);
    controller.open('Room Builder Stereo');
    
    // Guardar referencias globales
    ~vstReverb = ();
    ~vstReverb[\bus] = bus;
    ~vstReverb[\synth] = synth;
    ~vstReverb[\controller] = controller;
    
    // Función para conectar SuperDirt al bus del VST
    ~connectVSTReverb = {
        // Redirigir output de SuperDirt al bus del VST
        ~dirt.orbits.do { |orbit|
            orbit.defaultOutputBus.notNil.if({
                // Guardar bus original
                if(~originalOutputBus.isNil) {
                    ~originalOutputBus = ~dirt.orbits[0].defaultOutputBus;
                };
                // Cambiar a bus del VST
                orbit.defaultOutputBus = bus;
            });
        };
        "SuperDirt conectado al VST Reverb".postln;
    };
    
    // Función para desconectar
    ~disconnectVSTReverb = {
        if(~originalOutputBus.notNil) {
            ~dirt.orbits.do { |orbit|
                orbit.defaultOutputBus = ~originalOutputBus;
            };
            "VST Reverb desconectado".postln;
        };
    };
    
    // Función para setear wet/dry mix (0-1)
    ~setVSTReverbMix = { |mix|
        ~vstReverb[\synth].set(\mix, mix);
        "VST Reverb mix: %".format(mix).postln;
    };
    
    // Función para abrir editor
    ~openVSTReverbEditor = {
        if(~vstReverb[\controller].notNil) {
            ~vstReverb[\controller].editor;
        };
    };
    
    // Función para listar parámetros
    ~listVSTReverbParams = {
        if(~vstReverb[\controller].notNil) {
            postln("\n=== Room Builder Stereo ===");
            for(0, ~vstReverb[\controller].numParameters - 1) { |i|
                postln("[%] % = %".format(
                    i,
                    ~vstReverb[\controller].getParameterName(i) ?? "?",
                    ~vstReverb[\controller].getParameter(i)
                ));
            };
        };
    };
    
    // Función para setear parámetro
    ~setVSTReverbParam = { |index, value|
        if(~vstReverb[\controller].notNil) {
            ~vstReverb[\controller].set(index, value);
            "VST Reverb parámetro % = %".format(index, value).postln;
        };
    };
    
    postln("\n========================================");
    postln("VST Reverb Global instalado");
    postln("========================================");
    postln("");
    postln("CONFIGURACIÓN:");
    postln("  ~connectVSTReverb.()    -- Conectar SuperDirt al VST");
    postln("  ~disconnectVSTReverb.() -- Desconectar");
    postln("");
    postln("CONTROL:");
    postln("  ~setVSTReverbMix.(0.5)   -- Wet/dry (0-1)");
    postln("  ~setVSTReverbParam.(0, 0.7) -- Parámetro por índice");
    postln("  ~openVSTReverbEditor.()  -- Abrir GUI");
    postln("  ~listVSTReverbParams.()  -- Ver parámetros");
    postln("");
    postln("ESTADO ACTUAL: Desconectado");
    postln("Ejecuta ~connectVSTReverb.() para activar");
}
)